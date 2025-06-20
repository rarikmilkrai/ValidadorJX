#!/bin/bash
# Script para construir a imagem Docker para o Validador JX

IMAGE_NAME="validador-jx"
IMAGE_TAG="latest"

echo "Construindo a imagem Docker $IMAGE_NAME:$IMAGE_TAG..."
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

if [ $? -eq 0 ]; then
  echo ""
  echo "Imagem Docker '$IMAGE_NAME:$IMAGE_TAG' construída com sucesso!"
  echo "Para executar, você pode usar o script ./run_docker.sh"
else
  echo ""
  echo "Falha ao construir a imagem Docker."
fi
