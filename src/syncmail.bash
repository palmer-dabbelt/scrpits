if [[ "$1" == "" ]]
then
    message="(auto) syncmail"
else
    message="$1"
fi

unset should_commit

cd "$(mhpath +)"

git pull --quiet

if [[ "$(git ls-files --others --exclude-standard)" != "" ]]
then
    should_commit="true"
fi
if [[ "$(git diff-files)" != "" ]]
then
    should_commit="true"
fi
if [[ "$(git diff-index --cached HEAD)" != "" ]]
then
    should_commit="true"
fi

if [[ "$should_commit" == "true" ]]
then
    git add .
    git commit -am "$message"
fi

git push --quiet

cd - >& /dev/null
