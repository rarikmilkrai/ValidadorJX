# Usar uma imagem base do Ubuntu
FROM ubuntu:latest

# Evitar prompts interativos durante a instalação de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# Variáveis para NVM e Node
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18.17.1

# Instalar dependências do sistema: jq, xmllint (libxml2-utils), curl (para nvm), build-essential (para npm)
RUN apt-get update && apt-get install -y \
    jq \
    libxml2-utils \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instalar NVM (Node Version Manager) e uma versão específica do Node.js
# CORREÇÃO APLICADA AQUI: Criar o diretório NVM_DIR antes de instalar o NVM
RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && nvm cache clear # Boa prática para reduzir o tamanho da imagem final

# Adicionar o diretório bin do Node ao PATH
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Instalar ajv-cli globalmente com npm
RUN npm install -g ajv-cli

# Criar diretório de trabalho
WORKDIR /app

# Copiar o script ValidadorJX.sh para o diretório de trabalho
COPY ValidadorJX.sh .

# Dar permissão de execução ao script
RUN chmod +x ValidadorJX.sh

# Definir o script como ponto de entrada. O contêiner executará este script.
ENTRYPOINT ["./ValidadorJX.sh"]
