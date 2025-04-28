from sqlalchemy.orm import Session
from fastapi import FastAPI, HTTPException, Depends, APIRouter
from app.models import Base, Exercise, UserInformation, Choose, User
from schemas.exercise import ExerciseResponse, ExerciseCreate, ExerciseUpdate
from typing import List
from random import random
import random
from sqlalchemy import and_, or_
from app.db import get_db

router = APIRouter()

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

# Helper function to map time to a number
def get_time_value(time: str) -> int:
    time_mapping = {
        "30-45 minutes": 4,
        "45-60 minutes": 6,
        "More than 1 hour": 8
    }
    if time not in time_mapping:
        raise HTTPException(status_code=400, detail="Invalid time duration")
    return time_mapping[time]

@router.get("/by_info/{uid}", response_model=List[ExerciseResponse])
async def get_exercises_by_info(
    uid: int,
    results: str,
    time: str,
    days: int,
    db: Session = Depends(get_db)
):
    # Validate uid
    user = db.query(User).filter(User.uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update or insert user information
    information = db.query(UserInformation).filter(UserInformation.uid == uid).first()
    if information:
        information.results = results
        information.time = time
        information.days = days
    else:
        information = UserInformation(uid=uid, results=results, time=time, days=days, weight_goal=None, level=None)
        db.add(information)

    db.commit()
    db.refresh(information)

    # PEC Mapping
    pec_mapping = {
        "Strength": ['Powerlifting', 'Ballistics', 'Mobility'],
        "Aesthetics": ['Bodybuilding'],
        "Endurance": ['Calisthenics', 'Grinds', 'Bodybuilding']
    }
    if results not in pec_mapping:
        raise HTTPException(status_code=400, detail="Invalid results type. Choose from Strength, Aesthetics, or Endurance")

    if days not in range(1, 7):
        raise HTTPException(status_code=400, detail="Days must be between 1 and 6")

    time_value = get_time_value(time)
    max_exercises = days * time_value

    # Define condition groups
    condition_groups = []

    if days == 6 or days == 3:
        condition_groups = [
            {"force_type": "Push", "body_region": "Upper Body"},
            {"force_type": "Pull", "body_region": "Upper Body"},
            {"body_region": "Lower Body"}
        ]
    elif days == 5:
        condition_groups = [
            {"target_muscle_group": ["Chest", "Triceps"]},
            {"target_muscle_group": ["Back", "Biceps"]},
            {"target_muscle_group": ["Shoulders", "Trapezius", "Forearms"]},
            {"target_muscle_group": ["Quadriceps", "Adductors", "Abdominals"]},
            {"target_muscle_group": ["Glutes", "Hamstrings", "Abductors"]}
        ]
    elif days == 4:
        condition_groups = [
            {"target_muscle_group": ["Chest", "Triceps"]},
            {"target_muscle_group": ["Back", "Biceps", "Abdominals"]},
            {"target_muscle_group": ["Shoulders", "Trapezius", "Forearms"]},
            {"target_muscle_group": ["Quadriceps", "Glutes", "Hamstrings"]}
        ]
    elif days in [2, 1]:
        condition_groups = [
            {"body_region": ["Upper Body", "Lower Body", "Midsection"]}
        ]

    selected_exercises = []

    for group in condition_groups:
        query = db.query(Exercise).filter(
            Exercise.primary_exercise_classification.in_(pec_mapping[results])
        )

        if "force_type" in group and "body_region" in group:
            query = query.filter(
                Exercise.force_type == group["force_type"],
                Exercise.body_region == group["body_region"]
            )
        elif "target_muscle_group" in group:
            query = query.filter(
                Exercise.target_muscle_group.in_(group["target_muscle_group"])
            )
        elif "body_region" in group:
            body_regions = group["body_region"]
            if isinstance(body_regions, str):
                body_regions = [body_regions]

            query = db.query(Exercise).filter(
                Exercise.body_region.in_(body_regions)
            )
        exercises = query.all()

        if not exercises:
            continue

        if days == 6:
            number_to_select = time_value * 2
        else:
            number_to_select = time_value

        selected = random.sample(exercises, min(len(exercises), number_to_select))
        selected_exercises.extend(selected)

    # Check if we need more exercises
    if len(selected_exercises) < max_exercises:
        remaining = max_exercises - len(selected_exercises)
        all_exercises = db.query(Exercise).filter(
            Exercise.primary_exercise_classification.in_(pec_mapping[results])
        ).all()
        selected_exercises.extend(random.sample(all_exercises, min(len(all_exercises), remaining)))

    # Trim to exactly max_exercises if overshooting
    selected_exercises = selected_exercises[:max_exercises]

    # Update Choose table
    db.query(Choose).filter(Choose.uid == uid).delete()

    new_entries = [Choose(uid=uid, eid=exercise.eid) for exercise in selected_exercises]
    db.bulk_save_objects(new_entries)
    db.commit()

    return [ExerciseResponse.from_orm(exercise) for exercise in selected_exercises]