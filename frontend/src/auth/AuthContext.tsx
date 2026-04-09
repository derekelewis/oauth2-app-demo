import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useReducer,
} from "react";
import type { ReactNode } from "react";
import type { User } from "../types";
import { fetchMe } from "../api/client";
import {
  startAuthorize,
  exchangeCodeForTokens,
  getAndClearCodeVerifier,
} from "./authService";
import { clearTokens, hasStoredTokens, storeTokens } from "./tokenManager";

interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  user: User | null;
  error: string | null;
}

type AuthAction =
  | { type: "LOADING" }
  | { type: "AUTHENTICATED"; user: User }
  | { type: "UNAUTHENTICATED" }
  | { type: "ERROR"; message: string };

function authReducer(_state: AuthState, action: AuthAction): AuthState {
  switch (action.type) {
    case "LOADING":
      return { isAuthenticated: false, isLoading: true, user: null, error: null };
    case "AUTHENTICATED":
      return { isAuthenticated: true, isLoading: false, user: action.user, error: null };
    case "UNAUTHENTICATED":
      return { isAuthenticated: false, isLoading: false, user: null, error: null };
    case "ERROR":
      return { isAuthenticated: false, isLoading: false, user: null, error: action.message };
  }
}

interface AuthContextValue extends AuthState {
  login: () => void;
  logout: () => void;
  handleCallback: (code: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(authReducer, {
    isAuthenticated: false,
    isLoading: true,
    user: null,
    error: null,
  });

  // Check for existing session on mount (mirrors AuthViewModel.checkSession)
  useEffect(() => {
    if (!hasStoredTokens()) {
      dispatch({ type: "UNAUTHENTICATED" });
      return;
    }

    fetchMe()
      .then((user) => dispatch({ type: "AUTHENTICATED", user }))
      .catch(() => {
        clearTokens();
        dispatch({ type: "UNAUTHENTICATED" });
      });
  }, []);

  const login = useCallback(() => {
    startAuthorize();
  }, []);

  const handleCallback = useCallback(async (code: string) => {
    dispatch({ type: "LOADING" });

    const codeVerifier = getAndClearCodeVerifier();
    if (!codeVerifier) {
      dispatch({ type: "ERROR", message: "Missing code verifier" });
      return;
    }

    try {
      const tokens = await exchangeCodeForTokens(code, codeVerifier);
      storeTokens(tokens);
      const user = await fetchMe();
      dispatch({ type: "AUTHENTICATED", user });
    } catch (err) {
      clearTokens();
      dispatch({
        type: "ERROR",
        message: err instanceof Error ? err.message : "Authentication failed",
      });
    }
  }, []);

  const logout = useCallback(() => {
    clearTokens();
    dispatch({ type: "UNAUTHENTICATED" });
  }, []);

  return (
    <AuthContext value={{ ...state, login, logout, handleCallback }}>
      {children}
    </AuthContext>
  );
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
