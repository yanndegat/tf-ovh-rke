#!/bin/bash
set -eEuo pipefail

PACKERBIN=$(which packer-io || which packer)
TARGET="${1:-ubuntu2004}"
TAG=$((git describe --tags) 2>/dev/null || echo "")
VERSION=${TAG:-latest}
COMMIT=$(git rev-parse --verify --short HEAD 2>/dev/null)
docker_version=${2:-18.09.2}

image_name=""
if [ "$TARGET" == "ubuntu2004" ]; then
    image_name="My 20.04"
    ssh_user=ubuntu
else
    echo "checking if image already built" >&2
    exit 1
fi

echo "checking if image already built for commit $COMMIT and target $TARGET" >&2
image_id=$(openstack image list \
                     --name "$image_name" \
                     --property "tag=$VERSION" \
                     --property "commit=$COMMIT" \
                     --status active \
                     -f value \
                     -c ID)

if [ ! -z "$image_id" ]; then
    echo "image already built under id $image_id" >&2
    exit 0
fi

$PACKERBIN build \
           -var commit="$COMMIT" \
           -var docker_version="$docker_version" \
           -var ext_net_id=$(openstack network show -c id -f value "Ext-Net") \
           -var image_name="$image_name" \
           -var region="$OS_REGION_NAME" \
           -var ssh_user="$ssh_user" \
           -var tag="$VERSION" \
           -only "$TARGET" \
           packer.json
