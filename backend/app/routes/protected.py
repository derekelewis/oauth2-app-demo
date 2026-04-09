from typing import Annotated

from fastapi import APIRouter, Depends

from ..auth import get_current_user
from ..models import ProtectedResource, UserInfo

router = APIRouter(prefix="/api")


@router.get("/me", response_model=UserInfo)
async def get_me(user: Annotated[UserInfo, Depends(get_current_user)]):
    return user


@router.get("/protected", response_model=ProtectedResource)
async def get_protected(user: Annotated[UserInfo, Depends(get_current_user)]):
    return ProtectedResource(
        message="You have accessed a protected resource!",
        user=user.preferred_username or user.sub,
    )
