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
    short_youtube_demonstration = Column(String, name="Short YouTube Demonstration", nullable=True)
    indepth_youtube_explanation = Column(String, name="InDepth YouTube Explanation", nullable=True)
    difficulty_level = Column(String, name="Difficulty Level", nullable=True)
    target_muscle_group = Column(String, name="Target Muscle Group", nullable=True)
    prime_mover_muscle = Column(String, name="Prime Mover Muscle", nullable=True)
    secondary_muscle = Column(String, name="Secondary Muscle", nullable=True)
    tertiary_muscle = Column(String, name="Tertiary Muscle", nullable=True)
    primary_equipment = Column(String, name="Primary Equipment", nullable=True)
    secondary_equipment = Column(String, name="Secondary Equipment", nullable=True)
    body_region = Column(String, name="Body Region", nullable=True)
    force_type = Column(String, name="Force Type", nullable=True)
    mechanics = Column(String, nullable=True)
    primary_exercise_classification = Column(String, name="Primary Exercise Classification", nullable=True)
    setsxreps = Column(String, nullable=True)

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
