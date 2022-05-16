#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

mirror_registry_url="$(< /var/run/vault/vsphere/vmc_mirror_registry_url)"

#save mirror registry url
cat > "${SHARED_DIR}"/mirror_registry_url << EOF
${mirror_registry_url}
EOF

#Get haproxy-router image for upi disconnected installation
target_release_image="${mirror_registry_url}/${RELEASE_IMAGE_LATEST#*/}"
target_release_image_repo="${target_release_image%:*}"
target_release_image_repo="${target_release_image_repo%@sha256*}"

haproxy_image_pullspec=$(oc adm release info "${RELEASE_IMAGE_LATEST}" --image-for haproxy-router | awk -F'@' '{print $2}')
target_haproxy_image="${target_release_image_repo}@${haproxy_image_pullspec}"
echo "target haproxy image: ${target_haproxy_image}"

cat > "${SHARED_DIR}/haproxy-router-image" << EOF
${target_haproxy_image}
$(cat /var/run/vault/vsphere/registry_creds)
EOF