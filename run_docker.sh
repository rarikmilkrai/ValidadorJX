#!/bin/bash
# Script para executar o Validador JX dentro de um contêiner Docker

IMAGE_NAME="validador-jx"
IMAGE_TAG="latest"
CONTAINER_DATA_PATH="/data" # Diretório dentro do contêiner onde os arquivos do host serão montados

echo "Executando o Validador JX a partir da imagem Docker $IMAGE_NAME:$IMAGE_TAG..."
echo "O diretório atual do host ($(pwd)) será montado em $CONTAINER_DATA_PATH dentro do contêiner."
echo "Quando o Validador JX pedir por caminhos de arquivo (para validação com schema),"
echo "use caminhos relativos a $CONTAINER_DATA_PATH."
echo "Exemplo: se seu arquivo está em $(pwd)/meu_schema.json, dentro do validador use $CONTAINER_DATA_PATH/meu_schema.json"
echo ""

docker run -it --rm \
  -v "$(pwd):$CONTAINER_DATA_PATH" \
  "$IMAGE_NAME:$IMAGE_TAG"

echo ""
echo "Sessão do Validador JX encerrada."
