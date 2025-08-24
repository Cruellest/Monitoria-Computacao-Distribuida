Nesta aula, vamos aprofundar nosso conhecimento na construção de imagens com Docker, focando nas melhores práticas e nas instruções essenciais de um `Dockerfile`. Enquanto a aula anterior apresentou um `Dockerfile` simples, agora vamos explorar como otimizar nossas imagens, torná-las mais eficientes e entender o propósito de cada comando chave.

---

#### **1. O que é um Dockerfile?**

Um `Dockerfile` é um script de texto que contém uma sequência de comandos que o Docker utiliza para montar (construir) uma imagem de contêiner. Ele automatiza o processo de criação de imagens, garantindo que o ambiente seja consistente e reprodutível em qualquer máquina que execute o Docker.

Cada instrução no `Dockerfile` cria uma nova "camada" (layer) na imagem. O Docker armazena essas camadas em cache para acelerar builds futuros. Entender como essas camadas funcionam é fundamental para criar imagens otimizadas.

---

#### **2. Anatomia de um Dockerfile: Instruções Essenciais**

Vamos detalhar as instruções mais comuns e sua finalidade.

- **`FROM`**: Define a imagem base a partir da qual você está construindo. Toda imagem começa com uma instrução `FROM`. A escolha de uma imagem base pequena (como `debian:slim` ou `alpine`) é a primeira etapa para uma imagem final leve.
    
- **`WORKDIR`**: Define o diretório de trabalho para qualquer instrução `RUN`, `CMD`, `ENTRYPOINT`, `COPY` e `ADD` que a segue. É uma prática melhor do que usar `RUN cd /meu-app`.
    
- **`COPY`**: Copia arquivos e diretórios da sua máquina local (o contexto do build) para o sistema de arquivos do contêiner.
    
- **`RUN`**: Executa comandos na shell do contêiner durante o processo de build. Cada instrução `RUN` cria uma nova camada. Para otimizar, é comum encadear vários comandos usando `&&`.
    
- **`CMD`**: Fornece o comando padrão que será executado quando um contêiner for iniciado a partir da imagem. Só pode haver uma instrução `CMD` em um `Dockerfile`. Se um comando for especificado ao iniciar o contêiner (`docker run minha-imagem comando-novo`), ele substituirá o `CMD`.
    
- **`EXPOSE`**: Informa ao Docker que o contêiner escuta em portas de rede específicas em tempo de execução. Esta instrução não publica a porta; ela funciona como um tipo de documentação entre o construtor da imagem e a pessoa que a executa.
    

---

#### **3. Construindo uma Imagem Otimizada na Prática**

Vamos criar uma imagem para uma aplicação web simples usando Nginx, aplicando as melhores práticas.

**Passo 1: Estrutura do Projeto**

Primeiro, crie um diretório para o projeto e os arquivos necessários.

```bash
mkdir meu-nginx-app && cd meu-nginx-app
mkdir public-html
echo "<h1>Ola do meu site personalizado!</h1>" > public-html/index.html
```

Agora, temos um diretório `meu-nginx-app` contendo uma pasta `public-html` com nosso site estático.

**Passo 2: Criando o `Dockerfile`**

Dentro do diretório `meu-nginx-app`, crie um arquivo chamado `Dockerfile`.

```bash
nano Dockerfile
```

Cole o seguinte conteúdo no arquivo:

```Dockerfile
# Passo 1: Definir a imagem base
# Usamos a versão 'alpine' do Nginx por ser extremamente leve.
FROM nginx:alpine

# Passo 2: Adicionar metadados (boa prática)
LABEL author="Seu Nome" description="Imagem Nginx com site estatico personalizado."

# Passo 3: Copiar os arquivos do nosso site para o diretório padrão do Nginx
# O Nginx na imagem 'alpine' serve arquivos de /usr/share/nginx/html
COPY public-html/ /usr/share/nginx/html

# Passo 4: Expor a porta padrão do Nginx
# Apenas para documentação, não publica a porta.
EXPOSE 80

# Passo 5: Comando para iniciar o Nginx
# Este comando é herdado da imagem base, mas o especificamos para clareza.
# O Nginx precisa rodar em foreground para manter o contêiner ativo.
CMD ["nginx", "-g", "daemon off;"]
```

**Análise do `Dockerfile`:**

- `FROM nginx:alpine`: Começamos com uma base pequena e já configurada.
    
- `LABEL`: Adicionamos metadados úteis.
    
- `COPY public-html/ /usr/share/nginx/html`: Copiamos apenas os arquivos necessários para o local onde o Nginx espera encontrá-los. Isso cria uma nova camada sobre a imagem base.
    
- `EXPOSE 80`: Documentamos que nossa aplicação usa a porta 80.
    
- `CMD ["nginx", "-g", "daemon off;"]`: Garantimos que o Nginx inicie corretamente em primeiro plano, o que é essencial para que o contêiner continue em execução.
    

**Passo 3: Construindo e Executando a Imagem**

Com o `Dockerfile` salvo, execute o build:

```bash
# O '.' no final indica que o contexto do build é o diretório atual
docker build -t meu-site-nginx .
```

O Docker executará cada passo, criando uma imagem chamada `meu-site-nginx`.

Agora, execute um contêiner a partir da sua nova imagem:

```bash
# Mapeamos a porta 8080 do host para a porta 80 do contêiner
docker run -d --name web-personalizado -p 8080:80 meu-site-nginx
```

Para verificar, abra seu navegador e acesse `http://localhost:8080`. Você verá a mensagem "Ola do meu site personalizado!".

---

#### **4. Otimização: Encadeando Comandos `RUN`**

Imagine que você precise instalar pacotes. Cada `RUN apt-get install` criaria uma nova camada. A forma otimizada é encadear os comandos.

**Não otimizado (cria 3 camadas):**

```Dockerfile
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
```

**Otimizado (cria 1 camada):**

```Dockerfile
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*
```

A inclusão de `rm -rf /var/lib/apt/lists/*` no final limpa o cache do gerenciador de pacotes na mesma camada, reduzindo ainda mais o tamanho da imagem final.