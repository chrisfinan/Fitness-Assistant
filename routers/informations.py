from sqlalchemy.orm import Session
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, UserInformation
from schemas.information import InformationUpdate, InformationResponse
from app.db import get_db

router = APIRouter()


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
    # Get uid
    information_to_delete = db.query(UserInformation).filter(UserInformation.uid == uid).first()

    if information_to_delete:
        # Set every field except for `uid` to None (or empty, depending on the type)
        for column in information_to_delete.__table__.columns:
            if column.name != "uid":
                setattr(information_to_delete, column.name, None)

        db.commit()
        return f"User {uid} successfully updated with all fields set to null except uid."
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")

@router.put("/{uid}", response_model=InformationResponse)
async def update_information(
    uid: int, userInformation_data: InformationUpdate, db: Session = Depends(get_db)
):
    # Get uid
    information_to_update = db.query(UserInformation).filter(UserInformation.uid == uid).first()

    if information_to_update:
        # Update user survey information
        for field, value in userInformation_data.dict().items():
            setattr(information_to_update, field, value)

        db.commit()
        db.refresh(information_to_update)
        return InformationResponse.from_orm(information_to_update)
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {uid} not found")