#!/bin/bash
# Script para preparar ambiente Minikube no Debian 13 (Pluto)
# Autor: Kaê
# Obs: Máquina com 3.2 GB RAM, swap ativo, 440 GiB disco, Docker já instalado

set -e

# Banners de início e fim
figlet -f smslant "Minikube | Install & Setup" | while IFS= read -r line; do
    echo -e "$(tput bold; tput setaf 3)$line$(tput sgr0)"  # negrito + amarelo
done

echo "[INFO] Atualizando pacotes..."
sudo apt update -y && sudo apt upgrade -y

echo "[INFO] Instalando dependências..."
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release conntrack

echo "[INFO] Instalando kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "[INFO] Verificando versão do kubectl..."
kubectl version --client --output=yaml || true

echo "[INFO] Instalando minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

echo "[INFO] Setando o Docker como o Driver padrão..."
minikube config set driver docker

echo "[INFO] Desativando swap..."
sudo swapoff -a

echo "[INFO] Removendo swap do /etc/fstab para não ativar no boot..."
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab

echo "[INFO] Garantindo que o usuário 'kaeu' esteja no grupo docker..."
sudo usermod -aG docker kaeu

echo "[INFO] Iniciando Minikube com Docker driver..."
# 3.2 GiB RAM ~ 3200 MiB
minikube start --driver=docker --memory=2500 --cpus=2 --disk-size=400g

echo "[INFO] Adicionando alias útil..."
echo 'alias kubectl="minikube kubectl --"' >> ~/.bashrc
source ~/.bashrc

echo "[INFO] Setup concluído!"
echo "Use 'minikube status' para verificar o cluster."

