Com os fundamentos de `Dockerfile` estabelecidos, vamos explorar instruções e técnicas mais avançadas para criar imagens eficientes e prontas para produção.

**1. `ENTRYPOINT` vs. `CMD`**

`CMD` e `ENTRYPOINT` definem o comando a ser executado quando o contêiner inicia, mas com uma diferença crucial:

- `ENTRYPOINT`: Define o executável principal do contêiner. Ele não é facilmente sobrescrito. É o "ponto de entrada" da imagem.
    
- `CMD`: Define os argumentos padrão para o `ENTRYPOINT`. O `CMD` pode ser facilmente sobrescrito ao iniciar o contêiner.
    

**Exemplo:**

```dockerfile
FROM debian
# ...
ENTRYPOINT ["/usr/sbin/apachectl"]
CMD ["-D", "FOREGROUND"]
```

Neste caso, o

`ENTRYPOINT` é o programa `apachectl`. O

`CMD` fornece os argumentos `-D FOREGROUND`. Ao executar

`docker run <imagem>`, o Apache iniciará. Ao executar `docker run <imagem> -X`, o `-X` substituirá o `CMD`, e o comando final será `apachectl -X`.

**2. `COPY` vs. `ADD`**

Ambos os comandos copiam arquivos para dentro da imagem, mas o `ADD` possui funcionalidades adicionais:

- `COPY`: Simplesmente copia arquivos e diretórios do contexto do build para a imagem.
    
- `ADD`: Faz o mesmo que o `COPY`, mas também pode baixar arquivos de uma URL e extrair arquivos `.tar` automaticamente para o destino.
    

**Recomendação:** Prefira `COPY` por ser mais explícito. Use `ADD` apenas quando precisar de suas funcionalidades extras.

**3. Builds Multi-Stage (Multi-Estágio)**

Builds multi-stage são uma técnica poderosa para criar imagens pequenas e seguras. A ideia é usar uma imagem maior com todas as ferramentas de compilação (como a imagem `golang`) para construir a aplicação e, em um segundo estágio, copiar apenas o binário compilado para uma imagem final mínima (como `alpine`).

```dockerfile
# Estágio 1: Build
FROM golang AS buildando
WORKDIR /app
ADD . /app
RUN go build -o meugo

# Estágio 2: Imagem Final
FROM alpine
WORKDIR /new
# Copia apenas o executável do estágio anterior
COPY --from=buildando /app/meugo /new/
ENTRYPOINT ./meugo
```

Isso resulta em uma imagem final drasticamente menor, contendo apenas o necessário para executar a aplicação.

**4. Publicando Imagens no Docker Hub**

Após construir sua imagem, você pode compartilhá-la no Docker Hub ou em outro registry.

```bash
# 1. Crie uma tag para a imagem no formato <usuario>/<repositorio>:<tag>
docker image tag minha-imagem:1.0 seu-usuario/minha-imagem:1.0

# 2. Faça login no Docker Hub
docker login

# 3. Envie a imagem
docker push seu-usuario/minha-imagem:1.0
```

**5. `HEALTHCHECK`**

A instrução `HEALTHCHECK` permite definir um comando que o Docker executa periodicamente dentro do contêiner para verificar se ele está funcionando corretamente.

```dockerfile
HEALTHCHECK --interval=1m --timeout=3s \
 CMD curl -f http://localhost/ || exit 1
```

O status da verificação (ex:

`starting`, `healthy`, `unhealthy`) aparecerá no `docker ps`.