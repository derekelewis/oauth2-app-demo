import { config } from "../config";
import type { User } from "../types";
import { getValidAccessToken } from "../auth/authService";

export async function fetchMe(): Promise<User> {
  const token = await getValidAccessToken();

  const response = await fetch(`${config.apiBaseUrl}/api/me`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (!response.ok) {
    throw new Error("Failed to fetch user profile");
  }

  return (await response.json()) as User;
}
