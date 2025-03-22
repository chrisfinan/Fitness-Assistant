from enum import Enum
from typing import List
from typing import Optional
from pydantic import BaseModel

class InformationResponse(BaseModel):
    uid: int
    weight_goal: Optional[str] = None
    results: Optional[str] = None
    time: Optional[str] = None
    days: Optional[int] = None
    level: Optional[str] = None
    class Config:
        arbitrary_types_allowed = True
        orm_mode = True

class InformationCreate(BaseModel):
    weight_goal: Optional[str] = None
    results: Optional[str] = None
    time: Optional[str] = None
    days: Optional[int] = None
    level: Optional[str] = None

class InformationUpdate(BaseModel):
    weight_goal: Optional[str] = None
    results: Optional[str] = None
    time: Optional[str] = None
    days: Optional[int] = None
    level: Optional[str] = None

# Enable ORM compatibility
    class Config:
        orm_mode = True