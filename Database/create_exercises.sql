-- Table: public.functionalfitnessdatabase

-- DROP TABLE IF EXISTS public.functionalfitnessdatabase;

CREATE TABLE IF NOT EXISTS public.functionalfitnessdatabase
(
    eid integer NOT NULL DEFAULT nextval('functionalfitnessdatabase_eid_seq'::regclass),
    exercise character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Short YouTube Demonstration" character varying(500) COLLATE pg_catalog."default",
    "InDepth YouTube Explanation" character varying(500) COLLATE pg_catalog."default",
    "Difficulty Level" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Target Muscle Group" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Prime Mover Muscle" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Secondary Muscle" character varying(255) COLLATE pg_catalog."default",
    "Tertiary Muscle" character varying(255) COLLATE pg_catalog."default",
    "Primary Equipment" character varying(255) COLLATE pg_catalog."default",
    "Secondary Equipment" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Body Region" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Force Type" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    mechanics character varying(255) COLLATE pg_catalog."default",
    "Primary Exercise Classification" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    setsxreps character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT functionalfitnessdatabase_pkey PRIMARY KEY (eid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.functionalfitnessdatabase
    OWNER to postgres;