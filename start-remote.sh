#!/bin/bash

echo "🌐 Starting Chatwoot on VPS with Local Access"
echo "============================================"

VPS_HOST="root@88.99.34.44"
LOCAL_PORT=3001
REMOTE_PORT=3001
PROJECT_PATH="/root/chatwoot"

# Check if tunnel already exists
if pgrep -f "ssh.*-L ${LOCAL_PORT}:localhost:${REMOTE_PORT}.*${VPS_HOST}" > /dev/null; then
    echo "✅ Web tunnel already running"
else
    echo "📡 Creating SSH tunnel for web access..."
    ssh -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} -N ${VPS_HOST} &
    TUNNEL_PID=$!
    echo $TUNNEL_PID > /tmp/web_tunnel.pid
    echo "✅ Web tunnel started (PID: $TUNNEL_PID)"
    sleep 2
fi

echo ""
echo "🚀 Starting Chatwoot development server on VPS..."
echo "📍 Local access: http://localhost:${LOCAL_PORT}"
echo "🖥️  Server running on VPS"
echo ""
echo "Press Ctrl+C to stop the server and close tunnel"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping remote server..."
    ssh ${VPS_HOST} "pkill -f 'rails server' || true"
    
    echo "🔌 Closing tunnels..."
    if [ -f /tmp/web_tunnel.pid ]; then
        kill $(cat /tmp/web_tunnel.pid) 2>/dev/null || true
        rm /tmp/web_tunnel.pid
    fi
    
    echo "✅ Cleanup complete"
    exit 0
}

# Set up trap for cleanup
trap cleanup SIGINT SIGTERM

# Start the Rails server on VPS and keep connection alive
ssh ${VPS_HOST} "cd ${PROJECT_PATH} && bundle exec rails server -p ${REMOTE_PORT} -b 0.0.0.0"