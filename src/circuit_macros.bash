echo "\\documentclass{school-base}"
echo "\\usepackage{pstricks}"
echo "\\usepackage{school-style-math}"
echo "\\usepackage{school-style-units}"

echo "\\paperheight=20in"
echo "\\paperwidth=20in"
echo "\\textwidth = 20in"
echo "\\textheight = 20in"
echo "\\hoffset = -.75in"
echo "\\voffset = -.75in"
echo "\\headsep = .25in"
echo "\\headheight = 14pt"

echo "\\begin{document}"
echo "\\thispagestyle{empty}"
echo "\\pagestyle{empty}"
m4 ~/school/_latex/circuit_macros/libcct.m4 "$1" | dpic -p
echo "\\end{document}"
