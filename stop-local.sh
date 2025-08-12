#!/bin/bash

echo "🛑 Stopping Amigo Desk Local Development"
echo "======================================"

# Kill SSH tunnel if running
if [ -f /tmp/vps_tunnel.pid ]; then
    PID=$(cat /tmp/vps_tunnel.pid)
    if kill $PID 2>/dev/null; then
        echo "✅ SSH tunnel stopped (PID: $PID)"
    else
        echo "⚠️ SSH tunnel was already stopped"
    fi
    rm -f /tmp/vps_tunnel.pid
fi

# Kill any remaining SSH tunnels
pkill -f "ssh -L 5433" 2>/dev/null && echo "🔧 Cleaned up remaining SSH tunnels"

echo "✅ Local development stopped"