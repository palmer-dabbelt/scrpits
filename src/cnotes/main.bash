today=`date +%Y-%m-%d`
file="${today}.tex"
afile="__all__.tex"

class=$(basename `pwd`)
if [[ "$class" == "notes" ]]
then
    up=$(dirname `pwd`)
    class=$(basename $up)
fi

longdate=`date "+%B %e, %Y"`

if ! test -f $file
then
    cat >$file <<EOF
\\documentclass{school-${class}-notes}
\\date{$longdate}

\\begin{document}
\\maketitle



\\end{document}
EOF
fi

start_date=$(cat `find -iname "*.tex" -type f | grep -v "__all__" | sort | head -1` | grep "\\date{" | head -1 | cut -d '{' -f 2 | cut -d '}' -f 1)
end_date=$(cat `find -iname "*.tex" -type f | grep -v "__all__" | sort | tail -1` | grep "\\date{" | head -1 | cut -d '{' -f 2 | cut -d '}' -f 1)

cat >$afile <<EOF
\\documentclass{school-${class}-notes}
\\date{${start_date} - ${end_date}}

\\renewcommand{\\topic}[1]{\\section{#1}}
\\renewcommand{\\subtopic}[1]{\\subsection{#1}}
\\renewcommand{\\subsubtopic}[1]{\\subsubsection{#1}}
\\renewcommand{\\subsubsubtopic}[1]{\\paragraph{#1}}
\\makeatletter
\\renewcommand{\\paragraph}{\\@startsection{paragraph}{4}{0ex}%
{-3.25ex plus -1ex minus -0.2ex}%
{1.5ex plus 0.2ex}%
{\\normalfont\\normalsize\\bfseries}}
\\makeatother

EOF

if test -f ~/.cnotesrc
then
    cat ~/.cnotesrc >> $afile
    echo "" >> $afile
fi

cat >>$afile <<EOF
\\documentclass{document}
\\maketitle
\\makecontents

\\renewcommand{\\maketitle}[1]{}
\\renewcommand{\\documentclass}[1]{}

EOF

for f in $(find -iname "*.tex" -type f)
do
    f=`basename $f`
    if [[ "$f" != "__all__.tex" ]]
    then
	echo "\\input{`echo $f | cut -d . -f 1`.stex}" >> $afile
    fi
done

cat >>$afile <<EOF
\\end{document}
EOF

if git rev-parse >& /dev/null
then
    git add $file
    git add $afile
fi

$VISUAL $file >& /dev/null &
