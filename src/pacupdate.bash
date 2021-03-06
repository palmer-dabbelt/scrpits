set -ex

# Ensure that my configuration is updated
cd /etc
git pull
cd ~
git pull

# Here's where I actually update everything (including build-time
# dependencies, which is recessary for revdep-rebuild)
emerge -avNDu --with-bdeps=y @world "$@"

# Scan through my system to ensure that everything is in working order
emerge -av @preserved-rebuild
revdep-rebuild

if [[ `which perl-cleaner 2>/dev/null` != "" ]]
then
    perl-cleaner --modules
fi

if [[ `which python-updater 2>/dev/null` != "" ]]
then
    python-updater
fi

if [[ `which haskell-updater 2>/dev/null` != "" ]]
then
    haskell-updater
fi

if [[ `which emacs-updater 2>/dev/null` != "" ]]
then
    emacs-updater
fi

# Remove anything unnecessary that was installed during the update
# process
emerge -av --depclean
