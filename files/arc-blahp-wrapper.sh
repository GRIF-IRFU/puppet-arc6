#!/usr/bin/env bash
#
# This wrapper only has 1 goal : make sure any "failedstate" record in an arc .local file is removed before running
# the "real" arc-blah logger and then restored.
#
# Reason is simple : any held/deleted job will not be accounted for (no blah accouting record will be written) even if
#   the job was killed because it used more ressources than allocated, which is not acceptable
#
# blahp logguer is called with such arguments :
#  /usr/libexec/arc/arc-blahp-logger -I %I  -U %u -L %C/job.%I.local -P %C/job.%I.proxy -p /var/log/arc/accounting/blahp.log


# the real blahp tool:
export ARC_LOCATION="/usr"
ARC_BLAHP_LOGER="$ARC_LOCATION/libexec/arc/arc-blahp-logger"

# Parse arguments, because we need to extract the local file path
# we are only interested in the -L param, but need to allow all supported ones :
while getopts "I:U:P:L:c:p:d:" options; do
  case $options in
    L ) localfile=$OPTARG;;
    * )  ;;
  esac
done

if [ -n "$localfile" ]; then
  cp -p $localfile{,.bak}
  sed -i -e '/failedstate=/d' $localfile
  #execute original program, with original arguments
  $ARC_BLAHP_LOGER "$@"
  #restore backup file
  mv -f $localfile{.bak,}
else
  echo "the -L param is mandatory : cannot run"
  exit 2
fi
