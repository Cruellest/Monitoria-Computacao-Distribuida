Nesta aula, vamos gerenciar aplicações complexas com múltiplos contêineres usando **Docker Compose**.
#### **O que é Docker Compose?**

`Docker Compose` é a ferramenta padrão do Docker para definir e executar aplicações multi-contêiner a partir de um único arquivo YAML (`compose.yml`). Ele automatiza a criação de serviços, redes e volumes, garantindo a reprodutibilidade do ambiente.

#### **Como o Docker Compose Funciona?**

O Docker Compose atua como um cliente da API do Docker. Ele lê o arquivo `compose.yml`, traduz as definições em chamadas de API para o daemon `dockerd`, que então executa as ações necessárias.

#### **Configurando o Ambiente**

O Docker Compose é instalado como um plugin (`docker-compose-plugin`) junto com o Docker Engine. Verifique a instalação com:


```bash
docker compose version
```

#### **Orquestrando o Portainer na Prática**

Vamos usar o Compose para implantar o Portainer, uma interface de gerenciamento para o Docker.

Crie um arquivo `compose.yml`:

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
      # Mapeia o socket do Docker para que o Portainer possa gerenciar o Docker
      - /var/run/docker.sock:/var/run/docker.sock
      # Volume para persistir os dados do Portainer
      - portainer_data:/data
    restart: always

volumes:
  portainer_data:
```

**Nota:** Em modo rootless, o caminho do socket muda para `/run/user/<UID>/docker.sock`.

Inicie a aplicação com:

```bash
docker compose up -d
```

Acesse a interface do Portainer em `https://localhost:9443`.