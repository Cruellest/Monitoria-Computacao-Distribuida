Vamos aplicar os conceitos de orquestração para implantar uma instância do Nextcloud com um banco de dados.

**1. Estrutura do Projeto** Crie um diretório para o projeto:

```bash
mkdir nextcloud-docker && cd nextcloud-docker
```

**2. Criando o Arquivo `compose.yml`** Crie um arquivo `compose.yml` com a seguinte configuração:

```YAML
version: '3.8'

services:
  db:
    image: mariadb:10.6
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
    image: nextcloud
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
  nextcloud_data:
```

**Análise:**

- **`services.db`**: Define o contêiner do banco de dados MariaDB, com um volume (`db_data`) para persistência.
    
- **`services.app`**: Define o contêiner do Nextcloud, que depende do serviço `db` e mapeia a porta 8080 do host.
    
- **`volumes`**: Declara os volumes nomeados para o Docker gerenciar.
    

**3. Executando a Aplicação** Inicie os serviços em segundo plano:

```bash
docker compose up -d
```

Verifique o status dos contêineres com `docker compose ps` ou `docker ps`.

**4. Acessando o Nextcloud** Abra seu navegador e acesse `http://localhost:8080` para finalizar a configuração, usando as credenciais do banco de dados definidas no arquivo `compose.yml`.