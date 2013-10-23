set -ex

emerge -avNDu --with-bdeps=y @world "$@"
revdep-rebuild
emerge -av --depclean
revdep-rebuild
