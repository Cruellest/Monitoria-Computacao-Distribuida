Nesta aula, vamos implantar o WordPress, o sistema de gerenciamento de conteúdo mais popular do mundo. Seguiremos a mesma abordagem da aula anterior, utilizando `podman-compose` para orquestrar um contêiner WordPress e um banco de dados MySQL de forma segura e isolada como um usuário comum.

---

#### **1. Pré-requisitos**

Assim como na aula anterior, garanta que seu ambiente Podman _rootless_ esteja totalmente configurado e que o `podman-compose` esteja instalado.

---

#### **2. Estrutura do Projeto**

Crie um diretório dedicado para o seu projeto WordPress.

```bash
mkdir wordpress-podman && cd wordpress-podman
```

---

#### **3. Criando o Arquivo `compose.yml`**

Dentro do diretório, crie o arquivo `compose.yml` com o seguinte conteúdo:

```bash
nano compose.yml
```

```YAML
version: '3.8'

services:
  db:
    image: docker.io/mysql:5.7
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
    image: docker.io/wordpress
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
    name: wordpress_db_data
```

**Análise do arquivo `compose.yml`:**

- **`services.db`**:
    
    - `image`: Utiliza a imagem `mysql:5.7`, uma versão amplamente compatível com o WordPress.
        
    - `volumes`: Persiste os dados do banco de dados no volume `db_data`.
        
- **`services.wordpress`**:
    
    - `ports`: Expõe o serviço na porta `8081` do host. Escolhemos uma porta diferente de `8080` para evitar conflitos com a aula anterior. Esta é uma prática recomendada ao rodar múltiplos projetos.
        
    - `depends_on`: Garante que o contêiner do WordPress inicie somente após o banco de dados estar pronto.
        
    - `environment`: Fornece ao contêiner do WordPress as informações necessárias para se conectar ao banco de dados. Note que `WORDPRESS_DB_HOST` é `db:3306`, onde `db` é o nome do serviço do banco de dados. O `podman-compose` cria uma rede interna que permite aos contêineres se comunicarem usando seus nomes de serviço.
        

---

#### **4. Executando a Aplicação**

Inicie a aplicação com o `podman-compose`, novamente sem `sudo`.


```bash
podman-compose up -d
```

Você pode acompanhar os logs para ver o processo de inicialização:

```bash
podman-compose logs -f wordpress
```

---

#### **5. Acessando o WordPress**

Abra seu navegador e acesse `http://localhost:8081`. Você será recebido pela famosa tela de instalação de cinco minutos do WordPress. Preencha as informações do site para concluir a configuração.

Assim como no Nextcloud, esta instalação é totalmente _rootless_. A segurança é aprimorada, pois, se um contêiner for comprometido, o invasor terá apenas as permissões do seu usuário local, e não acesso `root` ao sistema host.
![[Pasted image 20250824032502.png]]