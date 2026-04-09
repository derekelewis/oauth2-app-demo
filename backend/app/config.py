from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    keycloak_url: str = "http://localhost:8080"
    keycloak_issuer_url: str | None = None
    keycloak_realm: str = "oauth2-demo"
    keycloak_client_id: str = "oauth2-demo-app"
    cors_allowed_origins: list[str] = ["*"]

    @property
    def jwks_url(self) -> str:
        return (
            f"{self.keycloak_url}/realms/{self.keycloak_realm}"
            f"/protocol/openid-connect/certs"
        )

    @property
    def issuer(self) -> str:
        base = self.keycloak_issuer_url or self.keycloak_url
        return f"{base}/realms/{self.keycloak_realm}"


settings = Settings()
