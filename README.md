# Validador JX

O Validador JX é uma ferramenta de linha de comando interativa para validar a sintaxe e a estrutura (via schema) de documentos JSON e XML. Ele também oferece funcionalidades de formatação e geração de modelos.

## Funcionalidades

*   Validação de sintaxe JSON e XML.
*   Validação de JSON contra JSON Schema (usando ajv-cli).
*   Validação de XML contra XSD (XML Schema Definition) (usando xmllint).
*   Indentação de JSON e XML.
*   Geração de modelos JSON, XML, JSON Schema e XSD.
*   Interface de menu interativa em português.

## Uso

### Direto (Requer Dependências Instaladas Manualmente)

Se você prefere instalar as dependências manualmente ou se o script de instalação automática abaixo encontrar problemas, aqui está o que você precisa:

1.  Certifique-se de ter as seguintes dependências instaladas em seu sistema:
    *   `bash`
    *   `jq`
    *   `libxml2-utils` (para `xmllint`)
    *   `nodejs` e `npm` (versão LTS recomendada)
    *   `ajv-cli` (instalado globalmente via `npm install -g ajv-cli`)
    *   `curl` (para baixar NVM, se optar por esse método para Node.js)
    *   Ferramentas de compilação C++ (como `build-essential` ou `gcc-c++`, `make` - podem ser necessárias para alguns módulos npm ou para compilar Node.js se não usar NVM/binários)
2.  Clone o repositório (ou baixe o script `ValidadorJX.sh`).
3.  Torne o script principal executável: `chmod +x ValidadorJX.sh`
4.  Execute o script: `./ValidadorJX.sh`

#### Script de Instalação de Dependências (Beta)

Para auxiliar na instalação das dependências listadas acima em sistemas Linux (Debian/Ubuntu, Fedora/RHEL) e macOS (com Homebrew), você pode usar o script `install_dependencies.sh`.

**Nota:** Este script é fornecido como uma conveniência e pode não funcionar em todas as distribuições ou configurações de sistema. Ele tentará usar `sudo` para instalar pacotes de sistema e `npm` globalmente.

1.  Torne o script de instalação executável:
    ```bash
    chmod +x install_dependencies.sh
    ```
2.  Execute o script de instalação:
    ```bash
    ./install_dependencies.sh
    ```
3.  Siga as instruções na tela. Após a execução, verifique a saída para quaisquer erros ou etapas manuais que possam ser necessárias. Pode ser necessário recarregar a configuração do seu shell (ex: `source ~/.bashrc`) ou abrir um novo terminal.

**Ainda recomendado:** Se você encontrar problemas com o script de instalação de dependências ou preferir um ambiente completamente isolado e pré-configurado, o método Docker abaixo é a maneira mais robusta de usar o Validador JX.

### Com Docker (Recomendado para Ambiente Isolado com Dependências)

Esta é a maneira mais simples e recomendada de executar o Validador JX, pois garante que todas as dependências estejam corretamente configuradas em um ambiente isolado.

**Pré-requisitos:**
*   Docker instalado em seu sistema.

**1. Executando a Imagem Pública do Docker Hub (Método Principal):**

   Para executar a versão mais recente do Validador JX diretamente do Docker Hub, utilize o seguinte comando no seu terminal:

   ```bash
   docker run -it --rm -v "$(pwd):/data" rarikmilkrai/oestudantedevops-validadorjx:1.0.0
   ```

   *   Este comando irá automaticamente baixar a imagem `rarikmilkrai/oestudantedevops-validadorjx:1.0.0` (versão 1.0.0) se ela ainda não estiver no seu sistema.
   *   A tag `:latest` também pode estar disponível, apontando para a versão mais recente. Para garantir que você está usando esta versão específica, use a tag `:1.0.0`.
   *   A flag `-it` garante que você possa interagir com o Validador JX.
   *   A flag `--rm` remove o contêiner automaticamente após o uso, mantendo seu sistema limpo.

   **Usando Arquivos Locais com a Versão Docker:**
   O comando acima usa `-v "$(pwd):/data"`. Isso monta o seu diretório atual (de onde você executa o comando) no diretório `/data` dentro do contêiner.
   Quando o Validador JX (dentro do Docker) pedir um caminho para um arquivo de dados ou um arquivo de schema, você deve fornecer o caminho como se estivesse dentro do contêiner, prefixando com `/data/`.

   *   **Exemplo:** Se você tem um arquivo `meu_arquivo.json` no seu diretório atual no host, e o Validador JX pede o "caminho para o seu arquivo JSON de dados", você digitaria: `/data/meu_arquivo.json`.
   *   Da mesma forma para arquivos de schema: `/data/meu_schema.json` ou `/data/meu_schema.xsd`.

**2. Construindo e Executando a Imagem Localmente (Alternativa para Desenvolvimento/Customização):**

   Se você deseja modificar o código ou prefere construir a imagem a partir dos fontes:

   **a. Construir a Imagem Docker Localmente:**
   Navegue até o diretório raiz do projeto (onde o `Dockerfile` está localizado) e execute o script de build:
   ```bash
   chmod +x build_docker.sh
   ./build_docker.sh
   ```
   Isso criará uma imagem Docker local chamada `validador-jx:latest`.

   **b. Executar o Validador JX em um Contêiner Local:**
   Após construir a imagem, você pode executar o Validador JX usando o script de execução:
   ```bash
   chmod +x run_docker.sh
   ./run_docker.sh
   ```
   Este script também monta o diretório atual em `/data` e explica como usá-lo.

## Licença
GNU
