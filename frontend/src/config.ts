const KEYCLOAK_URL =
  import.meta.env.VITE_KEYCLOAK_URL ?? "http://localhost:8080";
const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:8000";
const REALM = import.meta.env.VITE_KEYCLOAK_REALM ?? "oauth2-demo";
const CLIENT_ID =
  import.meta.env.VITE_KEYCLOAK_CLIENT_ID ?? "oauth2-demo-app";
const REDIRECT_URI =
  import.meta.env.VITE_REDIRECT_URI ?? "http://localhost:5173/callback";
const SCOPES = "openid profile email";

const realmPath = `${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect`;

export const config = {
  clientId: CLIENT_ID,
  redirectUri: REDIRECT_URI,
  scopes: SCOPES,
  authorizationEndpoint: `${realmPath}/auth`,
  tokenEndpoint: `${realmPath}/token`,
  logoutEndpoint: `${realmPath}/logout`,
  apiBaseUrl: API_URL,
} as const;
