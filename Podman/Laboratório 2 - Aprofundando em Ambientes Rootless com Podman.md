
Nesta aula, vamos explorar em profundidade um dos recursos mais importantes do Podman: sua capacidade de operar em um ambiente **rootless**. Enquanto a aula base apresentou a instalação e os comandos essenciais, agora vamos focar no *porquê* e no *como* do modo rootless, que representa uma mudança fundamental em segurança e na forma como gerenciamos contêineres.

---
## O que é um Ambiente Rootless?

Tradicionalmente, ferramentas de contêiner como o Docker dependem de um *daemon* (um processo de fundo) que roda com privilégios de **root** (superusuário). Isso significa que, mesmo que você execute comandos como um usuário comum, a criação e o gerenciamento dos contêineres são, na verdade, realizados por um processo com acesso total ao sistema host.

Um ambiente **rootless** (sem root) quebra esse paradigma. Com o Podman, todo o ciclo de vida de um contêiner desde baixar uma imagem, executá-la, configurar redes e volumes acontece inteiramente com os privilégios do **seu próprio usuário**, sem nenhuma necessidade de escalação para `root`.

**A principal vantagem é a segurança:** se um processo malicioso escapar de um contêiner, ele terá apenas as permissões do usuário que o executou, e não acesso irrestrito ao sistema host.

---
## 2. Como o Rootless Funciona? (Os Bastidores)

Para que um usuário comum possa gerenciar contêineres, o Podman utiliza tecnologias do kernel Linux para criar um ambiente isolado. As duas mais importantes são:

* **User Namespaces (userns):** Permitem que um usuário tenha privilégios de "root" *dentro* do seu próprio namespace, sem ser o root do sistema host. O sistema mapeia o ID do seu usuário (ex: `1000`) para o ID `0` (root) dentro do contêiner, e uma faixa de outros UIDs/GIDs para os demais usuários do contêiner.

* **slirp4netns:** Para a rede, como um usuário comum não pode controlar as interfaces de rede do host, o `slirp4netns` cria uma rede virtual "user-space", permitindo que os contêineres acessem a rede externa através do namespace de rede do usuário.

---

## 3. Configurando o Ambiente para Rootless

Para que o modo rootless funcione corretamente, algumas dependências e configurações são necessárias. A instalação básica do Podman nem sempre as inclui.
#### Passo 1: Instalar Dependências Essenciais

Como superusuário (`sudo` ou `su -`), instale os pacotes que fornecem as funcionalidades de rede e armazenamento para o modo rootless:

```bash

# Use sudo ou troque para root com 'su -'

sudo apt-get update

sudo apt-get -y install podman slirp4netns fuse-overlayfs

```

* `slirp4netns`: Fornece a rede para os contêineres rootless.

* `fuse-overlayfs`: Permite a criação de camadas de sistema de arquivos sem privilégios de root.

#### Passo 2: Configurar UIDs e GIDs Subordinados
  
O sistema precisa saber quais faixas de User IDs (UIDs) e Group IDs (GIDs) seu usuário tem permissão para usar dentro dos seus namespaces. Isso é definido nos arquivos `/etc/subuid` e `/etc/subgid`.

Se seu usuário foi criado de forma padrão, essas entradas podem já existir. Verifique com os comandos:

```bash

grep $USER /etc/subuid

grep $USER /etc/subgid

```

Se não houver saída, você (ou o administrador do sistema) precisa adicioná-las. O comando `usermod` pode fazer isso. **Execute como root**:

```bash

# Substitua 'seu_usuario' pelo seu nome de usuário

sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 seu_usuario

```

Isso aloca 65.536 UIDs e GIDs para o seu usuário usar em contêineres.

  

---

## 4. Operando em Modo Rootless na Prática

Com o ambiente configurado, vamos usar o Podman como ele foi projetado para ser usado.
#### Verificando a Instalação (Como Usuário Comum)

Execute o comando `podman info`. Você notará que os caminhos de armazenamento agora apontam para o seu diretório `home`:

```bash

podman info | grep -E 'graphRoot|runRoot'

```

A saída será algo como:

```

  graphRoot: /home/seu_usuario/.local/share/containers/storage

  runRoot: /run/user/1000/containers

```

Isso prova que o Podman está operando dentro do seu espaço de usuário.

#### Executando um Contêiner

O comando é o mesmo, mas a diferença é crucial: **sem `sudo`**.

```bash

podman run --rm debian:latest echo "Olá do meu contêiner rootless!"

```

#### Mapeamento de Portas

Uma limitação importante do modo rootless é que usuários comuns não podem mapear para portas privilegiadas do host (abaixo de 1024).  

**Isso falhará:**

```bash

# Erro: Usuário comum não pode usar a porta 80 do host

podman run -d --name web -p 80:80 nginx

```

**Isso funcionará:**

```bash

# Mapeia a porta 8080 do host para a porta 80 do contêiner

podman run -d --name web -p 8080:80 nginx

```

Agora você pode acessar o Nginx em `http://localhost:8080`.

#### Construindo Imagens com `Containerfile`

O processo de build é idêntico, mas o resultado é diferente. A imagem que você cria será armazenada no seu repositório local (`~/.local/share/containers`), não no repositório do sistema.

```bash

# Crie o diretório e o arquivo

mkdir meucontainer-rootless && cd meucontainer-rootless

nano Containerfile

```

Use o mesmo conteúdo do exemplo anterior:

```dockerfile

FROM debian

  

LABEL app="MeuContainerRootless"

  

RUN apt-get update && apt-get install -y stress && apt-get clean

  

CMD stress --cpu 1 --vm-bytes 32m --vm 1

```  

Construa a imagem, **sem sudo**:

```bash

podman build -t meucontainer-rootless .

```

Verifique se a imagem existe apenas para o seu usuário:

```bash

# Listará a imagem

podman images

# Não listará a imagem (a menos que já exista no sistema)

sudo podman images

```
