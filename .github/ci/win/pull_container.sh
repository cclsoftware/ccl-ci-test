#!/usr/bin/env bash
set -euo pipefail

image="${1}"

timeout=30
interval=5
elapsed=0

echo "-- Waiting for Docker to be ready..."

while [ "$elapsed" -lt "$timeout" ]; do
    if docker info > /dev/null 2>&1; then
        echo "Docker is ready!"
		docker pull "${image}"
        exit 0
    fi

    echo "Docker not ready yet... waiting ${interval}s"
    sleep "$interval"
    elapsed=$((elapsed + interval))
done

echo "ERROR: Docker did not become ready within ${timeout} seconds."
exit 1
