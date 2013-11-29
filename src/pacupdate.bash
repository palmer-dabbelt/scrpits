set -ex

cd /etc
git pull
cd

emerge -avNDu --with-bdeps=y @world "$@"
revdep-rebuild
emerge -av --depclean
revdep-rebuild
