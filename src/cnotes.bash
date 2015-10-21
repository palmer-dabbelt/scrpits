today=`date +%Y-%m-%d`
file="${today}.tex"
afile="__all__.tex"

class=$(basename `pwd`)
if [[ "$class" == "notes" ]]
then
    up=$(dirname `pwd`)
    class=$(basename $up)
fi
research=$(basename $(dirname $(dirname `pwd`)))
if [[ "$research" == "research" ]]
then
    class="research"
fi

longdate=`date "+%B %e, %Y"`

# If the notes file exists then don't overwrite it
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

# Finds the first and last notes in the list and uses their dates
start_date=$(cat `find -iname "*.tex" -type f | grep -v "__all__" | sort | head -1` | grep "\\date{" | head -1 | cut -d '{' -f 2 | cut -d '}' -f 1)
end_date=$(cat `find -iname "*.tex" -type f | grep -v "__all__" | sort | tail -1` | grep "\\date{" | head -1 | cut -d '{' -f 2 | cut -d '}' -f 1)

# Creates the file that lists all notes
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

# If there is a configuration file then use it
if test -f ~/.cnotesrc
then
    cat ~/.cnotesrc >> $afile
    echo "" >> $afile
fi

# More header information
cat >>$afile <<EOF
\\begin{document}
\\maketitle
\\makecontents

\\renewcommand{\\maketitle}[1]{}
\\renewcommand{\\documentclass}[1]{}

EOF

# Lists every tex file
for f in $(find -iname "*.tex" ! -wholename "*/.tek_cache/*" -type f | sort)
do
    f=`basename $f`
    if [[ "$f" != "__all__.tex" ]]
    then
	echo "\\input{`echo $f | cut -d . -f 1`.stex}" >> $afile
    fi
done

# Finishes the input file
cat >>$afile <<EOF
\\end{document}
EOF

# If there is a git repository then add these files
if git rev-parse >& /dev/null
then
    git add $file
    git add $afile
fi

# Checks for tek and runs it
if test -e `tek`
then
    tek
fi

# Looks for an editor 
if [[ "$CNOTES_EDITOR" != "" ]]
then
    $CNOTES_EDITOR $file
elif [[ "$VISUAL" != "" ]]
then
    $VISUAL $file
elif [[ "$EDITOR" != "" ]]
then
    $EDITOR $file
else
    echo "Set CNOTES_EDITOR, VISUAL, or EDITOR"
fi

# Runs git add again, this only really matters if it's not a visual editor
if git rev-parse >& /dev/null
then
    git add $file
fi