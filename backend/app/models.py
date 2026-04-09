from pydantic import BaseModel


class UserInfo(BaseModel):
    sub: str
    email: str | None = None
    preferred_username: str | None = None
    name: str | None = None
    given_name: str | None = None
    family_name: str | None = None
    email_verified: bool | None = None


class ProtectedResource(BaseModel):
    message: str
    user: str
