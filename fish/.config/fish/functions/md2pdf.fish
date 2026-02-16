function md2pdf
    # Check if markdown file is provided
    if test (count $argv) -eq 0
        echo "Usage: md2pdf <markdown-file> [output-pdf] [css-file]"
        echo ""
        echo "Examples:"
        echo "  md2pdf README.md                    # Creates README.pdf with auto-detected custom.css"
        echo "  md2pdf README.md report.pdf         # Creates report.pdf with auto-detected custom.css"
        echo "  md2pdf README.md report.pdf style.css  # Uses specific CSS file"
        echo ""
        echo "Note: If css-file is not specified, looks for 'custom.css' in current directory"
        return 1
    end

    set md_file $argv[1]

    # Validate input file exists
    if not test -f $md_file
        echo "Error: Markdown file '$md_file' not found"
        return 1
    end

    # Determine output filename
    if test (count $argv) -ge 2
        set pdf_file $argv[2]
    else
        set pdf_file (basename $md_file .md).pdf
    end

    # Determine CSS file
    set css_file ""
    if test (count $argv) -ge 3
        # CSS file explicitly provided
        set css_file $argv[3]
        if not test -f $css_file
            echo "Error: CSS file '$css_file' not found"
            return 1
        end
        echo "Using specified CSS: $css_file"
    else if test -f custom.css
        # Auto-detect custom.css
        set css_file "custom.css"
        echo "Found custom.css - applying custom styling"
    else
        echo "No CSS file specified or found - using default pandoc styling"
    end

    set html_file (basename $md_file .md).html
    set use_docker_pandoc 0
    set use_docker_wkhtml 0

    # Check if pandoc is available locally
    if not command -v pandoc >/dev/null 2>&1
        echo "pandoc not found locally - will use docker"
        set use_docker_pandoc 1

        # Check if docker is available
        if not command -v docker >/dev/null 2>&1
            echo "Error: Neither pandoc nor docker is available"
            echo "Please install pandoc or docker"
            return 1
        end
    end

    # Check if wkhtmltopdf is available locally
    if not command -v wkhtmltopdf >/dev/null 2>&1
        echo "wkhtmltopdf not found locally - will use docker"
        set use_docker_wkhtml 1

        # Check if docker is available
        if not command -v docker >/dev/null 2>&1
            echo "Error: Neither wkhtmltopdf nor docker is available"
            echo "Please install wkhtmltopdf or docker"
            return 1
        end
    end

    echo "Converting $md_file -> $html_file..."

    # Convert markdown to HTML with embedded resources
    if test -n "$css_file"
        if test $use_docker_pandoc -eq 1
            docker run --rm --volume "$(pwd):/data" --user (id -u):(id -g) \
                pandoc/core /data/$md_file -o /data/$html_file --css=/data/$css_file --embed-resources --standalone
        else
            pandoc $md_file -o $html_file --css=$css_file --embed-resources --standalone
        end
    else
        if test $use_docker_pandoc -eq 1
            docker run --rm --volume "$(pwd):/data" --user (id -u):(id -g) \
                pandoc/core /data/$md_file -o /data/$html_file --embed-resources --standalone
        else
            pandoc $md_file -o $html_file --embed-resources --standalone
        end
    end

    if test $status -ne 0
        echo "Error: Failed to convert markdown to HTML"
        return 1
    end

    echo "Converting $html_file -> $pdf_file..."

    # Convert HTML to PDF
    if test $use_docker_wkhtml -eq 1
        # Use docker wkhtmltopdf
        docker run --rm --volume "$(pwd):/data" --user (id -u):(id -g) \
            surnet/alpine-wkhtmltopdf:3.16.2-0.12.6-full \
            --enable-local-file-access /data/$html_file /data/$pdf_file
    else
        # Use local wkhtmltopdf
        wkhtmltopdf --enable-local-file-access $html_file $pdf_file
    end

    if test $status -ne 0
        echo "Error: Failed to convert HTML to PDF"
        return 1
    end

    # Clean up HTML file
    rm $html_file

    echo "✓ Successfully created: $pdf_file"
    ls -lh $pdf_file
end
