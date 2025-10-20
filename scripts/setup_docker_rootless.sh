#!/bin/bash
# TODO: testar apenas o modo rootless
# ERROR:
# kaeu@saturn:~$ docker run hello-world
# docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: unable to apply cgroup configuration: unable to start unit "docker-e5b8ca81b388818bd409ebefac3e826b6e22b4eb1bcd0896372fc6fbcf059d68.scope" (properties [{Name:Description Value:"libcontainer container e5b8ca81b388818bd409ebefac3e826b6e22b4eb1bcd0896372fc6fbcf059d68"} {Name:Slice Value:"user.slice"} {Name:Delegate Value:true} {Name:PIDs Value:@au [22533]} {Name:MemoryAccounting Value:true} {Name:CPUAccounting Value:true} {Name:IOAccounting Value:true} {Name:TasksAccounting Value:true} {Name:DefaultDependencies Value:false}]): Interactive authentication required.: unknown

# ============== Configura Docker Rootless ==============
echo "[6/8] Configurando ambiente para o modo rootless..."
echo "[6a/8] Instalando dependências para rootless..."
apt-get install -y uidmap

echo "[6b/8] Descobre todos os usuários do grupo sudo..."
USERS=$(getent group sudo | awk -F: '{print $4}' | tr ',' ' ')
if [ -z "$USERS" ]; then
  echo "Nenhum usuário encontrado no grupo sudo."
  exit 1
fi

# Caminho do script rootless
DOCKER_ROOTLESS_SCRIPT=$(which dockerd-rootless-setuptool.sh)

if [ -z "$DOCKER_ROOTLESS_SCRIPT" ]; then
  echo "dockerd-rootless-setuptool.sh não encontrado. Verifique se o Docker CLI está instalado."
  exit 1
fi

# Loop pelos usuários sudo
for USER_NAME in $USERS; do
  echo "Instalando Docker rootless para $USER_NAME..."

  # Instala rootless no contexto do usuário
  su - "$USER_NAME" -c "$DOCKER_ROOTLESS_SCRIPT install"

  echo "[7/8] Configurando variáveis de ambiente para rootless..."

  RC_FILE="/home/$USER_NAME/.bashrc"

  # Adiciona PATH e DOCKER_HOST se não existirem
  grep -qxF 'export PATH=$HOME/bin:$PATH' "$RC_FILE" || echo 'export PATH=$HOME/bin:$PATH' >> "$RC_FILE"
  grep -qxF 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' "$RC_FILE" || echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> "$RC_FILE"

  # Inicia dockerd-rootless.sh no contexto do usuário em background
  su - "$USER_NAME" -c "export PATH=/usr/bin:/sbin:/usr/sbin:\$PATH && nohup dockerd-rootless.sh > \$HOME/dockerd-rootless.log 2>&1 &"

  echo "Configuração concluída para $USER_NAME."
done

echo "=== Docker rootless instalado para todos os usuários do grupo sudo ===>"
