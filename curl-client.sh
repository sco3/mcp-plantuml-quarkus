#!/usr/bin/env -S bash

set -xueo pipefail

URL="http://localhost:8080/mcp"

echo "--- Initializing ---"
# 1. Initialize
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -D headers.txt \
  -d '{
    "jsonrpc": "2.0",
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": { "name": "curl-test", "version": "1.0.0" }
    },
    "id": 1
  }' "$URL" >/dev/null

# 2. Extract Session ID
SESSION_ID=$(grep -i "mcp-session-id" headers.txt | awk '{print $2}' | tr -d '\r')

if [[ -z "$SESSION_ID" ]]; then
  echo "Error: Mcp-Session-Id not found in headers.txt" >&2
  cat headers.txt
  exit 1
fi

echo "Session ID: $SESSION_ID"

# 3. Send Initialized Notification
echo "--- Sending Initialized Notification ---"
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{
    "jsonrpc": "2.0",
    "method": "notifications/initialized"
  }' "$URL"

echo -e "\n--- Calling renderDiagram ---"
# 4. Call Tool
# For tool calls, Quarkus returns the JSON-RPC result in the body
# because it's a synchronous HTTP POST in this session mode.
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {
      "name": "renderDiagram",
      "arguments": {
        "source": "@startuml\nUser -> AI: Native Quarkus Works\n@enduml"
      }
    }
  }' "$URL")

echo "$RESPONSE" | jq .

# Extract and display the base64 content
BASE64_CONTENT=$(echo "$RESPONSE" | jq -r '.result.content[0].data // empty')
if [[ -n "$BASE64_CONTENT" ]]; then
  echo -e "\n--- Base64 Response (first 100 chars) ---"
  echo "${BASE64_CONTENT:0:100}..."
  
  # Optionally decode and save to file
  echo -e "\n--- Decoding to output.png ---"
  echo "$BASE64_CONTENT" | base64 -d > output.png
  echo "Saved PNG image to output.png"
fi
