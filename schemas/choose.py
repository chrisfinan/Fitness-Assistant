from enum import Enum
from typing import List
from typing import Optional
from pydantic import BaseModel

class ChooseResponse(BaseModel):
    uid: int
    eid: int

    # Enable ORM compatibility
    class Config:
        orm_mode = True

class ChooseCreate(BaseModel):
    uid: int
    eid: int

    # Enable ORM compatibility
    class Config:
        orm_mode = True

class ChooseUpdate(BaseModel):
    uid: int
    eid: int

    # Enable ORM compatibility
    class Config:
        orm_mode = True