from sqlalchemy.orm import Session
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, User, UserInformation, Choose
from schemas.user import UserResponse, UserCreate, UserUpdate
from passlib.context import CryptContext
from app.db import get_db

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

router = APIRouter()

@router.get("/{uid}", response_model=UserResponse)
async def get_user_by_uid(uid: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.uid == uid).first()
    if user is None:
        raise HTTPException(status_code=404, detail=f"User {uid} not found")
    return UserResponse.from_orm(user)

@router.get("", response_model=list[UserResponse])
async def list_users(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    users = db.query(User).offset(skip).limit(limit).all()
    return [UserResponse.from_orm(user) for user in users]

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

@router.post("", response_model=UserResponse)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    hashed_password = hash_password(user.password)
    new_user = User(
        username=user.username,
        password=hashed_password,
        first_name=user.first_name,
        last_name=user.last_name,
        email_address=user.email_address,
    )

    # If a username is already taken (username must be unique)
    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already taken")

    # Add new user and commit to get the UID
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Create a new record in the 'information' table, using the user's uid as foreign key
    new_information = UserInformation(
        uid=new_user.uid,
    )

    # Add new information record and commit
    db.add(new_information)
    db.commit()

    # Return the user response
    return UserResponse.from_orm(new_user)

@router.delete("/{uid}", response_model=str)
async def delete_user(uid: int, db: Session = Depends(get_db)):
    # Retrieve the User object by its ID
    user_to_delete = db.query(User).filter(User.uid == uid).first()

    if user_to_delete:
        # Delete all related rows in the Information table
        db.query(UserInformation).filter(UserInformation.uid == uid).delete()

        # Delete all related rows in the Choose table
        db.query(Choose).filter(Choose.uid == uid).delete()

        # Delete the User object
        db.delete(user_to_delete)

        # Commit the changes to the database
        db.commit()

        return f"User {uid} and all associated information successfully deleted."
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")

@router.put("/{uid}", response_model=UserResponse)
async def update_user(
    uid: int, user_data: UserUpdate, db: Session = Depends(get_db)
):
    # Retrieve the User object by its ID
    user_to_update = db.query(User).filter(User.uid == uid).first()

    if not user_to_update:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")

    # Update fields dynamically, but hash the password if it's being updated
    for field, value in user_data.dict().items():
        if field == "password" and value:  # Ensure password is not empty before hashing
            setattr(user_to_update, field, hash_password(value))
        elif value is not None:  # Only update fields that are provided
            setattr(user_to_update, field, value)

    db.commit()
    db.refresh(user_to_update)
    return UserResponse.from_orm(user_to_update)

@router.get("/{uid}", response_model=UserResponse)
async def get_all_user_info_by_uid(uid: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.uid == uid).first()
    if user is None:
        raise HTTPException(status_code=404, detail=f"User {uid} not found")
    return UserResponse.from_orm(user)

@router.get("/user_info/{uid}")
async def get_user_info(uid: int, db: Session = Depends(get_db)):
    db_user = (
        db.query(User, UserInformation, Choose)
        .join(UserInformation, User.uid == UserInformation.uid, isouter=True)
        .join(Choose, User.uid == Choose.uid, isouter=True)
        .filter(User.uid == uid)
        .first()
    )

    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    user, information, choose = db_user  # Unpacking joined results

    return {
        "username": user.username,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "email_address": user.email_address,
        "results": information.results if information else None,
        "time": information.time if information else None,
        "days": information.days if information else None,
        "chosen_exercises": choose.eid if choose else None
    }
