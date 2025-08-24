Nesta aula, vamos aprofundar nosso conhecimento em Podman, focando em como orquestrar múltiplos contêineres usando arquivos **Compose**. Enquanto a aula base focaria em contêineres individuais, agora vamos aprender a gerenciar aplicações complexas, explorando as peculiaridades e vantagens que o Podman oferece em comparação com o fluxo de trabalho tradicional do `docker-compose`.

---

## 1. O que é a Utilização de Compose no Podman?

No universo Docker, o `docker-compose` é a ferramenta padrão para definir e executar aplicações com múltiplos contêineres a partir de um único arquivo YAML. O Podman, por sua vez, foi projetado para ser modular e não inclui uma ferramenta "compose" em seu núcleo. Em vez disso, a comunidade desenvolveu o **`podman-compose`**, um script Python que traduz a sintaxe dos arquivos `docker-compose.yml` em comandos `podman`.

Isso significa que você pode, na maioria dos casos, usar seus arquivos `docker-compose.yml` existentes com pouca ou nenhuma modificação.

**A principal vantagem é a integração com o ecossistema Podman:** `podman-compose` opera de forma **rootless** por padrão, não depende de um daemon central e pode se integrar com outras funcionalidades do Podman, como os **Pods**.

---

## 2. Como o `podman-compose` Funciona? (Os Bastidores)

Diferente do `docker-compose` (versão 1) ou do plugin `docker compose` (versão 2), que se comunicam com o daemon do Docker via API, o `podman-compose` atua como um **tradutor de comandos**.

1. **Leitura do YAML:** Ele lê e interpreta seu arquivo `docker-compose.yml` ou `compose.yml`.
    
2. **Tradução para Comandos Podman:** Para cada serviço, rede ou volume definido no arquivo, `podman-compose` gera e executa o comando `podman` correspondente.
    
    - Um serviço `webapp` se torna um `podman run ...`.
        
    - Uma seção `networks` se torna `podman network create ...`.
        
    - Uma seção `volumes` se torna `podman volume create ...`.
        
3. **Execução Direta:** Os comandos são executados diretamente, sem passar por um processo de fundo (daemon). Se você está rodando `podman-compose` como um usuário comum, todos os contêineres, redes e volumes serão criados dentro do seu _user namespace_, de forma totalmente rootless.
    

Isso torna o processo mais transparente, mas também introduz algumas peculiaridades, especialmente na gestão de redes.

---

## 3. Configurando o Ambiente para `podman-compose`

Para usar o `podman-compose`, precisamos garantir que o Podman esteja configurado para o modo rootless e, em seguida, instalar a ferramenta.

#### Passo 1: Garantir as Dependências do Podman Rootless

Como visto na aula anterior, o ambiente rootless precisa de componentes específicos para rede e armazenamento. Se ainda não os tiver, instale-os como root:

Bash

```
# Troque para root com 'su -'
apt-get update
apt-get -y install podman slirp4netns fuse-overlayfs
```
#### Passo 2: Instalar `podman-compose`

A forma mais comum de instalar o `podman-compose` no Debian é através do `apt`, o gerenciador de pacotes do Debian

Bash

```
# Como root
apt-get install podman-compose
```

---

## 4. Orquestrando na Prática

Vamos subir uma aplicação simples na pratica utilizando composes via Podman:

Estaremos utilizando o Portainer como exemplo, diferentemente de outras aplicações precisaremos rodar o socket do Podman para permitir alteração dos containers, para iniciar o socket do podman podemos executar:

```
systemctl --user enable --now podman.socket
```

Agora podemos criar um compose.yml no seguinte formato:

```yml
services:
  portainer:

    # Imagem do Portainer Community Edition. A tag 'sts' usa a versão de suporte de curto prazo mais recente (Possui suporte ao Podman).
    image: docker.io/portainer/portainer-ce:sts
    
    container_name: portainer
    # Portainer precisa de acesso privilegiado para gerenciar o ambiente Podman completamente.

    privileged: true
    # Mapeamento de portas:
    # 9443: Porta principal para a interface web (HTTPS).
    # 8000: Usada pelo túnel para os Edge Agents (opcional).

    ports:
      - "9443:9443"
      - "8000:8000"

    volumes:
      # Mapeia o socket do Podman para dentro do contêiner.
      # Portainer foi projetado para o socket do Docker, mas o Podman cria um link de compatibilidade.

      # Este é o caminho padrão para o socket do Podman em modo rootful.
      - /run/podman/podman.sock:/var/run/docker.sock

      # Volume nomeado para persistir os dados do Portainer (configurações, usuários, etc.).
      - portainer_data:/data

    # Garante que o Portainer reinicie automaticamente em caso de falha ou após um reboot do sistema.
    restart: always

# Define o volume nomeado que será gerenciado pelo Podman.
volumes:
  portainer_data:
    name: portainer_data

```

Agora como root podemos iniciar o container com:

```bash
podman compose up
```

> Atualmente o Portainer Podman não possui suporte a execução no modo rootless, pois a aplicação necessita de privilégios para alterar configurações do Podman, além disso o Portainer Podman só possui suporte oficial para CentOs 

## 5. Orquestrando Rootless na pratica
---

## 6. Peculiaridades e Funcionalidades Extras

Aqui o Podman realmente se destaca.

#### Peculiaridade: Resolução de Nomes (Networking)

No modo rootless, a rede padrão é `slirp4netns`. Contudo, para que os contêineres se encontrem pelo nome (como `webapp` encontrando `redis_db`), `podman-compose` cria uma rede bridge dedicada, assim como o Docker. A diferença é que esta rede opera inteiramente dentro do namespace do seu usuário.

#### Funcionalidade Extra: O Conceito de "Pod"

A maior vantagem do Podman é o conceito de **Pods**, emprestado do Kubernetes. Um Pod é um grupo de contêineres que compartilham os mesmos namespaces de rede, o que significa que eles podem se comunicar via `localhost`. Isso é mais leve e eficiente do que criar uma rede virtual.

`podman-compose` **não gerencia Pods nativamente**, mas você pode usar o Podman para criar uma estrutura equivalente e ainda mais integrada.

**Exemplo de fluxo de trabalho com Pods:**

1. **Crie um Pod:**
    
    ```
    # O Pod expõe a porta 8080 para o host
    podman pod create --name minha-app-pod -p 8080:5000
    ```
    
2. **Execute os contêineres _dentro_ do Pod:**
    
    ```
    # Note o '--pod' e a ausência de mapeamento de porta no contêiner
    podman run -d --pod minha-app-pod --name redis_db redis:alpine
    podman run -d --pod minha-app-pod --name webapp localhost/minha-app-compose_webapp
    ```
    
    Neste cenário, o `app.py` precisaria ser ajustado para se conectar ao Redis em `localhost`, pois eles compartilham a mesma interface de rede.
    

#### Funcionalidade Extra: Gerar Manifestos Kubernetes

Podman pode gerar manifestos Kubernetes a partir de seus contêineres e pods em execução. Isso cria uma ponte incrível entre o desenvolvimento local e a produção em ambientes como OpenShift ou GKE.

```
# Gere o YAML a partir do Pod que criamos
podman kube generate pod minha-app-pod > minha-app.yml
```

O arquivo `minha-app.yml` conterá uma definição Kubernetes pronta para ser aplicada em um cluster com `kubectl apply -f minha-app.yml`. Essa é uma funcionalidade poderosa que o Docker Compose não oferece nativamente.