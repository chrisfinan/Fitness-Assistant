from typing import List

from pydantic import BaseModel
class UserResponse(BaseModel):
    uid: int
    username: str
    password: str
    first_name: str
    last_name: str
    email_address: str

    class Config:
        arbitrary_types_allowed = True
        orm_mode = True

class UserCreate(BaseModel):
    username: str
    password: str
    first_name: str
    last_name: str
    email_address: str

class UserUpdate(BaseModel):
    username: str
    password: str
    first_name: str
    last_name: str
    email_address: str

# Enable ORM compatibility
    class Config:
        orm_mode = True

class UserLogin(BaseModel):
    username: str
    password: str

    class Config:
        orm_mode = True

