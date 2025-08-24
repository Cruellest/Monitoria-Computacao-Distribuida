## O que é Podman?

Podman é um motor (engine) de contêineres sem daemon (daemonless) e de código aberto para Linux, desenvolvido para facilitar a criação, execução, compartilhamento e busca de aplicações utilizando contêineres e imagens compatíveis com a Open Container Initiative (OCI), provendo uma interface familiar à do Docker.

Observação: embora voltado ao Linux, o Podman também pode ser usado em macOS/Windows por meio de uma VM ou conexão remota.

### Diferenças entre Docker e Podman

Docker e Podman oferecem funcionalidades muito similares; a principal diferença está na arquitetura.

- Docker utiliza um modelo cliente-servidor com um daemon central (`dockerd`).
- Podman opera sem daemon central: cada comando gerencia contêineres diretamente (via `conmon`, `runc`/`crun` e bibliotecas `containers/*`). Opcionalmente, pode expor um serviço com `podman system service`, mas não depende disso para funcionar.

Um daemon é um serviço em segundo plano. Muitos daemons executam como root (especialmente runtimes de contêiner), o que pode ampliar o impacto de uma falha. O Docker historicamente executa com `dockerd` como root, mas também oferece um modo rootless. O Podman, por sua vez, foi concebido com suporte rootless por padrão (via namespaces de usuário).

O Podman integra-se ao `systemd`, permitindo maior integração com o sistema operacional (por exemplo, gerar units e gerenciar contêineres como serviços). Essa integração muitas vezes pode trazer menor tempo de inicialização e melhor integração com o sistema

### Rootless: diferenças estruturais entre Docker e Podman

Embora ambos suportem execução rootless, a arquitetura difere de forma importante.

- Modelo de execução
  - Docker (rootless): mantém a arquitetura cliente-servidor. Um daemon `dockerd` (e o `containerd`) roda como processos do usuário, normalmente lançados via `dockerd-rootless-setuptool.sh` e gerenciados por `systemd --user`. A CLI fala com um socket do usuário. É necessário um serviço em execução para gerenciar contêineres.
  - Podman (rootless): não usa daemon central. Cada comando (`podman run`, `podman stop` etc.) cria/gerencia diretamente processos do contêiner via `conmon` + runtime OCI (`crun` recomendado, ou `runc`). Um serviço opcional (`podman system service`) pode expor uma API compatível com Docker, mas o funcionamento rootless não depende dele.

- Namespaces e mapeamento de IDs
  - Ambos usam user namespaces e exigem faixas `subuid/subgid` com os helpers `newuidmap/newgidmap`.
  - Podman foi concebido “rootless-first” e integra isso na configuração padrão; `crun` oferece suporte maduro a rootless e cgroups v2.

- Rede
  - Docker (rootless): usa `rootlesskit` + `slirp4netns` para rede em modo usuário e encaminhamento de portas. Limitações típicas: portas <1024 não podem ser vinculadas, algumas funções (multicast, hairpin NAT) e ICMP podem ter restrições.
  - Podman (rootless): usa `slirp4netns` ou `pasta` (quando disponível). As limitações são semelhantes. No modo rootful, o Podman usa `netavark/aardvark-dns`, mas no rootless cai para user-mode networking.

- Armazenamento e overlay
  - Docker (rootless): armazena em `~/.local/share/docker` e geralmente usa `fuse-overlayfs`.
  - Podman (rootless): armazena em `~/.local/share/containers` e geralmente usa `fuse-overlayfs` (ou overlay idmap quando suportado pelo kernel).
  - Em ambos, I/O pode ser um pouco mais lento que no modo rootful.

- Cgroups e limites de recursos
  - Ambos dependem de cgroups v2 para limitação de recursos no modo rootless; cgroups v1 têm suporte limitado ou ausente.
  - Podman com `crun` e `systemd --user` costuma ter delegação de cgroups v2 bem integrada; no Docker rootless o suporte existe, mas pode ter mais restrições conforme distro/kernel.

- Integração com systemd
  - Docker (rootless): normalmente você gerencia um serviço `dockerd` por usuário. Não há geração nativa de unit por contêiner.
  - Podman (rootless): pode gerar units nativamente por contêiner/pod (`podman generate systemd`) e integrá-las ao `systemd --user` ou de sistema.

- Compatibilidade de API/CLI e Compose
  - Docker (rootless): expõe a mesma API do Docker; `docker compose` funciona normalmente nesse modo.
  - Podman (rootless): alta compatibilidade de CLI; para Compose, usa-se `podman compose` ou o socket compatível com Docker via `podman system service` (não é idêntico em 100% dos casos).

- Superfície de ataque e escopo
  - Docker (rootless): ainda há um daemon por usuário; um comprometimento desse processo pode afetar todos os contêineres daquele usuário.
  - Podman (rootless): sem daemon central; os processos de cada contêiner são gerenciados por invocação do Podman e pelo `conmon`, reduzindo o ponto único de comprometimento no plano de controle.

### Vantagens da Arquitetura do Podman

- Segurança aprimorada (rootless): executar contêineres como usuário comum reduz o impacto de compromissos. Observação: alguns recursos podem ter limitações em modo rootless.
- Integração com systemd: é possível gerar units (`podman generate systemd`) e controlar contêineres com `systemctl` (iniciar, parar, habilitar no boot).
- Escopo por usuário: cada usuário gerencia seu próprio conjunto de contêineres e imagens isoladamente.
- Compatibilidade com a CLI do Docker: muitos comandos são equivalentes, e é comum usar `alias docker=podman`. Para Docker Compose, utiliza-se `podman compose` ou integrações específicas; não é 100% idêntico ao Docker.

### Ecossistema Modular

Diferente do Docker “tudo-em-um”, o Podman compõe um ecossistema de ferramentas especializadas:

- Buildah: foco na construção de imagens OCI, com controle granular do processo.
- Skopeo: inspeciona, copia, assina e gerencia imagens em registros remotos sem baixar localmente.

Essa abordagem modular oferece flexibilidade para usar apenas as ferramentas necessárias.