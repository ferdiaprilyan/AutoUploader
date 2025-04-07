#!/bin/bash
# ------------
# JANGAN DI JUAL BELIKAN
# ------------

PHOTO_MAX_SIZE=$((10 * 1024 * 1024))     # 10MB
VIDEO_MAX_SIZE=$((50 * 1024 * 1024))     # 50MB
DOC_MAX_SIZE=$((2000 * 1024 * 1024))     # 2GB

BOT_TOKEN="BOT_TOKENMU"
CHAT_ID="-100" #ID GROUP TOPIC WAJIB HIDUP
DATA_FILE="/data/data/com.termux/files/home/storage/shared/DCIM/AutoUploader.json"
FOLDER_PATH="/data/data/com.termux/files/home/storage/shared/DCIM/"

[[ ! -f "$DATA_FILE" ]] && echo '{"topics": {}, "sent_files": []}' > "$DATA_FILE"

get_or_create_topic_id() {
    local folder="$1"
    local topic_id

    topic_id=$(jq -r --arg folder "$folder" '.topics[$folder] // empty' "$DATA_FILE")
    if [[ -n "$topic_id" && "$topic_id" != "null" ]]; then
        echo "$topic_id"
        return
    fi

    response=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/createForumTopic" \
        -d "chat_id=$CHAT_ID" \
        -d "name=$folder")

    topic_id=$(echo "$response" | jq -r '.result.message_thread_id')
    if [[ -n "$topic_id" && "$topic_id" != "null" ]]; then
        jq --arg folder "$folder" --arg topic_id "$topic_id" \
            '.topics[$folder] = $topic_id' "$DATA_FILE" > temp.json && mv temp.json "$DATA_FILE"
        echo "$topic_id"
    else
        echo "Gagal membuat topik untuk $folder" >&2
        exit 1
    fi
}

show_progress() {
    local current=$1
    local total=$2
    local folder=$3
    local bar_length=20
    local filled=$((current * bar_length / total))
    local empty=$((bar_length - filled))
    local bar=$(printf "%0.s#" $(seq 1 $filled))
    bar+=$(printf "%0.s-" $(seq 1 $empty))
    echo "[$bar] $current/$total file dikirim ($folder)"
}

send_file() {
    local file="$1"
    local topic_id="$2"
    local folder_name="$3"

    if jq -e --arg file "$file" '.sent_files | index($file)' "$DATA_FILE" >/dev/null; then
        return
    fi

    file_size=$(stat -c%s "$file")

    if [[ "$file" == *.jpg || "$file" == *.png ]]; then
        if [[ "$file_size" -le $PHOTO_MAX_SIZE ]]; then
            file_type="photo"
            api_endpoint="sendPhoto"
        else
            file_type="document"
            api_endpoint="sendDocument"
        fi
    elif [[ "$file" == *.mp4 ]]; then
        if [[ "$file_size" -le $VIDEO_MAX_SIZE ]]; then
            file_type="video"
            api_endpoint="sendVideo"
        else
            file_type="document"
            api_endpoint="sendDocument"
        fi
    else
        echo "Lewati: Format file tidak didukung ($file)."
        return
    fi

    caption=$(basename "$file")
    caption="${caption%.*}"
    escaped_caption=$(echo "$caption" | sed -e 's/[-_*()~`>#+=|{}.!]/\\&/g')
    caption="\`$escaped_caption\`"

    echo "Mengirim: $file sebagai $file_type ($((file_size / 1024)) KB)"

    response=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/$api_endpoint" \
        -F "chat_id=$CHAT_ID" \
        -F "message_thread_id=$topic_id" \
        -F "$file_type=@$file" \
        -F "caption=$caption" \
        -F "parse_mode=MarkdownV2")

    if echo "$response" | jq -e '.ok' >/dev/null; then
        jq --arg file "$file" '.sent_files += [$file] | .sent_files |= unique' "$DATA_FILE" > temp.json && mv temp.json "$DATA_FILE"
        ((current++))
        show_progress "$current" "$total" "$folder_name"
    else
        echo "Gagal mengirim: $file"
        echo "$response"
    fi
}

while true; do
    for folder in "$FOLDER_PATH"/*; do
        if [ -d "$folder" ]; then
            folder_name=$(basename "$folder")
            topic_id=$(get_or_create_topic_id "$folder_name")
            echo "Memproses folder: $folder_name (TOPIC_ID: $topic_id)"

            files=$(find "$folder" -iname "*.jpg" -o -iname "*.png" -o -iname "*.mp4")
            total=$(echo "$files" | wc -w)
            current=0

            for file in $files; do
                if [ -f "$file" ]; then
                    send_file "$file" "$topic_id" "$folder_name"
                fi
            done
        fi
    done

    echo "Menunggu file baru..."
    sleep 5
done