-- Table: public.choose

-- DROP TABLE IF EXISTS public.choose;

CREATE TABLE IF NOT EXISTS public.choose
(
    uid integer,
    eid integer,
    CONSTRAINT fk_exercises FOREIGN KEY (eid)
        REFERENCES public.functionalfitnessdatabase (eid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_users FOREIGN KEY (uid)
        REFERENCES public.users (uid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.choose
    OWNER to postgres;