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

class Exercise(Base):
    __tablename__ = "functionalfitnessdatabase"
    eid = Column(Integer, primary_key=True, index=True, autoincrement=True)
    exercise = Column(String)
    short_youtube_demonstration = Column(String, name="Short YouTube Demonstration")
    indepth_youtube_explanation = Column(String, name="InDepth YouTube Explanation")
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
    uid: int = Column(Integer, primary_key=True, index=True, autoincrement=True)
    username = Column(String)
    password = Column(String)
    first_name = Column(String)
    last_name = Column(String)
    email_address = Column(String)
    phone_number = Column(String)

class UserInformation(Base):
    __tablename__ = "information"
    uid = Column(Integer, ForeignKey('users.uid', ondelete='CASCADE'), primary_key=True)
    user = relationship('User', backref='users', foreign_keys=[uid])
    weight_goal = Column(String)
    results = Column(String)
    time = Column(String)
    days = Column(Integer)
    level = Column(String)

class Choice(Base):
    __tablename__ = "choose"
    uid = Column(Integer, ForeignKey('users.uid', ondelete='CASCADE'), primary_key=True)
    user = relationship('User', backref='chooses', foreign_keys=[uid])
    eid = Column(Integer, ForeignKey('functionalfitnessdatabase.eid', ondelete='CASCADE'))
    exercise = relationship('Exercise', backref='choose', foreign_keys=[eid])
