# *******************************************************************
# Change this to the directory you want the file to be downloaded to:
readonly DOWNLOAD_DIR="/home/bob/.lexaloffle/pico-8/carts/incoming"

#mkdir -p "$DOWNLOAD_DIR"
# *******************************************************************

# v1.0 - November 12, 2025

TMPFILE="lexaloffle-tmp.html"
TMP_TXTFILE="lexaloffle-tmp.txt"
LEXALOFFLE_ID_URL="https://www.lexaloffle.com/bbs/?tid="

main() {
    cmdline "$@"
}

cart_download() {
    local URL="$1"
    echo "[INFO] Downloading thread: $URL"
    curl -sL "$URL" -o "$TMPFILE"

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

get_DOWNLOAD_URL() {
    local DL_URL=$(grep -oP '<a[^>]+href="\K/bbs/cposts/.*?\.p8\.png' "$TMPFILE" | head -n1)
    if [[ -n "$DL_URL" ]]; then
        echo "https://www.lexaloffle.com$DL_URL"
    fi
}

get_DOWNLOAD_FILENAME() {
    local AUTHOR=$(grep -oP '<a[^>]+href="\?uid=[0-9]+[^>]*>[^<]+' "$TMPFILE" | head -n1 | sed 's/.*>\(.*\)/\1/')
    local TITLE=$(grep -oP '<div style="font-size:16pt;[^"]*">.*?</div>' "$TMPFILE" | head -n1 | sed 's/.*>\(.*\)<.*/\1/')
    local TID=$(echo "$URL" | grep -oP '[0-9]+$')

    AUTHOR=$(echo "$AUTHOR" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '_')
    TITLE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '_')

    echo "${AUTHOR}_${TITLE}_${TID}.p8.png"
}

function get_carts_from_file() {
    local FILE="$1"

    tr '\n' ' ' < "$FILE" | grep -oP '<a href="\?tid=\K[0-9]+' > "$TMP_TXTFILE"

    echo "[INFO] Found $(wc -l < "$TMP_TXTFILE") threads in $FILE"

    while read -r TID; do
        local URL="${LEXALOFFLE_ID_URL}${TID}"
        cart_download "$URL"
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
