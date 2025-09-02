Docker Swarm é a ferramenta de orquestração nativa do Docker para gerenciar um cluster de nós (máquinas) como se fossem um único sistema.

**1. Arquitetura Manager e Worker**

- **Managers:** Responsáveis por gerenciar o estado do cluster e agendar os serviços. Para alta disponibilidade, recomenda-se um número ímpar de managers.
    
- **Workers:** Executam os contêineres (tarefas) que são atribuídos pelos managers.

OBS: O ideal é que possuamos um numero mínimo de 3 gerentes ou mantenhamos a proporção 50% + 1

**2. Inicializando o Cluster**

No nó que será o primeiro manager, execute:

```bash
docker swarm init
```

Este comando tornará o nó atual um manager e gerará um token para que outros nós possam se juntar ao swarm.

**3. Gerenciando Nós do Cluster**

- **Juntando-se ao Cluster:** Nos nós workers, execute o comando `docker swarm join` fornecido pelo `init`.
    
- **Listando os Nós:** `docker node ls`
    
- **Promovendo um Worker a Manager:** `docker node promote <NOME_DO_NO>`
    
- **Removendo um Nó:** No próprio nó, execute `docker swarm leave`.
    

**4. Executando Serviços**

No Swarm, você não executa contêineres diretamente; você cria **serviços**, que definem como os contêineres devem ser executados, incluindo a imagem, o número de réplicas e as portas.

```bash
# Cria um serviço chamado 'webserver' com 3 réplicas da imagem nginx
docker service create --name webserver --replicas 3 -p 8080:80 nginx
```

- **Listando Serviços:** `docker service ls`
    
- **Verificando as Tarefas (Contêineres) de um Serviço:** `docker service ps webserver`
    

**5. Escalando Serviços e Gerenciando a Disponibilidade dos Nós**

A principal vantagem de um orquestrador é a capacidade de escalar e gerenciar falhas.

- **Escalando um Serviço:**
    
    ```bash
    docker service scale webserver=10 
    ```
    
- **Gerenciando a Disponibilidade de um Nó:**
    
    - `pause`: O nó não aceitará novas tarefas, mas as existentes continuarão rodando.

        ```bash
        docker node update --availability pause node01 
        ```
        
    - `drain`: O nó não aceitará novas tarefas e o Swarm removerá as tarefas existentes dele, reagendando-as em outros nós ativos. Ideal para manutenção.

        ```bash
        docker node update --availability drain node01
        ```
        
    - `active`: Retorna o nó ao estado normal, permitindo que ele aceite novas tarefas.