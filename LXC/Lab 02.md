# Laboratório Incus

> Vamos agora experimentar o uso do **Incus** (versão livre do LXD).

> Agora vamos instalar o Incus para gerenciamento de containers.  
> No Debian 13, ele será nativo, mas no Debian 12 precisamos instalar externamente:  
> [https://github.com/zabbly/incus](https://github.com/zabbly/incus)

---

## Adicionar repositório Zabbly

> Primeiro, baixe o fingerprint do repositório:

```bash
$ mkdir -p /etc/apt/keyrings/
$ curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc
```

> Agora adicione o repositório:

```bash
$ sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-lts-6.0.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/lts-6.0
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'
```

---

## Atualizar pacotes e instalar Incus

```bash
$ apt-get update
$ apt-get install incus
```

---
