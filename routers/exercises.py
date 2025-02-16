from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_PASS, DB_USER, DB_NAME, DB_HOST
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, Exercise
from schemas.exercise import ExerciseResponse, ExerciseCreate, ExerciseUpdate

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
async def list_exercises(skip: int=0, limit: int=10, db: Session = Depends(get_db)):
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
async def update_exercise(
    eid: int, exercise_data: ExerciseUpdate, db: Session = Depends(get_db)
):
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
