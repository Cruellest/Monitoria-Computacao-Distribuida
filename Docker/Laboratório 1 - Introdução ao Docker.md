#### **Instalação**

Para instalar o Docker, siga a documentação oficial para a sua distribuição. No Debian, o processo geralmente envolve adicionar o repositório do Docker e instalar os pacotes necessários.

Inicie a sessão como superusuário utilizando o comando:

```bash
su -
```

Agora podemos instalar o Docker Engine, incluindo a CLI e o Compose, diretamente do repositório oficial:

```bash
# Adicionar o repositório do Docker
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar o Docker Engine
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

> Para outras distribuições, mais informações em: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

Agora podemos testar nossa instalação do Docker por meio do comando:

```bash
docker -v
```

---

#### **Iniciando nosso primeiro contêiner**

Executar um contêiner no Docker é simples. Para rodar um contêiner de teste, use:


```bash
docker run hello-world
```

> Esse comando baixa a imagem `hello-world` (caso não esteja em cache) e a executa.

Se tudo estiver configurado corretamente, você verá uma mensagem de confirmação do Docker.

#### **Executando o Docker como um usuário não-root (Rootless)**

O Docker também suporta um modo _rootless_, permitindo rodar contêineres sem privilégios de superusuário para maior segurança. A configuração é mais envolvida do que a do Podman e requer um script de instalação específico. Para mais detalhes, consulte a [documentação oficial](https://docs.docker.com/engine/security/rootless/). Após a configuração, você pode executar os comandos do Docker como um usuário comum, sem `sudo`.

#### **Operando Contêineres no Docker**

O Docker oferece uma série de comandos para gerenciar contêineres.

**Exemplos de imagens:**

- `debian`
    
- `ubuntu`
    
- `nginx`
    

---

**Sair de um contêiner sem encerrar:**

```bash
CTRL + P + Q
```

---

**Abrir um terminal interativo no contêiner:**

```bash
docker exec -it <ID_CONTAINER> /bin/bash
```

---

**Exibir informações detalhadas do contêiner:**

```bash
docker inspect <ID_CONTAINER>
```

---

**Pausar e retomar a execução de um contêiner:**

```bash
docker pause <ID_CONTAINER>
docker unpause <ID_CONTAINER>
```

---

**Parar e iniciar um contêiner:**

```bash
docker stop <ID_CONTAINER>
docker start <ID_CONTAINER>
```

---

**Remover um contêiner:**

```bash
docker rm <ID_CONTAINER>
# Forçar a remoção
docker rm -f <ID_CONTAINER>
```

---

**Exibir estatísticas de uso (CPU, memória, etc.):**

```bash
docker stats
```

---

**Limitar recursos de um contêiner (CPU e Memória):**

```bash
# Limita o contêiner a 50% da CPU disponível
docker update --cpus 0.5 <ID_CONTAINER>

# Limita o contêiner a 128 MB de memória
docker update --memory 128M <ID_CONTAINER>
```

---

#### **Primeiro Dockerfile com Docker**

O Docker utiliza um arquivo chamado `Dockerfile` para definir como construir uma imagem de contêiner.

**Criar o diretório do projeto e o Dockerfile:**

```bash
mkdir meucontainer && cd meucontainer
nano Dockerfile
```

Use a sintaxe padrão do `Dockerfile`. **Exemplo:**

```Dockerfile
FROM debian

LABEL app="MeuContainer"

RUN apt-get update && apt-get install -y stress && apt-get clean

CMD stress --cpu 1 --vm-bytes 32m --vm 1
```

**Para construir a imagem:**

```bash
docker build -t meucontainer .
```

**Executando a imagem criada:**

```bash
docker run meucontainer
```