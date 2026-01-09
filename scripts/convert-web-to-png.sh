#!/bin/bash

# Diretório base contendo as pastas dos sistemas (ex: roms)
# Ajuste conforme necessário
BASE_DIR="/media/marcoriesco/YODA/images/RIESCADE/roms"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   Conversor WebP -> PNG & Limpeza${NC}"
echo -e "${BLUE}   Base: $BASE_DIR${NC}"
echo -e "${BLUE}==========================================${NC}"

if [ ! -d "$BASE_DIR" ]; then
    echo -e "${RED}Erro: Diretório base '$BASE_DIR' não encontrado.${NC}"
    exit 1
fi

# Detectar conversor
if command -v ffmpeg &> /dev/null; then
    CONVERTER="ffmpeg"
    echo -e "Usando ferramenta: ${GREEN}ffmpeg${NC}"
elif command -v magick &> /dev/null; then
    CONVERTER="magick"
    echo -e "Usando ferramenta: ${GREEN}ImageMagick (magick)${NC}"
elif command -v convert &> /dev/null; then
    CONVERTER="convert"
    echo -e "Usando ferramenta: ${GREEN}ImageMagick (convert)${NC}"
else
    echo -e "${RED}Erro: Não foi encontrado 'ffmpeg' nem 'ImageMagick'. Instale um deles.${NC}"
    exit 1
fi

echo ""

process_system() {
    local system_path="$1"
    local system_name=$(basename "$system_path")
    local img_dir="$system_path/images"
    local ma_dir="$system_path/medium_artwork"

    echo -e "${YELLOW}>> Sistema: $system_name${NC}"

    # 1. Converter WebP em PNG na pasta images
    if [ -d "$img_dir" ]; then
        count_webp=$(find "$img_dir" -type f -name "*.webp" | wc -l)
        
        if [ "$count_webp" -gt 0 ]; then
            echo -e "   Encontrados $count_webp arquivos .webp em images. Convertendo para PNG..."
            
            find "$img_dir" -type f -name "*.webp" | while read -r webp_file; do
                png_file="${webp_file%.*}.png"
                
                # Converter
                if [ "$CONVERTER" == "ffmpeg" ]; then
                    ffmpeg -i "$webp_file" "$png_file" -y -v error < /dev/null
                elif [ "$CONVERTER" == "magick" ]; then
                    magick "$webp_file" "$png_file"
                else
                    convert "$webp_file" "$png_file"
                fi
                
                # Verificar e apagar o original
                if [ $? -eq 0 ] && [ -f "$png_file" ]; then
                    rm "$webp_file"
                    # echo -e "   ${GREEN}✓${NC} Convertido: $(basename "$webp_file")"
                else
                    echo -e "   ${RED}✗ Erro${NC}: $(basename "$webp_file")"
                fi
            done
            echo -e "   ${GREEN}✓ Conversão concluída${NC}"
        else
            echo -e "   (Sem arquivos .webp na pasta images)"
        fi
    fi

    # 2. Apagar pasta medium_artwork
    if [ -d "$ma_dir" ]; then
        echo -n "   Removendo pasta medium_artwork... "
        rm -rf "$ma_dir"
        echo -e "${GREEN}OK${NC}"
    fi
}

# Loop pelos sistemas
for sys in "$BASE_DIR"/*; do
    if [ -d "$sys" ]; then
        process_system "$sys"
    fi
done

echo ""
echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}Processo concluído!${NC}"