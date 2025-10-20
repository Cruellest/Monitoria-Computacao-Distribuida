# Computação Distribuída | Guia Prático

Este repositório foi criado com o intuito de auxiliar as aulas práticas da disciplina de Computação Distribuída. Nele apresentamos guias e casos práticos para algumas das tecnologias mais utilizadas pelo mercado como Ansible, Docker, Podman, Kubernetes e LXC.

- [Ansible | Documentação Oficial](https://docs.ansible.com/)
- [Docker | Documentação Oficial](https://docs.docker.com/)
- [Podman | Documentação Oficial](https://docs.podman.io/en/latest/)
- [Kubernetes | Documentação Oficial](https://kubernetes.io/docs/home/)
- [LXC | Documentação Oficial](https://linuxcontainers.org/lxc/introduction/)

## Sumário

- [Configuração do Ambiente](#configuração-do-ambiente)
- [Ansible](#ansible)
- [Docker](#docker)
- [Kubernetes](#kubernetes)
- [LXC](#lxc)
- [Podman](#podman)

---

### Configuração do Ambiente

Antes de iniciar os laboratórios, é crucial preparar a máquina virtual.

- [Guia de Configuração da VM](./configurando_a_VM.md)
- [Instruções para Debian 12 no VirtualBox](./debian_12-virtualbox.pdf)

### Ansible

Ferramenta de automação de TI para provisionamento de software, gerenciamento de configuração e implantação de aplicativos.

- [Laboratório 1 - Introdução à Automação com Ansible](./Ansible/Laborat%C3%B3rio%201%20-%20Introdu%C3%A7%C3%A3o%20%C3%A0%20Automa%C3%A7%C3%A3o%20com%20Ansible.md)
- [Laboratório 2 - Aprofundando em Playbooks: Módulos, Arquivos e Handlers](./Ansible/Laborat%C3%B3rio%202%20-%20Aprofundando%20em%20Playbooks%20M%C3%B3dulos,%20Arquivos%20e%20Handlers.md)
- [Laboratório 3 - Variáveis e Templates para Automação Dinâmica](./Ansible/Laborat%C3%B3rio%203%20-%20Vari%C3%A1veis%20e%20Templates%20para%20Automa%C3%A7%C3%A3o%20Din%C3%A2mica.md)

### Docker

Plataforma de contêineres que permite empacotar e distribuir aplicações de forma isolada e portátil.

- [Laboratório 1 - Introdução ao Docker](./Docker/Laborat%C3%B3rio%201%20-%20Introdu%C3%A7%C3%A3o%20ao%20Docker.md)
- [Laboratório 2 - Aprofundando na Criação de Dockerfiles](./Docker/Laborat%C3%B3rio%202%20-%20Aprofundando%20na%20Cria%C3%A7%C3%A3o%20de%20Dockerfiles.md)
- [Laboratório 3 - Gerenciando Dados com Volumes](./Docker/Laborat%C3%B3rio%203%20-%20Gerenciando%20Dados%20com%20Volumes.md)
- [Laboratório 4 - Tópicos Avançados de Dockerfile](./Docker/Laborat%C3%B3rio%204%20-%20T%C3%B3picos%20Avan%C3%A7ados%20de%20Dockerfile.md)
- [Laboratório 5 - Orquestrando Contêineres com Docker Compose](./Docker/Laborat%C3%B3rio%205%20-%20Orquestrando%20Cont%C3%AAineres%20com%20Docker%20Compose.md)
- [Laboratório 6 - Instanciando o Nextcloud com Docker Compose](./Docker/Laborat%C3%B3rio%206%20-%20Instanciando%20o%20Nextcloud%20com%20Docker%20Compose.md)
- [Laboratório 7 - Instanciando o WordPress com Docker](./Docker/Laborat%C3%B3rio%207%20-%20Instanciando%20o%20WordPress%20com%20Docker.md)
- [Laboratório 8 - Orquestração com Docker Swarm](./Docker/Laborat%C3%B3rio%208%20-%20Orquestra%C3%A7%C3%A3o%20com%20Docker%20Swarm.md)
- [Laboratório 9 - Gerenciamento de Rede Avançado com Traefik e Docker](./Docker/Laborat%C3%B3rio%209%20-%20Gerenciamento%20de%20Rede%20Avan%C3%A7ado%20com%20Traefik%20e%20Docker.md)
- [Laboratório Extra - Expandindo o Docker Compose Profiles e Outros Conceitos Avançados](./Docker/Laborat%C3%B3rio%20Extra%20-%20Expandindo%20o%20Docker%20Compose%20Profiles%20e%20Outros%20Conceitos%20Avan%C3%A7ados.md)

### Kubernetes

Sistema de orquestração de contêineres open-source que automatiza a implantação, o dimensionamento e a gestão de aplicações em contêineres.

- [Introdução](./Kubernetes/Introdu%C3%A7%C3%A3o.md)
- [Laboratório 1 - Instalação](./Kubernetes/Laborat%C3%B3rio%201%20-%20Instala%C3%A7%C3%A3o.md)
- [Laboratório 2 - Dashboard e Métricas](./Kubernetes/Laborat%C3%B3rio%202%20-%20Dashboard%20e%20M%C3%A9tricas.md)
- [Laboratório 3 - Instanciando Serviços](./Kubernetes/Laborat%C3%B3rio%203%20-%20Instanciando%20Servi%C3%A7os.md)

### LXC

Tecnologia de virtualização a nível de sistema operacional (contêineres) que permite executar múltiplos sistemas Linux isolados em um único host.

- [Laboratório 1](./LXC/Lab%2001.md)
- [Laboratório 2](./LXC/Lab%2002.md)

### Podman

Ferramenta de gerenciamento de contêineres sem a necessidade de um daemon central, com foco em segurança e compatibilidade com o Docker.

- [Introdução](./Podman/Introdu%C3%A7%C3%A3o.md)
- [Laboratório 1 - Introdução ao Podman](./Podman/Laborat%C3%B3rio%201%20-%20Introdu%C3%A7%C3%A3o%20ao%20Podman.md)
- [Laboratório 2 - Aprofundando em Ambientes Rootless com Podman](./Podman/Laborat%C3%B3rio%202%20-%20Aprofundando%20em%20Ambientes%20Rootless%20com%20Podman.md)
- [Laboratório 3 - Compose](./Podman/Laborat%C3%B3rio%203%20-%20Compose.md)
- [Laboratório 4 - Instanciando o Nextcloud com Podman Compose](./Podman/Laborat%C3%B3rio%204%20-%20Instanciando%20o%20Nextcloud%20com%20Podman%20Compose.md)
- [Laboratório 5 - Instanciando o WordPress com Podman Compose](./Podman/Laborat%C3%B3rio%205%20-%20Instanciando%20o%20WordPress%20com%20Podman%20Compose.md)
- [Laboratório 6 - Gerenciamento de Rede Avançado com Traefik e Podman](./Podman/Laborat%C3%B3rio%206%20-%20Gerenciamento%20de%20Rede%20Avan%C3%A7ado%20com%20Traefik%20e%20Podman.md)