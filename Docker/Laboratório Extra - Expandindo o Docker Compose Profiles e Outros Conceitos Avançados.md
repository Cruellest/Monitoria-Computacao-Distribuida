A beleza do Docker Compose está em sua simplicidade para iniciar, mas ele também oferece ferramentas robustas para cenários mais complexos. Vamos explorar algumas delas.

#### **1. O que são Profiles?**

`Profiles` (Perfis) é uma funcionalidade que permite agrupar serviços em um arquivo `compose.yml` e ativá-los seletivamente. Isso é extremamente útil para separar ambientes, como desenvolvimento, teste e produção, sem precisar de múltiplos arquivos Compose.

Imagine que, além do Portainer, você queira rodar uma ferramenta de visualização de logs como o `Dozzle`, mas apenas durante o desenvolvimento.

**Exemplo Prático com `profiles`:**

Vamos adaptar nosso `compose.yml` para incluir o serviço `dozzle` em um perfil chamado `debug`.

```YAML
version: '3.8'

services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    ports:
      - "9443:9443"
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    restart: always

  # Novo serviço 'dozzle' associado ao perfil 'debug'
  dozzle:
    image: amir20/dozzle:latest
    container_name: dozzle
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "8081:8080"
    profiles:
      - debug  # Este serviço só iniciará se o perfil 'debug' for ativado
    restart: always

volumes:
  portainer_data:
```

**Como usar os perfis:**

1. **Executando sem o perfil `debug` (comportamento padrão):**

```bash
    docker compose up -d
    ```
    
    Neste caso, apenas o serviço `portainer` será iniciado, pois ele não pertence a nenhum perfil e é considerado padrão.
    
2. **Executando com o perfil `debug`:**
    
    ```bash
    docker compose --profile debug up -d
    ```
    
    Este comando iniciará **ambos** os serviços: `portainer` (porque é padrão) e `dozzle` (porque o perfil `debug` foi explicitamente ativado).
    

O uso de `profiles` mantém seu arquivo `compose.yml` limpo e organizado, permitindo customizar a inicialização dos serviços para diferentes necessidades.

---

#### **2. Outros Conceitos Legais**

**a) Arquivos `.env` para Variáveis de Ambiente**

Em vez de "chumbar" valores como senhas, nomes de usuário ou portas diretamente no `compose.yml`, é uma boa prática usar um arquivo de variáveis de ambiente chamado `.env`. O Docker Compose o carrega automaticamente.

**Exemplo:**

1. Crie um arquivo `.env` no mesmo diretório do `compose.yml`:
    
    Snippet de código
    
    ```
    # .env
    PORTAINER_WEB_PORT=9443
    PORTAINER_AGENT_PORT=9000
    ```
    
2. Modifique seu `compose.yml` para usar essas variáveis:
    
    ```YAML
    version: '3.8'
    
    services:
      portainer:
        image: portainer/portainer-ce:latest
        container_name: portainer
        ports:
          # Usando as variáveis do arquivo .env
          - "${PORTAINER_WEB_PORT}:9443"
          - "${PORTAINER_AGENT_PORT}:9000"
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - portainer_data:/data
        restart: always
    
    volumes:
      portainer_data:
    ```
    
    Agora, para mudar as portas, basta editar o arquivo `.env` sem tocar na lógica do Compose. Isso é mais seguro e flexível.
    

**b) `depends_on` e Health Checks**

O `depends_on` garante que um contêiner só inicie _depois_ de outro. No entanto, ele apenas aguarda o contêiner ser "iniciado", não que o serviço dentro dele esteja "pronto" (por exemplo, um banco de dados pronto para aceitar conexões).

Para um controle mais fino, podemos adicionar um `healthcheck`.

**Exemplo (Teórico, pois Portainer não precisa):** Imagine um serviço `webapp` que depende de um banco de dados `db`.

```YAML
services:
  webapp:
    image: minha-webapp
    depends_on:
      db:
        condition: service_healthy # Condição aprimorada

  db:
    image: postgres
    healthcheck:
      # Comando que o Docker roda para verificar a saúde do serviço
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
```

Neste caso, o `webapp` só iniciará quando o comando `pg_isready` dentro do contêiner `db` retornar sucesso, garantindo que o banco de dados está realmente pronto.

**c) `extends` para Reutilização**

Se você tem múltiplos arquivos Compose (ex: um para desenvolvimento, outro para produção) que compartilham configurações, a instrução `extends` permite que um arquivo herde configurações de outro, evitando repetição de código.

**Exemplo:**

1. **`common.yml` (arquivo base):**
    
    ```yaml
    # common.yml
    services:
      base-service:
        image: alpine
        restart: always
    ```
    
2. **`compose.yml` (arquivo principal):**
    
    ```yaml
    # compose.yml
    version: '3.8'
    extends:
      file: common.yml
    
    services:
      my-service:
        extends:
          service: base-service # Herda tudo de 'base-service'
        container_name: my_specific_container
    ```
    
    O `my-service` terá a imagem `alpine` e a política `restart: always` sem precisar declará-las novamente.