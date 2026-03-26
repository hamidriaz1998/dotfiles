function yta
    if test (count $argv) -eq 0
        echo "Usage: yta <youtube-url>"
        return 1
    end

    set base_dir "$HOME/Music/YouTube"

    yt-dlp \
        -f bestaudio \
        -x \
        --audio-format mp3 \
        --audio-quality 0 \
        --embed-thumbnail \
        --convert-thumbnails jpg \
        --add-metadata \
        --parse-metadata "%(uploader)s:%(artist)s" \
        --download-archive "$base_dir/.yta_archive" \
        --no-overwrites \
        --concurrent-fragments 5 \
        --no-playlist-reverse \
        --progress \
        -o "$base_dir/%(artist)s/%(artist)s - %(title)s.%(ext)s" \
        $argv
end
