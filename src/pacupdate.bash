set -ex

emerge -avNDu world "$@"
revdep-rebuild
emerge -av --depclean
revdep-rebuild
