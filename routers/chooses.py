from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_PASS, DB_USER, DB_NAME, DB_HOST
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, Choose
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
    choose = db.query(Choose).filter(Choose.uid == uid).first()
    if choose is None:
        raise HTTPException(status_code=404, detail=f"User {uid} not found")
    return ChooseResponse.from_orm(choose)

@router.get("", response_model=list[ChooseResponse])
async def list_users(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    chooses = db.query(Choose).offset(skip).limit(limit).all()
    return [ChooseResponse.from_orm(choose) for choose in chooses]

@router.put("/{uid}", response_model=ChooseResponse)
async def update_user(
    uid: int, choose_data: ChooseUpdate, db: Session = Depends(get_db)
):
    # Retrieve the User object by its ID
    choose_to_update = db.query(Choose).filter(Choose.uid == uid).first()

    if choose_to_update:
        # Update the User object with the new data
        for field, value in choose_data.dict().items():
            setattr(choose_to_update, field, value)

        db.commit()
        db.refresh(choose_to_update)
        return ChooseResponse.from_orm(choose_to_update)
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")