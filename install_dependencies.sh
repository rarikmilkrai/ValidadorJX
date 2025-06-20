#!/bin/bash

echo "-------------------------------------------------------------------"
echo " Script de Instalação de Dependências para o Validador JX"
echo "-------------------------------------------------------------------"
echo "Este script tentará instalar as seguintes dependências:"
echo "  - jq (processador JSON de linha de comando)"
echo "  - libxml2-utils (para xmllint - processador XML)"
echo "  - Node.js e npm (ambiente de execução JavaScript e gerenciador de pacotes)"
echo "  - ajv-cli (validador de JSON Schema, via npm)"
echo "  - Ferramentas auxiliares como curl e build-essential (se necessário)"
echo ""
echo "O script pode precisar de privilégios de superusuário (sudo) para instalar"
echo "pacotes do sistema e o ajv-cli globalmente."
echo ""
read -p "Você deseja continuar com a instalação? (s/N): " confirmation

if [[ ! "$confirmation" =~ ^[Ss]$ ]]; then
    echo "Instalação cancelada pelo usuário."
    exit 0
fi

echo "Iniciando a instalação das dependências..."
echo ""

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Instalação de dependências do sistema
echo "-------------------------------------------------------------------"
echo " Tentando instalar dependências do sistema..."
echo "-------------------------------------------------------------------"
SYSTEM_PACKAGES_INSTALLED=false

if command_exists apt-get; then
    echo "Detectado sistema baseado em Debian/Ubuntu (apt-get)."
    echo "Atualizando listas de pacotes (pode demorar um pouco)..."
    sudo apt-get update -qq
    echo "Instalando jq, libxml2-utils, curl, build-essential..."
    sudo apt-get install -y jq libxml2-utils curl build-essential
    SYSTEM_PACKAGES_INSTALLED=true
elif command_exists dnf; then
    echo "Detectado sistema baseado em Fedora (dnf)."
    echo "Instalando jq, libxml2, curl, make, gcc-c++..."
    sudo dnf install -y jq libxml2-devel curl make gcc-c++ # libxml2-devel geralmente fornece xmllint e headers
    SYSTEM_PACKAGES_INSTALLED=true
elif command_exists yum; then
    echo "Detectado sistema baseado em RHEL/CentOS (yum)."
    echo "Instalando jq, libxml2, curl, make, gcc-c++..."
    sudo yum install -y jq libxml2-devel curl make gcc-c++ # libxml2-devel geralmente fornece xmllint e headers
    SYSTEM_PACKAGES_INSTALLED=true
elif command_exists brew; then
    echo "Detectado macOS com Homebrew."
    echo "Atualizando Homebrew (pode demorar um pouco)..."
    brew update
    echo "Instalando jq, libxml2, node..." # node via brew geralmente inclui npm. curl é nativo.
    brew install jq libxml2 node
    # build-essential não é um pacote brew, equivalentes são instalados com XCode Command Line Tools.
    # Se 'node' do brew não for suficiente, NVM será tentado depois.
    SYSTEM_PACKAGES_INSTALLED=true # Parcialmente, Node/NVM será tratado depois
else
    echo "[AVISO] Gerenciador de pacotes do sistema não reconhecido (apt-get, dnf, yum, brew)."
    echo "Por favor, instale manualmente: jq, libxml2-utils (ou libxml2-devel), curl, e um ambiente de build C++ (como build-essential ou gcc-c++)."
fi

if $SYSTEM_PACKAGES_INSTALLED; then
    echo "Instalação de pacotes base do sistema concluída (ou tentada)."
else
    echo "Não foi possível instalar pacotes base do sistema automaticamente."
    echo "A instalação de Node.js e ajv-cli pode falhar se as dependências de build não estiverem presentes."
fi
echo ""

# Instalação de Node.js e npm via NVM (Node Version Manager)
echo "-------------------------------------------------------------------"
echo " Tentando instalar Node.js e npm via NVM..."
echo "-------------------------------------------------------------------"
NODE_INSTALLED_SUCCESSFULLY=false

# Verificar se curl está instalado, pois é necessário para baixar NVM
if ! command_exists curl; then
    echo "[AVISO] curl não está instalado. Não é possível baixar NVM automaticamente."
    echo "Por favor, instale curl ou instale Node.js e npm manualmente (versão LTS recomendada)."
else
    # Instalar NVM e Node.js
    # Fonte: https://github.com/nvm-sh/nvm#install--update-script
    # Você pode querer fixar uma versão específica do NVM ou do Node LTS no futuro.
    NVM_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh" # Usando uma versão específica do NVM
    NODE_LTS_VERSION="--lts" # Instala a última versão LTS

    echo "Baixando e executando o script de instalação do NVM de $NVM_INSTALL_SCRIPT_URL..."
    # shellcheck disable=SC2091
    curl -o- "$NVM_INSTALL_SCRIPT_URL" | bash

    # O script de instalação do NVM define NVM_DIR e o adiciona ao PATH na sessão atual do script.
    # Para carregar o NVM na sessão atual do script, precisamos carregar nvm.sh
    # A localização de NVM_DIR pode variar, mas o script de instalação do NVM o define.
    # Se NVM_DIR não estiver definido, tente o padrão ~/.nvm
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command_exists nvm; then
        echo "NVM instalado com sucesso."
        echo "Instalando a versão LTS mais recente do Node.js (pode demorar)..."
        nvm install "$NODE_LTS_VERSION"

        # Define a versão LTS instalada como padrão para novas shells
        nvm alias default "$NODE_LTS_VERSION"

        # Usa a versão instalada na sessão atual
        nvm use default

        if command_exists node && command_exists npm; then
            echo "Node.js e npm instalados com sucesso via NVM."
            echo "Node version: $(node -v)"
            echo "npm version: $(npm -v)"
            NODE_INSTALLED_SUCCESSFULLY=true
        else
            echo "[ERRO] Falha ao instalar Node.js/npm via NVM, mesmo após a instalação do NVM."
        fi
    else
        echo "[ERRO] Falha ao instalar NVM."
    fi
fi

if ! $NODE_INSTALLED_SUCCESSFULLY; then
    echo "[AVISO] Não foi possível instalar Node.js e npm automaticamente via NVM."
    echo "Por favor, verifique se o curl está instalado e tente instalar o Node.js (versão LTS) e o npm manualmente."
    echo "Instruções para NVM: https://github.com/nvm-sh/nvm#installing-and-updating"
    echo "Downloads diretos do Node.js: https://nodejs.org/"
    echo "A instalação do ajv-cli pode falhar se o npm não estiver disponível."
fi
echo ""

# Instalação de ajv-cli globalmente via npm
echo "-------------------------------------------------------------------"
echo " Tentando instalar ajv-cli globalmente via npm..."
echo "-------------------------------------------------------------------"
AJV_INSTALLED_SUCCESSFULLY=false

if command_exists npm; then
    echo "npm encontrado. Tentando instalar ajv-cli..."
    # Tenta instalar sem sudo primeiro. Se Node foi instalado via NVM, sudo não é necessário.
    # Se Node foi instalado pelo sistema, o usuário pode precisar executar isto com sudo manualmente se falhar.
    if npm install -g ajv-cli; then
        echo "ajv-cli instalado com sucesso globalmente."
        AJV_INSTALLED_SUCCESSFULLY=true
    else
        echo "[AVISO] Falha ao instalar ajv-cli globalmente com 'npm install -g ajv-cli'."
        echo "Se você vir erros de permissão, pode ser necessário executar o comando com sudo:"
        echo "  sudo npm install -g ajv-cli"
        echo "Ou, se você usou NVM, certifique-se de que o NVM está corretamente carregado em seu shell."
    fi
else
    echo "[AVISO] npm não encontrado. Não é possível instalar ajv-cli."
    echo "Por favor, certifique-se de que Node.js e npm estão instalados e no seu PATH."
fi

if ! $AJV_INSTALLED_SUCCESSFULLY; then
    echo "[AVISO] Não foi possível instalar ajv-cli automaticamente."
    echo "O Validador JX precisará do ajv-cli para a funcionalidade de validação de JSON com Schema."
fi
echo ""

# Verificação final das dependências principais
echo "-------------------------------------------------------------------"
echo " Verificação final das dependências principais:"
echo "-------------------------------------------------------------------"
MISSING_DEPS=0

check_dependency() {
    local cmd_name="$1"
    local purpose="$2"
    if command_exists "$cmd_name"; then
        echo "[OK] $cmd_name encontrado. ($purpose)"
    else
        echo "[ERRO] $cmd_name NÃO encontrado. ($purpose)"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
}

check_dependency "jq" "Processador JSON"
check_dependency "xmllint" "Processador XML/XSD (de libxml2-utils)"
check_dependency "node" "Ambiente de execução JavaScript"
check_dependency "npm" "Gerenciador de pacotes Node"
check_dependency "ajv" "Validador de JSON Schema (ajv-cli)" # 'ajv' é o comando instalado por 'ajv-cli'

echo ""
if [ $MISSING_DEPS -gt 0 ]; then
    echo "[ATENÇÃO] Algumas dependências principais estão faltando. O Validador JX pode não funcionar corretamente."
    echo "Por favor, revise as mensagens de erro acima e tente instalar as dependências manualmente ou corrija os problemas."
else
    echo "Todas as dependências principais parecem estar instaladas!"
    echo "Lembre-se que para o NVM e Node.js fazerem efeito em seu terminal atual,"
    echo "você pode precisar recarregar a configuração do seu shell (ex: 'source ~/.bashrc', 'source ~/.zshrc')"
    echo "ou abrir um novo terminal."
fi

echo ""
echo "Script de instalação de dependências concluído." # Mensagem final atualizada
echo "Lembre-se de tornar este script executável com: chmod +x install_dependencies.sh"
