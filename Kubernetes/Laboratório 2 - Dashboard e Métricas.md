# Dashboard do Minikube e Métricas

## Instalação e configuração das Métricas + Dashboard

```bash
$ minikube addons enable metrics-server
💡  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image registry.k8s.io/metrics-server/metrics-server:v0.7.2
🌟  The 'metrics-server' addon is enabled
```

> e depois:

```bash
$ minikube dashboard
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:37853/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```

## Acessando o Dashboard via Tunnel SSH

> Agora que temos a URL, nos deparamos com outro problema: esse ip de gateway `127.0.0.1` só é acessível pela interface interna de rede da VM `lo`.
>
> Para acessar no navegador da sua máquina física, vamos precisar de dois terminais.

### Terminal 1 | Servindo o Dashboard

> Após executar os [comandos](#instalação-e-configuração-das-métricas--dashboard) para habilitar as métricas e subir o dashboard, vamos recolher o número da porta na qual ele está servindo. Neste caso, temos que a porta é `37853`.

### Terminal 2 | Acesso via SSH

> No terminal da sua máquina (Unix-like), execute:

```bash
$ ssh -L <porta-host>:127.0.0.1:<porta-guest> usuario@<ip-VM>

# No meu caso seria:
$ ssh -L 37853:127.0.0.1:37853 kaeu@192.168.56.3
```

> Você também pode escolher a porta da sua máquina que esteja livre. Basta alterar o <porta-host>, mantendo a porta final <porta-guest> conforme foi entregue pelo minikube.
