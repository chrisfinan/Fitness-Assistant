from sqlalchemy import (
    Column,
    Integer,
    String,
    ARRAY,
    DateTime,
    Enum,
    Float,
    Double,
    ForeignKey,
    Boolean,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class Exercises(Base):
    __tablename__ = "functionalfitnessdatabase"
    exercise_id = Column(Integer, primary_key=True, index=True)
    exercise = Column(String)
    short_youtube_demonstration = Column(String, name="Short Youtube Demonstration")
    indepth_youtube_explanation = Column(String, name="InDepth Youtube Explanation")
    difficulty_level = Column(String, name="Difficulty Level")
    target_muscle_group = Column(String, name="Target Muscle Group")
    prime_mover_muscle = Column(String, name="Prime Mover Muscle")
    secondary_muscle = Column(String, name="Secondary Muscle")
    tertiary_muscle = Column(String, name="Tertiary Muscle")
    primary_equipment = Column(String, name="Primary Equipment")
    secondary_equipment = Column(String, name="Secondary Equipment")
    body_region = Column(String, name="Body Region")
    force_type = Column(String, name="Force Type")
    mechanics = Column(String)
    primary_exercise_classification = Column(String, name="Primary Exercise Classification")
    setsxreps = Column(String)

class User(Base):
    __tablename__ = "users"
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String)
    password = Column(String)
    first_name = Column(String)
    last_name = Column(String)
    email_address = Column(String)
    phone_number = Column(String)

class UserInformation(Base):
    __tablename__ = "information"
    user_id = Column(Integer, ForeignKey('User.user_id', ondelete='CASCADE'), nullable=False)
    user = relationship('User', backred='users')
    weight_goal = Column(String)
    results = Column(String)
    time = Column(String)
    days = Column(Integer)
    level = Column(String)

class Choices(Base):
    __tablename__ = "choose"
    user_id = Column(Integer, ForeignKey('User.user_id', ondelete='CASCADE'), nullable=False)
    user = relationship('User', backred='users')
    exercise_id = Column(Integer, ForeignKey('Exercises.exercises_id', ondelete='CASCADE'), nullable=False)
    exercise = relationship('Exercises', backred='functionalfitnessdatabase')
