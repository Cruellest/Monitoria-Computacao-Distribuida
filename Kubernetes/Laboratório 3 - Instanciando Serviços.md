# Instanciando Serviços

## Casos práticos

1. [Nextcloud](#nextcloud)
2. [Wordpress](#wordpress)

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

# Deletando o
```

### Parando o namespace

```bash
$ kubectl scale deployment <app> --replicas=0 -n <app-projeto>
```
> Caso deseje voltar, apenas altere as replicas para 1.

### Deletando todos os recursos do namespace, mantendo o namespace

```bash
$ kubectl delete all --all -n <namespace>
$ kubectl delete pvc --all -n <namespace>

# Exemplo
$ kubectl delete pvc --all -n nextcloud
pod "nextcloud-55846b7f8c-55mvk" deleted
pod "postgres-6967f5b4b-fftqm" deleted
service "nextcloud" deleted
service "postgres" deleted
deployment.apps "nextcloud" deleted
deployment.apps "postgres" deleted
persistentvolumeclaim "nextcloud-pvc" deleted
persistentvolumeclaim "postgres-pvc" deleted
```

## Nextcloud

```bash
# Criando o namespace
$ kubectl create namespace nextcloud
namespace/nextcloud created
```

### Deploy | PostgreSQL

```bash
$ mkdir nextcloud
$ cd nextcloud
$ sudo nano postgres-deployment.yml
```

```yaml
# postgres-deployment.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: nextcloud
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: nextcloud
spec:
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:16
        env:
        - name: POSTGRES_DB
          value: nextcloud
        - name: POSTGRES_USER
          value: nextcloud
        - name: POSTGRES_PASSWORD
          value: nextpass
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: nextcloud
spec:
  ports:
  - port: 5432
  selector:
    app: postgres
# Fim postgres-deployment.yml

# Aplicar o manifesto
$ kubectl apply -f postgres-deployment.yml
persistentvolumeclaim/postgres-pvc created
deployment.apps/postgres created
service/postgres created
```

### Deploy | Nextcloud

```bash
# Ainda em ~/nextcloud
$ sudo nano nextcloud-deployment.yml

# nextcloud-deployment.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nextcloud-pvc
  namespace: nextcloud
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nextcloud
  namespace: nextcloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nextcloud
  template:
    metadata:
      labels:
        app: nextcloud
    spec:
      containers:
      - name: nextcloud
        image: nextcloud:29-apache
        env:
        - name: POSTGRES_HOST
          value: postgres
        - name: POSTGRES_DB
          value: nextcloud
        - name: POSTGRES_USER
          value: nextcloud
        - name: POSTGRES_PASSWORD
          value: nextpass
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nextcloud-data
          mountPath: /var/www/html
      volumes:
      - name: nextcloud-data
        persistentVolumeClaim:
          claimName: nextcloud-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: nextcloud
  namespace: nextcloud
spec:
  ports:
  - port: 80
  selector:
    app: nextcloud
  type: NodePort
# Fim nextcloud-deployment.yml

# Aplicar o manifesto
$ kubectl apply -f nextcloud-deployment.yml
persistentvolumeclaim/nextcloud-pvc created
deployment.apps/nextcloud created
service/nextcloud created
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
# Na shell da sua máquina execute:
$ ssh -L 8080:192.168.49.2:32563 kaeu@192.168.56.3
```

> Acesse o serviço em `http://localhost:8080`.

- [Nextcloud | Documentação Oficial](https://docs.nextcloud.com/)

## Wordpress

```bash
# Criando o namespace
$ kubectl create namespace wordpress
namespace/wordpress created

# Criando o repositorio
$ mkdir wordpress
$ cd wordpress
```

### Deploy

```bash
$ sudo nano wp-deployment.yml
````

```bash
# wp-mysql-deployment.yml
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: wordpress
---
# PVC compartilhado (usado por MySQL e WordPress)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wordpress-pvc
  namespace: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
---
# Secret com a senha do MySQL
apiVersion: v1
kind: Secret
metadata:
  name: mysql-pass
  namespace: wordpress
type: Opaque
data:
  password: cGFzc3dvcmQ=  # "password" em base64
---
# Deployment do MySQL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: wordpress
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: wordpress-pvc
---
# Service do MySQL
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: mysql
---
# Deployment do WordPress
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:6.5-apache
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql.wordpress.svc.cluster.local
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 80
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wordpress-pvc
---
# Service do WordPress
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: wordpress
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30080
  selector:
    app: wordpress

# Fim wp-mysql-deployment.yml
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

### Deploy | Verificação

```bash
# Ainda em ~/wordpress
$ kubectl get pvc -n wordpress
$ kubectl get pods -n wordpress
$ kubectl logs -n wordpress -l app=mysql
$ kubectl logs -n wordpress -l app=wordpress
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
# Na shell da sua máquina física execute:
$ ssh -L 8080:192.168.49.2:32563 kaeu@192.168.56.3
```

> Acesse o serviço em `http://localhost:30080`.

- [Wordpress | Documentação Oficial](https://docs.nextcloud.com/)