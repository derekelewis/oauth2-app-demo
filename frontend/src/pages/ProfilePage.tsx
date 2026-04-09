import { useAuth } from "../auth/AuthContext";
import styles from "./ProfilePage.module.css";

export default function ProfilePage() {
  const { user, logout } = useAuth();

  if (!user) return null;

  return (
    <div className={styles.container}>
      <h1 className={styles.heading}>Profile</h1>

      <div className={styles.card}>
        <dl className={styles.fields}>
          <Row label="Username" value={user.preferred_username} />
          <Row label="Name" value={user.name} />
          <Row label="Email" value={user.email} />
          <Row
            label="Email Verified"
            value={user.email_verified != null ? (user.email_verified ? "Yes" : "No") : null}
          />
          <Row label="Subject" value={user.sub} />
        </dl>
      </div>

      <button className={styles.signOut} onClick={logout}>
        Sign Out
      </button>
    </div>
  );
}

function Row({ label, value }: { label: string; value: string | null }) {
  return (
    <div className={styles.row}>
      <dt className={styles.label}>{label}</dt>
      <dd className={styles.value}>{value ?? "\u2014"}</dd>
    </div>
  );
}
