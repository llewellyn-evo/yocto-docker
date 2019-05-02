#!/bin/bash

# first check if environment variable be set or not
if [ -z "${USER}" ]; then
  echo "ERROR: We need USER to be set!"; exit 100
fi

if [ -z "${HOST_UID}" ]; then
    echo "ERROR: We need HOST_UID be set" ; exit 100
fi

if [ -z "${HOST_GID}" ]; then
    echo "ERROR: We need HOST_GID be set" ; exit 100
fi

# reset user_?id to either new id or if empty old (still one of above
# might not be set)
USER_UID=${HOST_UID:=$UID}
USER_GID=${HOST_GID:=$GID}

# Create user
groupadd --gid ${USER_GID} ${USER} > /dev/null 2>&1
useradd ${USER} --shell /bin/bash --create-home \
	--uid ${USER_UID} --gid ${USER_GID} > /dev/null 2>&1

echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

chown -R ${USER_UID}:${USER_GID} /home/${USER}
export HOME=/home/$USER

export WORKDIR="$(pwd)"
if [ -f ../sources/oe-init-build-env ]; then
    cd ../sources
    source oe-init-build-env "$WORKDIR" > /dev/null
    echo ENV_SUPATH PATH=$PATH >> /etc/login.defs
    echo ENV_PATH   PATH=$PATH >> /etc/login.defs
fi

# Tuning bas
# enable bash completion
sed -i '/enable bash completion/!b;:z;n;s/^#//;tz' /etc/bash.bashrc

cat >> /etc/bash.bashrc << END

help() {
    make --no-print-directory -C \$WORKDIR/.. help
    printf "\n\nYou can type 'help' to invoke build system help\n\n"
}
END

# switch to current user
if [ $# -gt 0 ]; then
    su -ms /bin/bash "${USER}" -c "$*"
else
    su -ms /bin/bash "${USER}" -c "make --no-print-directory -C $WORKDIR/.. help"
    printf "\n\nYou can type 'help' to invoke build system help\n\n"
    su -ms /bin/bash "${USER}"
fi

