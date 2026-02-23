#!/usr/bin/env bash

set -euo pipefail

URL="http://localhost:8080/mcp"
HEADERS_FILE="headers.txt"

# --- Initialize ---
echo "--- Initializing ---"

curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -D "$HEADERS_FILE" \
    -d '{
        "jsonrpc": "2.0",
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {
                "name": "curl-test",
                "version": "1.0.0"
            }
        },
        "id": 1
    }' "$URL" >/dev/null

# --- Extract Session ID ---
SESSION_ID=$(grep -i "mcp-session-id" "$HEADERS_FILE" | awk '{print $2}' | tr -d '\r')

if [[ -z "$SESSION_ID" ]]; then
    echo "Error: Mcp-Session-Id not found in $HEADERS_FILE" >&2
    cat "$HEADERS_FILE"
    exit 1
fi

echo "Session ID: $SESSION_ID"

# --- Send Initialized Notification ---
echo "--- Sending Initialized Notification ---"

curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Mcp-Session-Id: $SESSION_ID" \
    -d '{
        "jsonrpc": "2.0",
        "method": "notifications/initialized"
    }' "$URL"

# --- List Tools ---
echo "--- Sending tools/list ---"

curl -v -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -H "Mcp-Session-Id: $SESSION_ID" \
    -d '{
        "jsonrpc": "2.0",
        "id": 3,
        "method": "tools/list"
    }' "$URL"

# --- Call renderDiagram Tool ---
echo -e "\n--- Calling renderDiagram ---"

RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Mcp-Session-Id: $SESSION_ID" \
    -H "Accept: application/json, text/event-stream" \
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

# --- Extract and Display Base64 Content ---
BASE64_CONTENT=$(echo "$RESPONSE" | jq -r '.result.content[0].data // empty')

if [[ -n "$BASE64_CONTENT" ]]; then
    echo -e "\n--- Base64 Response (first 100 chars) ---"
    echo "${BASE64_CONTENT:0:100}..."

    echo -e "\n--- Decoding to output.svg ---"
    echo "$BASE64_CONTENT" | base64 -d > output.svg
    echo "Saved SVG image to output.svg"
fi
