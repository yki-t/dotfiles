#!/bin/bash

set -eu
DESCRIPTION='prevent cpu soft lockup'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if [ "$(cat /boot/config-*|grep 'CONFIG_LOCKUP_DETECTOR=y')" = '' ];then
  echo 'Already Set'
  exit 0
fi

FILENAME="$(ls /boot/config-*)"

sudo sed -i.org -e 's/^CONFIG_LOCKUP_DETECTOR=y$/CONFIG_LOCKUP_DETECTOR=n/' $FILENAME

