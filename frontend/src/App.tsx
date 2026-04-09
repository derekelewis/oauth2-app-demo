import { BrowserRouter, Routes, Route } from "react-router";
import { AuthProvider, useAuth } from "./auth/AuthContext";
import LoginPage from "./pages/LoginPage";
import ProfilePage from "./pages/ProfilePage";
import CallbackPage from "./pages/CallbackPage";
import "./App.module.css";

function RootPage() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div style={{ textAlign: "center", marginTop: "4rem" }}>
        <p>Loading...</p>
      </div>
    );
  }

  return isAuthenticated ? <ProfilePage /> : <LoginPage />;
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/callback" element={<CallbackPage />} />
          <Route path="*" element={<RootPage />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}
