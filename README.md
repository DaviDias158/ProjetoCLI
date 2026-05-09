# Agenda Elixir CLI

Uma aplicação de terminal para gerenciamento de contatos desenvolvida em **Elixir**. O sistema utiliza persistência de dados em formato JSON e segue os princípios da programação funcional.

---

## Pré-requisitos

Para rodar este projeto, você precisa ter instalado em sua máquina:
* **Erlang/OTP** (versão 24 ou superior)
* **Elixir** (versão 1.12 ou superior)

---

## Como Inicializar

Siga os passos abaixo para preparar e rodar o ambiente:

1.  **Abra o seu terminal** e navegue até a pasta raiz do projeto.
2.  **Baixe as dependências** (necessário apenas na primeira vez):
    ```bash
    mix deps.get
    ```
3.  **Compile o projeto**:
    ```bash
    mix compile
    ```
4.  **Inicie a aplicação**:
    ```bash
    mix run -e "AgendaCli.main([])"
    ```

---

## Comandos e Uso

Após iniciar, você verá o prompt `agenda> `. Digite os comandos conforme os exemplos abaixo:

### 1. Adicionar Contato (`add`)
Cria um novo contato. Todos os campos são obrigatórios.
* **Uso:** `add --name "Nome" --phone "11999998888" --email "email@exemplo.com" --company "Empresa"`
* **Resultado:** Exibe "Contato adicionado!" e gera um ID único baseado no timestamp.

### 2. Listar Todos (`list`)
Exibe uma tabela com todos os contatos salvos.
* **Uso:** `list`
* **Resultado:** Uma tabela formatada com ID, Nome, Telefone, Email e Empresa.

### 3. Buscar Contato (`search`)
Filtra contatos por um campo específico.
* **Uso:** `search --name "David"` ou `search --email "gmail.com"`
* **Resultado:** Lista apenas os contatos que contêm o termo pesquisado.

### 4. Mostrar Detalhes (`show`)
Exibe informações detalhadas de um único contato através do ID.
* **Uso:** `show 1715284920000`
* **Resultado:** Mostra a linha específica do contato na tabela.

### 5. Editar Contato (`edit`)
Atualiza um ou mais campos de um contato existente sem alterar os outros.
* **Uso:** `edit 1715284920000 --phone "85900000000"`
* **Resultado:** Mescla os novos dados ao contato e salva no arquivo.

### 6. Deletar Contato (`del`)
Remove um contato da base de dados permanentemente.
* **Uso:** `del 1715284920000`
* **Resultado:** Exibe "Contato [ID] removido!".

### 7. Sair (`exit`)
Encerra a execução do programa de forma segura.

---

## Arquitetura do Sistema

O projeto foi organizado em módulos distintos para separar responsabilidades, seguindo o padrão de design funcional:

* **`AgendaCli`**: Atua como o **controlador de interface**. Contém o loop principal (recursão de cauda) e o interpretador de comandos (*parser*). Ele recebe a string bruta do usuário e a transforma em dados estruturados.
* **`AgendaCli.Contacts`**: É o núcleo da **lógica de negócio**. Este módulo é composto por funções puras que manipulam a lista de contatos (adicionar, filtrar, editar e remover) sem efeitos colaterais.
* **`AgendaCli.Store`**: Responsável pela **persistência (I/O)**. Gerencia a leitura e escrita no arquivo `contacts.json` utilizando a biblioteca `Jason` para transformar mapas de Elixir em texto JSON e vice-versa.
* **Fluxo de Dados**: O estado da agenda (a lista de contatos) nunca é mutável. A cada comando, uma nova lista é gerada, salva no disco e passada para a próxima iteração do loop via recursão.