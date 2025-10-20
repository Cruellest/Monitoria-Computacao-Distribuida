#!/bin/bash

# Script para instalar Docker em Linux (Debian/Ubuntu)
# Autor: Kaê
# Uso: ./setup-docker.sh

# Caso qualquer comando falhe, o script será interrompido
set -e

echo "=== Instalando o Docker ===>"

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
  echo "Por favor, execute como root (ex: sudo $0)"
  exit 1
fi

# Atualiza pacotes
echo "[1/8] Atualizando pacotes..."
apt-get update -y
apt-get upgrade -y

# Instala dependências
echo "[2/8] Instalando dependências..."
apt-get install -y \
    ca-certificates \
    curl \
    lsb-release \
    gnupg

# Adiciona chave oficial do Docker
echo "[3/8] Adicionando chave oficial do Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Detecta sistema operacional e define repositório correto
OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2)
OS_CODENAME=$(grep '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2)

if [ "$OS_ID" = "debian" ]; then
  DOCKER_REPO="debian"
else
  DOCKER_REPO="ubuntu"
fi

# Adiciona repositório Docker
echo "[4/8] Adicionando repositório do Docker para $OS_ID..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DOCKER_REPO \
  $OS_CODENAME stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instala Docker
echo "[5/8] Instalando Docker Engine..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Ativa e inicia Docker
echo "[6/8] Ativando serviço do Docker..."
systemctl enable docker
systemctl start docker

echo "=== Docker instalado com sucesso! ==="
docker --version
docker info

echo "Para usar o Docker rootless, abra um novo terminal ou execute: source ~/.bashrc"