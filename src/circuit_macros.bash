echo "\\documentclass{school-base}"
echo "\\usepackage{pstricks}"
echo "\\usepackage{school-style-math}"
echo "\\usepackage{school-style-units}"
echo "\\begin{document}"
echo "\\thispagestyle{empty}"
m4 ~/school/_latex/circuit_macros/libcct.m4 "$1" | dpic -p
echo "\\end{document}"
