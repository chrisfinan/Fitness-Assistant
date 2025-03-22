from fastapi import FastAPI, HTTPException, Depends, APIRouter, Request, Response
from sqlalchemy.orm import Session
from app.models import Base, User
from routers.users import pwd_context
from schemas.user import UserLogin
import uuid
from app.db import get_db

# In-memory session store
sessions = {}

router = APIRouter()

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

@router.post("/login")
async def login(user: UserLogin, response: Response, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == user.username).first()

    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    if not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Invalid username or password")

    # Create a session token
    session_token = str(uuid.uuid4())
    sessions[session_token] = db_user.uid

    # Set session in cookies
    response.set_cookie(key="session_token", value=session_token, httponly=True)

    return {
        "message": "Login successful!",
        "uid": db_user.uid,
        "username": db_user.username,
        "first_name": db_user.first_name,
        "last_name": db_user.last_name,
        "email_address": db_user.email_address
    }

@router.get("/logout")
async def logout(request: Request, response: Response):
    session_token = request.cookies.get("session_token")

    if session_token in sessions:
        del sessions[session_token]

    response.delete_cookie("session_token")
    return {"message": "Logged out successfully"}

@router.get("/me")
async def get_current_user(request: Request, db: Session = Depends(get_db)):
    session_token = request.cookies.get("session_token")

    if not session_token or session_token not in sessions:
        raise HTTPException(status_code=401, detail="Unauthorized")

    user_id = sessions[session_token]
    db_user = db.query(User).filter(User.uid == user_id).first()

    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    return {"username": db_user.username,
            "first_name": db_user.first_name,
            "last_name": db_user.last_name,
            "email_address": db_user.email_address}