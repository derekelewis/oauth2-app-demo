import { useAuth } from "../auth/AuthContext";
import styles from "./LoginPage.module.css";

export default function LoginPage() {
  const { isLoading, error, login } = useAuth();

  return (
    <div className={styles.container}>
      <div className={styles.hero}>
        <svg
          className={styles.icon}
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
          <rect x="9" y="10" width="6" height="5" rx="1" />
          <path d="M10 10V8a2 2 0 1 1 4 0v2" />
        </svg>

        <h1 className={styles.title}>OAuth2 Demo</h1>
        <p className={styles.subtitle}>Sign in with Keycloak using PKCE</p>
      </div>

      {error && <p className={styles.error}>{error}</p>}

      <button
        className={styles.button}
        onClick={login}
        disabled={isLoading}
      >
        {isLoading && <span className={styles.spinner} />}
        Sign In
      </button>
    </div>
  );
}
