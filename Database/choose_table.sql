CREATE TABLE choose(
   user_ID                           INTEGER
  ,exercise_ID                       INTEGER
  ,CONSTRAINT fk_users FOREIGN KEY (user_ID) REFERENCES Users(user_ID)
  ,CONSTRAINT fk_exercises FOREIGN KEY (exercise_ID) REFERENCES functionalfitnessdatabase(exercise_ID)
);
 