# OAuth2 App Demo

A monorepo demonstrating OAuth2 Authorization Code Flow with PKCE across four components:

- **iOS App** — Swift 6 / SwiftUI client using `ASWebAuthenticationSession`
- **React Frontend** — React 19 / TypeScript SPA with manual PKCE implementation
- **FastAPI Backend** — Python resource server validating JWTs via JWKS
- **Keycloak** — Identity Provider running in Docker

## Architecture

```
Client (iOS / Web)               Keycloak (IdP)                 FastAPI (Resource Server)
  │                                  │                                │
  ├─ Redirect / ASWebAuth ──────────►│ /auth (login page)             │
  │                                  │                                │
  │◄── callback?code= ──────────────│                                │
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
- Node.js 22+ (for frontend development)
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

### 3. Run the React Frontend

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173, click "Sign In", and log in with the demo credentials.

> **Note:** If Keycloak was already running before adding the web redirect URI, you need to either:
> - Run `docker compose down -v && docker compose up -d` to re-import the realm, or
> - Manually add `http://localhost:5173/callback` as a valid redirect URI in the Keycloak Admin Console (Clients > oauth2-demo-app > Valid redirect URIs).

### 4. Run the iOS App

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
├── frontend/               # React 19 web app (Vite + TypeScript)
├── backend/                # FastAPI resource server
├── keycloak/               # Realm export for auto-import
├── scripts/                # Test scripts
└── docker-compose.yml      # Keycloak + Postgres + Backend + Frontend
```

## Running Tests

```bash
cd backend
pip install pytest
python -m pytest tests/ -v
```
