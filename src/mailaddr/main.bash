file=$(grep -i "fn:" ~/.pim/contacts/* | grep "$1" | cut -d ':' -f 1)
grep "EMAIL:" "$file" | cut -d ':' -f 2

