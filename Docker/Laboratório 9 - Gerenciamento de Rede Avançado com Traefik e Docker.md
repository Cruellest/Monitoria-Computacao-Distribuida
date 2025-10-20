Nesta aula, vamos introduzir o Traefik, um moderno proxy reverso e load balancer projetado para o mundo dos contêineres. Ele simplifica drasticamente a exposição de serviços à internet.

#### **O que é o Traefik?**

Traefik é um _Cloud Native Edge Router_. Em termos simples, ele é um proxy reverso que observa sua infraestrutura (como o Docker) e configura a si mesmo automaticamente.

A principal vantagem é a **descoberta de serviço (service discovery)**. Em vez de editar manualmente um arquivo de configuração (como no Nginx ou Apache) toda vez que você sobe um novo contêiner, o Traefik detecta automaticamente que o contêiner foi iniciado e cria uma rota para ele.

#### **Como Funciona?**

O Traefik opera com três conceitos principais:

- **EntryPoints:** As portas de entrada da sua rede (ex: porta 80 para HTTP, 443 para HTTPS).
    
- **Routers:** Regras que analisam as requisições recebidas (ex: pelo domínio, como `Host('meu-app.localhost')`) e as direcionam para um serviço.
    
- **Services:** Representam os contêineres de aplicação que receberão o tráfego.
    

#### **Instalação e Configuração Prática com Docker**

Vamos configurar o Traefik para gerenciar um serviço de exemplo.

**Passo 1: Estrutura do Projeto**

Crie um diretório para o nosso projeto.

```BASH
mkdir traefik-docker && cd traefik-docker
```

**Passo 2: Arquivo de Configuração Estática (`traefik.yml`)**

Este arquivo contém as configurações que raramente mudam, como os EntryPoints e o provedor (Docker). Crie o arquivo `traefik.yml`:

```YAML
# traefik.yml
api:
  dashboard: true
  insecure: true # Habilita o dashboard em modo inseguro (apenas para lab)

entryPoints:
  web:
    address: ":80"

providers:
  docker:
    exposedByDefault: false # Boa prática: só expor contêineres com label explícito
```

**Passo 3: Arquivo Docker Compose (`docker-compose.yml`)**

Este arquivo irá definir como o Traefik e nossas aplicações serão executados.

```YAML
# docker-compose.yml
version: '3.8'

services:
  traefik:
    image: traefik:v2.11
    container_name: traefik
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"     # Porta para o tráfego HTTP
      - "8080:8080" # Porta para o Dashboard do Traefik
    volumes:
      # Monta o socket do Docker para que o Traefik possa ouvir os eventos
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - proxy

  whoami:
    image: traefik/whoami
    container_name: whoami
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
      - "traefik.http.routers.whoami.entrypoints=web"
    networks:
      - proxy

networks:
  proxy:
    name: proxy
```

**Análise do `docker-compose.yml`:**

- **Serviço `traefik`:**
    
    - Mapeamos as portas `80` (tráfego) e `8080` (dashboard).
        
    - O volume `- /var/run/docker.sock:/var/run/docker.sock:ro` é crucial. É assim que o Traefik monitora os contêineres Docker. O `:ro` significa _read-only_ (apenas leitura), uma boa prática de segurança.
        
- **Serviço `whoami` (nosso app de exemplo):**
    
    - As **`labels`** são a mágica do Traefik:
        
        - `traefik.enable=true`: "Olá Traefik, por favor, gerencie este contêiner."
            
        - `traefik.http.routers.whoami.rule=Host(\`whoami.localhost`)`: "Crie uma rota. Se uma requisição chegar com o domínio` whoami.localhost`, envie-a para mim."
            
        - `traefik.http.routers.whoami.entrypoints=web`: "Esta regra se aplica ao tráfego vindo pelo EntryPoint `web` (porta 80)."
            
- **Rede `proxy`:** Garante que o Traefik e os serviços possam se comunicar de forma isolada.
    

**Passo 4: Executando**

```bash
docker compose up -d
```

**Passo 5: Verificação**

1. **Acesse o Dashboard:** Abra seu navegador em `http://localhost:8080` e veja como o Traefik já detectou o serviço `whoami`.
    
2. **Acesse a Aplicação:** Use o comando `curl` para simular uma requisição com o domínio configurado.
    
```bash
    curl -H Host:whoami.localhost http://localhost
```
    
    Você verá a resposta do contêiner `whoami`, confirmando que o Traefik roteou a requisição corretamente.