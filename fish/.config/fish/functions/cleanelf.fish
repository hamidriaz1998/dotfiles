function cleanelf
    set dry_run 0
    set interactive 0
    set dir (pwd)

    # Parse flags
    for arg in $argv
        switch $arg
            case --dry-run -n
                set dry_run 1
            case --interactive -i
                set interactive 1
            case '*'
                set dir $arg
        end
    end

    echo "Scanning for ELF executables in $dir ..."

    fd --type f . $dir | while read -l file
        # Must be executable
        if not test -x "$file"
            continue
        end

        # Must actually be ELF
        if not file "$file" | string match -q "*ELF*"
            continue
        end

        if test $dry_run -eq 1
            echo "[DRY RUN] $file"
            continue
        end

        if test $interactive -eq 1
            read -P "Delete $file? [y/N] " confirm
            if test "$confirm" != "y"
                continue
            end
        end

        echo "Removing $file"
        rm "$file"
    end

    echo "Done."
end

