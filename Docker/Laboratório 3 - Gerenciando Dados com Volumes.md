Nesta aula, vamos aprender a gerenciar dados persistentes em contêineres Docker, uma tarefa essencial para qualquer aplicação que precise manter estado, como bancos de dados ou uploads de usuários.

**1. Por que Volumes?**

Contêineres são, por padrão, efêmeros. Seus sistemas de arquivos são destruídos quando eles são removidos. Volumes são o mecanismo preferido pelo Docker para persistir dados gerados e usados por contêineres.

**2. Tipos de Volumes**

Existem dois tipos principais de volumes no Docker:

- **Named Volumes (Volumes Nomeados):** Gerenciados pelo Docker, seus dados são armazenados em uma área específica no host (geralmente em `/var/lib/docker/volumes/`). Esta é a abordagem recomendada para a maioria dos casos de uso.
    
- **Bind Mounts:** Mapeiam um diretório ou arquivo existente no sistema de arquivos do host para dentro de um contêiner. São úteis para compartilhar arquivos de configuração ou código-fonte durante o desenvolvimento.
    

**3. Trabalhando com Volumes na Prática**

**Bind Mounts**

Vamos mapear um diretório do host para dentro do contêiner.

```bash
# Crie um diretório no host
mkdir /opt/meucontainer

# Execute um contêiner montando o diretório
# O que for criado em /dados dentro do contêiner, aparecerá em /opt/meucontainer no host
docker container run -ti --mount type=bind,src=/opt/meucontainer,dst=/dados debian
```

É possível também montar um diretório em modo de apenas leitura (read-only).

**Volumes Nomeados**

Agora, vamos usar um volume gerenciado pelo Docker.

```bash
# Crie um volume nomeado
docker volume create meusdados

# Verifique os volumes existentes
docker volume ls

# Inspecione o volume para ver onde ele está no host
docker volume inspect meusdados

# Execute um contêiner usando o volume
docker container run -ti --mount type=volume,src=meusdados,dst=/dados debian
```

**4. Gerenciamento de Volumes**

O Docker oferece comandos para gerenciar o ciclo de vida dos volumes.

- **Remover um volume:** `docker volume rm meusdados` (só funciona se nenhum contêiner o estiver usando).
    
- **Limpar volumes não utilizados:** O comando `docker volume prune` remove todos os volumes que não estão associados a pelo menos um contêiner.
    

**5. Backup de Volumes**

Uma estratégia comum de backup é executar um contêiner temporário que monta o volume a ser "backupeado" e um diretório de backup no host.

```bash 
# Crie um diretório para o backup no host
mkdir /mnt/backup

# Execute um contêiner que cria um arquivo .tar do volume no diretório de backup
docker container run --rm --mount type=volume,src=meusdados,dst=/data --mount type=bind,
```