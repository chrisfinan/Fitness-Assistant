from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_PASS, DB_USER, DB_NAME, DB_HOST
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, Choice
from schemas.choose import ChooseCreate, ChooseResponse, ChooseUpdate

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

@router.get("/{uid}", response_model=ChooseResponse)
async def get_user_by_uid(uid: int, db: Session = Depends(get_db)):
    choice = db.query(Choice).filter(Choice.uid == uid).first()
    if choice is None:
        raise HTTPException(status_code=404, detail=f"User {uid} not found")
    return ChooseResponse.from_orm(choice)

@router.get("", response_model=list[ChooseResponse])
async def list_users(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    choices = db.query(Choice).offset(skip).limit(limit).all()
    return [ChooseResponse.from_orm(choice) for choice in choices]

@router.put("/{uid}", response_model=ChooseResponse)
async def update_user(
    uid: int, choose_data: ChooseUpdate, db: Session = Depends(get_db)
):
    # Retrieve the User object by its ID
    choice_to_update = db.query(Choice).filter(Choice.uid == uid).first()

    if choice_to_update:
        # Update the User object with the new data
        for field, value in choose_data.dict().items():
            setattr(choice_to_update, field, value)

        db.commit()
        db.refresh(choice_to_update)
        return ChooseResponse.from_orm(choice_to_update)
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")