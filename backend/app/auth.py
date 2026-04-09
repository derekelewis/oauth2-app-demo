from typing import Annotated

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from .config import settings
from .models import UserInfo

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

_jwks_client = jwt.PyJWKClient(settings.jwks_url, cache_keys=True)


async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
) -> UserInfo:
    try:
        signing_key = _jwks_client.get_signing_key_from_jwt(token)
        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            issuer=settings.issuer,
            options={"verify_aud": False},
        )
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except jwt.InvalidTokenError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {e}",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return UserInfo(
        sub=payload.get("sub", ""),
        email=payload.get("email"),
        preferred_username=payload.get("preferred_username"),
        name=payload.get("name"),
        given_name=payload.get("given_name"),
        family_name=payload.get("family_name"),
        email_verified=payload.get("email_verified"),
    )
