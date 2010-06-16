version=""

for x in $(ls ~/prog/extern/pintool/)
do
	version="$x"
done

~/prog/extern/pintool/$x/pin $@
exit $?

