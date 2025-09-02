Nesta aula, vamos implantar o WordPress com um banco de dados MySQL usando `docker-compose`.

**1. Estrutura do Projeto** Crie um diretório dedicado:

```bash
mkdir wordpress-docker && cd wordpress-docker
```

**2. Criando o Arquivo `compose.yml`** Crie o arquivo `compose.yml`:

```yaml
version: '3.8'

services:
  db:
    image: mysql:5.7
    container_name: wordpress_db
    restart: always
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: seu_password_super_secreto
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password

  wordpress:
    image: wordpress
    container_name: wordpress_app
    restart: always
    ports:
      - "8081:80"
    depends_on:
      - db
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress_password
      WORDPRESS_DB_NAME: wordpress

volumes:
  db_data:
```

**Análise:**

- **`services.db`**: Configura o contêiner MySQL.
    
- **`services.wordpress`**: Configura o contêiner do WordPress, que se conecta ao serviço `db` pela rede interna do Docker Compose. A porta 8081 é usada para evitar conflitos.
    

**3. Executando a Aplicação** Inicie a aplicação:

```bash
docker compose up -d
```

Acompanhe os logs para ver o processo de inicialização:

```bash
docker compose logs -f wordpress
```

**4. Acessando o WordPress** Abra seu navegador e acesse `http://localhost:8081`. Você será recebido pela tela de instalação do WordPress para concluir a configuração.