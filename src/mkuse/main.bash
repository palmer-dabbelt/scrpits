echo "USE=\"" > /etc/portage/make.conf
cat /etc/portage/use.db/* | sed 's@$@ \\@' >> /etc/portage/make.conf
echo "\"" >> /etc/portage/make.conf
