# OAuth2 App Demo

A monorepo demonstrating OAuth2 Authorization Code Flow with PKCE across three components:

- **iOS App** — Swift 6 / SwiftUI client using `ASWebAuthenticationSession`
- **FastAPI Backend** — Python resource server validating JWTs via JWKS
- **Keycloak** — Identity Provider running in Docker

## Architecture

```
iOS App                          Keycloak (IdP)                 FastAPI (Resource Server)
  │                                  │                                │
  ├─ ASWebAuthenticationSession ────►│ /auth (login page)             │
  │                                  │                                │
  │◄── oauth2appdemo://callback?code=│                                │
  │                                  │                                │
  ├─ POST /token (code + verifier) ─►│                                │
  │◄── access_token, refresh_token ──│                                │
  │                                  │                                │
  ├─ GET /api/me ────────────────────┼───────────────────────────────►│
  │   Authorization: Bearer <token>  │                                │
  │                                  │   validate JWT via JWKS ◄──────│
  │◄── user info ────────────────────┼────────────────────────────────│
```

## Prerequisites

- Docker & Docker Compose
- Xcode 16.2+ (for iOS Simulator)
- Python 3.12+ (for local backend development)

## Quick Start

### 1. Start Infrastructure

```bash
cp .env.example .env
docker compose up -d
```

Wait for Keycloak to be healthy (~30-60 seconds):
```bash
docker compose ps
```

Keycloak admin console: http://localhost:8080 (admin / admin)

### 2. Test the Backend

```bash
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

### 3. Run the iOS App

Open the Xcode project:
```bash
open ios/OAuth2Demo.xcodeproj
```

Run on iOS Simulator. Tap "Sign In", log in with:
- Username: `demo`
- Password: `demo123`

## Demo Credentials

| Field    | Value      |
|----------|------------|
| Username | `demo`     |
| Password | `demo123`  |

## Running on a Physical Device

The iOS app defaults to `localhost` which works in the Simulator. For a physical device:

1. Find your Mac's IP on the local network (e.g., `192.168.1.100`)
2. Set custom hosts in the iOS app via UserDefaults:

```swift
UserDefaults.standard.set("192.168.1.100", forKey: "keycloak_host")
UserDefaults.standard.set("192.168.1.100", forKey: "api_host")
```

Or update the defaults in `AuthConfiguration.swift` under the `#else` branch.

3. Update Keycloak's redirect URI to include your scheme, and ensure `KC_HOSTNAME` matches.

## Local Backend Development

Run the backend outside Docker for hot-reload:

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
KEYCLOAK_URL=http://localhost:8080 uvicorn app.main:app --reload --port 8000
```

## Project Structure

```
├── ios/                    # iOS app (Swift 6 / SwiftUI)
├── backend/                # FastAPI resource server
├── keycloak/               # Realm export for auto-import
├── scripts/                # Test scripts
└── docker-compose.yml      # Keycloak + Postgres + Backend
```

## Running Tests

```bash
cd backend
pip install pytest
python -m pytest tests/ -v
```
