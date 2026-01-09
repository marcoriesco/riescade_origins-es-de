#!/bin/bash

# Script para converter estrutura medium_artwork para o formato do EmulationStation/ES-DE
# Mapeamento:
# medium_artwork/logo/imagem   => images/imagem-marquee
# medium_artwork/cover/imagem  => images/imagem-thumb
# medium_artwork/fanart/imagem => images/imagem-image
# medium_artwork/video/video   => videos/video-video

# Diretório base contendo as pastas dos sistemas (ex: roms)
BASE_DIR="/media/marcoriesco/YODA/images/RIESCADE/roms"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo "  Conversor de Estrutura de Artwork"
echo "  Base: $BASE_DIR"
echo -e "${BLUE}==========================================${NC}"

if [ ! -d "$BASE_DIR" ]; then
    echo -e "${RED}Erro: Diretório base '$BASE_DIR' não encontrado.${NC}"
    exit 1
fi

process_system() {
    local system_path="$1"
    local system_name=$(basename "$system_path")
    
    local ma_path="$system_path/medium_artwork"
    
    # Se não tiver medium_artwork, pula
    if [ ! -d "$ma_path" ]; then
        return
    fi
    
    echo -e "\n${YELLOW}Processando sistema: $system_name${NC}"
    
    # Criar diretórios de destino dentro do sistema
    local img_dir="$system_path/images"
    local vid_dir="$system_path/videos"
    
    mkdir -p "$img_dir"
    mkdir -p "$vid_dir"
    
    local count_logo=0
    local count_cover=0
    local count_fanart=0
    local count_video=0
    
    # Funcao auxiliar para copiar/renomear
    # $1: origem
    # $2: destino_dir
    # $3: sufixo
    process_files() {
        local src="$1"
        local dst_dir="$2"
        local suffix="$3"
        local counter_var="$4"
        
        if [ -d "$src" ]; then
            find "$src" -type f | while read -r file; do
                filename=$(basename "$file")
                ext="${filename##*.}"
                name="${filename%.*}"
                
                new_name="${name}-${suffix}.${ext}"
                
                # Copiar arquivo (use cp -f para forçar overwrite)
                cp -f "$file" "$dst_dir/$new_name"
                
            done
            # Contar arquivos copiados (aproximação)
            local count=$(find "$src" -type f | wc -l)
            echo "$count"
        else
            echo "0"
        fi
    }

    # Processar Logotipo -> Marquee
    if [ -d "$ma_path/logo" ]; then
        echo -n "  Copiando Logos... "
        count_logo=$(process_files "$ma_path/logo" "$img_dir" "marquee")
        echo -e "${GREEN}$count_logo ok${NC}"
    fi

    # Processar Cover -> Thumb
    if [ -d "$ma_path/cover" ]; then
        echo -n "  Copiando Covers... "
        count_cover=$(process_files "$ma_path/cover" "$img_dir" "thumb")
        echo -e "${GREEN}$count_cover ok${NC}"
    fi

    # Processar Fanart -> Image
    if [ -d "$ma_path/fanart" ]; then
        echo -n "  Copiando Fanarts... "
        count_fanart=$(process_files "$ma_path/fanart" "$img_dir" "image")
        echo -e "${GREEN}$count_fanart ok${NC}"
    fi

    # Processar Video -> Video
    if [ -d "$ma_path/video" ]; then
        echo -n "  Copiando Videos... "
        count_video=$(process_files "$ma_path/video" "$vid_dir" "video")
        echo -e "${GREEN}$count_video ok${NC}"
    fi
}

# Loop pelos sistemas
for sys in "$BASE_DIR"/*; do
    if [ -d "$sys" ]; then
        process_system "$sys"
    fi
done

echo -e "\n${BLUE}Concluído!${NC}"
