No laboratório anterior, instalamos o Nginx com sucesso. Agora, vamos dar o próximo passo: personalizar a configuração do nosso servidor web. Para isso, vamos aprender a copiar arquivos do nosso nó de controle para os servidores gerenciados e a reiniciar serviços apenas quando uma mudança de configuração ocorrer, introduzindo um dos conceitos mais importantes do Ansible: os **Handlers**.

---

#### **1. O que são Handlers?**

Um **Handler** é uma tarefa especial que só é executada quando "notificada" por outra tarefa. A principal utilidade de um handler é otimizar a execução do playbook, evitando ações desnecessárias.

O caso de uso clássico é o reinício de um serviço: você só quer reiniciar o Nginx se o arquivo de configuração dele for realmente alterado. Se o playbook rodar e o arquivo já estiver correto, não há motivo para reiniciar o serviço. Handlers resolvem exatamente isso.

---

#### **2. Módulos Essenciais para Gerenciamento**

Para este laboratório, vamos usar dois novos módulos muito comuns:

- **`copy`**: Copia arquivos do nó de controle para um local específico no nó gerenciado. Ele é **idempotente**, o que significa que só fará a cópia se o arquivo de destino for diferente do arquivo de origem (ou se não existir).
    
- **`service`**: Gerencia o estado de serviços nos nós gerenciados. Permite iniciar, parar, reiniciar e habilitar serviços na inicialização do sistema.
    

---

#### **3. Aprimorando nosso Playbook na Prática**

Vamos modificar nosso playbook anterior para servir uma página `index.html` personalizada e reiniciar o Nginx de forma inteligente.

**Passo 1: Preparar o Arquivo Personalizado**

Dentro do seu diretório `ansible-lab`, crie uma pasta chamada `files` e, dentro dela, um novo arquivo `index.html`.

```bash
# Certifique-se de que está no diretório ansible-lab
mkdir files
echo "<h1>Bem-vindo ao meu site gerenciado pelo Ansible!</h1>" > files/index.html
```

Sua estrutura de projeto agora deve ser:

```
ansible-lab/
├── files/
│   └── index.html
├── hosts
└── install_nginx.yml
```

**Passo 2: Atualizar o Playbook com a Cópia e um Handler**

Edite seu arquivo `install_nginx.yml` para que ele fique assim:

```bash
nano install_nginx.yml
```

Substitua o conteúdo pelo código abaixo:

```yaml
# install_nginx.yml
---
- name: Instalar e configurar o Nginx
  hosts: webservers
  become: yes

  tasks:
    - name: Garantir que o Nginx esteja instalado
      apt:
        name: nginx
        state: present

    - name: Copiar a pagina index.html personalizada
      copy:
        src: files/index.html                     # Arquivo de origem no Control Node
        dest: /var/www/html/index.html            # Caminho de destino no Managed Node
      notify: Reiniciar Nginx                     # Notifica o handler se este arquivo for alterado

  handlers:
    - name: Reiniciar Nginx
      service:
        name: nginx
        state: restarted
```

**Análise do Playbook Aprimorado:**

- **Nova Tarefa `copy`**:
    
    - `src: files/index.html`: Aponta para o arquivo que criamos em nosso nó de controle.
        
    - `dest: /var/www/html/index.html`: Especifica para onde o arquivo deve ser copiado no servidor gerenciado, substituindo a página padrão do Nginx.
        
- **Cláusula `notify: Reiniciar Nginx`**: Esta é a "mágica". Ela diz ao Ansible: "Se esta tarefa de cópia resultar em uma **mudança** (o arquivo foi copiado), então acione o handler chamado `Reiniciar Nginx` no final da execução".
    
- **Bloco `handlers`**: Esta é uma seção especial no mesmo nível de `tasks`.
    
    - `name: Reiniciar Nginx`: O nome deste handler corresponde exatamente ao que foi especificado na cláusula `notify`.
        
    - O handler em si usa o módulo `service` para garantir que o serviço Nginx seja reiniciado (`state: restarted`).
        

---

#### **4. Executando e Verificando a Idempotência**

Agora vem a parte mais importante: observar o comportamento do playbook.

**Passo 1: Primeira Execução**

Execute o playbook como antes:

```bash
ansible-playbook -i hosts install_nginx.yml
```

Observe a saída. Você verá que a tarefa "Copiar a pagina index.html personalizada" terá o status `changed`. No final, na seção `PLAY RECAP`, você verá uma notificação de `RUNNING HANDLER` e a tarefa "Reiniciar Nginx" será executada.

Acesse o IP do seu servidor (`http://192.168.1.100`) no navegador. Você deve ver a sua nova mensagem personalizada.

**Passo 2: Segunda Execução (a Prova da Inteligência)**

Agora, **execute o mesmo comando novamente**, sem alterar nada.

```bash
ansible-playbook -i hosts install_nginx.yml
```

Observe a saída com atenção! Desta vez, a tarefa "Copiar a pagina index.html personalizada" terá o status `ok` (em verde), pois o Ansible verificou que o arquivo de destino já é idêntico ao de origem. Como **não houve mudança**, o handler **não será notificado e não será executado**. O `PLAY RECAP` mostrará `changed=0`.

Isso demonstra o poder e a eficiência do Ansible: ele apenas realiza as ações estritamente necessárias.