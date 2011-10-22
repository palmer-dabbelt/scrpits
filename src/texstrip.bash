in="$1"
out="$2"

if [[ "$out" == "" ]]
then
	echo "texstrip <in> <out>"
	echo "converts tex files into stex files"
	exit 1
fi

echo "% Created by texstrip, will be overwritten -- do not edit" > $out
cat $in | grep -v "documentclass{" | grep -v "begin{document}" | grep -v "end{document}" | grep -v "usepackage{" >> $out

