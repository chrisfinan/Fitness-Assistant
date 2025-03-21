from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_PASS, DB_USER, DB_NAME, DB_HOST
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, Exercise, UserInformation, Choose, User
from schemas.exercise import ExerciseResponse, ExerciseCreate, ExerciseUpdate
from typing import List
from operator import or_
from random import random
import random
from routers.users import get_user_by_uid

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


@router.get("/{eid}", response_model=ExerciseResponse)
async def get_exercise_by_eid(eid: int, db: Session = Depends(get_db)):
    exercise = db.query(Exercise).filter(Exercise.eid == eid).first()
    if exercise is None:
        raise HTTPException(status_code=404, detail=f"Exercise {eid} not found")
    return ExerciseResponse.from_orm(exercise)


@router.get("", response_model=list[ExerciseResponse])
async def list_exercises(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    exercises = db.query(Exercise).offset(skip).limit(limit).all()
    return [ExerciseResponse.from_orm(exercise) for exercise in exercises]


@router.post("", response_model=ExerciseResponse)
async def create_exercise(exercise: ExerciseCreate, db: Session = Depends(get_db)):
    # Create a new exercise in the database
    new_exercise = Exercise(
        exercise=exercise.exercise,
        short_youtube_demonstration=exercise.short_youtube_demonstration,
        indepth_youtube_explanation=exercise.indepth_youtube_explanation,
        difficulty_level=exercise.difficulty_level,
        target_muscle_group=exercise.target_muscle_group,
        prime_mover_muscle=exercise.prime_mover_muscle,
        secondary_muscle=exercise.secondary_muscle,
        tertiary_muscle=exercise.tertiary_muscle,
        primary_equipment=exercise.primary_equipment,
        secondary_equipment=exercise.secondary_equipment,
        body_region=exercise.body_region,
        force_type=exercise.force_type,
        mechanics=exercise.mechanics,
        primary_exercise_classification=exercise.primary_exercise_classification,
        setsxreps=exercise.setsxreps
    )
    db.add(new_exercise)
    db.commit()
    db.refresh(new_exercise)
    return ExerciseResponse.from_orm(new_exercise)


@router.delete("/{eid}", response_model=str)
async def delete_exercise(eid: int, db: Session = Depends(get_db)):
    # Retrieve the Exercise object by its ID
    exercise_to_delete = db.query(Exercise).filter(Exercise.eid == eid).first()

    if exercise_to_delete:
        # Delete the Exercise object
        db.delete(exercise_to_delete)
        db.commit()
        return f"Exercise {eid} successfully deleted."
    else:
        raise HTTPException(status_code=404, detail=f"Exercise with ID {eid} not found")


@router.put("/{eid}", response_model=ExerciseResponse)
async def update_exercise(eid: int, exercise_data: ExerciseUpdate, db: Session = Depends(get_db)):
    exercise_to_update = db.query(Exercise).filter(Exercise.eid == eid).first()

    if exercise_to_update:
        # Update the Exercise object with the new data
        for field, value in exercise_data.dict().items():
            setattr(exercise_to_update, field, value)

        db.commit()
        db.refresh(exercise_to_update)
        return ExerciseResponse.from_orm(exercise_to_update)
    else:
        raise HTTPException(status_code=404, detail=f"Exercise with ID {eid} not found")


# Helper function to get max number of exercises based on time and days
def get_max_exercises(time: str, days: int) -> int:
    time_mapping = {
        "30-45 minutes": 4,
        "45-60 minutes": 6,
        "More than 1 hour": 8
    }

    # Validate time
    if time not in time_mapping:
        raise HTTPException(status_code=400, detail="Invalid time duration")
    return time_mapping[time] * days


@router.get("/by_info/{uid}", response_model=List[ExerciseResponse])
async def get_exercises_by_info(
        uid: int,
        results: str,
        time: str,
        days: int,
        db: Session = Depends(get_db)
):
    # Validate that the uid exists
    user = db.query(User).filter(User.uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update or insert user information
    information_to_update = db.query(UserInformation).filter(UserInformation.uid == uid).first()

    if information_to_update:
        # Update existing record
        information_to_update.results = results
        information_to_update.time = time
        information_to_update.days = days
    else:
        # Create new record if not found
        information_to_update = UserInformation(
            uid=uid,
            results=results,
            time=time,
            days=days,
            weight_goal=None,
            level=None
        )
        db.add(information_to_update)

    db.commit()
    db.refresh(information_to_update)

    # Define PEC mapping
    pec_mapping = {
        "Strength": ['Powerlifting', 'Ballistics', 'Mobility'],
        "Aesthetics": ['Bodybuilding'],
        "Endurance": ['Calisthenics', 'Grinds', 'Bodybuilding']
    }

    if results not in pec_mapping:
        raise HTTPException(status_code=400,
                            detail="Invalid results type. Choose from Strength, Aesthetics, or Endurance")

    if days not in range(1, 7):
        raise HTTPException(status_code=400, detail="Days must be between 1 and 6")

    max_exercises = get_max_exercises(time, days)

    # Query all exercises filtering by results
    exercises = (
        db.query(Exercise)
        .filter(Exercise.primary_exercise_classification.in_(pec_mapping[results]))
    )

    # Apply day-based filters
    if days in [3, 6]:
        exercises = exercises.filter(
            or_(
                Exercise.force_type.in_(["Push", "Pull"]),
                Exercise.body_region == "Lower Body"
            )
        )
    elif days in [4, 5]:
        exercises = exercises.filter(
            Exercise.target_muscle_group.in_([
                "Chest", "Triceps", "Back", "Biceps", "Shoulders", "Trapezius", "Forearms",
                "Quadriceps", "Adductors", "Abdominals", "Glutes", "Hamstrings", "Abductors"
            ])
        )
    elif days in [1, 2]:
        exercises = exercises.filter(
            Exercise.body_region.in_(["Upper Body", "Lower Body", "Midsection"])
        )

    exercises = exercises.all()

    if not exercises:
        raise HTTPException(status_code=404, detail="No exercises found")

    # Randomly filter exercises down to max_exercises limit
    selected_exercises = random.sample(exercises, min(len(exercises), max_exercises))

    # Delete existing entries in Choose table for user entered
    db.query(Choose).filter(Choose.uid == uid).delete()

    # Insert new selected exercises into Choose table for this user
    new_entries = [Choose(uid=uid, eid=exercise.eid) for exercise in selected_exercises]
    db.bulk_save_objects(new_entries)

    db.commit()  # Commit transaction to apply changes

    return [ExerciseResponse.from_orm(exercise) for exercise in selected_exercises]