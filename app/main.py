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

# Include routers so their APIs are in FastAPI
#app.include_router(users.router, prefix="/users", tags=["Users"])
#/ app.include_router(trips.router, prefix="/trips", tags=["Trips"])
#app.include_router(
#    campus_locations.router, prefix="/campus_locations", tags=["Campus Locations"]
#)
#app.include_router(vehicles.router, prefix="/vehicles", tags=["Vehicles"])
#app.include_router(shuttles.router, prefix="/shuttles", tags=["Shuttles"])
#app.include_router(drivers.router, prefix="/drivers", tags=["Drivers"])
