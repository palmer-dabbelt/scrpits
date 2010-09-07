echo "\\begin{verbatim}" > "$2"
cat "$1" >> "$2"
echo "\\end{verbatim}" >> "$2"