#!/bin/sh

UID=${UID:=1000}
GID=${GID:=1000}
NUT_STATEPATH=${NUT_STATEPATH:="/var/state/ups"}
NUT_ALTPIDPATH=${NUT_ALTPIDPATH:="${NUT_STATEPATH}"}
NUTUSER="nut"
NUTGROUP="nut"
NUTHOME="/nut"

if [ "$(id -u)" != "0" ]; then
    >&2 echo "ERROR: Not running as root. Please run as root, and pass UID and GID."
    >&2 echo "    e.g.: docker run -e UID=\$(id -u) -e GID=\$(id -g) ..."
    exit 120
fi

GROUP_NAME=$(getent group "${GID}" | cut -d: -f1)
if [ "${GROUP_NAME}" = "" ]; then
    addgroup --gid "${GID}" "${NUTGROUP}"
else
    if [ "${GROUP_NAME}" != "${NUTGROUP}" ]; then
        delgroup "${GROUP_NAME}" 2>/dev/null || true
        addgroup --gid "${GID}" "${NUTGROUP}"
    fi
fi

USER_NAME=$(getent passwd "${UID}" | cut -d: -f1)
if [ "${USER_NAME}" = "" ]; then
    useradd -M -s "/bin/false" -d "${NUTHOME}" -u "${UID}" -g "${NUTGROUP}" "${NUTUSER}"
else
    if [ "${USER_NAME}" != "${NUTUSER}" ]; then
        deluser "${USER_NAME}" 2>/dev/null || true
        useradd -M -s "/bin/false" -d "${NUTHOME}" -u "${UID}" -g "${NUTGROUP}" "${NUTUSER}"
    fi
fi

usermod -a -G dialout "${NUTUSER}"

echo "UID=${UID};GID=${GID}"
mkdir -p "${NUT_ALTPIDPATH}"
echo "-1" > "${NUT_ALTPIDPATH}/upsd.pid"

chown -R "${UID}:${GID}" "${NUTHOME}"
chown -R "${UID}:${GID}" "${NUT_STATEPATH}"
chown -R "${UID}:${GID}" "${NUT_ALTPIDPATH}"

printf "Exce: %s\n" "$*"
exec "$@" || { printf "ERROR on startup.\n"; exit; }