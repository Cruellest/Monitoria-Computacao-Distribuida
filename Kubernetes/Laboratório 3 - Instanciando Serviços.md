# Instanciando Serviços

## Casos práticos

1. [Nextcloud](#nextcloud)
2. [Wordpress](#wordpress)
3. [Sterling PDF]()
3. [Portainer + NPM]()

## Pré-requisitos

> Agora vamos começar a operar os serviços do Minikube. Mas antes vamos verificar se está tudo ok.

- [ ] Minikube com 2 nós: `control-plane` + `worker`. Verifique com `minikube status` ou `kubectl get nodes -o wide`.
- [ ] `kubectl` configurado e apontando para o cluster. Verifique se tá apontando com `kubectl cluster-info`.
- [ ] Verificar se o `storage-provisioner` está habilitado com `minikube addons list`. Caso não esteja habilitado, rode `minikube addons enable storage-provisioner` e verifique se o pod está rodando com `kubectl get pods -n kube-system`.

> - [ ] `ingress` addon habilitado. Este último é opcional, mas serve como um controlador de entrada de tráfego para os serviços que vamos instanciar. Assim, ao invés de utilizar o ip exposto e a porta feia do serviço podemos acessar por domínios `http://nextcloud.local` ou caminhos `http://meuservicos.local/nextcloud` bonitões. Todavia será necessário mapear o host/caminho no arquivo `/etc/hosts` da máquina física. Caso não esteja, habilite com `minikube addons enable ingress`.

## Namespaces

> Ao invés de jogar todos os objetos do serviço no namespace padrão `default`, uma prática recomendada é criar o espaço para cada projeto ou aplicação que você venha a instanciar. Outros benefícios são:

- **Isolamento lógico**: dois serviços podem ter o mesmo nome desde que estejam em namespaces diferentes.
- **Segurança**: podemos aplicar o controle de acesso baseado em papéis (RBAC). Assim, o time A só enxerga o namespace `dev` e o time B só verá o `prod`.
- **Ajuste de Recursos**: como configurar limites de CPU, memória e storage para não utilizar todos os recursos do cluster.
- **Facilidade de gerenciamento**: facilidade de aplicar ou deletar tudo de uma aplicação.

```bash
$ kubectl create namespace <app-projeto>

# Ver os namespaces
$ kubectl get namespaces
#ou
$ kubectl get ns
NAME                   STATUS   AGE
default                Active   47h
ingress-nginx          Active   35h
kube-node-lease        Active   47h
kube-public            Active   47h
kube-system            Active   47h
kubernetes-dashboard   Active   47h

# Alterando para um ns específico
$ kubectl config set-context --current --namespace=wordpress

# Deletando o namespace
$ kubectl delete namespace <nome-namespace>
# Parando o namespace
$ kubectl scale deployment <app> --replicas=0 -n <app-projeto> # Caso deseje voltar, apenas altere as replicas para 1.

# Deletando todos os recursos do namespace, mantendo o namespace
$ kubectl delete all --all -n <namespace>

# Deletando Volumes Persistentes
$ kubectl delete pv --all -n <namespace>

# Deletando a requisição de uso do PV 
$ kubectl delete pvc --all -n <namespace>
```

## Verificações

- [ ] Namespace
- [ ] Pods
- [ ] Volumes Persistentes (PV ou PVC)
- [ ] Serviços

## Nextcloud

```bash
# Criando o namespace
$ kubectl create namespace nextcloud
namespace/nextcloud created
```

### Deploy

> Podemos fazer o deploy executanto um único arquivo. Aqui nomeamos como [postgres-nextcloud.yml](./services/postgres-nextcloud.yml).
>
> Antes, vamos criar uma pasta só para esse serviço:
>

```bash
$ mkdir nextcloud
$ cd nextcloud
$ sudo nano postgres-nextcloud.yml

# Aplicar o manifesto
$ kubectl apply -f postgres-nextcloud.yml
persistentvolumeclaim/postgres-pvc created
deployment.apps/postgres created
service/postgres created
```

#### Acessando o serviço | localhost:8080

> Pode demorar alguns minutos até subir o nextcloud. Verifique com `kubectl get pods -n nextcloud`.

```bash
# Solicite a URL do serviço
$ minikube service nextcloud --url
http://192.168.49.2:32563
```

> Assim como vimos la no [laboratório 2 de acesso ao dashboard](Laboratório%202%20-%20Dashboard%20e%20Métricas.md) via navegador da sua máquina física, vamos fazer o tunelamento via SSH para o `nextcloud`.

```bash
# Na shell da sua máquina execute, alterando para o seu usuário e ip da sua máquina:
$ ssh -L 8080:192.168.49.2:32563 kaeu@192.168.56.3
```

> Acesse o serviço em `http://localhost:8080`.

- [Nextcloud | Documentação Oficial](https://docs.nextcloud.com/)

## Wordpress

```bash
# Criando o repositorio
$ mkdir wordpress
$ cd wordpress

# Descrevendo o manifesto
$ sudo nano [wp-mysql.yml](./services/wp-mysql.yml)
```

```bash
# Aplicar o manifesto
$ kubectl apply -f wp-mysql-deployment.yml
namespace/wordpress created
persistentvolumeclaim/wordpress-pvc created
secret/mysql-pass created
deployment.apps/mysql created
service/mysql created
deployment.apps/wordpress created
service/wordpress created
```

### Verificação

```bash
# Ainda em ~/wordpress
$ kubectl get pvc -n wordpress
$ kubectl get pods -n wordpress

# Logs dos pods
$ kubectl logs -n wordpress -l app=mysql
$ kubectl logs -n wordpress -l app=wordpress

# 
$ kubectl rollout restart deployment wordpress -n wordpress
```

#### Acessando o serviço | localhost:8080

> Pode demorar alguns minutos até subir o wordpress. Verifique com `kubectl get pods -n wordpress`.

```bash
# Solicite a URL do serviço
$ minikube service wordpress -n wordpress --url
http://192.168.49.2:30080
```

> Assim como vimos la no [laboratório 2 de acesso ao dashboard](Laboratório%202%20-%20Dashboard%20e%20Métricas.md) via navegador da sua máquina física, vamos fazer o tunelamento via SSH para o `wordpress`.

```bash
# Na shell da sua máquina física execute, alterando para o seu usuário:
$ ssh -L 8080:192.168.49.2:30080 kaeu@192.168.56.3
```

> Acesse o serviço em `http://localhost:8080`.

## Portainer com Nginx Proxy Manager (NPM)

```bash
$ kubectl apply -n portainer -f https://downloads.portainer.io/ce-lts/portainer.yaml
```

```bash
# Ainda em ~/wordpress
$ kubectl get pvc -n wordpress
$ kubectl get pods -n wordpress

# Logs dos pods
$ kubectl logs -n wordpress -l app=mysql
$ kubectl logs -n wordpress -l app=wordpress

# 
$ kubectl rollout restart deployment wordpress -n wordpress
```

## Links e outras referências

- [Wordpress + MySQL | Ambiente de Desenvolvimento](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/)
- [Wordpress + MySQL | Ambiente de Produção](https://github.com/bitnami/charts/tree/main/bitnami/wordpress)
- [Portainer](https://docs.portainer.io/start/install-ce/server/kubernetes/baremetal#deploy-using-yaml-manifests)
- [Nginx Proxy Manager (NPM) | Full setup on Docker](https://nginxproxymanager.com/setup/)