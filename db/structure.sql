--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

--
-- Name: pg_search_dmetaphone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pg_search_dmetaphone(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: friendships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friendships (
    id integer NOT NULL,
    buddy_id integer,
    friend_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: friendships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendships_id_seq OWNED BY friendships.id;


--
-- Name: interests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE interests (
    id integer NOT NULL,
    watched_on timestamp without time zone,
    user_id integer,
    movie_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rating integer
);


--
-- Name: interests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE interests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE interests_id_seq OWNED BY interests.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE jobs (
    id integer NOT NULL,
    title character varying,
    person_id integer,
    movie_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: movies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE movies (
    id integer NOT NULL,
    title character varying,
    original_title character varying,
    runtime integer,
    tagline character varying,
    credits json,
    poster_url character varying,
    trailer_url character varying,
    website_url character varying,
    imdb_id character varying,
    cnc_url character varying,
    tmdb_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    genres json,
    overview text,
    popularity double precision,
    original_language character varying,
    spoken_languages text,
    release_date date,
    imdb_score double precision,
    collection json,
    setup boolean DEFAULT false,
    adult boolean DEFAULT false,
    fr_title character varying,
    fr_tagline character varying,
    fr_overview character varying,
    fr_release_date date,
    tsv tsvector
);


--
-- Name: movies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE movies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: movies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE movies_id_seq OWNED BY movies.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE people (
    id integer NOT NULL,
    name character varying,
    tmdb_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE providers (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE providers_id_seq OWNED BY providers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE shows (
    id integer NOT NULL,
    starts_at timestamp without time zone,
    movie_id integer,
    theater_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE shows_id_seq OWNED BY shows.id;


--
-- Name: streamings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE streamings (
    id integer NOT NULL,
    consumption character varying,
    link character varying,
    price integer,
    movie_id integer,
    provider_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: streamings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE streamings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: streamings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE streamings_id_seq OWNED BY streamings.id;


--
-- Name: theaters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE theaters (
    id integer NOT NULL,
    address character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    latitude double precision,
    longitude double precision
);


--
-- Name: theaters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE theaters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: theaters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE theaters_id_seq OWNED BY theaters.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    address character varying,
    provider character varying,
    uid character varying,
    picture character varying,
    first_name character varying,
    last_name character varying,
    token character varying,
    token_expiry timestamp without time zone,
    access_token character varying,
    full_name_friendlist character varying,
    fullname character varying,
    zip_code character varying DEFAULT '75001'::character varying,
    city character varying DEFAULT 'Paris'::character varying,
    admin boolean DEFAULT false NOT NULL,
    friendslist json,
    messenger_id character varying,
    secondary_email character varying,
    newsletter boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendships ALTER COLUMN id SET DEFAULT nextval('friendships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY interests ALTER COLUMN id SET DEFAULT nextval('interests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY movies ALTER COLUMN id SET DEFAULT nextval('movies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY providers ALTER COLUMN id SET DEFAULT nextval('providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY shows ALTER COLUMN id SET DEFAULT nextval('shows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY streamings ALTER COLUMN id SET DEFAULT nextval('streamings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY theaters ALTER COLUMN id SET DEFAULT nextval('theaters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: interests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY interests
    ADD CONSTRAINT interests_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: movies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: shows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shows
    ADD CONSTRAINT shows_pkey PRIMARY KEY (id);


--
-- Name: streamings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY streamings
    ADD CONSTRAINT streamings_pkey PRIMARY KEY (id);


--
-- Name: theaters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY theaters
    ADD CONSTRAINT theaters_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_friendships_on_buddy_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendships_on_buddy_id ON friendships USING btree (buddy_id);


--
-- Name: index_friendships_on_friend_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendships_on_friend_id ON friendships USING btree (friend_id);


--
-- Name: index_interests_on_movie_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_interests_on_movie_id ON interests USING btree (movie_id);


--
-- Name: index_interests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_interests_on_user_id ON interests USING btree (user_id);


--
-- Name: index_jobs_on_movie_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_movie_id ON jobs USING btree (movie_id);


--
-- Name: index_jobs_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_person_id ON jobs USING btree (person_id);


--
-- Name: index_movies_on_fr_title_and_original_title_and_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_movies_on_fr_title_and_original_title_and_title ON movies USING btree (fr_title, original_title, title);


--
-- Name: index_movies_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_movies_on_tsv ON movies USING gin (tsv);


--
-- Name: index_shows_on_movie_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shows_on_movie_id ON shows USING btree (movie_id);


--
-- Name: index_shows_on_theater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shows_on_theater_id ON shows USING btree (theater_id);


--
-- Name: index_streamings_on_movie_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_streamings_on_movie_id ON streamings USING btree (movie_id);


--
-- Name: index_streamings_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_streamings_on_provider_id ON streamings USING btree (provider_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON movies FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tsv', 'pg_catalog.english', 'fr_title', 'original_title', 'title');


--
-- Name: fk_rails_461174dca7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_rails_461174dca7 FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: fk_rails_71a7989ee7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY streamings
    ADD CONSTRAINT fk_rails_71a7989ee7 FOREIGN KEY (provider_id) REFERENCES providers(id);


--
-- Name: fk_rails_8b73576aa5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_rails_8b73576aa5 FOREIGN KEY (movie_id) REFERENCES movies(id);


--
-- Name: fk_rails_9e13f841bc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shows
    ADD CONSTRAINT fk_rails_9e13f841bc FOREIGN KEY (movie_id) REFERENCES movies(id);


--
-- Name: fk_rails_b57b7eda41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY interests
    ADD CONSTRAINT fk_rails_b57b7eda41 FOREIGN KEY (movie_id) REFERENCES movies(id);


--
-- Name: fk_rails_c57c8539e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY streamings
    ADD CONSTRAINT fk_rails_c57c8539e2 FOREIGN KEY (movie_id) REFERENCES movies(id);


--
-- Name: fk_rails_cca9363be1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shows
    ADD CONSTRAINT fk_rails_cca9363be1 FOREIGN KEY (theater_id) REFERENCES theaters(id);


--
-- Name: fk_rails_fba4c79abd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY interests
    ADD CONSTRAINT fk_rails_fba4c79abd FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20160520193725');

INSERT INTO schema_migrations (version) VALUES ('20160523164004');

INSERT INTO schema_migrations (version) VALUES ('20160523165427');

INSERT INTO schema_migrations (version) VALUES ('20160523170410');

INSERT INTO schema_migrations (version) VALUES ('20160523170444');

INSERT INTO schema_migrations (version) VALUES ('20160523170510');

INSERT INTO schema_migrations (version) VALUES ('20160523170708');

INSERT INTO schema_migrations (version) VALUES ('20160523171104');

INSERT INTO schema_migrations (version) VALUES ('20160523205130');

INSERT INTO schema_migrations (version) VALUES ('20160524101626');

INSERT INTO schema_migrations (version) VALUES ('20160524204838');

INSERT INTO schema_migrations (version) VALUES ('20160524220331');

INSERT INTO schema_migrations (version) VALUES ('20160525101829');

INSERT INTO schema_migrations (version) VALUES ('20160525105316');

INSERT INTO schema_migrations (version) VALUES ('20160525132004');

INSERT INTO schema_migrations (version) VALUES ('20160525153139');

INSERT INTO schema_migrations (version) VALUES ('20160525160750');

INSERT INTO schema_migrations (version) VALUES ('20160525164957');

INSERT INTO schema_migrations (version) VALUES ('20160525170649');

INSERT INTO schema_migrations (version) VALUES ('20160530091055');

INSERT INTO schema_migrations (version) VALUES ('20160530093806');

INSERT INTO schema_migrations (version) VALUES ('20160530102020');

INSERT INTO schema_migrations (version) VALUES ('20160602184306');

INSERT INTO schema_migrations (version) VALUES ('20160609081121');

INSERT INTO schema_migrations (version) VALUES ('20160609151850');

INSERT INTO schema_migrations (version) VALUES ('20160613161204');

INSERT INTO schema_migrations (version) VALUES ('20160614131904');

INSERT INTO schema_migrations (version) VALUES ('20160614132013');

INSERT INTO schema_migrations (version) VALUES ('20160614141846');

INSERT INTO schema_migrations (version) VALUES ('20160615210426');

INSERT INTO schema_migrations (version) VALUES ('20160627101521');

INSERT INTO schema_migrations (version) VALUES ('20160627101908');

INSERT INTO schema_migrations (version) VALUES ('20160628142925');

INSERT INTO schema_migrations (version) VALUES ('20160829160529');

INSERT INTO schema_migrations (version) VALUES ('20160830141737');

