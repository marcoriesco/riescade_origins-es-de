#!/bin/bash

# Script modificado para criar symlinks de mídia de todos os sistemas
# Fonte: /media/marcoriesco/YODA/images/RIESCADE/roms/<sistema>
# Destino: /home/marcoriesco/retrodeck/ES-DE/downloaded_media/<sistema>
#
# Estrutura esperada na origem:
# - images/ (contendo arquivos com sufixos: -thumb, -image, -marquee)
# - videos/ (contendo arquivos com sufixo: -video)
#
# O script remove o sufixo ao criar o link para que o ES-DE reconheça corretamente
# Ex: images/game-thumb.png -> downloaded_media/<sistema>/covers/game.png

ROMS_DIR="/media/marcoriesco/YODA/images/RIESCADE/roms"
DEST_BASE="/home/marcoriesco/retrodeck/ES-DE/downloaded_media"

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "Script: Symlink Mídia (Sem medium_artwork)"
echo "Origem: $ROMS_DIR"
echo "==========================================${NC}"
echo ""

if [ ! -d "$ROMS_DIR" ]; then
    echo -e "${RED}Erro: Diretório de ROMs não encontrado: $ROMS_DIR${NC}"
    exit 1
fi

# Função para criar symlinks
link_files() {
    local src_dir=$1
    local dest_dir=$2
    local pattern=$3
    local suffix=$4
    local type=$5
    
    # Contar arquivos
    count=$(find "$src_dir" -maxdepth 1 -name "$pattern" -type f 2>/dev/null | wc -l)
    
    if [ "$count" -gt 0 ]; then
        echo -e "  Processando $type ($count arquivos)..."
        mkdir -p "$dest_dir"
        
        find "$src_dir" -maxdepth 1 -name "$pattern" -type f 2>/dev/null | while read -r file; do
            # Pega nome base e extensão
            basename=$(basename "$file")
            extension="${basename##*.}"
            filename_no_ext="${basename%.*}"
            
            # Remove o sufixo (ex: -thumb, -image, -marquee, -video)
            # Se o arquivo não tiver o sufixo (por algum erro de padrão), o nome fica igual
            filename_cleaned="${filename_no_ext%-${suffix}}"
            
            # Nome final com extensão
            newname="${filename_cleaned}.${extension}"
            
            # Criar Symlink (ln -sf)
            # -s: simbólico
            # -f: força (sobrescreve se existir)
            if ln -sf "$file" "$dest_dir/$newname" 2>/dev/null; then
               : # Sucesso silencioso
            else
               echo -e "${RED}✗ Erro${NC} $basename → $newname"
            fi
        done
        echo -e "  ${GREEN}✓ $type concluído${NC}"
    elif [ -d "$src_dir" ]; then
        # Se a pasta existe mas não achou arquivos com o padrão
        # Isso ajuda a depurar se os arquivos estão lá mas com nome errado
        echo -e "  ${YELLOW}⚠ $type: pasta existe em '$src_dir' mas sem arquivos no padrão '$pattern'${NC}"
    fi
}

# Iterar sobre todos os diretórios em ROMS_DIR
for system_path in "$ROMS_DIR"/*; do
    if [ ! -d "$system_path" ]; then
        continue
    fi

    system_name=$(basename "$system_path")
    DEST_MEDIA="$DEST_BASE/$system_name"
    
    SOURCE_IMAGES="$system_path/images"
    SOURCE_VIDEOS="$system_path/videos"
    
    # Se não tiver nem pasta de imagens nem de vídeos, pula este diretório
    if [ ! -d "$SOURCE_IMAGES" ] && [ ! -d "$SOURCE_VIDEOS" ]; then
        continue
    fi

    echo -e "${YELLOW}>> Sistema: $system_name ${NC}"

    # Processar Imagens
    if [ -d "$SOURCE_IMAGES" ]; then
        # Covers
        link_files "$SOURCE_IMAGES" "$DEST_MEDIA/covers" "*-thumb.*" "thumb" "Covers"
        # Fanart
        link_files "$SOURCE_IMAGES" "$DEST_MEDIA/fanart" "*-image.*" "image" "Fanart"
        # Marquees (Logos)
        link_files "$SOURCE_IMAGES" "$DEST_MEDIA/marquees" "*-marquee.*" "marquee" "Marquees"
    fi

    # Processar Vídeos
    if [ -d "$SOURCE_VIDEOS" ]; then
        link_files "$SOURCE_VIDEOS" "$DEST_MEDIA/videos" "*-video.*" "video" "Vídeos"
    fi
    
    echo ""
done

echo -e "${BLUE}=========================================="
echo "Processo concluído!"
echo "==========================================${NC}"