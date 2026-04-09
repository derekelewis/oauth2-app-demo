import type { TokenResponse } from "../types";

const STORAGE_PREFIX = "oauth2_demo_";

let accessToken: string | null = null;
let refreshToken: string | null = null;

export function storeTokens(response: TokenResponse): void {
  accessToken = response.access_token;
  refreshToken = response.refresh_token ?? null;

  sessionStorage.setItem(`${STORAGE_PREFIX}access_token`, response.access_token);
  if (response.refresh_token) {
    sessionStorage.setItem(`${STORAGE_PREFIX}refresh_token`, response.refresh_token);
  }
  if (response.id_token) {
    sessionStorage.setItem(`${STORAGE_PREFIX}id_token`, response.id_token);
  }
}

export function getAccessToken(): string | null {
  return accessToken ?? sessionStorage.getItem(`${STORAGE_PREFIX}access_token`);
}

export function getRefreshToken(): string | null {
  return refreshToken ?? sessionStorage.getItem(`${STORAGE_PREFIX}refresh_token`);
}

export function hasStoredTokens(): boolean {
  return getAccessToken() !== null;
}

export function clearTokens(): void {
  accessToken = null;
  refreshToken = null;
  sessionStorage.removeItem(`${STORAGE_PREFIX}access_token`);
  sessionStorage.removeItem(`${STORAGE_PREFIX}refresh_token`);
  sessionStorage.removeItem(`${STORAGE_PREFIX}id_token`);
}

export function isTokenExpired(token: string): boolean {
  const parts = token.split(".");
  if (parts.length !== 3) return true;

  let payload = parts[1]!;
  // Pad base64 string
  const remainder = payload.length % 4;
  if (remainder > 0) {
    payload += "=".repeat(4 - remainder);
  }

  try {
    const json = JSON.parse(atob(payload)) as { exp?: number };
    if (typeof json.exp !== "number") return true;
    // Consider expired 30 seconds before actual expiry (same as iOS)
    return Date.now() / 1000 >= json.exp - 30;
  } catch {
    return true;
  }
}
