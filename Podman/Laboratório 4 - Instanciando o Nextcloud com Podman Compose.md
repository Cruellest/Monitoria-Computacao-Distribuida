esta aula, vamos aplicar os conceitos de orquestração de múltiplos contêineres para implantar uma instância completa do Nextcloud, uma plataforma de colaboração e armazenamento de arquivos. Utilizaremos o `podman-compose` para gerenciar a aplicação e seu banco de dados, operando inteiramente em modo _rootless_.

---

#### **1. Pré-requisitos**

Antes de começar, certifique-se de que seu ambiente atende aos seguintes requisitos, conforme abordado nos laboratórios anteriores:

- Podman instalado e configurado para operar em modo _rootless_.
    
- Dependências como `slirp4netns` (para rede) e `fuse-overlayfs` (para armazenamento) instaladas.
    
- Seu usuário possui UIDs e GIDs subordinados configurados em `/etc/subuid` e `/etc/subgid`.
    
- A ferramenta `podman-compose` está instalada.
    

---

#### **2. Estrutura do Projeto**

Primeiro, crie um diretório para organizar os arquivos da sua aplicação Nextcloud.

```bash
mkdir nextcloud-podman && cd nextcloud-podman
```

---

#### **3. Criando o Arquivo `compose.yml`**

Dentro do diretório `nextcloud-podman`, crie um arquivo chamado `compose.yml`. Este arquivo definirá os dois serviços necessários: o aplicativo Nextcloud e o banco de dados MariaDB.

```bash
nano compose.yml
```

Cole o seguinte conteúdo no arquivo:

```YAML
version: '3.8'

services:
  db:
    image: docker.io/mariadb:10.6
    container_name: nextcloud_db
    restart: always
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    volumes:
      - db_data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=seu_password_super_secreto
      - MYSQL_PASSWORD=nextcloud_password
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud

  app:
    image: docker.io/nextcloud
    container_name: nextcloud_app
    restart: always
    ports:
      - "8080:80"
    volumes:
      - nextcloud_data:/var/www/html
    depends_on:
      - db

volumes:
  db_data:
    name: nextcloud_db_data
  nextcloud_data:
    name: nextcloud_app_data
```

**Análise do arquivo `compose.yml`:**

- **`services`**: Define os contêineres que compõem nossa aplicação.
    
    - **`db`**: O serviço do banco de dados MariaDB.
        
        - `image`: Usa a imagem oficial do MariaDB.
            
        - `volumes`: Cria um volume nomeado `db_data` para persistir os dados do banco de dados, mesmo que o contêiner seja removido.
            
        - `environment`: Configura as credenciais e o nome do banco de dados que o Nextcloud usará para se conectar.
            
    - **`app`**: O serviço do Nextcloud.
        
        - `ports`: Mapeia a porta `8080` do seu computador (host) para a porta `80` do contêiner. Lembre-se que, em modo _rootless_, não podemos usar portas privilegiadas (abaixo de 1024).
            
        - `volumes`: Cria um volume nomeado `nextcloud_data` para armazenar os arquivos e configurações do Nextcloud.
            
        - `depends_on`: Garante que o contêiner do banco de dados (`db`) seja iniciado antes do contêiner da aplicação (`app`).
            

---

#### **4. Executando a Aplicação**

Com o arquivo salvo, execute a aplicação em modo "detached" (`-d`) para que os contêineres rodem em segundo plano. Como estamos em modo _rootless_, **não use `sudo`**.

```bash
podman-compose up -d
```

O `podman-compose` irá ler o arquivo `compose.yml` e traduzir cada seção em comandos `podman` equivalentes, como `podman network create`, `podman volume create` e `podman run`.

Para verificar o status dos contêineres:

```bash
podman ps
```

---
l
#### **5. Acessando o Nextcloud**

Abra seu navegador e acesse `http://<ip-do-dispositivo>:8080`. Você verá a tela de configuração inicial do Nextcloud. Use as credenciais do banco de dados definidas no arquivo `compose.yml` para finalizar a instalação.

Todos os dados e imagens estarão armazenados no seu diretório de usuário, em locais como `/home/seu_usuario/.local/share/containers/storage`.

![[Pasted image 20250824032033.png]]