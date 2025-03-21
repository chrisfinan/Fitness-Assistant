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

@router.post("", response_model=UserResponse)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    # Create a new user in the database
    new_user = User(
        username=user.username,
        password=user.password,
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

    # Create a new record in the 'informations' table, using the user's uid as foreign key
    new_information = UserInformation(
        uid=new_user.uid  # Use the newly created user's UID as the foreign key
        # You can add other fields here if necessary, depending on your Information model
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

    if user_to_update:
        # Update the User object with the new data
        for field, value in user_data.dict().items():
            setattr(user_to_update, field, value)

        db.commit()
        db.refresh(user_to_update)
        return UserResponse.from_orm(user_to_update)
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")

'''
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