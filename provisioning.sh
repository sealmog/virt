#!/bin/bash

set -e

create_dir() {
    if [ -d "$1" ]; then
        echo "Directory '$1' exists."
    else
        mkdir -p "$1"
    fi
}

rke2_pre() {

ETCRKE2=/etc/rancher/rke2
create_dir $ETCRKE2

KUBEAUDIT=/var/log/kube-audit
create_dir $KUBEAUDIT

cat <<EOF >> /etc/profile.d/rke2.sh
#!/bin/bash
################################################################################
#                                                                              #
#    Set envvars for rke2 tools (crictl, kubectl)                              #
#                                                                              #
################################################################################

# Add /var/lib/rancher/rke2/bin to the path for sh compatible users

if [ -z "${PATH-}" ] ; then
    export PATH=/var/lib/rancher/rke2/bin
elif ! echo "${PATH}" | grep -q /var/lib/rancher/rke2/bin ; then
    export PATH="${PATH}:/var/lib/rancher/rke2/bin"
fi

# Add config for crictl

if ! echo "${CRI_CONFIG_FILE-}" | grep -q /var/lib/rancher/rke2/agent/etc/crictl.yaml ; then
    export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
fi

# Add config for kubectl

if ! echo "${KUBECONFIG-}" | grep -q /etc/rancher/rke2/rke2.yaml ; then
    export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
fi
EOF
}

run() {
    rke2_pre
}

run
