import time
from unittest.mock import MagicMock, patch

import jwt as pyjwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
from fastapi.testclient import TestClient


def _generate_rsa_keypair():
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    return private_key


@pytest.fixture(scope="session")
def rsa_keypair():
    return _generate_rsa_keypair()


@pytest.fixture(scope="session")
def rsa_private_key(rsa_keypair):
    return rsa_keypair


@pytest.fixture(scope="session")
def rsa_public_key(rsa_keypair):
    return rsa_keypair.public_key()


@pytest.fixture
def make_token(rsa_private_key):
    def _make(
        sub="test-user-id",
        email="demo@example.com",
        preferred_username="demo",
        name="Demo User",
        exp_offset=300,
        issuer="http://localhost:8080/realms/oauth2-demo",
    ):
        now = int(time.time())
        payload = {
            "sub": sub,
            "email": email,
            "preferred_username": preferred_username,
            "name": name,
            "given_name": "Demo",
            "family_name": "User",
            "email_verified": True,
            "iss": issuer,
            "iat": now,
            "exp": now + exp_offset,
        }
        private_pem = rsa_private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )
        return pyjwt.encode(payload, private_pem, algorithm="RS256")

    return _make


@pytest.fixture
def client(rsa_public_key):
    mock_jwk_client = MagicMock()
    mock_signing_key = MagicMock()
    mock_signing_key.key = rsa_public_key
    mock_jwk_client.get_signing_key_from_jwt.return_value = mock_signing_key

    with patch("app.auth._jwks_client", mock_jwk_client):
        from app.main import app
        yield TestClient(app)
