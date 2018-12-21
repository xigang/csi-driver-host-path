#!/usr/bin/env bash

# This script captures the steps required to successfully
# deploy the hostpath plugin driver.  This should be considered
# authoritative and all updates for this process should be
# done here and referenced elsewhere.

# The script assumes that kubectl is available on the OS path 
# where it is executed.

K8S_RELEASE=${K8S_RELEASE:-"release-1.13"}
PROVISIONER_RELEASE=${PROVISIONER_RELEASE:-"release-1.0"}
ATTACHER_RELEASE=${ATTACHER_RELEASE:-"release-1.0"}
INSTALL_CRD=${INSTALL_CRD:-"false"}
BASE_DIR=$(dirname "$0")

# apply CSIDriver and CSINodeInfo API objects
if [[ "${INSTALL_CRD}" =~ ^(y|Y|yes|true)$ ]] ; then
    echo "installing CRDs"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/csi-api/${K8S_RELEASE}/pkg/crd/manifests/csidriver.yaml --validate=false
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/csi-api/${K8S_RELEASE}/pkg/crd/manifests/csinodeinfo.yaml --validate=false
fi

# rbac rules
echo "applying RBAC rules"
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-provisioner/${PROVISIONER_RELEASE}/deploy/kubernetes/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-attacher/${ATTACHER_RELEASE}/deploy/kubernetes/rbac.yaml

# deploy hostpath plugin and registrar sidecar
echo "deploying hostpath components"
kubectl apply -f ${BASE_DIR}/hostpath
