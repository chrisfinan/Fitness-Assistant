from typing import List

from pydantic import BaseModel
class InformationResponse(BaseModel):
    uid: int
    weight_goal: str
    results: str
    time: str
    days: str
    level: str
    class Config:
        arbitrary_types_allowed = True
        orm_mode = True

class InformationCreate(BaseModel):
    weight_goal: str
    results: str
    time: str
    days: str
    level: str

class InformationUpdate(BaseModel):
    weight_goal: str
    results: str
    time: str
    days: str
    level: str

# Enable ORM compatibility
    class Config:
        orm_mode = True
