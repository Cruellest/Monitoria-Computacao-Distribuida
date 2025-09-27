# Laboratório LXC

> Primeiro vamos instalar o LXC:

```bash
$ su -
$ apt-get install lxc
```

> Feito isso, vamos instanciar um container LXC:

```bash
$ apt install lxc-templates -y
$ lxc-create -n teste -t debian
```

> Ele vai baixar por debootstrap e preparar o ambiente. Agora vamos acessar o container e instalar algum programa.
>
> Primeiro vamos listar os containers existentes:

```bash
$ lxc-ls
teste
```

> Agora vamos iniciar o container:

```bash
# lxc-start -n teste
```

> E em seguida vamos acessar o container:

```bash
# lxc-attach -n teste
root@teste:~#
```

> Notem que já estamos dentro do container. Para sair basta digitar: `exit` ou `CTRL+D`.

---

## Rede do Container

> Percebam também que você consegue pingar o IP do container e foi criada uma interface do tipo **vETH** na sua máquina real:

```bash
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ce:58:e8 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 83706sec preferred_lft 83706sec
    inet6 fe80::a00:27ff:fece:58e8/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:44:95:25 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.101/24 brd 192.168.56.255 scope global dynamic enp0s8
       valid_lft 426sec preferred_lft 426sec
    inet6 fe80::a00:27ff:fe44:9525/64 scope link 
       valid_lft forever preferred_lft forever
4: lxcbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000                          <===== rede para os containers LXC
    link/ether 00:16:3e:00:00:00 brd ff:ff:ff:ff:ff:ff
    inet 10.0.3.1/24 brd 10.0.3.255 scope global lxcbr0
       valid_lft forever preferred_lft forever
    inet6 fe80::216:3eff:fe00:0/64 scope link 
       valid_lft forever preferred_lft forever
6: vethONrrIZ@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master lxcbr0 state UP group default qlen 1000    <===== interface compartilhada com o container
    link/ether fe:e1:9c:59:d3:8d brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::fce1:9cff:fe59:d38d/64 scope link 
       valid_lft forever preferred_lft forever

```

---

## Informações do Container

> Agora vamos mostrar as informações do container:

```bash
$ lxc-info -n teste
```

``` 
Name:           teste
State:          RUNNING
PID:            26205
IP:             10.0.3.19
Link:           vethONrrIZ
 TX bytes:      1.73 KiB
 RX bytes:      2.20 KiB
 Total bytes:   3.93 KiB
```

---

## Monitoramento de Containers

> Para visualizarmos os containers ativos e seu consumo, podemos usar o comando:

```bash
$ lxc-top
Container                   CPU          CPU          CPU                                BlkIO        Mem
Name                       Used          Sys         User                    Total(Read/Write)       Used
teste                      0.00         0.00         0.00 3087018381.88 GiB(3583086992.87 GiB/2779823561.52 GiB)    0.00   
TOTAL 1 of 1               0.00         0.00         0.00 3087018381.88 GiB(3583086992.87 GiB/2779823561.52 GiB)    0.00  
```

---

## Parando Containers

> Agora vamos parar o container e tentar fazer um attach nele:

```bash
$ lxc-stop -n teste
$ lxc-attach -n teste
lxc-attach: teste: ../src/lxc/attach.c: get_attach_context: 406 Connection refused - Failed to get init pid
lxc-attach: teste: ../src/lxc/attach.c: lxc_attach: 1470 Connection refused - Failed to get attach context

$ lxc-top
Container                   CPU          CPU          CPU                                BlkIO        Mem
Name                       Used          Sys         User                    Total(Read/Write)       Used
TOTAL 0 of 0               0.00         0.00         0.00         0.00   (  0.00   /  0.00   )    0.00 
```

> O LXC é bem restrito ao ambiente que você está utilizando e mais simples. 
---

## Verificando Configurações do Kernel

> Agora nós vamos visualizar quais capabilities nosso ambiente tem para utilizar o lxc:

```bash
$ lxc-checkconfig
LXC version 6.0.4
Kernel configuration not found at /proc/config.gz; searching...
Kernel configuration found at /boot/config-6.1.0-23-amd64

--- Namespaces ---
Namespaces: enabled
Utsname namespace: enabled
Ipc namespace: enabled
Pid namespace: enabled
User namespace: enabled
Network namespace: enabled
Namespace limits:
  cgroup: 14895
  ipc: 14895
  mnt: 14895
  net: 14895
  pid: 14895
  time: 14895
  user: 14895
  uts: 14895

--- Control groups ---
Cgroups: enabled
Cgroup namespace: enabled
Cgroup v1 mount points: 
Cgroup v2 mount points: 
 - /sys/fs/cgroup
Cgroup device: enabled
Cgroup sched: enabled
Cgroup cpu account: enabled
Cgroup memory controller: enabled
Cgroup cpuset: enabled

--- Misc ---
Veth pair device: enabled, loaded
Macvlan: enabled, not loaded
Vlan: enabled, not loaded
Bridges: enabled, loaded
Advanced netfilter: enabled, loaded
CONFIG_IP_NF_TARGET_MASQUERADE: enabled, not loaded
CONFIG_IP6_NF_TARGET_MASQUERADE: enabled, not loaded
CONFIG_NETFILTER_XT_TARGET_CHECKSUM: enabled, not loaded
CONFIG_NETFILTER_XT_MATCH_COMMENT: enabled, not loaded
FUSE (for use with lxcfs): enabled, loaded

--- Checkpoint/Restore ---
checkpoint restore: enabled
CONFIG_FHANDLE: enabled
CONFIG_EVENTFD: enabled
CONFIG_EPOLL: enabled
CONFIG_UNIX_DIAG: enabled
CONFIG_INET_DIAG: enabled
CONFIG_PACKET_DIAG: enabled
CONFIG_NETLINK_DIAG: enabled
File capabilities: enabled

Note: Before booting a new kernel, you can check its configuration with:

  CONFIG=/path/to/config /usr/bin/lxc-checkconfig

```

---

## Arquivo de Configuração do Container

> Agora vamos aprofundar nas configurações do container de teste. Vamos visualizar a configuração dele:

```bash
$ cat /var/lib/lxc/teste/config
# Template used to create this container: /usr/share/lxc/templates/lxc-debian
# Parameters passed to the template:
# For additional config options, please look at lxc.container.conf(5)

# Uncomment the following line to support nesting containers:
#lxc.include = /usr/share/lxc/config/nesting.conf
# (Be aware this has security implications)

lxc.net.0.type = veth
lxc.net.0.hwaddr = 00:16:3e:d6:57:df
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.apparmor.profile = generated
lxc.apparmor.allow_nesting = 1
lxc.rootfs.path = dir:/var/lib/lxc/teste/rootfs

# Common configuration
lxc.include = /usr/share/lxc/config/debian.common.conf

# Container specific configuration
lxc.tty.max = 4
lxc.uts.name = teste
lxc.arch = amd64
lxc.pty.max = 1024

```

---

## Configuração de DNS

> DNS settings podem ser configurados editando `/etc/resolv.conf` dentro do container, como em um sistema normal:

```bash
$ cat /etc/resolv.conf
# Generated by dhcpcd from wlp1s0.dhcp, wlp1s0.dhcp6, wlp1s0.ra
# /etc/resolv.conf.head can replace this line
nameserver 181.213.132.2
nameserver 181.213.132.3
nameserver 2804:14d:1:0:181:213:132:2
nameserver 2804:14d:1:0:181:213:132:3
# /etc/resolv.conf.tail can replace this line

```

---
## Configuração de Interfaces Padrão

```bash
$ cat /etc/lxc/default.conf
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up

lxc.apparmor.profile = generated
lxc.apparmor.allow_nesting = 1
```

---
## Inicializando Containers com Systemd

> Para inicializar os containers lxc junto com o systemd do sistema:

```bash
$ systemctl start lxc@teste
$ systemctl status lxc@teste
● lxc@teste.service - LXC Container: teste
     Loaded: loaded (/lib/systemd/system/lxc@.service; disabled; preset: enabled)
     Active: active (running) since Tue 2024-08-27 10:06:13 -04; 1s ago
       Docs: man:lxc-start
             man:lxc
   Main PID: 26938 (lxc-start)
      Tasks: 0 (limit: 4644)
     Memory: 420.0K
        CPU: 297ms
     CGroup: /system.slice/system-lxc.slice/lxc@teste.service
             ‣ 26938 /usr/bin/lxc-start -F -n teste

ago 27 10:06:13 compdist systemd[1]: Started lxc@teste.service - LXC Container: teste.
```

> Se você quiser que ele inicialize junto com o sistema no boot:

```bash
$ systemctl enable lxc@teste
Created symlink '/etc/systemd/system/multi-user.target.wants/lxc@teste.service' → '/usr/lib/systemd/system/lxc@.service'.
```

> Para desativar do boot:

```bash
$ systemctl disable lxc@teste
Removed '/etc/systemd/system/multi-user.target.wants/lxc@teste.service'.
```
---

### Pergunta

> **1. Só é possível executar containers Debian no LXC do Debian?**

```bash
$ ls /usr/share/lxc/templates/
lxc-alpine     lxc-busybox  lxc-debian	  lxc-fedora	     lxc-kali	lxc-openmandriva  lxc-plamo    lxc-slackware   lxc-ubuntu
lxc-altlinux   lxc-centos   lxc-devuan	  lxc-fedora-legacy  lxc-local	lxc-opensuse	  lxc-pld      lxc-sparclinux  lxc-ubuntu-cloud
lxc-archlinux  lxc-cirros   lxc-download  lxc-gentoo	     lxc-oci	lxc-oracle	  lxc-sabayon  lxc-sshd        lxc-voidlinux

```

---

## Download de Templates

> Vamos mandar o sistema baixar os dados de um template. Vocês devem ter notado que o primeiro download para o container do Debian levou um bom tempo, mas para criar um segundo container (façam isso agora), ele vai ser bem rápido.
> Para listar todas as imagens disponíveis para download:

```bash
$ lxc-create -t download -n alpha -- --list
Downloading the image index

---
DIST             RELEASE     ARCH   VARIANT  BUILD         
---
almalinux        10          amd64  default  20250925_23:08
almalinux        10          arm64  default  20250925_23:08
almalinux        8           amd64  default  20250925_23:08
almalinux        8           arm64  default  20250925_23:08
almalinux        9           amd64  default  20250925_23:08
almalinux        9           arm64  default  20250925_23:08
alpine           3.19        amd64  default  20250927_13:00
alpine           3.19        arm64  default  20250927_13:01
alpine           3.19        armhf  default  20250927_13:03
alpine           3.20        amd64  default  20250927_13:00
alpine           3.20        arm64  default  20250927_13:02
alpine           3.20        armhf  default  20250927_13:02
alpine           3.20        riscv64  default  20250927_13:06
alpine           3.21        amd64  default  20250927_13:00
alpine           3.21        arm64  default  20250927_13:02
alpine           3.21        armhf  default  20250927_13:02
alpine           3.21        riscv64  default  20250927_13:03
alpine           3.22        amd64  default  20250927_13:00
alpine           3.22        arm64  default  20250927_13:00
alpine           3.22        armhf  default  20250927_13:03
alpine           3.22        riscv64  default  20250927_13:04
alpine           edge        amd64  default  20250927_13:00
alpine           edge        arm64  default  20250927_13:00
alpine           edge        armhf  default  20250927_13:02
alpine           edge        riscv64  default  20250927_13:07
alt              Sisyphus    amd64  default  20250927_01:43
alt              Sisyphus    arm64  default  20250927_01:43
alt              p11         amd64  default  20250927_01:43
alt              p11         arm64  default  20250927_01:43
amazonlinux      2           amd64  default  20250926_05:09
amazonlinux      2           arm64  default  20250926_05:09
amazonlinux      2023        amd64  default  20250926_05:09
archlinux        current     amd64  default  20250926_19:46
archlinux        current     arm64  default  20250926_19:54
archlinux        current     riscv64  default  20250926_19:46
busybox          1.36.1      amd64  default  20250927_06:00
busybox          1.36.1      arm64  default  20250927_06:00
centos           10-Stream   amd64  default  20250924_07:44
centos           10-Stream   arm64  default  20250921_08:31
centos           9-Stream    amd64  default  20250924_08:35
centos           9-Stream    arm64  default  20250924_08:35
debian           bookworm    amd64  default  20250927_05:24
debian           bookworm    arm64  default  20250927_05:24
debian           bookworm    armhf  default  20250927_05:36
debian           bullseye    amd64  default  20250927_05:24
debian           bullseye    arm64  default  20250927_05:24
debian           bullseye    armhf  default  20250927_05:41
debian           forky       amd64  default  20250927_05:24
debian           forky       arm64  default  20250927_05:24
debian           forky       armhf  default  20250927_05:24
debian           forky       riscv64  default  20250927_05:24
debian           trixie      amd64  default  20250927_05:24
debian           trixie      arm64  default  20250927_05:24
debian           trixie      armhf  default  20250927_05:24
debian           trixie      riscv64  default  20250927_05:24
devuan           chimaera    amd64  default  20250927_11:50
devuan           chimaera    arm64  default  20250927_11:50
devuan           daedalus    amd64  default  20250927_11:50
devuan           daedalus    arm64  default  20250927_11:50
fedora           40          amd64  default  20250926_20:33
fedora           40          arm64  default  20250926_22:23
fedora           41          amd64  default  20250926_20:33
fedora           41          arm64  default  20250926_22:23
fedora           42          amd64  default  20250926_20:33
fedora           42          arm64  default  20250926_22:23
funtoo           next        amd64  default  20250927_16:45
kali             current     amd64  default  20250926_20:05
kali             current     arm64  default  20250926_20:05
mint             ulyana      amd64  default  20250927_08:51
mint             ulyssa      amd64  default  20250927_08:51
mint             uma         amd64  default  20250927_08:51
mint             una         amd64  default  20250927_08:51
mint             vanessa     amd64  default  20250927_08:51
mint             vera        amd64  default  20250927_08:51
mint             victoria    amd64  default  20250927_08:51
mint             virginia    amd64  default  20250927_08:51
mint             wilma       amd64  default  20250927_08:51
nixos            25.05       amd64  default  20250927_01:44
nixos            25.05       arm64  default  20250927_01:48
nixos            unstable    amd64  default  20250927_01:43
nixos            unstable    arm64  default  20250927_01:45
openeuler        20.03       amd64  default  20250925_15:48
openeuler        20.03       arm64  default  20250925_15:48
openeuler        22.03       amd64  default  20250925_15:48
openeuler        22.03       arm64  default  20250925_15:48
openeuler        24.03       amd64  default  20250925_15:48
openeuler        24.03       arm64  default  20250925_15:48
openeuler        25.03       amd64  default  20250925_15:48
openeuler        25.03       arm64  default  20250925_15:48
opensuse         15.5        amd64  default  20250927_04:20
opensuse         15.5        arm64  default  20250927_04:20
opensuse         15.6        amd64  default  20250927_04:20
opensuse         15.6        arm64  default  20250927_04:20
opensuse         tumbleweed  amd64  default  20250927_04:20
opensuse         tumbleweed  arm64  default  20250927_04:20
openwrt          22.03       amd64  default  20250927_11:57
openwrt          22.03       arm64  default  20250927_11:57
openwrt          23.05       amd64  default  20250927_11:57
openwrt          23.05       arm64  default  20250927_11:57
openwrt          24.10       amd64  default  20250927_11:57
openwrt          24.10       arm64  default  20250927_11:57
openwrt          snapshot    amd64  default  20250927_11:57
openwrt          snapshot    arm64  default  20250927_11:57
oracle           7           amd64  default  20250926_07:46
oracle           7           arm64  default  20250926_07:46
oracle           8           amd64  default  20250926_07:46
oracle           8           arm64  default  20250926_07:49
oracle           9           amd64  default  20250926_07:46
oracle           9           arm64  default  20250926_08:09
plamo            8.x         amd64  default  20250927_01:43
rockylinux       10          amd64  default  20250926_02:06
rockylinux       10          arm64  default  20250926_02:06
rockylinux       8           amd64  default  20250926_02:06
rockylinux       8           arm64  default  20250926_02:06
rockylinux       9           amd64  default  20250926_02:06
rockylinux       9           arm64  default  20250926_02:06
slackware        15.0        amd64  default  20250927_01:42
slackware        current     amd64  default  20250927_01:43
springdalelinux  7           amd64  default  20250926_06:38
springdalelinux  8           amd64  default  20250926_06:38
springdalelinux  9           amd64  default  20250926_06:38
ubuntu           jammy       amd64  default  20250927_07:42
ubuntu           jammy       arm64  default  20250927_07:42
ubuntu           jammy       armhf  default  20250927_08:03
ubuntu           jammy       riscv64  default  20250927_08:03
ubuntu           noble       amd64  default  20250927_07:42
ubuntu           noble       arm64  default  20250927_07:42
ubuntu           noble       armhf  default  20250927_07:42
ubuntu           noble       riscv64  default  20250927_08:20
ubuntu           oracular    armhf  default  20250911_08:05
ubuntu           oracular    riscv64  default  20250911_10:08
ubuntu           plucky      amd64  default  20250927_07:42
ubuntu           plucky      arm64  default  20250927_07:42
ubuntu           plucky      armhf  default  20250927_07:42
ubuntu           plucky      riscv64  default  20250927_08:04
voidlinux        current     amd64  default  20250927_17:10
voidlinux        current     arm64  default  20250927_17:48
```

> Exemplo: baixar a imagem do Alpine:

```bash
$ lxc-create -t download -n alpine -- -d alpine -r 3.20 -a amd64
Downloading the image index
Downloading the rootfs
Downloading the metadata
The image cache is now ready
Unpacking the rootfs

---
You just created an Alpinelinux 3.20 x86_64 (20240826_13:00) container.
```
> Isso vai baixar a imagem pronta, ao invés de usar o debootstrap no próprio Debian, por exemplo.

```bash
$ lxc-ls
alpine teste

# e vamos inicializa-lo e conectar nele:

$ lxc-start -n alpine
$ lxc-attach -n alpine

# depois sair
$ exit
```
---

## Snapshots

> Agora vamos trabalhar com snapshots dos containers. Primeiro vamos verificar se o container tem algum snapshot:
> Verificar snapshots:

```bash
$ lxc-snapshot -L -n teste
No snapshots
```

> Criar snapshot:

```bash
$ lxc-stop -n teste
$ lxc-snapshot -n teste
$ lxc-snapshot -L -n teste
snap0 (/var/lib/lxc/teste/snaps) 2025:09:27 16:39:56
$ lxc-snapshot -n teste
root@compdist:~# lxc-snapshot -L -n teste
snap1 (/var/lib/lxc/teste/snaps) 2025:09:27 16:40:32
snap0 (/var/lib/lxc/teste/snaps) 2025:09:27 16:39:56
```

> Restaurar snapshot ou iniciar um container a partir de um snapshot:

```bash
$ lxc-snapshot -n teste -r snap1 -N teste-snap1
$ lxc-ls
alpine      teste       teste-snap1 

# O parâmetro -N da um novo nome para o snapshot restaurado.
```

> Destruir snapshot:

```bash
$ lxc-snapshot -n teste -d snap0
lxc-snapshot -L -n teste
snap1 (/var/lib/lxc/teste/snaps) 2025:09:27 16:40:32
```

> Destruir container:

```bash
$ lxc-destroy teste-snap1
$ lxc-ls
alpine teste  
```

---

## Dispositivos no Container

> Você pode mover dispositivos para dentro do container, como um USB ou placa de vídeo (mas isso foge ao nosso escopo):

```bash
# Cria um dispositivo /dev/video0 no contêiner p1 baseado no dispositivo correspondente do host.
$ lxc-device -n alpine add /dev/video0
# Move a interface eth0 do host para dentro de p1 como eth1.
$ lxc-device -n alpine add eth0 eth1
```

---

## Tipos de Interfaces de Rede

### `empty`

> O tipo de interface vazia inicia o contêiner com apenas uma interface de loopback; se nenhuma outra interface for definida, o contêiner deverá ser isolado da rede do host.

### `phys`

> O tipo de interface phys pode ser usado para dar a um contêiner acesso a uma única interface no sistema host. Ele deve ser usado junto com lxc.net.{i}.link que especifica a interface do host.

```bash 
FILE /var/lib/lxc/{container name}/configPassing eth0 to the container
lxc.net.0.type = phys
lxc.net.0.flags = up
lxc.net.0.link = eth0
```

### `veth`

> O veth ou Virtual Ethernet Pair Device pode ser usado para fazer bridge ou rotear, especificado com lxc.net.{i}.mode, tráfego entre o host e o contêiner usando dispositivos ethernet virtuais. O modo padrão de operação é o modo bridge de rede.

### `bridge` mode

> Quando lxc.net.{i}.veth.mode não for especificado, o modo bridge será usado, o que geralmente espera que um link seja definido para uma interface bridge no sistema host com lxc.net.{i}.link. Se esse link não for definido, a interface veth será criada no contêiner, mas não configurada no host.

```bash 
FILE /var/lib/lxc/{container name}/configDefining a veth device connected to the default lxcbr0 interface
lxc.net.0.type = veth
lxc.net.0.flags = up
lxc.net.0.link = lxcbr0
```

> Nota: O modo bridge pode ser usado com outras interfaces [macvlan](#macvlan) no modo [vepa](#vepa-virtual-ethernet-port-aggregator) se usado com um switch com capacidade para hairpin.

> Definir lxc.net.{i}.macvlan.mode = bridge resulta em uma interface macvlan que só entrega tráfego pela bridge, não permitindo tráfego de saída.

```bash 
FILE /var/lib/lxc/{container name}/configDefining two bridge macvlan interfaces on eth0.100
lxc.net.0.type = macvlan
lxc.net.0.flags = up
lxc.net.0.macvlan.mode = bridge
lxc.net.0.link = eth0
lxc.net.0.macvlan.vlan = 100
lxc.net.0.name = macvlan_bridge0

lxc.net.1.type = macvlan
lxc.net.1.flags = up
lxc.net.1.macvlan.mode = bridge
lxc.net.1.link = eth0
lxc.net.1.macvlan.vlan = 100
lxc.net.1.name = macvlan_bridge1
```

### `router` mode

> Se lxt.net.{i}.veth.mode = router, rotas estáticas são criadas entre os endereços associados ao dispositivo de link do host especificado e a interface veth do contêiner. Para contêineres privilegiados, entradas ARP são proxyadas entre a interface do host e a interface de gateway especificada do contêiner.

```bash
FILE /var/lib/lxc/{container name}/configDefining a routed veth device associated with eth0.
lxc.net.0.type = veth
lxc.net.0.flags = up
lxc.net.0.veth.mode = router
lxc.net.0.link = eth0
```

### `vlan`

> O tipo de interface vlan pode ser usado com uma interface de host especificada com lxc.net.{i}.link e ID de VLAN especificada com lxc.net.{i}.vlan.id. Esse tipo é comparável ao tipo phys, mas somente a VLAN especificada é compartilhada.

```bash 
FILE /var/lib/lxc/{container name}/configDefining a vlan device on VLAN 100, interface eth0
lxc.net.0.type = vlan
lxc.net.0.flags = up
lxc.net.0.link = eth0
lxc.net.0.vlan.id = 100

```

### `macvlan`

> O tipo de interface macvlan pode ser usado para compartilhar uma interface física com o host. Um link deve ser especificado com lxc.net.{i}.link. O modo pode ser configurado com lxc.net.{i}.macvlan.mode onde o modo padrão é o modo privado.

### `private` mode

> Definir lxc.net.{i}.macvlan.mode = private resulta em uma interface macvlan que não pode se comunicar com os dispositivos upper_dev, ou a interface na qual a interface macvlan é baseada.

```bash
FILE /var/lib/lxc/{container name}/configDefining uma interface macvlan privada em eth0.100

lxc.net.0.type = macvlan
lxc.net.0.flags = up
lxc.net.0.link = eth0
lxc.net.0.macvlan.vlan = 100
```

> lxc.net.{i}.macvlan.mode = private é opcional, mas pode ser adicionado para maior clareza.

### `vepa` (Virtual Ethernet Port Aggregator)

> Definir lxc.net.{i}.macvlan.mode = vepa resulta em uma interface macvlan que opera similarmente ao modo privado, mas os pacotes são realmente enviados para o switch, não virtualmente em bridge. Isso permite que diferentes subinterfaces se comuniquem entre si usando outro switch.
>
> *Importante*
> 
> A interface deve ser conectada a um switch que suporte o modo hairpin, permitindo que o tráfego seja enviado de volta pela interface de onde veio.

```bash
FILE /var/lib/lxc/{container name}/configDefining a vepa macvlan interface em eth0.100
lxc.net.0.type = macvlan
lxc.net.0.flags = up
lxc.net.0.macvlan.mode = vepa
lxc.net.0.link = eth0
lxc.net.0.macvlan.vlan = 100
```

### `passthru`

> Somente uma subinterface pode usar lxc.net.{i}.macvlan.mode = bridge, que opera de forma semelhante ao uso do modo phys ou vlan, mas oferece mais isolamento, já que o contêiner não obtém acesso à interface física, mas à interface macvlan associada a ela.

```bash
FILE /var/lib/lxc/{container name}/configUsing eth0.100 in passthru macvlan mode.
lxc.net.0.type = macvlan
lxc.net.0.flags = up
lxc.net.0.macvlan.mode = passthru
lxc.net.0.link = eth0
lxc.net.0.macvlan.vlan = 100
```

---

## Conclusão

> Com isso encerramos nosso laboratório de containers LXC.

---

## Atividades

1. Crie 5 containers, sendo 2 Debian, 1 Ubuntu e 2 Alpine  
2. Instale e acesse via SSH o container criado com um usuário comum  
3. Instale e acesse via SSH o container criado com um par de chaves SSH da sua máquina local  
4. Desative o login por senha do SSH e permita apenas conexão SSH por chaves  
5. Permita conexão remota por chaves para o usuário root  
6. Configure o servidor Nextcloud em um container e, em outro, configure o servidor MySQL, fazendo o sistema funcionar.  
