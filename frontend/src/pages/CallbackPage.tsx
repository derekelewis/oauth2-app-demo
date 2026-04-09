import { useEffect, useRef } from "react";
import { useNavigate, useSearchParams } from "react-router";
import { useAuth } from "../auth/AuthContext";

export default function CallbackPage() {
  const [searchParams] = useSearchParams();
  const { handleCallback, error } = useAuth();
  const navigate = useNavigate();
  const handledRef = useRef(false);

  useEffect(() => {
    if (handledRef.current) return;
    handledRef.current = true;

    const code = searchParams.get("code");
    if (!code) {
      navigate("/", { replace: true });
      return;
    }

    handleCallback(code).then(() => {
      navigate("/", { replace: true });
    });
  }, [searchParams, handleCallback, navigate]);

  if (error) {
    return (
      <div style={{ textAlign: "center", marginTop: "4rem" }}>
        <p style={{ color: "#dc2626" }}>{error}</p>
        <a href="/">Back to login</a>
      </div>
    );
  }

  return (
    <div style={{ textAlign: "center", marginTop: "4rem" }}>
      <p>Completing sign in...</p>
    </div>
  );
}
