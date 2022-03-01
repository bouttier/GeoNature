--
-- PostgreSQL database dump
--

-- Dumped from database version 13.6 (Debian 13.6-1.pgdg110+1)
-- Dumped by pg_dump version 14.2 (Ubuntu 14.2-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ref_geo; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA ref_geo;


ALTER SCHEMA ref_geo OWNER TO geonatadmin;

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO geonatadmin;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO geonatadmin;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO geonatadmin;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: geonatadmin
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: fct_trg_meta_dates_change(); Type: FUNCTION; Schema: public; Owner: geonatadmin
--

CREATE FUNCTION public.fct_trg_meta_dates_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            IF(TG_OP = 'INSERT') THEN
                    NEW.meta_create_date = NOW();
            ELSIF(TG_OP = 'UPDATE') THEN
                    NEW.meta_update_date = NOW();
                    IF(NEW.meta_create_date IS NULL) THEN
                            NEW.meta_create_date = NOW();
                    END IF;
            END IF;
            RETURN NEW;
        END;
    $$;


ALTER FUNCTION public.fct_trg_meta_dates_change() OWNER TO geonatadmin;

--
-- Name: fct_get_altitude_intersection(public.geometry); Type: FUNCTION; Schema: ref_geo; Owner: geonatadmin
--

CREATE FUNCTION ref_geo.fct_get_altitude_intersection(mygeom public.geometry) RETURNS TABLE(altitude_min integer, altitude_max integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    thesrid int;
    is_vectorized int;
BEGIN
  SELECT gn_commons.get_default_parameter('local_srid', NULL) INTO thesrid;
  SELECT COALESCE(gid, NULL) FROM ref_geo.dem_vector LIMIT 1 INTO is_vectorized;

  IF is_vectorized IS NULL THEN
    -- Use dem
    RETURN QUERY
    SELECT min((altitude).val)::integer AS altitude_min, max((altitude).val)::integer AS altitude_max
    FROM (
	SELECT public.ST_DumpAsPolygons(public.ST_clip(
    rast,
    1,
	  public.st_transform(myGeom,thesrid),
    true)
  ) AS altitude
	FROM ref_geo.dem AS altitude
	WHERE public.st_intersects(rast,public.st_transform(myGeom,thesrid))
    ) AS a;
  -- Use dem_vector
  ELSE
    RETURN QUERY
    WITH d  as (
        SELECT public.st_transform(myGeom,thesrid) a
     )
    SELECT min(val)::int as altitude_min, max(val)::int as altitude_max
    FROM ref_geo.dem_vector, d
    WHERE public.st_intersects(a,geom);
  END IF;
END;
$$;


ALTER FUNCTION ref_geo.fct_get_altitude_intersection(mygeom public.geometry) OWNER TO geonatadmin;

--
-- Name: fct_get_area_intersection(public.geometry, integer); Type: FUNCTION; Schema: ref_geo; Owner: geonatadmin
--

CREATE FUNCTION ref_geo.fct_get_area_intersection(mygeom public.geometry, myidtype integer DEFAULT NULL::integer) RETURNS TABLE(id_area integer, id_type integer, area_code character varying, area_name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
  isrid int;
BEGIN
  SELECT gn_commons.get_default_parameter('local_srid', NULL) INTO isrid;
  RETURN QUERY
  WITH d  as (
      SELECT public.st_transform(myGeom,isrid) geom_trans
  )
  SELECT a.id_area, a.id_type, a.area_code, a.area_name
  FROM ref_geo.l_areas a, d
  WHERE public.st_intersects(geom_trans, a.geom)
    AND (myIdType IS NULL OR a.id_type = myIdType)
    AND enable=true;
END;
$$;


ALTER FUNCTION ref_geo.fct_get_area_intersection(mygeom public.geometry, myidtype integer) OWNER TO geonatadmin;

--
-- Name: fct_trg_calculate_alt_minmax(); Type: FUNCTION; Schema: ref_geo; Owner: geonatadmin
--

CREATE FUNCTION ref_geo.fct_trg_calculate_alt_minmax() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	the4326geomcol text := quote_ident(TG_ARGV[0]);
  thelocalsrid int;
BEGIN
	-- si c'est un insert et que l'altitude min ou max est null -> on calcule
	IF (TG_OP = 'INSERT' and (new.altitude_min IS NULL or new.altitude_max IS NULL)) THEN 
		--récupérer le srid local
		SELECT INTO thelocalsrid parameter_value::int FROM gn_commons.t_parameters WHERE parameter_name = 'local_srid';
		--Calcul de l'altitude
		
    SELECT (ref_geo.fct_get_altitude_intersection(st_transform(hstore(NEW)-> the4326geomcol,thelocalsrid))).*  INTO NEW.altitude_min, NEW.altitude_max;
    -- si c'est un update et que la geom a changé
  ELSIF (TG_OP = 'UPDATE' AND NOT public.ST_EQUALS(hstore(OLD)-> the4326geomcol, hstore(NEW)-> the4326geomcol)) then
	 -- on vérifie que les altitude ne sont pas null 
   -- OU si les altitudes ont changé, si oui =  elles ont déjà été calculés - on ne relance pas le calcul
	   IF (new.altitude_min is null or new.altitude_max is null) OR (NOT OLD.altitude_min = NEW.altitude_min or NOT OLD.altitude_max = OLD.altitude_max) THEN 
	   --récupérer le srid local	
	   SELECT INTO thelocalsrid parameter_value::int FROM gn_commons.t_parameters WHERE parameter_name = 'local_srid';
		--Calcul de l'altitude
        SELECT (ref_geo.fct_get_altitude_intersection(st_transform(hstore(NEW)-> the4326geomcol,thelocalsrid))).*  INTO NEW.altitude_min, NEW.altitude_max;
	   end IF;
	 else 
	 END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION ref_geo.fct_trg_calculate_alt_minmax() OWNER TO geonatadmin;

--
-- Name: fct_trg_calculate_geom_local(); Type: FUNCTION; Schema: ref_geo; Owner: geonatadmin
--

CREATE FUNCTION ref_geo.fct_trg_calculate_geom_local() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
	the4326geomcol text := quote_ident(TG_ARGV[0]);
	thelocalgeomcol text := quote_ident(TG_ARGV[1]);
        thelocalsrid int;
        thegeomlocalvalue public.geometry;
        thegeomchange boolean;
BEGIN
	-- si c'est un insert ou que c'est un UPDATE ET que le geom_4326 a été modifié
	IF (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NOT public.ST_EQUALS(hstore(OLD)-> the4326geomcol, hstore(NEW)-> the4326geomcol)  )) THEN
		--récupérer le srid local
		SELECT INTO thelocalsrid parameter_value::int FROM gn_commons.t_parameters WHERE parameter_name = 'local_srid';
		EXECUTE FORMAT ('SELECT public.ST_TRANSFORM($1.%I, $2)',the4326geomcol) INTO thegeomlocalvalue USING NEW, thelocalsrid;
                -- insertion dans le NEW de la geom transformée
		NEW := NEW#= hstore(thelocalgeomcol, thegeomlocalvalue);
	END IF;
  RETURN NEW;
END;
$_$;


ALTER FUNCTION ref_geo.fct_trg_calculate_geom_local() OWNER TO geonatadmin;

--
-- Name: fct_tri_calculate_geojson(); Type: FUNCTION; Schema: ref_geo; Owner: geonatadmin
--

CREATE FUNCTION ref_geo.fct_tri_calculate_geojson() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      NEW.geojson_4326 = public.ST_asgeojson(public.st_transform(NEW.geom, 4326));
      RETURN NEW;
    END;
  $$;


ALTER FUNCTION ref_geo.fct_tri_calculate_geojson() OWNER TO geonatadmin;

--
-- Name: get_id_area_type(character varying); Type: FUNCTION; Schema: ref_geo; Owner: geonatadmin
--

CREATE FUNCTION ref_geo.get_id_area_type(mytype character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function which return the id_type_area from the type_code of an area type
DECLARE theidtype character varying;
  BEGIN
SELECT INTO theidtype id_type FROM ref_geo.bib_areas_types WHERE type_code = mytype;
return theidtype;
  END;
$$;


ALTER FUNCTION ref_geo.get_id_area_type(mytype character varying) OWNER TO geonatadmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: geonatadmin
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO geonatadmin;

--
-- Name: bib_areas_types; Type: TABLE; Schema: ref_geo; Owner: geonatadmin
--

CREATE TABLE ref_geo.bib_areas_types (
    id_type integer NOT NULL,
    type_name character varying(200) NOT NULL,
    type_code character varying(25) NOT NULL,
    type_desc text,
    ref_name character varying(200),
    ref_version integer,
    num_version character varying(50)
);


ALTER TABLE ref_geo.bib_areas_types OWNER TO geonatadmin;

--
-- Name: COLUMN bib_areas_types.ref_name; Type: COMMENT; Schema: ref_geo; Owner: geonatadmin
--

COMMENT ON COLUMN ref_geo.bib_areas_types.ref_name IS 'Indique le nom du référentiel géographique utilisé pour ce type';


--
-- Name: COLUMN bib_areas_types.ref_version; Type: COMMENT; Schema: ref_geo; Owner: geonatadmin
--

COMMENT ON COLUMN ref_geo.bib_areas_types.ref_version IS 'Indique l''année du référentiel utilisé';


--
-- Name: bib_areas_types_id_type_seq; Type: SEQUENCE; Schema: ref_geo; Owner: geonatadmin
--

CREATE SEQUENCE ref_geo.bib_areas_types_id_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_geo.bib_areas_types_id_type_seq OWNER TO geonatadmin;

--
-- Name: bib_areas_types_id_type_seq; Type: SEQUENCE OWNED BY; Schema: ref_geo; Owner: geonatadmin
--

ALTER SEQUENCE ref_geo.bib_areas_types_id_type_seq OWNED BY ref_geo.bib_areas_types.id_type;


--
-- Name: dem; Type: TABLE; Schema: ref_geo; Owner: geonatadmin
--

CREATE TABLE ref_geo.dem (
    rid integer NOT NULL,
    rast public.raster
);


ALTER TABLE ref_geo.dem OWNER TO geonatadmin;

--
-- Name: dem_rid_seq; Type: SEQUENCE; Schema: ref_geo; Owner: geonatadmin
--

CREATE SEQUENCE ref_geo.dem_rid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_geo.dem_rid_seq OWNER TO geonatadmin;

--
-- Name: dem_rid_seq; Type: SEQUENCE OWNED BY; Schema: ref_geo; Owner: geonatadmin
--

ALTER SEQUENCE ref_geo.dem_rid_seq OWNED BY ref_geo.dem.rid;


--
-- Name: dem_vector; Type: TABLE; Schema: ref_geo; Owner: geonatadmin
--

CREATE TABLE ref_geo.dem_vector (
    gid integer NOT NULL,
    geom public.geometry(Geometry,2154),
    val double precision
);


ALTER TABLE ref_geo.dem_vector OWNER TO geonatadmin;

--
-- Name: dem_vector_gid_seq; Type: SEQUENCE; Schema: ref_geo; Owner: geonatadmin
--

CREATE SEQUENCE ref_geo.dem_vector_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_geo.dem_vector_gid_seq OWNER TO geonatadmin;

--
-- Name: dem_vector_gid_seq; Type: SEQUENCE OWNED BY; Schema: ref_geo; Owner: geonatadmin
--

ALTER SEQUENCE ref_geo.dem_vector_gid_seq OWNED BY ref_geo.dem_vector.gid;


--
-- Name: l_areas; Type: TABLE; Schema: ref_geo; Owner: geonatadmin
--

CREATE TABLE ref_geo.l_areas (
    id_area integer NOT NULL,
    id_type integer NOT NULL,
    area_name character varying(250),
    area_code character varying(25),
    geom public.geometry(MultiPolygon,2154),
    centroid public.geometry(Point,2154),
    geojson_4326 character varying,
    source character varying(250),
    comment text,
    enable boolean DEFAULT true NOT NULL,
    additional_data jsonb,
    meta_create_date timestamp without time zone,
    meta_update_date timestamp without time zone,
    CONSTRAINT enforce_geotype_l_areas_centroid CHECK (((public.geometrytype(centroid) = 'POINT'::text) OR (centroid IS NULL))),
    CONSTRAINT enforce_geotype_l_areas_geom CHECK (((public.geometrytype(geom) = 'MULTIPOLYGON'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_l_areas_centroid CHECK ((public.st_srid(centroid) = 2154)),
    CONSTRAINT enforce_srid_l_areas_geom CHECK ((public.st_srid(geom) = 2154))
);
ALTER TABLE ONLY ref_geo.l_areas ALTER COLUMN geom SET STORAGE EXTERNAL;


ALTER TABLE ref_geo.l_areas OWNER TO geonatadmin;

--
-- Name: l_areas_id_area_seq; Type: SEQUENCE; Schema: ref_geo; Owner: geonatadmin
--

CREATE SEQUENCE ref_geo.l_areas_id_area_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_geo.l_areas_id_area_seq OWNER TO geonatadmin;

--
-- Name: l_areas_id_area_seq; Type: SEQUENCE OWNED BY; Schema: ref_geo; Owner: geonatadmin
--

ALTER SEQUENCE ref_geo.l_areas_id_area_seq OWNED BY ref_geo.l_areas.id_area;


--
-- Name: li_grids; Type: TABLE; Schema: ref_geo; Owner: geonatadmin
--

CREATE TABLE ref_geo.li_grids (
    id_grid character varying(50) NOT NULL,
    id_area integer NOT NULL,
    cxmin integer,
    cxmax integer,
    cymin integer,
    cymax integer
);


ALTER TABLE ref_geo.li_grids OWNER TO geonatadmin;

--
-- Name: li_municipalities; Type: TABLE; Schema: ref_geo; Owner: geonatadmin
--

CREATE TABLE ref_geo.li_municipalities (
    id_municipality character varying(25) NOT NULL,
    id_area integer NOT NULL,
    status character varying(50),
    insee_com character varying(5),
    nom_com character varying(50),
    insee_arr character varying(2),
    nom_dep character varying(30),
    insee_dep character varying(3),
    nom_reg character varying(35),
    insee_reg character varying(2),
    code_epci character varying(9),
    plani_precision double precision,
    siren_code character varying(10),
    canton character varying(200),
    population integer,
    multican character varying(3),
    cc_nom character varying(250),
    cc_siren bigint,
    cc_nature character varying(5),
    cc_date_creation character varying(10),
    cc_date_effet character varying(10),
    insee_commune_nouvelle character varying(5),
    meta_create_date timestamp without time zone,
    meta_update_date timestamp without time zone
);


ALTER TABLE ref_geo.li_municipalities OWNER TO geonatadmin;

--
-- Name: bib_areas_types id_type; Type: DEFAULT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.bib_areas_types ALTER COLUMN id_type SET DEFAULT nextval('ref_geo.bib_areas_types_id_type_seq'::regclass);


--
-- Name: dem rid; Type: DEFAULT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.dem ALTER COLUMN rid SET DEFAULT nextval('ref_geo.dem_rid_seq'::regclass);


--
-- Name: dem_vector gid; Type: DEFAULT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.dem_vector ALTER COLUMN gid SET DEFAULT nextval('ref_geo.dem_vector_gid_seq'::regclass);


--
-- Name: l_areas id_area; Type: DEFAULT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.l_areas ALTER COLUMN id_area SET DEFAULT nextval('ref_geo.l_areas_id_area_seq'::regclass);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: geonatadmin
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: bib_areas_types pk_bib_areas_types; Type: CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.bib_areas_types
    ADD CONSTRAINT pk_bib_areas_types PRIMARY KEY (id_type);


--
-- Name: dem pk_dem; Type: CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.dem
    ADD CONSTRAINT pk_dem PRIMARY KEY (rid);


--
-- Name: dem_vector pk_dem_vector; Type: CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.dem_vector
    ADD CONSTRAINT pk_dem_vector PRIMARY KEY (gid);


--
-- Name: l_areas pk_l_areas; Type: CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.l_areas
    ADD CONSTRAINT pk_l_areas PRIMARY KEY (id_area);


--
-- Name: li_grids pk_li_grids; Type: CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.li_grids
    ADD CONSTRAINT pk_li_grids PRIMARY KEY (id_grid);


--
-- Name: li_municipalities pk_li_municipalities; Type: CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.li_municipalities
    ADD CONSTRAINT pk_li_municipalities PRIMARY KEY (id_municipality);


--
-- Name: bib_areas_types unique_bib_areas_types_type_code; Type: CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.bib_areas_types
    ADD CONSTRAINT unique_bib_areas_types_type_code UNIQUE (type_code);


--
-- Name: l_areas unique_id_type_area_code; Type: CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.l_areas
    ADD CONSTRAINT unique_id_type_area_code UNIQUE (id_type, area_code);


--
-- Name: i_unique_bib_areas_types_type_code; Type: INDEX; Schema: ref_geo; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_bib_areas_types_type_code ON ref_geo.bib_areas_types USING btree (type_code);


--
-- Name: i_unique_l_areas_id_type_area_code; Type: INDEX; Schema: ref_geo; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_l_areas_id_type_area_code ON ref_geo.l_areas USING btree (id_type, area_code);


--
-- Name: index_dem_vector_geom; Type: INDEX; Schema: ref_geo; Owner: geonatadmin
--

CREATE INDEX index_dem_vector_geom ON ref_geo.dem_vector USING gist (geom);


--
-- Name: index_l_areas_centroid; Type: INDEX; Schema: ref_geo; Owner: geonatadmin
--

CREATE INDEX index_l_areas_centroid ON ref_geo.l_areas USING gist (centroid);


--
-- Name: index_l_areas_geom; Type: INDEX; Schema: ref_geo; Owner: geonatadmin
--

CREATE INDEX index_l_areas_geom ON ref_geo.l_areas USING gist (geom);


--
-- Name: index_li_grids_id_area; Type: INDEX; Schema: ref_geo; Owner: geonatadmin
--

CREATE INDEX index_li_grids_id_area ON ref_geo.li_grids USING btree (id_area);


--
-- Name: index_li_municipalities_id_area; Type: INDEX; Schema: ref_geo; Owner: geonatadmin
--

CREATE INDEX index_li_municipalities_id_area ON ref_geo.li_municipalities USING btree (id_area);


--
-- Name: l_areas tri_calculate_geojson; Type: TRIGGER; Schema: ref_geo; Owner: geonatadmin
--

CREATE TRIGGER tri_calculate_geojson BEFORE INSERT OR UPDATE OF geom ON ref_geo.l_areas FOR EACH ROW EXECUTE FUNCTION ref_geo.fct_tri_calculate_geojson();


--
-- Name: l_areas tri_meta_dates_change_l_areas; Type: TRIGGER; Schema: ref_geo; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_l_areas BEFORE INSERT OR UPDATE ON ref_geo.l_areas FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: li_municipalities tri_meta_dates_change_li_municipalities; Type: TRIGGER; Schema: ref_geo; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_li_municipalities BEFORE INSERT OR UPDATE ON ref_geo.li_municipalities FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: l_areas fk_l_areas_id_type; Type: FK CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.l_areas
    ADD CONSTRAINT fk_l_areas_id_type FOREIGN KEY (id_type) REFERENCES ref_geo.bib_areas_types(id_type) ON UPDATE CASCADE;


--
-- Name: li_grids fk_li_grids_id_area; Type: FK CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.li_grids
    ADD CONSTRAINT fk_li_grids_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: li_municipalities fk_li_municipalities_id_area; Type: FK CONSTRAINT; Schema: ref_geo; Owner: geonatadmin
--

ALTER TABLE ONLY ref_geo.li_municipalities
    ADD CONSTRAINT fk_li_municipalities_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

