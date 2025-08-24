## Instalação

Inicie a sessão como superusuário utilizando o comando:

```bash
su -
```

Agora podemos instalar o Podman diretamente do gerenciador de pacotes do Debian ``apt`` por meio do comando:

```bash
apt-get update & apt-get -y install podman
```

> Para outras distros mais informações em: https://podman.io/docs/installation

Agora podemos testar nossa instalação do Podman por meio do comando:

```bash
podman -v
```
---
## Iniciando nosso primeiro container

Executar um container no Podman é simples. O processo é semelhante ao do Docker. Por exemplo, para rodar o container de teste, use:

```bash
podman run hello
```

> Esse comando baixa a imagem `hello` (caso não esteja em cache) e a executa.

Se tudo estiver configurado corretamente, você verá uma mensagem semelhante a esta:

```
!... Hello Podman World ...!

         .--"--.
       / -     - \
      / (O)   (O) \
   ~~~| -=(,Y,)=- |
    .---. /`  \   |~~
 ~/  o  o \~~~~.----. ~~
  | =(X)= |~  / (O (O) \
   ~~~~~~~  ~| =(Y_)=-  |
  ~~~~    ~~~|   U      |~~

Project:   https://github.com/containers/podman
Website:   https://podman.io
Desktop:   https://podman-desktop.io
Documents: https://docs.podman.io
YouTube:   https://youtube.com/@Podman
X/Twitter: @Podman_io
Mastodon:  @Podman_io@fosstodon.org
```

## Executando o Podman em modo rootless

O Podman suporta execução *rootless*, permitindo rodar containers sem privilégios de superusuário.  
Para isso, basta utilizar um usuário comum e garantir que o Podman esteja instalado com suporte a esse modo.

Primeiro, verifique se o modo rootless está disponível:

```bash
podman info --debug | grep rootless
```

Se estiver habilitado, basta executar o comando normalmente, **sem** `sudo` ou login como `root`:

```bash
podman run hello
```

## Operando Containers no Podman

O Podman oferece uma série de comandos para gerenciar containers em execução ou parados.  
A sintaxe é semelhante à do Docker, mas os comandos usam o prefixo `podman`.

### Exemplos de imagens:
- `debian`
- `ubuntu`
- `nginx`

---
### Sair de um container sem encerrar:
```bash
CTRL + P + Q
```


---
### Abrir um terminal interativo no container:

```bash
podman exec -it <ID_CONTAINER>
```
 

---
### Exibir informações detalhadas do container:

```bash
podman inspect <ID_CONTAINER>
```


---
### Pausar a execução de um container:

```
podman pause <ID_CONTAINER>
```


---
### Retomar um container pausado:

```
podman unpause <ID_CONTAINER>
```


---
### Parar um container:

```bash
podman stop <ID_CONTAINER>
```


---
### Iniciar um container parado:

```bash
podman start <ID_CONTAINER>
```


---
### Remover um container:

```bash
podman rm <ID_CONTAINER>
```


---
### Forçar a remoção de um container:

```bash
podman rm -f <ID_CONTAINER>
```


---
### Exibir estatísticas de uso (CPU, memória, etc.):

```bash
podman stats
```


---
### Limitar uso de CPU:

```bash
podman update --cpus 0.5 <ID_CONTAINER>
```

> Limita o container a 50% da CPU disponível.

---

### Limitar uso de memória RAM:

```bash
podman update -m 128M <ID_CONTAINER>
```

> Limita o container a **128 MB** de memória.

---
## Primeiro Containerfile com Podman

Assim como o Docker usa o `Dockerfile`, o Podman utiliza o mesmo formato de arquivo, mas a convenção é chamá-lo de **Containerfile**.
#### Criar o diretório do projeto:

```bash
mkdir meucontainer
cd meucontainer
```

#### Crie um arquivo containerfile:

```bash
nano Containerfile
```

Agora podemos utilizar o container usando a mesma sintaxe do `Dockerfile`
Exemplo: 

```dockerfile
FROM debian

LABEL app="MeuContainer"

RUN apt-get update && apt-get install -y stress && apt-get clean

CMD stress --cpu 1 --vm-bytes 32m --vm 1
```

Para criar essa imagem podemos utilizar o comando:

```bash
podman build -t meucontainer .
```

#### Executando imagem criada:

Executamos a imagem da mesma forma que realizamos no `docker` somente substituindo o sufixo por `podman`

```bash
podman run meucontainer
```