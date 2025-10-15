No laboratório anterior, aprendemos a copiar um arquivo estático e a usar handlers para reiniciar o Nginx de forma inteligente. No entanto, em um cenário real, os arquivos de configuração raramente são idênticos entre diferentes ambientes ou servidores. Eles precisam ser adaptáveis.

Nesta aula, vamos introduzir dois conceitos fundamentais para criar automações flexíveis e reutilizáveis: **Variáveis** e o módulo **`template`**. Com eles, poderemos gerar arquivos de configuração dinamicamente a partir de um modelo.

---

#### **1. O Poder das Variáveis**

Variáveis no Ansible permitem que você armazene e reutilize valores, como nomes de usuário, endereços IP, portas ou qualquer string que você precise. Usar variáveis torna os playbooks mais fáceis de ler e manter, pois você pode centralizar os dados que mudam com frequência em um único lugar.

A forma mais simples de definir variáveis é diretamente dentro do playbook, usando a seção `vars`.

---

#### **2. O Módulo `template` e o Motor Jinja2**

O módulo `template` é muito semelhante ao módulo `copy`, mas com uma grande vantagem: antes de enviar o arquivo para o nó gerenciado, ele o processa através do motor de templates **Jinja2**.

Isso permite que você crie arquivos de modelo (templates) que contenham variáveis, expressões e lógicas (como laços e condicionais). O Ansible substitui as variáveis do template pelos valores definidos no playbook, gerando um arquivo final personalizado para cada host. A sintaxe para uma variável em um template Jinja2 é `{{ nome_da_variavel }}`.

---

#### **3. Criando um Playbook Dinâmico na Prática**

Vamos refatorar nosso playbook para usar uma variável e um template para gerar nossa página `index.html` personalizada.

**Passo 1: Criar o Arquivo de Template**

Primeiro, vamos transformar nosso arquivo `index.html` estático em um template dinâmico. A convenção é usar a extensão `.j2` para arquivos de template.

```bash
# Crie o diretório de templates (se não existir)
mkdir -p templates

# Crie o arquivo de template com uma variável dentro
echo "<h1>{{ mensagem_da_pagina }}</h1>" > templates/index.html.j2

# Podemos remover o diretório 'files' antigo para manter o projeto limpo
rm -rf files
```

Nossa estrutura de projeto agora será:

```
ansible-lab/
├── templates/
│   └── index.html.j2
├── hosts
└── install_nginx.yml
```

**Passo 2: Atualizar o Playbook com Variáveis e o Módulo `template`**

Agora, edite o arquivo `install_nginx.yml` para definir e usar a nossa nova variável.

```bash
nano install_nginx.yml
```

Substitua o conteúdo pelo código abaixo:

```yaml
# install_nginx.yml
---
- name: Instalar e configurar o Nginx com Templates
  hosts: webservers
  become: yes

  vars:
    mensagem_da_pagina: "Este site foi configurado dinamicamente com Ansible!"

  tasks:
    - name: Garantir que o Nginx esteja instalado
      apt:
        name: nginx
        state: present

    - name: Gerar a pagina index.html a partir do template
      template:
        src: templates/index.html.j2    # Arquivo de origem (template)
        dest: /var/www/html/index.html  # Arquivo de destino (resultado final)
      notify: Reiniciar Nginx

  handlers:
    - name: Reiniciar Nginx
      service:
        name: nginx
        state: restarted
```

**Análise do Playbook Dinâmico:**

- **Seção `vars`**: Introduzimos esta nova seção para definir nossas variáveis. Aqui, `mensagem_da_pagina` recebe uma string como valor.
    
- **Módulo `template`**: Substituímos o antigo módulo `copy` pelo `template`.
    
    - `src: templates/index.html.j2`: Aponta para o nosso novo arquivo de template.
        
    - O Ansible irá ler este arquivo, encontrar `{{ mensagem_da_pagina }}`, substituí-la pelo valor definido em `vars`, e então enviar o arquivo resultante para o `dest`.
        
- O `notify` e o `handler` continuam funcionando da mesma forma, garantindo que o serviço seja reiniciado se a página `index.html` for alterada.
    

---

#### **4. Executando e Verificando o Resultado**

**Passo 1: Executar o Playbook**

Rode o playbook para aplicar as novas configurações:

```bash
ansible-playbook -i hosts install_nginx.yml
```

A tarefa "Gerar a pagina index.html a partir do template" deve aparecer como `changed`, pois o conteúdo do arquivo no servidor será diferente. Consequentemente, o handler para reiniciar o Nginx será executado.

Acesse o IP do seu servidor (`http://192.168.1.100`) no navegador. Você verá a mensagem que foi definida na variável dentro do seu playbook.

**Passo 2: Testar o Poder das Variáveis**

Agora, a melhor parte. Sem tocar no template, edite apenas o playbook `install_nginx.yml` e altere o valor da variável:

```yaml
# ...
  vars:
    mensagem_da_pagina: "O conteúdo mudou apenas alterando uma variável!"
# ...
```

Salve o arquivo e execute o playbook novamente: `ansible-playbook -i hosts install_nginx.yml`.

O Ansible detectará que o conteúdo resultante do template será diferente do arquivo que está no servidor, marcará a tarefa como `changed` novamente e reiniciará o Nginx. Verifique seu navegador e a nova mensagem estará lá. Isso demonstra como é fácil gerenciar configurações em escala, alterando apenas as variáveis.
