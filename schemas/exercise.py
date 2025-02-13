from enum import Enum
from typing import List

from pydantic import BaseModel

class ExerciseResponse(BaseModel):
    eid: int
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