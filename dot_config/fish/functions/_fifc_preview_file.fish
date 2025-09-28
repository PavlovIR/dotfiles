function _fifc_preview_file -d "Preview the selected file with the right tool depending on its type"
    set -l file_type (_fifc_file_type "$fifc_candidate")
    kitten icat --clear break 2>/dev/null
    switch $file_type
        case txt
            if type -q bat
                bat --color=always $fifc_bat_opts "$fifc_candidate"
            else
                cat "$fifc_candidate"
            end
        case json
            if type -q bat
                bat --color=always -l json $fifc_bat_opts "$fifc_candidate"
            else
                cat "$fifc_candidate"
            end
        case image
            if type -q kitty
                kitten icat --clear --transfer-mode=memory --stdin=no --place="$FZF_PREVIEW_COLUMNS"x"$FZF_PREVIEW_LINES"@20x0 "$fifc_candidate"
            else
                _fifc_preview_file_default "$fifc_candidate"
            end
        case archive
            if type -q 7z
                7z l ""$fifc_candidate"" | tail -n +17 | awk '{ print $6 }'
            else
                _fifc_preview_file_default "$fifc_candidate"
            end
        case binary
            if type -q hexyl
                hexyl $fifc_hexyl_opts "$fifc_candidate"
            else
                _fifc_preview_file_default "$fifc_candidate"
            end

    end
end
