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
    UniqueConstraint,
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
    username = Column(String, unique=True)
    password = Column(String)
    first_name = Column(String, nullable=True)
    last_name = Column(String, nullable=True)
    email_address = Column(String, nullable=True)

class UserInformation(Base):
    __tablename__ = "information"
    uid = Column(Integer, ForeignKey('users.uid', ondelete='CASCADE'), primary_key=True)
    user = relationship('User', backref='users', foreign_keys=[uid])
    weight_goal = Column(String, nullable=True)
    results = Column(String, nullable=True)
    time = Column(String, nullable=True)
    days = Column(Integer, nullable=True)
    level = Column(String,nullable=True)


class Choose(Base):
    __tablename__ = "choose"

    uid = Column(Integer, ForeignKey('users.uid', ondelete='CASCADE'), primary_key=True)
    eid = Column(Integer, ForeignKey('functionalfitnessdatabase.eid', ondelete='CASCADE'), primary_key=True)

    # Relationships
    user = relationship('User', backref='chooses', foreign_keys=[uid])
    exercise = relationship('Exercise', backref='choose', foreign_keys=[eid])

    # Unique constraint for the combination of uid and eid (optional, since it's already a primary key)
    __table_args__ = (
        UniqueConstraint('uid', 'eid', name='_uid_eid_uc'),
    )