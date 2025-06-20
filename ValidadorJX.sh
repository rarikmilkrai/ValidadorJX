#!/bin/bash

# Script Name: ValidadorJX.sh
# Description: This script will validate Rarik files and provide templates.
# Author: Your Name
# Date: 2023-10-27
# Version: 1.5

# --- Configuration for Testing ---
_SIMULATE_JQ_MISSING=false      # Set to true to test jq missing scenario
_SIMULATE_XMLLINT_MISSING=false # Set to true to test xmllint missing scenario
_SIMULATE_AJV_MISSING=false     # Set to true to test ajv missing scenario
# --- End Configuration for Testing ---

# ANSI Color Codes
CYAN='\033[0;36m' # Using Cyan for the new banner as well
BLUE='\033[0;34m' # Kept if other elements use it, though banner will use CYAN
NC='\033[0m' # No Color

# Exit codes
SUCCESS=0
ERR_SYNTAX=1
ERR_SEMANTIC=2
ERR_FILE_NOT_FOUND=3
ERR_INVALID_CHOICE=4
ERR_MISSING_DEPENDENCY=5

# --- Helper Functions ---

display_banner() {
  echo -e "${CYAN}" # Start Cyan color
  echo -e "********************************************************"
  echo -e "*                                                      *"
  echo -e "*             V A L I D A D O R   J X                  *"
  echo -e "*                                                      *"
  echo -e "********************************************************"
  echo -e "${NC}" # Reset color
  echo # Add a newline for spacing
}

display_main_menu() {
  echo "---------------------------"
  echo "  Validador JX & Ferramentas  "
  echo "---------------------------"
  echo "1. Validar JSON (Sintaxe)"
  echo "2. Validar XML (Sintaxe)"
  echo "3. Validar JSON com Schema"
  echo "4. Validar XML com Schema (XSD)"
  echo "5. Obter Modelo JSON"
  echo "6. Obter Modelo XML"
  echo "7. Ajuda"
  echo "0. Sair"
  echo "---------------------------"
}

get_json_template() {
  echo ""
  echo "Aqui está um modelo JSON que você pode usar:"
  cat <<EOF
{
  "chave": "valor",
  "numero": 123,
  "booleano": true,
  "array": [1, "texto", null],
  "objeto": {
    "propriedade": "interna"
  }
}
EOF
}

get_xml_template() {
  echo ""
  echo "Aqui está um modelo XML que você pode usar:"
  cat <<EOF
<raiz>
  <elemento atributo="valor">Conteúdo</elemento>
  <outroElemento>
    <subElemento>Mais conteúdo</subElemento>
  </outroElemento>
</raiz>
EOF
}

get_json_schema_template() {
    echo ""
    echo "Aqui está um exemplo básico de JSON Schema (Draft 07):"
    cat <<EOF
{
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Exemplo de Schema",
  "description": "Um schema de exemplo para um objeto simples.",
  "type": "object",
  "properties": {
    "id": {
      "description": "Identificador único.",
      "type": "integer"
    },
    "nome": {
      "description": "Nome do item.",
      "type": "string"
    },
    "preco": {
      "type": "number",
      "exclusiveMinimum": 0
    },
    "tags": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "minItems": 1,
      "uniqueItems": true
    }
  },
  "required": ["id", "nome", "preco"]
}
EOF
    echo -e "\nNota: JSON Schemas podem ser muito mais complexos e específicos."
    echo "Consulte a documentação em https://json-schema.org/ para mais detalhes."
}

get_xsd_template() {
    echo ""
    echo "Aqui está um exemplo básico de XSD (XML Schema Definition):"
    cat <<EOF
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xs:element name="nota">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="para" type="xs:string"/>
        <xs:element name="de" type="xs:string"/>
        <xs:element name="titulo" type="xs:string"/>
        <xs:element name="corpo" type="xs:string"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>

</xs:schema>
EOF
    echo -e "\nNota: XSDs podem ser muito mais complexos."
    echo "Consulte a documentação do W3C XML Schema para mais detalhes."
}


display_help() {
  echo ""
  echo "=============== Ajuda: Validador JX & Ferramentas ==============="
  cat <<EOF

Propósito da Ferramenta:
  Esta ferramenta ajuda a validar a sintaxe de arquivos JSON e XML,
  e também a validação contra schemas (JSON Schema e XSD).
  Ela fornece modelos básicos para esses formatos e oferece
  funcionalidades para ajudar na correção e formatação.

Como Usar as Opções do Menu:

1. Validar JSON (Sintaxe):
   - Verifica a sintaxe básica do JSON.
   - Solicita que você cole o conteúdo JSON. Ctrl+D para finalizar.
   - Se válido, pergunta se deseja ver o JSON indentado.
   - Se inválido, exibe o erro do 'jq', tenta destacar o erro (experimental),
     e pergunta se deseja ver um modelo JSON.

2. Validar XML (Sintaxe):
   - Verifica a sintaxe básica do XML.
   - Solicita que você cole o conteúdo XML. Ctrl+D para finalizar.
   - Se válido, pergunta se deseja ver o XML indentado.
   - Se inválido, exibe o erro do 'xmllint' e pergunta se deseja
     ver um modelo XML.

3. Validar JSON com Schema:
   - Valida um arquivo JSON de dados contra um arquivo JSON Schema.
   - Requer 'ajv-cli' instalado (npm install -g ajv-cli).
   - Solicita os caminhos para o arquivo de dados JSON e o arquivo de schema JSON.
   - Informa se o JSON é válido ou não de acordo com o schema.
   - Oferece um modelo de JSON Schema para referência.

4. Validar XML com Schema (XSD):
   - Valida um arquivo XML de dados contra um arquivo XSD (XML Schema Definition).
   - Utiliza 'xmllint' (já uma dependência para validação de sintaxe XML).
   - Solicita os caminhos para o arquivo de dados XML e o arquivo XSD.
   - Informa se o XML é válido ou não de acordo com o XSD.
   - Oferece um modelo de XSD para referência.

5. Obter Modelo JSON:
   - Exibe um exemplo de estrutura JSON bem formatada.

6. Obter Modelo XML:
   - Exibe um exemplo de estrutura XML bem formatada.

7. Ajuda:
   - Exibe esta mensagem de ajuda.

0. Sair:
   - Encerra o script Validador JX.

Dependências:
  - 'jq': Para validação de sintaxe JSON e formatação.
    (Instalação: sudo apt-get install jq)
  - 'xmllint' (do pacote libxml2-utils): Para validação de sintaxe XML, formatação,
    e validação com XSD.
    (Instalação: sudo apt-get install libxml2-utils)
  - 'ajv-cli': Para validação de JSON com Schema.
    (Instalação: npm install -g ajv-cli)

Obrigado por usar o Validador JX!
EOF
  echo "===================================================================="
  echo ""
}

validate_json() {
  if [ "$_SIMULATE_JQ_MISSING" = true ] || ! command -v jq &> /dev/null; then
    echo "jq não está instalado. Por favor, instale jq para usar esta funcionalidade."
    echo "Exemplo de instalação: sudo apt-get install jq"
  else
    echo "Cole o conteúdo JSON e pressione Ctrl+D quando terminar:"
    json_content=$(cat)

    if [ -z "$json_content" ]; then
      echo "Nenhum conteúdo JSON fornecido."
    else
      validation_output=$(echo "$json_content" | jq '.' 2>&1)
      jq_exit_code=$?

      if [ $jq_exit_code -eq 0 ]; then
        echo "JSON válido!"
        read -p "Deseja indentá-lo? (s/n): " indent_choice
        if [[ "$indent_choice" =~ ^[Ss]$ ]]; then
          echo "JSON Indentado:"
          echo "$json_content" | jq '.'
        fi
        return $jq_exit_code
      else
        echo "JSON inválido. Erro:"
        echo "$validation_output"

        read -p "Deseja que eu tente destacar a linha e coluna do erro no seu input? (s/n) (experimental): " highlight_choice
        if [[ "$highlight_choice" =~ ^[Ss]$ ]]; then
          line_info=$(echo "$validation_output" | grep -oE 'line [0-9]+, column [0-9]+')
          if [ -n "$line_info" ]; then
            line_num=$(echo "$line_info" | grep -oE '[0-9]+' | head -1)
            col_num=$(echo "$line_info" | grep -oE '[0-9]+' | tail -1)
            echo "--- Input com destaque (experimental) ---"
            echo "$json_content" | awk -v line="$line_num" -v col="$col_num" '
            NR==line {
              print ">> " $0
              if (col > 0) {
                for (i=1; i<(col+3); i++) printf " ";
                print "^"
              }
            }
            NR!=line { print "   " $0 }'
            echo "-----------------------------------------"
          else
            echo "Não foi possível extrair a linha/coluna do erro para destaque automático."
          fi
        fi
      fi
    fi
  fi
  read -p "Gostaria de um modelo JSON para comparar ou usar como base? (s/n): " template_choice
  if [[ "$template_choice" =~ ^[Ss]$ ]]; then
    get_json_template
  fi
  [ -z "$jq_exit_code" ] && return $ERR_MISSING_DEPENDENCY || return $jq_exit_code
}

validate_xml() {
  if [ "$_SIMULATE_XMLLINT_MISSING" = true ] || ! command -v xmllint &> /dev/null; then
    echo "xmllint não está instalado. Por favor, instale xmllint para usar esta funcionalidade (geralmente parte do pacote libxml2-utils)."
    echo "Exemplo de instalação: sudo apt-get install libxml2-utils"
  else
    echo "Cole o conteúdo XML e pressione Ctrl+D quando terminar:"
    xml_content=$(cat)

    if [ -z "$xml_content" ]; then
      echo "Nenhum conteúdo XML fornecido."
    else
      xml_validation_output=$(echo "$xml_content" | xmllint --noout - 2>&1)
      xmllint_exit_code=$?

      if [ $xmllint_exit_code -eq 0 ]; then
        echo "XML válido!"
        read -p "XML válido! Deseja indentá-lo? (s/n): " indent_choice
        if [[ "$indent_choice" =~ ^[Ss]$ ]]; then
          echo "XML Indentado:"
          echo "$xml_content" | xmllint --format -
        fi
        return $xmllint_exit_code
      else
        echo "XML inválido."
        if [ -n "$xml_validation_output" ]; then
            filtered_errors=$(echo "$xml_validation_output" | grep -v "validates$" | grep -v "^-$")
            if [ -n "$filtered_errors" ]; then
                echo "Erros:"
                echo "$filtered_errors"
            fi
        fi
      fi
    fi
  fi
  read -p "Gostaria de um modelo XML para comparar ou usar como base? (s/n): " template_choice
  if [[ "$template_choice" =~ ^[Ss]$ ]]; then
    get_xml_template
  fi
  [ -z "$xmllint_exit_code" ] && return $ERR_MISSING_DEPENDENCY || return $xmllint_exit_code
}

validate_json_with_schema() {
  if [ "$_SIMULATE_AJV_MISSING" = true ] || ! command -v ajv &> /dev/null; then
    echo -e "\nSentimos muito, mas para validar JSON com schema, você precisa ter o 'ajv-cli' instalado.\nPor favor, instale-o globalmente usando: npm install -g ajv-cli\n"
  else
    echo ""
    read -p "Digite o caminho para o seu arquivo JSON de dados: " data_file_path
    read -p "Digite o caminho para o seu arquivo JSON Schema: " schema_file_path

    if [ ! -f "$data_file_path" ]; then
      echo "Arquivo de dados JSON não encontrado: $data_file_path"
    elif [ ! -f "$schema_file_path" ]; then
      echo "Arquivo de Schema JSON não encontrado: $schema_file_path"
    else
      validation_output=$(ajv validate -s "$schema_file_path" -d "$data_file_path" 2>&1)
      validation_status=$?
      if [ $validation_status -eq 0 ]; then
        if echo "$validation_output" | grep -q "valid"; then
             echo -e "\nJSON válido de acordo com o schema!"
        else
             echo -e "\nJSON inválido de acordo com o schema. Erros:\n$validation_output"
        fi
      else
        echo -e "\nOcorreu um erro ao tentar validar com o ajv."
        echo -e "Possivelmente o schema é inválido ou o ajv não pôde processar os arquivos."
        echo -e "Saída do ajv:\n$validation_output"
      fi
    fi
  fi

  read -p "Deseja ver um modelo de JSON Schema para referência? (s/n): " view_template_choice
  if [[ "$view_template_choice" =~ ^[Ss]$ ]]; then
    get_json_schema_template
  fi
  return $SUCCESS
}

validate_xml_with_xsd() {
  if [ "$_SIMULATE_XMLLINT_MISSING" = true ] || ! command -v xmllint &> /dev/null; then
    echo -e "\n'xmllint' não está instalado, o qual é necessário para esta funcionalidade."
    echo "Por favor, instale o pacote 'libxml2-utils'."
  else
    echo -e "\nEsta funcionalidade usa 'xmllint' para validar o XML contra um schema XSD."
    read -p "Digite o caminho para o seu arquivo XML de dados: " data_file_path
    read -p "Digite o caminho para o seu arquivo XSD (Schema XML): " xsd_file_path

    if [ ! -f "$data_file_path" ]; then
      echo "Arquivo de dados XML não encontrado: $data_file_path"
    elif [ ! -f "$xsd_file_path" ]; then
      echo "Arquivo XSD não encontrado: $xsd_file_path"
    else
      validation_output=$(xmllint --noout --schema "$xsd_file_path" "$data_file_path" 2>&1)
      validation_status=$?

      if [ $validation_status -eq 0 ]; then
        echo -e "\nXML válido de acordo com o Schema XSD!"
      else
        echo -e "\nXML inválido de acordo com o Schema XSD. Erros:\n$validation_output"
      fi
    fi
  fi

  read -p "Deseja ver um modelo de XSD (Schema XML) para referência? (s/n): " view_template_choice
  if [[ "$view_template_choice" =~ ^[Ss]$ ]]; then
    get_xsd_template
  fi
  return $SUCCESS
}


# --- Main Script Logic ---
while true; do
  clear
  display_banner
  display_main_menu
  read -p "Digite sua escolha [0-7]: " choice

  case $choice in
    1)
      validate_json
      ;;
    2)
      validate_xml
      ;;
    3)
      validate_json_with_schema
      ;;
    4)
      validate_xml_with_xsd
      ;;
    5)
      get_json_template
      ;;
    6)
      get_xml_template
      ;;
    7)
      display_help
      ;;
    0)
      echo "Saindo..."
      exit $SUCCESS
      ;;
    *)
      echo "Opção inválida. Por favor, tente novamente."
      ;;
  esac
  echo
  read -p "Pressione Enter para continuar..."
done

# --- Sugestões para Testes Manuais ---
#
# Devido à natureza interativa deste script (menus, leitura de input multilinhas),
# os testes automatizados diretos via pipe simples (ex: echo '...' | ./script.sh)
# não cobrirão todos os fluxos. Testes manuais são recomendados.
#
# Para testar, execute o script: ./ValidadorJX.sh
#
# Cenários de Teste Gerais:
# - Navegar por todas as opções do menu para garantir que as funções corretas são chamadas.
# - Testar a opção "Ajuda" (7) e "Sair" (0).
# - Testar entradas inválidas no menu.
#
# 1. Validar JSON (Sintaxe) (Opção 1):
#    - Cole um JSON válido, ex: {"nome": "Teste", "valor": 100} (Ctrl+D para finalizar)
#      - Verifique "JSON válido!". Responda 's' e 'n' para indentação.
#    - Cole um JSON inválido, ex: {"nome": "Teste", "valor":} (Ctrl+D)
#      - Verifique "JSON inválido." e erro do jq.
#      - Responda 's'/'n' para destaque de erro e modelo.
#    - Teste com input vazio (apenas Ctrl+D).
#    - Teste com _SIMULATE_JQ_MISSING=true.
#
# 2. Validar XML (Sintaxe) (Opção 2):
#    - Cole um XML válido, ex: <teste><item>Olá</item></teste> (Ctrl+D)
#      - Verifique "XML válido!". Responda 's' e 'n' para indentação.
#    - Cole um XML inválido, ex: <teste><item>Olá</item> (Ctrl+D)
#      - Verifique "XML inválido." e erro do xmllint.
#      - Responda 's'/'n' para obter modelo.
#    - Teste com input vazio (apenas Ctrl+D).
#    - Teste com _SIMULATE_XMLLINT_MISSING=true.
#
# 3. Validar JSON com Schema (Opção 3):
#    a. Crie os seguintes arquivos de teste:
#       - test_data.json: {"nome": "John Doe", "idade": 30, "estudante": false}
#       - test_schema.json: {"type": "object", "properties": {"nome": {"type": "string"}, "idade": {"type": "integer", "minimum": 0}, "estudante": {"type": "boolean"}}, "required": ["nome", "idade"]}
#       - test_invalid_data.json: {"nome": "Jane Doe", "idade": "vinte"}
#       - test_invalid_schema.json: {"type": "object", "properties": {"nome": {"type": "strng"}}}
#    b. Teste validação bem-sucedida:
#       - Escolha a opção 3. Forneça o caminho para test_data.json e test_schema.json.
#       - Verifique a mensagem "JSON válido de acordo com o schema!".
#    c. Teste dados inválidos:
#       - Forneça test_invalid_data.json e test_schema.json.
#       - Verifique a mensagem "JSON inválido de acordo com o schema." e os erros.
#    d. Teste schema inválido:
#       - Forneça test_data.json e test_invalid_schema.json.
#       - Verifique a mensagem "Ocorreu um erro ao tentar validar com o ajv..." e a saída do ajv.
#    e. Teste arquivos não existentes para dados e schema.
#    f. Teste com _SIMULATE_AJV_MISSING=true (edite o script).
#    g. Para todos os casos, teste responder 's' e 'n' para "Deseja ver um modelo de JSON Schema?".
#
# 4. Validar XML com Schema (XSD) (Opção 4):
#    a. Crie os seguintes arquivos de teste:
#       - test_data.xml: <pessoa><nome>John Doe</nome><idade>30</idade></pessoa>
#       - test_schema.xsd:
#         <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
#           <xs:element name="pessoa">
#             <xs:complexType>
#               <xs:sequence>
#                 <xs:element name="nome" type="xs:string"/>
#                 <xs:element name="idade" type="xs:integer"/>
#               </xs:sequence>
#             </xs:complexType>
#           </xs:element>
#         </xs:schema>
#       - test_invalid_data.xml: <pessoa><nome>Jane Doe</nome><idade>desconhecida</idade></pessoa>
#       - test_invalid_schema.xsd: <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"><xs:element name="pessoa">...</xs:schem> <!-- Erro de sintaxe -->
#    b. Teste validação bem-sucedida:
#       - Escolha a opção 4. Forneça o caminho para test_data.xml e test_schema.xsd.
#       - Verifique a mensagem "XML válido de acordo com o Schema XSD!".
#    c. Teste dados inválidos:
#       - Forneça test_invalid_data.xml e test_schema.xsd.
#       - Verifique "XML inválido de acordo com o Schema XSD." e os erros.
#    d. Teste schema XSD inválido:
#       - Forneça test_data.xml e test_invalid_schema.xsd.
#       - Verifique "XML inválido de acordo com o Schema XSD." e os erros do xmllint.
#    e. Teste arquivos não existentes para dados XML e XSD.
#    f. Teste com _SIMULATE_XMLLINT_MISSING=true (lembre-se que xmllint é usado aqui).
#    g. Para todos os casos, teste responder 's' e 'n' para "Deseja ver um modelo de XSD?".
#
# 5. Obter Modelo JSON (Opção 5): Verifique se o modelo é exibido.
# 6. Obter Modelo XML (Opção 6): Verifique se o modelo é exibido.
#
# --- Fim das Sugestões para Testes Manuais ---
