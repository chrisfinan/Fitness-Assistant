from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_PASS, DB_USER, DB_NAME, DB_HOST
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, UserInformation
from schemas.information import InformationUpdate, InformationCreate, InformationResponse

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


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()



@router.get("/{uid}", response_model=InformationResponse)
async def get_info_by_uid(uid: int, db: Session = Depends(get_db)):
    information = db.query(UserInformation).filter(UserInformation.uid == uid).first()
    if information is None:
        raise HTTPException(status_code=404, detail=f"User {uid} not found")
    return InformationResponse.from_orm(information)

@router.get("", response_model=list[InformationResponse])
async def list_information(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    informations = db.query(UserInformation).offset(skip).limit(limit).all()
    return [InformationResponse.from_orm(information) for information in informations]

@router.delete("/{uid}", response_model=str)
async def delete_information(uid: int, db: Session = Depends(get_db)):
    # Retrieve the User object by its ID
    information_to_delete = db.query(UserInformation).filter(UserInformation.uid == uid).first()

    if information_to_delete:
        # Set every field except for `uid` to None (or empty, depending on the type)
        for column in information_to_delete.__table__.columns:
            if column.name != "uid":
                setattr(information_to_delete, column.name, None)

        # Commit the changes to update the record
        db.commit()
        return f"User {uid} successfully updated with all fields set to null except uid."
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")

@router.put("/{uid}", response_model=InformationResponse)
async def update_information(
    uid: int, userInformation_data: InformationUpdate, db: Session = Depends(get_db)
):
    # Retrieve the User object by its ID
    information_to_update = db.query(UserInformation).filter(UserInformation.uid == uid).first()

    if information_to_update:
        # Update the User object with the new data
        for field, value in userInformation_data.dict().items():
            setattr(information_to_update, field, value)

        db.commit()
        db.refresh(information_to_update)
        return InformationResponse.from_orm(information_to_update)
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")