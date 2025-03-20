from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import users, exercises, informations, chooses

app = FastAPI()
origins = [
    "http://localhost/",
    "http://localhost/:8000",
]

app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(exercises.router, prefix="/exercises", tags=["Exercises"])
app.include_router(informations.router, prefix="/informations", tags=["Informations"])
app.include_router(chooses.router, prefix="/chooses", tags=["Chooses"])

