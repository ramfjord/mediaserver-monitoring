#!/bin/bash
# Wait for WireGuard container to have network connectivity
# Used by dependent services to ensure VPN tunnel is established

MAX_ATTEMPTS=30
ATTEMPT=0

echo "Waiting for WireGuard tunnel to be established..."

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Check if we can ping through the WireGuard container
    if docker exec wireguard ping -c 1 -W 2 1.1.1.1 > /dev/null 2>&1; then
        echo "WireGuard tunnel is up"
        exit 0
    fi

    ATTEMPT=$((ATTEMPT + 1))
    echo "Attempt $ATTEMPT/$MAX_ATTEMPTS - tunnel not ready, waiting..."
    sleep 2
done

echo "ERROR: WireGuard tunnel failed to establish after $MAX_ATTEMPTS attempts"
exit 1
