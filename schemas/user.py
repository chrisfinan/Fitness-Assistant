from typing import List

from pydantic import BaseModel
class UserResponse(BaseModel):
    uid: int
    username: str
    password: str
    first_name: str
    last_name: str
    email_address: str
    phone_number: str

    class Config:
        arbitrary_types_allowed = True
        orm_mode = True

class UserCreate(BaseModel):
    username: str
    password: str
    first_name: str
    last_name: str
    email_address: str
    phone_number: str

class UserUpdate(BaseModel):
    username: str
    password: str
    first_name: str
    last_name: str
    email_address: str
    phone_number: str

# Enable ORM compatibility
    class Config:
        orm_mode = True
