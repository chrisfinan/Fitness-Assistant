-- Table: public.information

-- DROP TABLE IF EXISTS public.information;

CREATE TABLE IF NOT EXISTS public.information
(
    uid integer,
    weight_goal character varying(255) COLLATE pg_catalog."default",
    results character varying(255) COLLATE pg_catalog."default",
    "time" character varying(255) COLLATE pg_catalog."default",
    days integer,
    level character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT fk_users FOREIGN KEY (uid)
        REFERENCES public.users (uid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.information
    OWNER to postgres;