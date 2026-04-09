def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_me_valid_token(client, make_token):
    token = make_token()
    resp = client.get("/api/me", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["sub"] == "test-user-id"
    assert data["email"] == "demo@example.com"
    assert data["preferred_username"] == "demo"


def test_protected_valid_token(client, make_token):
    token = make_token()
    resp = client.get("/api/protected", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["message"] == "You have accessed a protected resource!"
    assert data["user"] == "demo"


def test_expired_token(client, make_token):
    token = make_token(exp_offset=-60)
    resp = client.get("/api/me", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 401
    assert "expired" in resp.json()["detail"].lower()


def test_missing_token(client):
    resp = client.get("/api/me")
    assert resp.status_code == 401


def test_malformed_token(client):
    resp = client.get("/api/me", headers={"Authorization": "Bearer not-a-jwt"})
    assert resp.status_code == 401
