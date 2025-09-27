# Kubernetes | K8s e Minikube

## O que é Kubernetes (K8s)?

É um sistema (plataforma ou PaaS) de código aberto para automatização de deploy (implantação), ajuste de dimensionamento e gerenciamento de aplicativos em containers. Assim, o que essa ferramenta faz é agrupar containers que compõem uma aplicação em unidades lógicas para uma fácil gestão e descoberta. A sigla *K8s* vem da fonética em inglês Kuber-eight-s que se assemelha à pronúncia do 8, também em inglês.

### Principais usos

- Gerenciar vários contêineres e serviços.
- Balancear carga.
- Autoescalar e reiniciar pods quando falham.
- Garantir alta disponibilidade.

## O que é Minikube?

Já o minikube é uma ferramenta derivada do Kubernetes que foi desenvolvida para facilitar o aprendizado e o desenvolvimento em K8s. Dessa forma, o minikube atua com um cluster K8 local - geralmente com um único nó - na máquina de quem a executa, enquanto o K8s roda com clusters distribuídos.

### Principais usos

- Aprender Kubernetes sem precisar de infraestrutura complexa.
- Testar configurações antes de levar para um cluster real.
- Desenvolver e depurar aplicações Kubernetes localmente.

## Laboratórios

Para essa disciplina vamos utilizar no laboratório somente o **minikube**.

- [Laboratório 1 - Instalando Minikube](Laboratório%201%20-%20Instalação.md)
- [Laboratório 2 - Dashboard e Métricas](Laboratório%202%20-%20Dashboard%20e%20Métricas.md)
- [Laboratório 3 - Instanciando Serviços](Laboratório%202%20-%20Dashboard%20e%20Métricas.md)

## Conceitos importantes

> Um cluster do kubernetes é composto por dois tipos de recursos principais:
> 
> - Control Plane
> - Node
> 
> ### Control Plane | Manager
> 
> Este recurso é responsável por gerenciar o cluster e tem como principais atividades:
> 
> - Agendamento de tarefas do(s) aplicativo(s)
> - Mantenimento do Estado Desejado da(s) Aplicação(ões)
> - Escalabilidade das Aplicações
> - Lançamento de Novas Atualizações e Lançamentos
> - Detecção de/Respostas à Eventos: como, por exemplo, detectar que o número de replicas não está sendo entregue.
> 
> ### Nodes | Workers
>
> Assim como seu nome já diz, os workers tem como responsabilidade
> 
> 

## Casos práticos

- [Caso 01: Nextcloud](Laboratório%203%20-%20Instanciando%20Serviços.md#nextcloud)
- [Caso 02: Wordpress](Laboratório%203%20-%20Instanciando%20Serviços.md#wordpress)
- [Caso 03: Portainer + NPM]()
- [Caso 04: Stripe]()
- [Caso 05: Setup FullStack]()

## Links e Referências

- [Minikube | Documentação oficial](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes | Documentação oficial](https://kubernetes.io/)
- [Oracle VirtualBox | Downloads](https://www.virtualbox.org/wiki/Downloads)
- [Debian 12 ou 13 | Download ISO](https://www.debian.org/)