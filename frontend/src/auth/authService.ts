import { config } from "../config";
import type { TokenResponse } from "../types";
import { generateCodeChallenge, generateCodeVerifier } from "./pkce";
import {
  getRefreshToken,
  isTokenExpired,
  getAccessToken,
  storeTokens,
} from "./tokenManager";

const VERIFIER_KEY = "oauth2_demo_code_verifier";

export async function startAuthorize(): Promise<void> {
  const codeVerifier = generateCodeVerifier();
  const codeChallenge = await generateCodeChallenge(codeVerifier);

  sessionStorage.setItem(VERIFIER_KEY, codeVerifier);

  const params = new URLSearchParams({
    response_type: "code",
    client_id: config.clientId,
    redirect_uri: config.redirectUri,
    scope: config.scopes,
    code_challenge: codeChallenge,
    code_challenge_method: "S256",
  });

  window.location.href = `${config.authorizationEndpoint}?${params.toString()}`;
}

export function getAndClearCodeVerifier(): string | null {
  const verifier = sessionStorage.getItem(VERIFIER_KEY);
  sessionStorage.removeItem(VERIFIER_KEY);
  return verifier;
}

export async function exchangeCodeForTokens(
  code: string,
  codeVerifier: string,
): Promise<TokenResponse> {
  const body = new URLSearchParams({
    grant_type: "authorization_code",
    client_id: config.clientId,
    code,
    redirect_uri: config.redirectUri,
    code_verifier: codeVerifier,
  });

  const response = await fetch(config.tokenEndpoint, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: body.toString(),
  });

  if (!response.ok) {
    throw new Error("Failed to exchange code for tokens");
  }

  return (await response.json()) as TokenResponse;
}

// Deduplication: reuse in-flight refresh (mirrors iOS actor-based refreshTask)
let refreshPromise: Promise<TokenResponse> | null = null;

export async function refreshAccessToken(): Promise<TokenResponse> {
  if (refreshPromise) return refreshPromise;

  const refresh = getRefreshToken();
  if (!refresh) {
    throw new Error("No refresh token available");
  }

  refreshPromise = (async () => {
    try {
      const body = new URLSearchParams({
        grant_type: "refresh_token",
        client_id: config.clientId,
        refresh_token: refresh,
      });

      const response = await fetch(config.tokenEndpoint, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: body.toString(),
      });

      if (!response.ok) {
        throw new Error("Failed to refresh token");
      }

      const tokens = (await response.json()) as TokenResponse;
      storeTokens(tokens);
      return tokens;
    } finally {
      refreshPromise = null;
    }
  })();

  return refreshPromise;
}

export async function getValidAccessToken(): Promise<string> {
  const token = getAccessToken();
  if (!token) {
    throw new Error("No access token available");
  }

  if (!isTokenExpired(token)) {
    return token;
  }

  const refreshed = await refreshAccessToken();
  return refreshed.access_token;
}
