from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.global_vars import DB_PASS, DB_USER, DB_NAME, DB_HOST

# Define connection string
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"

# Create engine
engine = create_engine(DATABASE_URL)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
