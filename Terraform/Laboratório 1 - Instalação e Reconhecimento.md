# Terraform

O terraform é uma ferramenta para gerenciamento de infraestrutura de aplicações via descrição de código (IaC). Ela é mantida e criada pela empresa HashiCorp e apresenta uma documentação bem amigável com [tutoriais](https://developer.hashicorp.com/terraform/tutorials) de instalação em diversos provedores Cloud como AWS, Azure, Oracle, Docker e Google Cloud, por exemplo, além de tutoriais mais específicos da própria ferramenta, também trazendo casos de uso. 

Aqui vamos seguir a documentação para implementação de uma infraestrutura com Docker para OS em Linux, mas caso queira, você pode seguir os passos para Windows ao longo do [tutorial](https://developer.hashicorp.com/terraform/tutorials/docker-get-started).

## Vantagens

- Gestão centralizada da infraestrutura em diversos provedores de plataformas na nuvem (Cloud) via arquivos de configuração.
- Linguagem declarativa e de alto nível para escrita rápida da infraestrutura.
- Controle dos estados permite acompanhar as alterações dos recursos ao longo das implantações.

## Processo para deploy

- *Scope*: identifique a infraestrutura do projeto
- *Author*: escreva a configuração que define a infraestrutura
- *Inicialize*: instale os provedores necessários
- *Plan*: visualize as mudanças que o Terraform vai fazer
- *Apply*: aplique as mudanças na infraestrutura

## 

## Arquivos de configurações e suas funções

- `main.tf`: arquivo de configuração de infraestrutura da aplicação.
- `terraform.tfstate`: responsável por guardar o estado das alterações ao longo do tempo, contendo mais detalhes sobre os recursos. Deve ser armazenado com cuidado por conter informações sensiveis como IDs, hashs e outros atributos dos recursos.

## Instalação

Para instalar a ferramenta, consulte a documentação no site oficial da HashiCorp e escolha o [tutorial](https://developer.hashicorp.com/terraform/install) de acordo com a sua máquina. Verifique se a instalação foi bem sucedida com `terraform --version` ou dê uma olhada nos comandos da ferramenta com `terraform -help`. Caso queira saber mais de um determinado comando basta incluí-lo no comando: `terraform plan -help`. Você pode habilitar o auto-complete de comandos com `terraform -install-autocomplete`.

## Build

Cada arquivo de configuração do terraform deve estar em um diretório de trabalho.

```bash
mkdir build && cd build
```

```bash
touch main.tf
```

> Adicione a configuração como no arquivo [`main.tf`](./build/main.tf) e depois inicialize o deploy com `terraform init`.

Aqui o terraform vai baixar o docker e instalar em um subdiretório escondido chamado `.terraform`. Ele também vai criar um arquivo de "trava" especificando a versão e o provedor exato que foi utilizado. Não é recomendado realizar alterações manuais nele, pois pode resultar em perdas futuras.

### Criando a infraestrutura

Ao executar `terraform apply`, o terraform vai mostrar o planejamento a ser executado descrevendo as ações a serem tomadas para subir a infraestrutura. Ele vai esperar você aprovar a aplicação e dentro de alguns segundos você terá seu nginx ativo em http://localhost:8000. Você pode verificar o estado atual da infraestrutura com `terraform show`.

## Fazendo alterações na infraestrutura

No arquivo `main.tf` altere a porta externa de `8000` para `8888`. Em seguida execute `terraform apply` como anteriormente e você verá que ele vai mostrar as alterações semelhante ao `git`. Verifique em http://localhost:8888.

## Destruindo 

Para destruir recursos, basta executar `terraform destroy`, o que executa exatamente o procedimento inverso do `terraform apply`.

## Variáveis

Uma boa prática dessa ferramenta é criar um arquivo de variáveis `variables.tf` para configurar os nomes de uma forma flexivel e segura. 

1. Adicione a variável conforme descrito no [arquivo](./build/variables.tf) e adapte para o nome que deseja em `default`. 
2. Em `main.tf`, vá no recurso do container e altere o nome de `"tutorial"` para `var.container_name`.
3. Aplique as alterações com `terraform apply`.

Você também pode aplicar isso diretamente com a flag `-var "container_name=OutroNome"`.

## Outputs

Crie um arquivo chamado `outputs.tf` e insira os blocos de id do container e da imagem, como está no [arquivo](./build/outputs.tf). Aplique as alterações novamente com `terraform apply` e você verá os valores dos respectivos IDs. De forma alternativa você pode verificar com `terraform output`. Entre os benefícios de utilizá-lo está a possibilidade de conectar os recursos de outros projetos a sua infraestrutura de modo a automatizar o workflow da sua aplicação. 

- [Output data from Terraform](https://developer.hashicorp.com/terraform/tutorials/configuration-language/outputs)


