#!/usr/bin/env bash
# make_sudo_user.sh
# Minimal: cria usuário de interesse se necessário e adiciona ao grupo sudo (Debian/Ubuntu).
# Uso:
#   sudo bash make_sudo_user.sh
# Para remover manualmente: sudo deluser USERNAME sudo && sudo rm -f /etc/sudoers.d/USERNAME

set -euo pipefail

USERNAME="debian"
SUDOERS_FILE="/etc/sudoers.d/${USERNAME}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Execute este script como root (use sudo)." >&2
  exit 1
fi
echo "[INFO] Script iniciado como root."
# Cria usuário se não existir
if ! id -u "${USERNAME}" >/dev/null 2>&1; then
  echo "Usuário ${USERNAME} não existe — criando..."
  useradd -m -s /bin/bash "${USERNAME}"
  echo "Defina a senha do usuário com: sudo passwd ${USERNAME}"
else
  echo "Usuário ${USERNAME} já existe."
fi

# Adiciona ao grupo sudo
if getent group sudo >/dev/null 2>&1; then
  echo "Adicionando ${USERNAME} ao grupo sudo..."
  usermod -aG sudo "${USERNAME}"
else
  echo "Grupo 'sudo' não encontrado — criando e adicionando..."
  groupadd sudo
  usermod -aG sudo "${USERNAME}"
fi

# Cria um sudoers.d simples que exige senha (mais seguro)
echo "${USERNAME} ALL=(ALL) ALL" > "${SUDOERS_FILE}.tmp"
chmod 0440 "${SUDOERS_FILE}.tmp"

# Valida com visudo se disponível, senão instala sem validação
if command -v visudo >/dev/null 2>&1; then
  if visudo -cf "${SUDOERS_FILE}.tmp"; then
    mv -f "${SUDOERS_FILE}.tmp" "${SUDOERS_FILE}"
    chmod 0440 "${SUDOERS_FILE}"
    echo "Sudoers instalado em ${SUDOERS_FILE}"
  else
    echo "Erro: visudo reportou problema. Abortando." >&2
    rm -f "${SUDOERS_FILE}.tmp"
    exit 2
  fi
else
  mv -f "${SUDOERS_FILE}.tmp" "${SUDOERS_FILE}"
  chmod 0440 "${SUDOERS_FILE}"
  echo "visudo não encontrado — arquivo copiado sem checagem (considere instalar sudo)."
fi

echo "Pronto. Usuário ${USERNAME} agora tem privilégios sudo."
echo "Teste: su - ${USERNAME} -c 'sudo whoami' (responda a senha do usuário)."
