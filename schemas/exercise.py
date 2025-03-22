from enum import Enum
from typing import List
from typing import Optional
from pydantic import BaseModel

class ExerciseResponse(BaseModel):
    eid: int
    exercise: Optional[str] = None
    short_youtube_demonstration: Optional[str] = None
    indepth_youtube_explanation: Optional[str] = None
    difficulty_level: Optional[str] = None
    target_muscle_group: Optional[str] = None
    prime_mover_muscle: Optional[str] = None
    secondary_muscle: Optional[str] = None
    tertiary_muscle: Optional[str] = None
    primary_equipment: Optional[str] = None
    secondary_equipment: Optional[str] = None
    body_region: Optional[str] = None
    force_type: Optional[str] = None
    mechanics: Optional[str] = None
    primary_exercise_classification: Optional[str] = None
    setsxreps: Optional[str] = None

    # Enable ORM compatibility
    class Config:
        orm_mode = True

class ExerciseCreate(BaseModel):
    exercise: str
    short_youtube_demonstration: str
    indepth_youtube_explanation: str
    difficulty_level: str
    target_muscle_group: str
    prime_mover_muscle: str
    secondary_muscle: str
    tertiary_muscle: str
    primary_equipment: str
    secondary_equipment: str
    body_region: str
    force_type: str
    mechanics: str
    primary_exercise_classification: str
    setsxreps: str

class ExerciseUpdate(BaseModel):
    exercise: str
    short_youtube_demonstration: str
    indepth_youtube_explanation: str
    difficulty_level: str
    target_muscle_group: str
    prime_mover_muscle: str
    secondary_muscle: str
    tertiary_muscle: str
    primary_equipment: str
    secondary_equipment: str
    body_region: str
    force_type: str
    mechanics: str
    primary_exercise_classification: str
    setsxreps: str