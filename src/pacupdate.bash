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
perl-cleaner --modules
python-updater
haskell-updater
emacs-updater

# Remove anything unnecessary that was installed during the update
# process
emerge -av --depclean
