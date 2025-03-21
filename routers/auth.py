from fastapi import FastAPI, HTTPException, Depends, APIRouter, Request, Response
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_PASS, DB_USER, DB_NAME, DB_HOST
from app.models import Base, User
from schemas.user import UserLogin
import uuid

# Define connection string
conn_string = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"
engine = create_engine(conn_string)
Base.metadata.create_all(bind=engine)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# In-memory session store (use Redis in production)
sessions = {}

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/login")
async def login(user: UserLogin, response: Response, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == user.username).first()

    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")

    # Create a session token
    session_token = str(uuid.uuid4())
    sessions[session_token] = db_user.uid

    # Set session in cookies
    response.set_cookie(key="session_token", value=session_token, httponly=True)

    return {
        "message": "Login successful!",
        "uid": db_user.uid  # <-- Include UID in the response
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

    return {"username": db_user.username}


'''
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_PASS, DB_USER, DB_NAME, DB_HOST
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, User, UserInformation, Choose, Exercise
from schemas.user import UserResponse, UserCreate, UserUpdate, UserLogin


# Define your connection string
conn_string = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"
engine = create_engine(conn_string)
Base.metadata.create_all(bind=engine)

# Use the create_engine function to establish the connection
engine = create_engine(conn_string)

# Create a session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    # Fetch the user from the database by username
    db_user = db.query(User).filter(User.username == user.username).first()

    # Check if user exists
    if db_user is None:
        # Log the error for debugging purposes
        print(f"User not found: {user.username}")
        raise HTTPException(status_code=404, detail="User not found")

    # If user exists, return a success message (ignoring password validation for now)
    return {"message": "Login successful!"}
'''