#!/bin/bash
# Change this to the directory where you want carts saved:
readonly DOWNLOAD_DIR="C:\Users\Bob\Downloads\Pico8"
#mkdir -p "$DOWNLOAD_DIR"

TMPFILE="lexaloffle-tmp.html"
TMP_TXTFILE="lexaloffle-tmp.txt"
LEXALOFFLE_ID_URL="https://www.lexaloffle.com/bbs/?tid="

main() {
    cmdline "$@"
}

cart_download() {
    local URL="$1"
    URL=$(echo "$URL" | tr -d ' ')
    echo "[INFO] Downloading thread: $URL"
    curl -sL "$URL" -o "$TMPFILE"

    if [[ ! -f "$TMPFILE" ]]; then
        echo "[WARN] Failed to download $URL"
        return
    fi

    local FINAL_FILENAME=$(get_DOWNLOAD_FILENAME)
    local DOWNLOAD_URL=$(get_DOWNLOAD_URL)

    if [[ -z "$DOWNLOAD_URL" ]]; then
        echo "[WARN] No cart found for thread $URL"
    else
        echo "[INFO] Downloading cart: $FINAL_FILENAME"
        curl -sL "$DOWNLOAD_URL" -o "$DOWNLOAD_DIR/$FINAL_FILENAME"
    fi

    rm -f "$TMPFILE"
}

get_DOWNLOAD_FILENAME() {
    local AUTHOR TITLE TID

    AUTHOR=$(grep -oP '<a href="/bbs/\?uid=[0-9]+"><b[^>]*>\K[^<]+' "$TMPFILE" | head -n1)

    TITLE=$(grep -oP '<div style="font-size:16pt;[^"]*">.*?</div>' "$TMPFILE" | head -n1 | sed 's/.*>\(.*\)<.*/\1/')
    
    TID=$(echo "$URL" | grep -oP '[0-9]+$')

    AUTHOR=$(echo "$AUTHOR" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '_')
    TITLE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '_')

    echo "${TITLE}_by_${AUTHOR}_${TID}.p8.png"
}

get_DOWNLOAD_URL() {
    local DL_URL
    DL_URL=$(grep -oP '<a[^>]+href="\K/bbs/cposts/.*?\.p8\.png(?=")' "$TMPFILE" | head -n1)

    if [[ -n "$DL_URL" ]]; then
        echo "https://www.lexaloffle.com$DL_URL"
    fi
}

get_carts_from_file() {
    local FILE="$1"

    grep -oP "\['[0-9]+'.*?\]" "$FILE" > "$TMP_TXTFILE"

    local NUM_CARTRIDGES
    NUM_CARTRIDGES=$(awk -F',' '$17==2 {count++} END{print count+0}' "$TMP_TXTFILE")
    echo "[INFO] Found $NUM_CARTRIDGES cartridge threads in $FILE"

    while read -r LINE; do
        local SUB=$(echo "$LINE" | awk -F',' '{gsub(/ /,""); print $17}')
        if [[ "$SUB" -eq 2 ]]; then
            local TID=$(echo "$LINE" | awk -F',' '{gsub(/ /,""); print $2}')
            local URL="${LEXALOFFLE_ID_URL}${TID}"
            cart_download "$URL"
        fi
    done < "$TMP_TXTFILE"
}

cmdline() {
    while [[ $# -gt 1 ]]; do
        key="$1"
        case $key in
            -p|--page)
                local INDEX_PAGE="$2"
                download_tmp_html_page "$INDEX_PAGE"
                get_carts_from_file "$TMPFILE"
                shift
                ;;
            *)
                ;;
        esac
        shift
    done

    if [[ -n $1 ]]; then
        cart_download "$1"
    fi
}

download_tmp_html_page() {
    local URL="$1"
    curl -sL "$URL" -o "$TMPFILE"
}

main "$@"
