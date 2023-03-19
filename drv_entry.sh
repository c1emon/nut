#!/bin/sh

# contains(string, substring)
#
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
contains() { case "$1" in *"$2"*) true ;; *) false ;; esac }

UID=${UID:=1000}
GID=${GID:=1000}
NUT_STATEPATH=${NUT_STATEPATH:="/var/state/ups"}
NUT_ALTPIDPATH=${NUT_ALTPIDPATH:="${NUT_STATEPATH}"}
NUTUSER="nut"
NUTGROUP="nut"
NUTHOME="/nut"

sh -c "/nut/drivers/upsdrvctl -u nut start"
PID=-1
# (%s-%s.pid) huawei-ups2000 huawei
for PID_F in "${NUT_ALTPIDPATH}"/*.pid
do
    if contains "${PID_F}" "/upsd.pid"; then
        continue
    fi
    PID=$(cat "${PID_F}")
    echo "${PID_F}: ${PID}"
    break
done

tail --pid="${PID}" -f /dev/null