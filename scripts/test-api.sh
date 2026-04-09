#!/usr/bin/env bash
set -euo pipefail

KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8080}"
REALM="${KEYCLOAK_REALM:-oauth2-demo}"
CLIENT_ID="${KEYCLOAK_CLIENT_ID:-oauth2-demo-app}"
USERNAME="${TEST_USERNAME:-demo}"
PASSWORD="${TEST_PASSWORD:-demo123}"
API_URL="${API_URL:-http://localhost:8000}"

echo "==> Fetching token from Keycloak..."
TOKEN_RESPONSE=$(curl -s -X POST \
  "${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=${CLIENT_ID}" \
  -d "username=${USERNAME}" \
  -d "password=${PASSWORD}" \
  -d "scope=openid profile email")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
echo "==> Got access token: ${ACCESS_TOKEN:0:20}..."

echo ""
echo "==> GET /api/me"
curl -s -H "Authorization: Bearer ${ACCESS_TOKEN}" "${API_URL}/api/me" | python3 -m json.tool

echo ""
echo "==> GET /api/protected"
curl -s -H "Authorization: Bearer ${ACCESS_TOKEN}" "${API_URL}/api/protected" | python3 -m json.tool

echo ""
echo "==> GET /health"
curl -s "${API_URL}/health" | python3 -m json.tool
