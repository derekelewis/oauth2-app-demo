export interface User {
  sub: string;
  email: string | null;
  preferred_username: string | null;
  name: string | null;
  given_name: string | null;
  family_name: string | null;
  email_verified: boolean | null;
}

export interface TokenResponse {
  access_token: string;
  refresh_token?: string;
  id_token?: string;
  expires_in: number;
  token_type: string;
}
