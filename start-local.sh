#!/bin/bash

echo "🚀 Starting Amigo Desk Local Development"
echo "======================================"

# Check if SSH tunnel is running
if ! pgrep -f "ssh -L 5433" > /dev/null; then
    echo "📡 Starting SSH tunnel to VPS..."
    ssh -L 5433:localhost:5432 -L 6380:localhost:6379 -N root@88.99.34.44 &
    SSH_PID=$!
    echo $SSH_PID > /tmp/vps_tunnel.pid
    echo "✅ SSH tunnel started (PID: $SSH_PID)"
    sleep 3
else
    echo "✅ SSH tunnel already running"
fi

# Set correct Ruby version
echo "🔧 Setting Ruby version..."
rbenv local 3.2.2
export PATH="$HOME/.rbenv/shims:$PATH"

# Test connections
echo "🔍 Testing VPS connections..."
if pg_isready -h localhost -p 5433 -U chatwoot > /dev/null 2>&1; then
    echo "✅ PostgreSQL connected"
else
    echo "❌ PostgreSQL connection failed"
    exit 1
fi

if redis-cli -p 6380 ping > /dev/null 2>&1; then
    echo "✅ Redis connected"
else
    echo "❌ Redis connection failed" 
    exit 1
fi

echo ""
echo "🎯 Starting Chatwoot server..."
echo "📍 Access at: http://localhost:3001"
echo "🗄️ Using VPS database"
echo ""

# Start Rails server
bundle exec rails server -p 3001 -b 0.0.0.0