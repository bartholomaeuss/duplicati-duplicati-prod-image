#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
workspace="$(cd -- "${script_dir}/../.." && pwd)"
image="duplicati"
tag="shipit"
dockerfile="Dockerfile"

echo "Using:"
echo "- Image: ${image}"
echo "- Tag: ${tag}"
echo "- Dockerfile: ${dockerfile}"
echo "- Script directory: ${script_dir}"
echo "- Workspace: ${workspace}"

containers="$(docker ps -q --filter "ancestor=${image}:${tag}")"
if [[ -n "${containers}" ]]; then
    echo "Stopping existing containers: ${containers}"
    docker kill ${containers} >/dev/null
    docker rm ${containers} >/dev/null
    docker image rm "${image}:${tag}" >/dev/null
else
    echo "No running containers to stop."
fi

echo "Building ${image}:${tag}..."
docker build -t "${image}:${tag}" -f "${workspace}/${dockerfile}" "${workspace}"

echo "Starting container ${image}_${tag}..."
docker run -d \
    --name="${image}_${tag}" \
    --net=host \
    -v ~/duplicati:/duplicati \
    -v /mnt/external_drive_1/tier2:/external_drive_1/tier2 \
    -v /mnt/external_drive_2/tier2:/external_drive_2/tier2 \
    -v /mnt/external_drive_1/tier3:/external_drive_1/tier3 \
    -v /mnt/external_drive_2/tier3:/external_drive_2/tier3 \
    --restart=unless-stopped \
    "${image}:${tag}"
