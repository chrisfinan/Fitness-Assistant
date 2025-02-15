from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import users, exercises

app = FastAPI()
origins = [
    "http://localhost/",
    "http://localhost/:8000",
]

app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(exercises.router, prefix="/exercises", tags=["Exercises"])

