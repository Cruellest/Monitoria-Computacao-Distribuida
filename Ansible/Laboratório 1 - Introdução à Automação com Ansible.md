Enquanto o Docker e o Compose nos permitem empacotar e executar aplicações de forma isolada e consistente, a tarefa de preparar e gerenciar a infraestrutura subjacente — como instalar pacotes, configurar serviços e garantir o estado dos servidores — ainda é um desafio. Nesta aula, vamos introduzir o **Ansible**, uma poderosa ferramenta de automação que simplifica radicalmente a configuração e o gerenciamento de sistemas.

---

#### **1. O que é o Ansible?**

O Ansible é um motor de automação de TI de código aberto que automatiza o provisionamento de software, o gerenciamento de configuração e a implantação de aplicações. Sua principal característica é a sua arquitetura **agentless** (sem agentes). Diferente de outras ferramentas como Puppet ou Chef, o Ansible não requer a instalação de nenhum software especial (agente) nos nós que ele gerencia. Ele se comunica diretamente com os servidores através de conexões SSH padrão, tornando sua implementação e uso extremamente simples.

---

#### **2. Conceitos Fundamentais do Ansible**

Para trabalhar com o Ansible, precisamos entender alguns termos essenciais:

- **Control Node (Nó de Controle):** A máquina onde o Ansible está instalado e de onde você executa os comandos. Pode ser o seu laptop ou um servidor dedicado.
    
- **Managed Nodes (Nós Gerenciados):** Os servidores ou dispositivos que o Ansible gerencia. O Ansible precisa ter acesso SSH a eles.
    
- **Inventory (Inventário):** Um arquivo de texto (geralmente em formato INI ou YAML) que lista e agrupa os nós gerenciados. É como a "agenda de contatos" do Ansible.
    
- **Playbook:** O coração do Ansible. É um arquivo YAML onde você define uma lista ordenada de tarefas a serem executadas em um grupo de servidores do inventário.
    
- **Task (Tarefa):** Uma única ação que o Ansible executa, como instalar um pacote, iniciar um serviço ou copiar um arquivo.
    
- **Module (Módulo):** Pequenos pedaços de código que o Ansible envia para os nós gerenciados para serem executados. Cada tarefa invoca um módulo. Por exemplo, existe um módulo `apt` para gerenciar pacotes no Debian/Ubuntu e um módulo `service` para gerenciar serviços.
    

---

#### **3. Instalação e Configuração Prática**

Vamos configurar um ambiente básico para executar nosso primeiro comando Ansible.

**Passo 1: Instalar o Ansible no Control Node**

O Ansible é facilmente instalado via gerenciador de pacotes. Em um sistema baseado em Debian/Ubuntu, execute:

```bash
# Atualiza o índice de pacotes e instala o Ansible
sudo apt-get update
sudo apt-get install -y ansible
```

Para verificar se a instalação foi bem-sucedida, cheque a versão:

```bash
ansible --version
```

**Passo 2: Criar um Inventário de Servidores**

O inventário define quais servidores o Ansible irá gerenciar. Crie um diretório para nosso projeto e um arquivo de inventário.

```bash
mkdir ansible-lab && cd ansible-lab
nano hosts
```

Dentro do arquivo `hosts`, adicione o endereço do seu servidor gerenciado. Para este exemplo, vamos assumir que você tem um servidor em `192.168.1.100` e que seu usuário local tem acesso a ele via chave SSH.
```TOML
# Arquivo: hosts

[webservers]
server1 ansible_host=192.168.1.100
```

- `[webservers]`: É um grupo de hosts. Playbooks podem ser direcionados a grupos inteiros.
    
- `server1`: É um apelido para o host.
    
- `ansible_host`: É uma variável que informa ao Ansible o IP ou domínio real a ser conectado.
    

**Passo 3: Testar a Conexão com um Comando Ad-Hoc**

Comandos ad-hoc são úteis para executar tarefas rápidas sem a necessidade de um playbook. Vamos usar o módulo `ping` para verificar se o nosso Control Node consegue se conectar e se comunicar com os Managed Nodes.

```bash
# O -i especifica o arquivo de inventário
# O -m especifica o módulo a ser usado (ping)
# 'all' indica que o comando deve ser executado em todos os hosts do inventário
ansible all -i hosts -m ping
```

Se tudo estiver configurado corretamente, você receberá uma resposta `SUCCESS` com um `"ping": "pong"`, confirmando que a comunicação está funcionando.

---

#### **4. Criando e Executando seu Primeiro Playbook**

Agora, vamos automatizar uma tarefa real: instalar o servidor web Nginx em nosso `server1`.

**Passo 1: Escrever o Playbook**

Crie um arquivo chamado `install_nginx.yml`:

```bash
nano install_nginx.yml
```

Cole o seguinte conteúdo YAML no arquivo:

```YAML
# install_nginx.yml
---
- name: Instalar e configurar o Nginx
  hosts: webservers
  become: yes  # Indica que as tarefas devem ser executadas com privilégios de superusuário (sudo)

  tasks:
    - name: Atualizar o cache do apt
      apt:
        update_cache: yes

    - name: Instalar o Nginx
      apt:
        name: nginx
        state: present
```

**Análise do Playbook:**

- `name`: Uma descrição do que o playbook faz.
    
- `hosts: webservers`: Define que este playbook será executado em todos os servidores do grupo `[webservers]` do nosso inventário.
    
- `become: yes`: Equivalente a usar `sudo`. É necessário para instalar pacotes.
    
- `tasks`: Uma lista de ações a serem executadas.
    
- Cada tarefa tem um `name` (descrição) e chama um `module` (neste caso, o módulo `apt`).
    
- `state: present` garante que o pacote `nginx` esteja instalado. Se já estiver, o Ansible não fará nada.
    

**Passo 2: Executar o Playbook**

Execute o playbook com o seguinte comando:

```bash
ansible-playbook -i hosts install_nginx.yml
```

O Ansible irá se conectar ao `server1`, executar as tarefas e mostrar um resumo (`PLAY RECAP`) no final, indicando o que foi alterado. Após a execução, você pode acessar o IP do `server1` em seu navegador e verá a página de boas-vindas do Nginx.