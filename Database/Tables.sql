CREATE TABLE Users(
   user_ID                           SERIAL  NOT NULL PRIMARY KEY
  ,username                          VARCHAR(255)
  ,first_name                        VARCHAR(255)
  ,last_name                         VARCHAR(255)
  ,emil_address                      VARCHAR(255)
  ,phone_number                      VARCHAR(255)
);
 
CREATE TABLE Information(
   user_ID                           INTEGER NOT NULL PRIMARY KEY
  ,weight_goal                       VARCHAR(255)
  ,results                           VARCHAR(255)
  ,time                              VARCHAR(255)
  ,days                              INT
  ,level                             VARCHAR(255)
  ,CONSTRAINT fk_users FOREIGN KEY (user_ID) REFERENCES Users(user_ID)
);

alter table information
add constraint r_settings CHECK(results in ('Strength', 'Aesthetics', 'Endurance'));
alter table information
add constraint wg_settings CHECK(weight_goal in ('Gain', 'Lose'));
alter table information
add constraint t_settings CHECK(time in ('30-45 mins', '45-60 mins', 'More than 1 hour'));
alter table information
add constraint d_settings CHECK(days>0 AND days<7);
alter table information
add constraint l_settings CHECK(level in ('Beginner', 'Novice', 'Intermediate', 'Advanced', 'Expert', 'Master', 'Legendary'));

