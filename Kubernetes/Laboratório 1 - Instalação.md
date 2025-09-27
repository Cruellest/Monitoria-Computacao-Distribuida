# Instalação Minikube

- [O que é Minikube?](Introdução.md#o-que-é-minikube)

## Instalando as ferramentas necessárias

### Pré-requisitos

> Pra essa prática, você já deve ter a VM com o sabor `Debian 12 Bookworm` rodando pra executar os próximos comando no terminal. Caso ainda não tenha feito isso você pode seguir os passos do pdf abaixo:
>
> - [Preparando e subindo a VM](../debian_12-virtualbox.pdf)

### Instalando o minikube e sua CLI (kubectl)

> Enquanto o `minikube` cria e executa os clusters K8s locais, o `kubectl` realiza toda interação necessária para qualquer cluster (local ou remoto).

```bash
$ sudo apt update
$ sudo apt install snapd curl        # Verificando a instalação
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
$ dpkg -i minikube_latest_amd64.deb
$ minikube version  
$ snap install kubectl --classic
```

> Caso dê algum erro dizendo que o comando não foi encontrado, basta executar um `sudo apt install` para resolver.

> - Outro erro que pode ocorrer é na hora de instalar a CLI com o `snap`. Uma alternativa é usar o `curl`:

```bash
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
$ chmod +x kubectl
$ sudo mv kubectl /usr/local/bin/
$ kubectl version --client        # Verificando a instalação
```

Você consegue ter mais informações e ajuda na própria documentação do Kubernetes:
> - [Instalando `kubectl` com `curl`](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux)

### Instalando o Driver | Docker

> Para que o K8s possa funcionar vamos precisamos que um Driver, como o Docker, esteja pronto nessa máquina. Mas antes, vamos  preparar o repositório estável do Docker na nossa VM com os seguintes comandos:

```bash
$ sudo apt-get update
$ sudo install -m 0755 -d /etc/apt/keyrings
$ sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
$ sudo chmod a+r /etc/apt/keyrings/docker.asc
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt-get update
```

> Agora que a gente vai de fato instalar as ferramentas do `docker` e verificar sua instalação:

```bash
$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
$ docker --version
```

> Além disso, vamos adicionar o nosso usuário ao grupo docker com o seguinte comando:

```bash
$ sudo adduser $(whoami) docker
```

> Ou, caso a bash não reconheça o `adduser`:

```bash
$ sudo usermod -aG docker $USER
```

> Em seguida, faça logout e login no terminal novamente para que as atualizações tenham efeito. Você pode confirmar com o comando `groups` para ver se deu tudo certo. 
>
> Agora, é necessário informar o `containerd` para usar o `systemd` ao gerenciar cgroups, para melhorar a compatibilidade e estabilidade, e evitar falhas no controle de recusos:

```bash
$ containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
$ sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
$ sudo systemctl restart containerd
$ sudo systemctl enable containerd
```

> Segue os links da documentação:

- [Instalando Docker usando o Repositório Oficial](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
- [Usando o Docker com um usuario não `root`](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

### Auto Complete

> Uma boa utilidade a se adicionar na shell da sua VM é o auto-complete do `kubectl` ou `minikube` que vai te apresentar a lista de todos os comandos possíveis da ferramenta. O seguinte comando realiza a escrita no arquivo base da shell `.bashrc` e depois reinicia a mesma:

```bash
kubectl completion bash > ~/.kubectl_completion
echo "source ~/.kubectl_completion" >> ~/.bashrc
source ~/.bashrc
```

- Para utilizar, digite `kubectl` e tecle `TAB` duas vezes. Também é possível utilizar com subcomandos como o `kubectl get`, por exemplo.

### Desativando a SWAP

> Agora nós vamos desabilitar a SWAP e ativar os parâmetros necessários do kernel.
> A SWAP precisa ser desativada porque o Kubernetes espera que os recursos de memória sejam totalmente previsíveis. Caso contrário, o agendador pode se confundir ao alocar pods em nós com memória insuficiente.

```bash
$ sudo swapoff -a
$ sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab   # Comenta a linha da SWAP no arquivo /etc/fstab para que ela não seja ativada após o reboot
$ sudo systemctl daemon-reload # Para as alterações fazerem efeito
$ free -h # Verifique com ...
```

### Carregando módulos necessários pro Kernel

> Os módulos `overlay` e `br_netfilter` são essenciais para que o Kubernetes funcione corretamente com redes em containers. O seguinte comando vai basicamente escrever no arquivo `conteinerd.conf` o nome dos módulos para serem carregados ao iniciar a sessão.
>
> Você pode verificar se já existem esses módulos com `lsmod | grep overlay` e `lsmod | grep br_netfilter`. Se retornar algo é que os modulos já estão configurados. Caso contrário, basta executar:

```bash
$ sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay             
br_netfilter
EOF
```

```bash
$ modprobe overlay  # Carrega imediatamente os modulos ao kernel
$ modprobe br_netfilter
```

> Agora vamos tornar isso perene no boot:

```bash
$ sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

> ... e ativar:

```bash
$ sudo sysctl --system
* Aplicando /usr/lib/sysctl.d/50-pid-max.conf ...
* Aplicando /usr/lib/sysctl.d/99-protect-links.conf ...
* Aplicando /etc/sysctl.d/99-sysctl.conf ...
* Aplicando /etc/sysctl.d/kubernetes.conf ...
* Aplicando /etc/sysctl.conf ...
kernel.pid_max = 4194304
fs.protected_fifos = 1
fs.protected_hardlinks = 1
fs.protected_regular = 2
fs.protected_symlinks = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
```

#### Sobre os módulos

- O `overlay` realiza a gestão dos sistemas de arquivos (FileSystem) por meio da sobreposição de camadas de cada repositório. É a base para as imagens do Docker ou outro Driver atuante. Sem ele não é possível montar as imagens ou rodar containers.
- O `br_netfilter` permite que o tráfego entre pods seja filtrado e roteado pelas regras do iptables. Sem ele não existe uma rede funcional entre os pods.


## Subindo o Minikube

> Agora vamos levantar o sistema e usar alguns dos comandos básicos. O padrão para iniciar um novo cluster é:

```bash
$ minikube start
😄  minikube v1.36.0 on Debian 12.11 (arm64)
✨  Automatically selected the docker driver

🧯  The requested memory allocation of 1975MiB does not leave room for system overhead (total system memory: 1975MiB). You may face stability issues.
💡  Suggestion: Start minikube with less memory allocated: 'minikube start --memory=1975mb'

📌  Using Docker driver with root privileges
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.47 ...
💾  Downloading Kubernetes v1.33.1 preload ...
    > preloaded-images-k8s-v18-v1...:  327.15 MiB / 327.15 MiB  100.00% 19.16 M
    > gcr.io/k8s-minikube/kicbase...:  463.69 MiB / 463.69 MiB  100.00% 11.30 M
🔥  Creating docker container (CPUs=2, Memory=1975MB) ...
🐳  Preparing Kubernetes v1.33.1 on Docker 28.1.1 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

> Porém, também é possível iniciar o cluster com nodes definidos com o seguinte comando:

```bash
# Criando cluster com nodes
$ minikube start --nodes=2
```

> Agora, vamos fazer alguns testes:

```bash
# Verificar nodes
$ kubectl get nodes
NAME           STATUS   ROLES           AGE    VERSION
minikube       Ready    control-plane   115s   v1.33.1
minikube-m02   Ready    <none>          93s    v1.33.1

# Verificar nodes com mais detalhes
$ kubectl get nodes -o wide
NAME           STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION        CONTAINER-RUNTIME
minikube       Ready    control-plane   2m21s   v1.33.1   192.168.49.2   <none>        Ubuntu 22.04.5 LTS   6.12.41+deb13-arm64   docker://28.1.1
minikube-m02   Ready    <none>          119s    v1.33.1   192.168.49.3   <none>        Ubuntu 22.04.5 LTS   6.12.41+deb13-arm64   docker://28.1.1

$ kubectl get pods
No resources found in default namespace.

$ kubectl get deployment
No resources found in default namespace.

$ kubectl get deployment --all-namespaces
NAMESPACE     NAME      READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   coredns   1/1     1            1           4m30s
```

### Entrando no node

```bash
$ minikube ip
192.168.49.2

$ minikube ssh
docker@minikube:~$ 
```

### Adicionando workers

> Agora vamos criar um cluster com um worker. Para ativarmos nosso cluster, primeiro nós vamos [criar o outro `node`](https://minikube.sigs.k8s.io/docs/commands/node/), caso já não o tenha feito:

```bash
$ minikube node add --worker
😄  Adding node m02 to cluster minikube as [worker]
❗  Cluster was created without any CNI, adding a node to it might cause broken networking.
👍  Starting "minikube-m02" worker node in "minikube" cluster
🚜  Pulling base image v0.0.47 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🐳  Preparing Kubernetes v1.33.1 on Docker 28.1.1 ...
🔎  Verifying Kubernetes components...
🏄  Successfully added m02 to minikube!

$ kubectl get nodes             # Verifique o nome do node criado.
NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   33m   v1.33.1
minikube-m02   Ready    <none>          17s   v1.33.1
```

### DNS resolver dos `hostname`

> Em CADA NÓ, vamos propagar o nome que queremos trabalhar ao arquivo responsável por mapear os ips e seus respectivos hosts: `/etc/hosts`. Fique atendo ao IP dos hosts. Você pode verificar seus ips corretamente com `kubectl get nodes -o wide`.
>
> Assim, ao executar um `cat /etc/hosts` você deve encontrar algo semelhante a isto quando abrir o arquivo:

```bash
127.0.0.1       localhost
127.0.1.1       controller-mo.localdomain       controller-mo

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

> Após verificar o ip do seu node, vamos propagar essa alteração com os seguintes comandos:

```bash
kaeu@controller-mo:~$ nano /etc/hosts
```

> Adicione as seguintes linhas no documento, substituindo com o seu respectivo ip:

```bash
192.168.49.2    k8smaster.facom.local
192.168.49.3    k8sworker1.facom.local
```

> Ao final você terá algo semelhante a isso no master:

```bash
kaeu@controller-mo:~$ cat /etc/hosts
127.0.0.1       localhost
127.0.1.1       controller-mo.localdomain       controller-mo

# Minikube cluster nodes
192.168.49.2    minikube k8smaster.facom.local
192.168.49.3    minikube-m02 k8sworker1.facom.local

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

> Você pode verificar a conectividade com:

```bash
kaeu@controller-mo:~$ ping -c 2 k8smaster.facom.local
PING minikube (192.168.49.2) 56(84) bytes of data.
64 bytes from minikube (192.168.49.2): icmp_seq=1 ttl=64 time=0.080 ms
64 bytes from minikube (192.168.49.2): icmp_seq=2 ttl=64 time=0.046 ms

--- minikube ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1006ms
rtt min/avg/max/mdev = 0.046/0.063/0.080/0.017 ms
```

> Repita o procedimento com os workers.

### Listando clusters existentes

> Você pode listar todos os clusters criados no Minikube com o comando:

```bash

$ minikube profile list
|----------|-----------|---------|--------------|------|---------|--------|-------|----------------|--------------------|
| Profile  | VM Driver | Runtime |      IP      | Port | Version | Status | Nodes | Active Profile | Active Kubecontext |
|----------|-----------|---------|--------------|------|---------|--------|-------|----------------|--------------------|
| minikube | docker    | docker  | 192.168.49.2 | 8443 | v1.33.1 | OK     |     2 | *              | *                  |
|----------|-----------|---------|--------------|------|---------|--------|-------|----------------|--------------------|
```

### Alternando entre clusters

> Para alternar entre clusters, use o comando `minikube profile` seguido do nome do cluster:

```bash
$ minikube profile meu-cluster
```

> Agora, todos os comandos `kubectl` serão executados no cluster selecionado.

### Parando clusters

```bash
$ 
```

### Deletando clusters

```bash
$ minikube delete
🔥  Deleting "minikube" in docker ...
🔥  Deleting container "minikube" ...
🔥  Deleting container "minikube-m02" ...
🔥  Deleting container "minikube-m03" ...
🔥  Removing /home/$USER/.minikube/machines/minikube ...
🔥  Removing /home/$USER/.minikube/machines/minikube-m02 ...
🔥  Removing /home/$USER/.minikube/machines/minikube-m03 ...
💀  Removed all traces of the "minikube" cluster.
```

> Para deletar um cluster específico, use o comando:

```bash
$ minikube delete --profile meu-cluster
🔥  Deleting "meu-cluster" in docker ...
🔥  Removed all traces of the "meu-cluster" cluster.
```

> Isso remove completamente o cluster com o nome especificado. Para mais informações, consulte a [documentação oficial do Minikube](https://minikube.sigs.k8s.io/docs/).

---

- Voltar ao [README.md](../README.md)
