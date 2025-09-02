#!/bin/sh

set -e

LOGNAME="provision"
LOGPATH="/root"
TIMESTAMP="$(date +%Y%m%d_%H%M)"


run() {
    echo "Provision log will be written to $LOGPATH/$LOGNAME-$TIMESTAMP.log"
    exec > "$LOGPATH/$LOGNAME-$TIMESTAMP.log" 2>&1
    rke2_pre
}

rke2_pre() {
        
    mkdir /var/log/kube-audit

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
