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
-- Name: gn_commons; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA gn_commons;


ALTER SCHEMA gn_commons OWNER TO geonatadmin;

--
-- Name: gn_imports; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA gn_imports;


ALTER SCHEMA gn_imports OWNER TO geonatadmin;

--
-- Name: gn_meta; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA gn_meta;


ALTER SCHEMA gn_meta OWNER TO geonatadmin;

--
-- Name: gn_monitoring; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA gn_monitoring;


ALTER SCHEMA gn_monitoring OWNER TO geonatadmin;

--
-- Name: gn_permissions; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA gn_permissions;


ALTER SCHEMA gn_permissions OWNER TO geonatadmin;

--
-- Name: gn_sensitivity; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA gn_sensitivity;


ALTER SCHEMA gn_sensitivity OWNER TO geonatadmin;

--
-- Name: gn_synthese; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA gn_synthese;


ALTER SCHEMA gn_synthese OWNER TO geonatadmin;

--
-- Name: ref_geo; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA ref_geo;


ALTER SCHEMA ref_geo OWNER TO geonatadmin;

--
-- Name: ref_habitats; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA ref_habitats;


ALTER SCHEMA ref_habitats OWNER TO geonatadmin;

--
-- Name: ref_nomenclatures; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA ref_nomenclatures;


ALTER SCHEMA ref_nomenclatures OWNER TO geonatadmin;

--
-- Name: taxonomie; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA taxonomie;


ALTER SCHEMA taxonomie OWNER TO geonatadmin;

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
-- Name: utilisateurs; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA utilisateurs;


ALTER SCHEMA utilisateurs OWNER TO geonatadmin;

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
-- Name: check_entity_field_exist(character varying); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.check_entity_field_exist(myentity character varying) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that allows to check if the field of an entity of a table type exists. Parameter : 'schema.table.field'
--USAGE : SELECT gn_commons.check_entity_field_exist('schema.table.field');
  DECLARE
    entity_array character varying(255)[];
  BEGIN
    entity_array = string_to_array(myentity,'.');
      IF entity_array[3] IN(SELECT column_name FROM information_schema.columns WHERE table_schema = entity_array[1] AND table_name = entity_array[2] AND column_name = entity_array[3] ) THEN
        RETURN true;
      END IF;
    RETURN false;
  END;
$$;


ALTER FUNCTION gn_commons.check_entity_field_exist(myentity character varying) OWNER TO geonatadmin;

--
-- Name: check_entity_uuid_exist(character varying, uuid); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.check_entity_uuid_exist(myentity character varying, myvalue uuid) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that allows to check if a uuid exists in the field of a table type.
--USAGE : SELECT gn_commons.check_entity_uuid_exist('schema.table.field', uuid);
  DECLARE
    entity_array character varying(255)[];
    r record;
    _row_ct integer;
  BEGIN


    entity_array = string_to_array(myentity,'.');
    EXECUTE 'SELECT '||entity_array[3]|| ' FROM '||entity_array[1]||'.'||entity_array[2]||' WHERE '||entity_array[3]||'=''' ||myvalue || '''' INTO r;
    GET DIAGNOSTICS _row_ct = ROW_COUNT;
      IF _row_ct > 0 THEN
        RETURN true;
      END IF;
    RETURN false;
  END;
$$;


ALTER FUNCTION gn_commons.check_entity_uuid_exist(myentity character varying, myvalue uuid) OWNER TO geonatadmin;

--
-- Name: check_entity_value_exist(character varying, integer); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.check_entity_value_exist(myentity character varying, myvalue integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that allows to check if a value exists in the field of a table type.
--USAGE : SELECT gn_commons.check_entity_value_exist('schema.table.field', value);
  DECLARE
    entity_array character varying(255)[];
    r record;
    _row_ct integer;
  BEGIN
    -- Cas particulier quand on insère le média avant l'entité
    IF myvalue = -1 Then
	    RETURN TRUE;
    END IF;

    entity_array = string_to_array(myentity,'.');
    EXECUTE 'SELECT '||entity_array[3]|| ' FROM '||entity_array[1]||'.'||entity_array[2]||' WHERE '||entity_array[3]||'=' ||myvalue INTO r;
    GET DIAGNOSTICS _row_ct = ROW_COUNT;
      IF _row_ct > 0 THEN
        RETURN true;
      END IF;
    RETURN false;
  END;
$$;


ALTER FUNCTION gn_commons.check_entity_value_exist(myentity character varying, myvalue integer) OWNER TO geonatadmin;

--
-- Name: fct_trg_add_default_validation_status(); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.fct_trg_add_default_validation_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
	theschema text := quote_ident(TG_TABLE_SCHEMA);
	thetable text := quote_ident(TG_TABLE_NAME);
	theuuidfieldname character varying(50);
	theuuid uuid;
  thecomment text := 'auto = default value';
BEGIN
  --Retouver le nom du champ stockant l'uuid de l'enregistrement en cours de validation
	SELECT INTO theuuidfieldname gn_commons.get_uuid_field_name(theschema,thetable);
  --Récupérer l'uuid de l'enregistrement en cours de validation
	EXECUTE format('SELECT $1.%I', theuuidfieldname) INTO theuuid USING NEW;
  --Insertion du statut de validation et des informations associées dans t_validations
  INSERT INTO gn_commons.t_validations (uuid_attached_row,id_nomenclature_valid_status,id_validator,validation_comment,validation_date)
  VALUES(
    theuuid,
    ref_nomenclatures.get_default_nomenclature_value('STATUT_VALID'), --comme la fonction est générique, cette valeur par défaut doit exister et est la même pour tous les modules
    null,
    thecomment,
    NOW()
  );
  RETURN NEW;
END;
$_$;


ALTER FUNCTION gn_commons.fct_trg_add_default_validation_status() OWNER TO geonatadmin;

--
-- Name: fct_trg_log_changes(); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.fct_trg_log_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
	theschema text := quote_ident(TG_TABLE_SCHEMA);
	thetable text := quote_ident(TG_TABLE_NAME);
	theidtablelocation int;
	theuuidfieldname character varying(50);
	theuuid uuid;
	theoperation character(1);
	thecontent json;
BEGIN
	--Retrouver l'id de la table source stockant l'enregistrement à tracer
	SELECT INTO theidtablelocation gn_commons.get_table_location_id(theschema,thetable);
	--Retouver le nom du champ stockant l'uuid de l'enregistrement à tracer
	SELECT INTO theuuidfieldname gn_commons.get_uuid_field_name(theschema,thetable);
	--Retrouver la première lettre du type d'opération (C, U, ou D)
	SELECT INTO theoperation LEFT(TG_OP,1);
	--Construction du JSON du contenu de l'enregistrement tracé
	IF(TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		--Construction du JSON
		thecontent :=  row_to_json(NEW.*);
		--Récupérer l'uuid de l'enregistrement à tracer
		EXECUTE format('SELECT $1.%I', theuuidfieldname) INTO theuuid USING NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		--Construction du JSON
		thecontent :=  row_to_json(OLD.*);
		--Récupérer l'uuid de l'enregistrement à tracer
		EXECUTE format('SELECT $1.%I', theuuidfieldname) INTO theuuid USING OLD;
	END IF;
  --Insertion du statut de validation et des informations associées dans t_validations
  INSERT INTO gn_commons.t_history_actions (id_table_location,uuid_attached_row,operation_type,operation_date,table_content)
  VALUES(
    theidtablelocation,
    theuuid,
    theoperation,
    NOW(),
    thecontent
  );
  RETURN NEW;
END;
$_$;


ALTER FUNCTION gn_commons.fct_trg_log_changes() OWNER TO geonatadmin;

--
-- Name: fct_trg_update_synthese_validation_status(); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.fct_trg_update_synthese_validation_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- This trigger function update validation informations in corresponding row in synthese table
BEGIN
  UPDATE gn_synthese.synthese 
  SET id_nomenclature_valid_status = NEW.id_nomenclature_valid_status,
  validation_comment = NEW.validation_comment,
  validator = (SELECT nom_role || ' ' || prenom_role FROM utilisateurs.t_roles WHERE id_role = NEW.id_validator)::text
  WHERE unique_id_sinp = NEW.uuid_attached_row;
RETURN NEW;
END;
$$;


ALTER FUNCTION gn_commons.fct_trg_update_synthese_validation_status() OWNER TO geonatadmin;

--
-- Name: get_default_parameter(text, integer); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.get_default_parameter(myparamname text, myidorganisme integer DEFAULT 0) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        theparamvalue text;
-- Function that allows to get value of a parameter depending on his name and organism
-- USAGE : SELECT gn_commons.get_default_parameter('taxref_version');
-- OR      SELECT gn_commons.get_default_parameter('uuid_url_value', 2);
  BEGIN
    IF myidorganisme IS NOT NULL THEN
      SELECT INTO theparamvalue parameter_value FROM gn_commons.t_parameters WHERE parameter_name = myparamname AND id_organism = myidorganisme LIMIT 1;
    ELSE
      SELECT INTO theparamvalue parameter_value FROM gn_commons.t_parameters WHERE parameter_name = myparamname LIMIT 1;
    END IF;
    RETURN theparamvalue;
  END;
$$;


ALTER FUNCTION gn_commons.get_default_parameter(myparamname text, myidorganisme integer) OWNER TO geonatadmin;

--
-- Name: get_id_module_bycode(text); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.get_id_module_bycode(mymodule text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	theidmodule integer;
BEGIN
  --Retrouver l'id du module par son code
  SELECT INTO theidmodule id_module FROM gn_commons.t_modules
	WHERE "module_code" ILIKE mymodule;
  RETURN theidmodule;
END;
$$;


ALTER FUNCTION gn_commons.get_id_module_bycode(mymodule text) OWNER TO geonatadmin;

--
-- Name: get_table_location_id(text, text); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.get_table_location_id(myschema text, mytable text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	theidtablelocation int;
BEGIN
--Retrouver dans gn_commons.bib_tables_location l'id (PK) de la table passée en paramètre
  SELECT INTO theidtablelocation id_table_location FROM gn_commons.bib_tables_location
	WHERE "schema_name" = myschema AND "table_name" = mytable;
  RETURN theidtablelocation;
END;
$$;


ALTER FUNCTION gn_commons.get_table_location_id(myschema text, mytable text) OWNER TO geonatadmin;

--
-- Name: get_uuid_field_name(text, text); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.get_uuid_field_name(myschema text, mytable text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	theuuidfieldname character varying(50);
BEGIN
--Retrouver dans gn_commons.bib_tables_location le nom du champs UUID de la table passée en paramètre
  SELECT INTO theuuidfieldname uuid_field_name FROM gn_commons.bib_tables_location
	WHERE "schema_name" = myschema AND "table_name" = mytable;
  RETURN theuuidfieldname;
END;
$$;


ALTER FUNCTION gn_commons.get_uuid_field_name(myschema text, mytable text) OWNER TO geonatadmin;

--
-- Name: is_in_period(date, date, date); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.is_in_period(dateobs date, datebegin date, dateend date) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
day_obs int;
begin_day int;
end_day int;
test int; 
--Function to check if a date (dateobs) is in a period (datebegin, dateend)
--USAGE : SELECT gn_commons.is_in_period(dateobs, datebegin, dateend);
BEGIN
day_obs = extract(doy FROM dateobs);--jour de la date passée
begin_day = extract(doy FROM datebegin);--jour début
end_day = extract(doy FROM dateend); --jour fin
test = end_day - begin_day; --test si la période est sur 2 année ou pas
--si on est sur 2 années
IF test < 0 then
	IF day_obs BETWEEN begin_day AND 366 OR day_obs BETWEEN 1 AND end_day THEN RETURN true;
	END IF;
-- si on est dans la même année
else 
	IF day_obs BETWEEN begin_day AND end_day THEN RETURN true;
	END IF;
END IF;
	RETURN false;	
END;
$$;


ALTER FUNCTION gn_commons.is_in_period(dateobs date, datebegin date, dateend date) OWNER TO geonatadmin;

--
-- Name: role_is_group(integer); Type: FUNCTION; Schema: gn_commons; Owner: geonatadmin
--

CREATE FUNCTION gn_commons.role_is_group(myidrole integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
	is_group boolean;
BEGIN
  SELECT INTO is_group groupe FROM utilisateurs.t_roles
	WHERE id_role = myidrole;
  RETURN is_group;
END;
$$;


ALTER FUNCTION gn_commons.role_is_group(myidrole integer) OWNER TO geonatadmin;

--
-- Name: fct_generate_import_query(text, text); Type: FUNCTION; Schema: gn_imports; Owner: geonatadmin
--

CREATE FUNCTION gn_imports.fct_generate_import_query(mysource_table text, mytarget_table text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    insertfield text; --prepared field to insert
    selectfield text; --prepared field in select clause
    sqlimport text; --returned query as text
    virgule text;
    ssname text; --source schema name
    stname text; --source table name
    tsname text; --destination schema name
    ttname text; --destination table name
    r record;
    g record;
BEGIN
    --test si la table source est fournie sinon on retourne un message d'erreur
    IF length(mysource_table) > 0 THEN
	--split schema.table n deux chaines
	SELECT split_part(mysource_table, '.', 1) into ssname;
	SELECT split_part(mysource_table, '.', 2) into stname;
    ELSE
        BEGIN
            RAISE WARNING 'ERREUR : %', 'Vous devez passer en paramètre une table source et une table de destination.';
        END;
    END IF;
    --test si la table destination est fournie sinon on retourne un message d'erreur
    IF length(mytarget_table) > 0 THEN
	--split schema.table en deux chaines
	SELECT split_part(mytarget_table, '.', 1) into tsname;
	SELECT split_part(mytarget_table, '.', 2) into ttname;
    ELSE
	BEGIN
            RAISE WARNING 'ERREUR : %', 'Vous devez passer en paramètre une table source et une table de destination.';
        END;
    END IF;
    --test si la table source et de destination existe et si un maping des champs a été préparé.
    insertfield = format('INSERT INTO %I.%I(%s',tsname, ttname, chr(10));
    selectfield = concat('SELECT ',chr(10));
    FOR r IN EXECUTE format('SELECT source_field, source_default_value, target_field, target_field_type 
			     FROM gn_imports.matching_fields f
			     JOIN gn_imports.matching_tables t ON t.id_matching_table = f.id_matching_table
			     WHERE t.source_schema = %L 
			     AND t.source_table = %L
			     AND t.target_schema = %L
			     AND t.target_table = %L'
			     ,ssname, stname,tsname, ttname)
    LOOP
        insertfield := concat(insertfield, virgule, r.target_field, chr(10));
        selectfield := concat(
				selectfield, 
				virgule, 
				COALESCE('a.'||r.source_field, r.source_default_value),
				'::',
				r.target_field_type, 
				' AS ', 
				r.target_field,
				chr(10));
        virgule := ',';
    END LOOP;
    --gestion du geom avec la table gn_imports.matching_geoms
    FOR g IN EXECUTE format('SELECT g.* FROM gn_imports.matching_geoms g
			     JOIN gn_imports.matching_tables t ON t.id_matching_table = g.id_matching_table
			     WHERE t.source_schema = %L 
			     AND t.source_table = %L
			     AND t.target_schema = %L
			     AND t.target_table = %L'
			     ,ssname, stname,tsname, ttname)
    LOOP
	--on test si un matching de geom est déclaré
	IF g.id_matching_geom IS NOT NULL THEN
	    --si oui on contruit le mapping
	    insertfield := concat(insertfield, virgule, g.target_geom_field, chr(10));
	    IF((g.source_geom_format = 'xy') AND (g.source_x_field IS NOT NULL) AND (g.source_y_field IS NOT NULL)) THEN
	        selectfield := concat(selectfield, virgule
	        , 'ST_Transform(ST_GeomFromText('
	        ,'''POINT(''|| '
	        ,g.source_x_field
	        ,' || '
	        ,''' '''
	        ,' || '
	        ,g.source_y_field
	        ,' ||'')'''
	        ,', '
	        ,g.source_srid,'), '
	        ,g.target_geom_srid
	        ,')'
	        ,chr(10)
	        );
	    ELSIF (g.source_geom_format = 'wkt' AND length(g.source_geom_field)>0) THEN
	        selectfield := concat(selectfield, virgule
	        ,'ST_Transform(ST_GeomFromText('
	        ,''''
	        ,g.source_geom_field
	        ,''', '
	        ,g.source_srid,'), '
	        ,g.target_geom_srid
	        ,')'
	        ,chr(10)
	        );
	    ELSE
	        BEGIN
	            RAISE EXCEPTION 'ATTENTION %', 'Le format du champ "source_geom_format" dans la table "gn_imports.matching_geoms" 
	            doit être "xy" ou "wkt" 
	            ET les champs "source_x_field" et "source_y_field" doivent être complétés pour le format "xy"
	            OU le champs "source_geom_field" doit être complété pour le format "wkt".';
	        END;
	    END IF;
	END IF;
    END LOOP;
    --finalisation de la clause insert
    insertfield := concat(insertfield, ')', chr(10));
    selectfield := concat(selectfield, 'FROM ', ssname, '.', stname, ' a', chr(10));
    --construction de la requête complète
    sqlimport := concat(insertfield, ' ', selectfield, ';');
    RETURN sqlimport;
END $$;


ALTER FUNCTION gn_imports.fct_generate_import_query(mysource_table text, mytarget_table text) OWNER TO geonatadmin;

--
-- Name: fct_generate_matching(text, text, boolean); Type: FUNCTION; Schema: gn_imports; Owner: geonatadmin
--

CREATE FUNCTION gn_imports.fct_generate_matching(mysource_table text, mytarget_table text, forcedelete boolean DEFAULT false) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    thesql text; --prepared query to execute
    deletesql text; --prepared query to delete row in matching tables
    sqlinsertt text; --prepared query to insert row in gn_imports.matching_tables
    sqlinsertf text; --prepared query to insert row in gn_imports.matching_fields
    theidmatchingtable integer; --id_matching_table return after insert in gn_imports.matching_tables
    ssname text; --source schema name
    stname text; --source table name
    tsname text; --destination schema name
    ttname text; --destination table name
    r record;
BEGIN
    --test si la table source est fournie sinon on retourne un message d'erreur
    IF length(mysource_table) > 0 THEN
	--split schema.table n deux chaines
	SELECT split_part(mysource_table, '.', 1) into ssname;
	SELECT split_part(mysource_table, '.', 2) into stname;
    ELSE
        BEGIN
            RAISE EXCEPTION 'ATTENTION : %', 'Vous devez passer en paramètre une table source et une table de destination.';
        END;
    END IF;
    --test si la table destination est fournie sinon on retourne un message d'erreur
    IF length(mytarget_table) > 0 THEN
	--split schema.table en deux chaines
	SELECT split_part(mytarget_table, '.', 1) into tsname;
	SELECT split_part(mytarget_table, '.', 2) into ttname;
    ELSE
	BEGIN
            RAISE EXCEPTION 'ATTENTION : %', 'Vous devez passer en paramètre une table source et une table de destination.';
        END;
    END IF;
    --Test si le matching existe
    thesql= format('SELECT id_matching_table
		    FROM gn_imports.matching_tables
		    WHERE source_schema = %L AND source_table = %L AND target_schema = %L AND target_table = %L;'
	    ,ssname, stname,tsname, ttname);
    EXECUTE thesql INTO theidmatchingtable;
    --suppression du matching existant s'il existe et que le parametre forcedelete est à true
    IF forcedelete AND theidmatchingtable IS NOT NULL THEN
	thesql = format('DELETE FROM gn_imports.matching_fields WHERE id_matching_table = %L;'
		    ,theidmatchingtable);
	EXECUTE thesql;
	thesql = format('DELETE FROM gn_imports.matching_geoms WHERE id_matching_table = %L;'
		    ,theidmatchingtable);
	EXECUTE thesql;
    ELSIF theidmatchingtable IS NULL THEN
        --Do nothing and continue
    ELSE
	BEGIN
            RAISE EXCEPTION 'ATTENTION : %', 'Un enregistrement pour ce mapping existe et vous n''avez pas indiqué de le supprimer.'
			    || chr(10) || 'Utilisez le parametre forcedelete = true pour forcer la suppression du mapping existant';
	END;
    END IF;
    --s'il n'existe pas, insertion de l'enregistrement du matching dans la table gn_imports.matching_tables
    IF theidmatchingtable IS NULL THEN
        thesql= format('INSERT INTO gn_imports.matching_tables(
			   source_schema,
			   source_table,
			   target_schema,
			   target_table) VALUES(%L,%L,%L,%L) RETURNING id_matching_table;'
			   ,ssname, stname,tsname, ttname);
	EXECUTE thesql INTO theidmatchingtable;
    END IF;
    --préparation de la requete d'insertion dans la table gn_imports.matching_fields
    FOR r IN EXECUTE format('SELECT column_name,  data_type, is_nullable, column_default
			     FROM information_schema.columns
			     WHERE table_schema = %L
			     AND table_name   = %L
			     ORDER BY ordinal_position;'
		     ,tsname, ttname)
    LOOP
        thesql = format( 
			    'INSERT INTO gn_imports.matching_fields(
			       source_field,
			       source_default_value,
			       target_field, 
			       target_field_type, 
			       id_matching_table) 
			     VALUES(''replace me'',%L,%L,%L,%L);'
		     ,r.column_default, r.column_name, r.data_type, theidmatchingtable);
	EXECUTE thesql;
    END LOOP;
    RETURN 'Insertion de tous les champs de la table de destination dans "gn_imports.matching_fields" ; vous devez maintenant adapter le contenu de cette table.';
END $$;


ALTER FUNCTION gn_imports.fct_generate_matching(mysource_table text, mytarget_table text, forcedelete boolean) OWNER TO geonatadmin;

--
-- Name: load_csv_file(text, text); Type: FUNCTION; Schema: gn_imports; Owner: geonatadmin
--

CREATE FUNCTION gn_imports.load_csv_file(csv_file text, target_table text) RETURNS text
    LANGUAGE plpgsql
    AS $$
--This function create a table and her structure according to the CSV structure and the passed name.
--CSV content is loaded in. 
--Then, the function tries to define the type of columns according to the content.
--You must check and adapt result.
--
--USAGE (due to 'copy' function usage, use it with a superuser only).
--SELECT gn_imports.load_csv_file('/path/to/file.csv', 'targetschema.targettable');
DECLARE
    col text; -- variable to keep the column name at each iteration
    sname text; --destination schema name
    tname text; --destination table name
BEGIN
    create temp table import (line text) on commit drop;
    --import all csv content
    EXECUTE format('copy import from %L', csv_file);
    -- if not blank, change the csv_temp_table name to the name given as parameter
    IF length(target_table) > 0 THEN
	--split schema.table to 2 strings
	SELECT split_part(target_table, '.', 1) into sname;
	SELECT split_part(target_table, '.', 2) into tname;
	--if a schema name is given
	IF(tname IS NOT NULL) THEN
	    --drop if exists and create table with first line as columns name in given schema (before point in target_table string)
	    EXECUTE format('DROP TABLE IF EXISTS %I.%I', sname, tname);
	    EXECUTE format('create table %I.%I (%s);', 
	        sname, tname, concat(replace(line, ';', ' text, '), ' text'))
            from import limit 1;
	    -- load data in target table
	    EXECUTE format('copy %I.%I from %L WITH DELIMITER '';'' quote ''"'' csv header', sname, tname, csv_file);
	--if no schema is given working with public schema
	ELSE
	    --drop if exists and create table with first line as columns name in public schema
	    EXECUTE format('DROP TABLE IF EXISTS %I', target_table);
	    EXECUTE format('create table %I (%s);', 
	        target_table, concat(replace(line, ';', ' text, '), ' text'))
            from import limit 1;
            -- load data in target table
	    EXECUTE format('copy %I from %L WITH DELIMITER '';'' quote ''"'' csv ', target_table, csv_file);
        END IF;
        --try to change convert numeric and date columns type. If error throw, do nothing, continue and keep 'text' type.
        FOR col IN EXECUTE format('SELECT column_name FROM information_schema.columns WHERE table_schema  = %L AND table_name = %L', sname, tname)
        LOOP
	    BEGIN
	        EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %s TYPE integer USING %s::integer', sname, tname, col, col);
	        EXCEPTION WHEN OTHERS THEN 
		    BEGIN
		        EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %s TYPE real USING %s::real', sname, tname, col, col);
		        EXCEPTION WHEN OTHERS THEN
			    BEGIN
			        EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %s TYPE date USING %s::date', sname, tname, col, col);
			        EXCEPTION WHEN OTHERS THEN -- keep looping
			    END;
		    END;
            END;
        END LOOP;
    END IF;
    RETURN format('CREATE TABLE %I.%I FROM %L', sname, tname, csv_file);
END $$;


ALTER FUNCTION gn_imports.load_csv_file(csv_file text, target_table text) OWNER TO geonatadmin;

--
-- Name: fct_trg_cor_site_area(); Type: FUNCTION; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE FUNCTION gn_monitoring.fct_trg_cor_site_area() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

	DELETE FROM gn_monitoring.cor_site_area WHERE id_base_site = NEW.id_base_site;
	INSERT INTO gn_monitoring.cor_site_area
	SELECT NEW.id_base_site, (ref_geo.fct_get_area_intersection(NEW.geom)).id_area;

  RETURN NEW;
END;
$$;


ALTER FUNCTION gn_monitoring.fct_trg_cor_site_area() OWNER TO geonatadmin;

--
-- Name: fct_trg_visite_date_max(); Type: FUNCTION; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE FUNCTION gn_monitoring.fct_trg_visite_date_max() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- Si la date max de la visite est nulle ou inférieure à la date_min
	--	Modification de date max pour garder une cohérence des données
	IF
		NEW.visit_date_max IS NULL
		OR NEW.visit_date_max < NEW.visit_date_min
	THEN
      NEW.visit_date_max := NEW.visit_date_min;
    END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION gn_monitoring.fct_trg_visite_date_max() OWNER TO geonatadmin;

--
-- Name: cruved_for_user_in_module(integer, character varying); Type: FUNCTION; Schema: gn_permissions; Owner: geonatadmin
--

CREATE FUNCTION gn_permissions.cruved_for_user_in_module(myuser integer, mymodulecode character varying) RETURNS json
    LANGUAGE plpgsql IMMUTABLE
    AS $$
-- the function return user's CRUVED in the requested module
-- warning: the function not return the parent CRUVED but only the module cruved - no heritage
-- USAGE : SELECT utilisateurs.cruved_for_user_in_module(requested_userid,requested_moduleid);
-- SAMPLE : SELECT utilisateurs.cruved_for_user_in_module(2,3);
DECLARE
 thecruved json;
BEGIN
    SELECT array_to_json(array_agg(row))
    INTO thecruved
    FROM (
  SELECT code_action AS action, max(value_filter::int) AS level
        FROM gn_permissions.v_roles_permissions
        WHERE id_role = myuser AND module_code = mymodulecode AND code_filter_type = 'SCOPE'
        GROUP BY code_action) row;
    RETURN thecruved;
END;
$$;


ALTER FUNCTION gn_permissions.cruved_for_user_in_module(myuser integer, mymodulecode character varying) OWNER TO geonatadmin;

--
-- Name: does_user_have_scope_permission(integer, character varying, character varying, integer); Type: FUNCTION; Schema: gn_permissions; Owner: geonatadmin
--

CREATE FUNCTION gn_permissions.does_user_have_scope_permission(myuser integer, mycodemodule character varying, myactioncode character varying, myscope integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
-- the function say if the given user can do the requested action in the requested module with its scope level
-- warning: NO heritage between parent and child module
-- USAGE : SELECT gn_persmissions.does_user_have_scope_permission(requested_userid,requested_actionid,requested_module_code,requested_scope);
-- SAMPLE : SELECT gn_permissions.does_user_have_scope_permission(2,'OCCTAX','R',3);
BEGIN
    IF myactioncode IN (
  SELECT code_action
    FROM gn_permissions.v_roles_permissions
    WHERE id_role = myuser AND module_code = mycodemodule AND code_action = myactioncode AND value_filter::int >= myscope AND code_filter_type = 'SCOPE') THEN
    RETURN true;
END
IF;
 RETURN false;
END;
$$;


ALTER FUNCTION gn_permissions.does_user_have_scope_permission(myuser integer, mycodemodule character varying, myactioncode character varying, myscope integer) OWNER TO geonatadmin;

--
-- Name: fct_tri_does_user_have_already_scope_filter(); Type: FUNCTION; Schema: gn_permissions; Owner: geonatadmin
--

CREATE FUNCTION gn_permissions.fct_tri_does_user_have_already_scope_filter() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Check if a role has already a SCOPE permission for an action/module/object
-- use in constraint to force not set multiple scope permission on the same action/module/object
DECLARE
the_code_filter_type character varying;
the_nb_permission integer;
BEGIN
 SELECT INTO the_code_filter_type bib.code_filter_type
 FROM gn_permissions.t_filters f
 JOIN gn_permissions.bib_filters_type bib ON bib.id_filter_type = f.id_filter_type
 WHERE f.id_filter = NEW.id_filter
;
-- if the filter type is NOT SCOPE, its OK to set multiple permissions
IF the_code_filter_type != 'SCOPE' THEN
RETURN NEW;
-- if the new filter is 'SCOPE TYPE', check if there is not already a permission for this
-- action/module/object/role
ELSE
    SELECT INTO the_nb_permission count(perm.id_permission)
    FROM gn_permissions.cor_role_action_filter_module_object perm
    JOIN gn_permissions.t_filters f ON f.id_filter = perm.id_filter
    JOIN gn_permissions.bib_filters_type bib ON bib.id_filter_type = f.id_filter_type AND bib.code_filter_type = 'SCOPE'
    WHERE id_role=NEW.id_role AND id_action=NEW.id_action AND id_module=NEW.id_module AND id_object=NEW.id_object;

 -- if its an insert 0 row must be present, if its an update 1 row must be present
  IF(TG_OP = 'INSERT' AND the_nb_permission = 0) OR (TG_OP = 'UPDATE' AND the_nb_permission = 1) THEN
        RETURN NEW;
    END IF;
    BEGIN
        RAISE EXCEPTION 'ATTENTION: il existe déjà un enregistrement de type SCOPE pour le role % l''action % sur le module % et l''objet % . Il est interdit de définir plusieurs portées à un role pour le même action sur un module et un objet', NEW.id_role, NEW.id_action, NEW.id_module, NEW.id_object ;
    END;


END IF;

END;

$$;


ALTER FUNCTION gn_permissions.fct_tri_does_user_have_already_scope_filter() OWNER TO geonatadmin;

--
-- Name: get_id_object(character varying); Type: FUNCTION; Schema: gn_permissions; Owner: geonatadmin
--

CREATE FUNCTION gn_permissions.get_id_object(mycodeobject character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
RETURN (SELECT id_object
FROM gn_permissions.t_objects
WHERE code_object = mycodeobject);
END;
$$;


ALTER FUNCTION gn_permissions.get_id_object(mycodeobject character varying) OWNER TO geonatadmin;

--
-- Name: user_max_accessible_data_level_in_module(integer, character varying, character varying); Type: FUNCTION; Schema: gn_permissions; Owner: geonatadmin
--

CREATE FUNCTION gn_permissions.user_max_accessible_data_level_in_module(myuser integer, myactioncode character varying, mymodulecode character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
 themaxscopelevel integer;
-- the function return the max accessible extend of data the given user can access in the requested module
-- warning: NO heritage between parent and child module
-- USAGE : SELECT gn_permissions.user_max_accessible_data_level_in_module(requested_userid,requested_actionid,requested_moduleid);
-- SAMPLE : SELECT gn_permissions.user_max_accessible_data_level_in_module(2,'U','GEONATURE');
BEGIN
    SELECT max(value_filter::int)
    INTO themaxscopelevel
    FROM gn_permissions.v_roles_permissions
    WHERE id_role = myuser AND module_code = mymodulecode AND code_action = myactioncode;
    RETURN themaxscopelevel;
END;
$$;


ALTER FUNCTION gn_permissions.user_max_accessible_data_level_in_module(myuser integer, myactioncode character varying, mymodulecode character varying) OWNER TO geonatadmin;

--
-- Name: calculate_cd_diffusion_level(character varying, character varying); Type: FUNCTION; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE FUNCTION gn_sensitivity.calculate_cd_diffusion_level(cd_nomenclature_diffusion_level character varying, cd_nomenclature_sensitivity character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF cd_nomenclature_diffusion_level IS NULL 
    THEN RETURN
    CASE 
      WHEN cd_nomenclature_sensitivity = '0' THEN '5'
      WHEN cd_nomenclature_sensitivity = '1' THEN '1'
      WHEN cd_nomenclature_sensitivity = '2' THEN '2'
      WHEN cd_nomenclature_sensitivity = '3' THEN '3'
      WHEN cd_nomenclature_sensitivity = '4' THEN '4'
    END;
  ELSE 
    RETURN cd_nomenclature_diffusion_level;
  END IF;
END;
$$;


ALTER FUNCTION gn_sensitivity.calculate_cd_diffusion_level(cd_nomenclature_diffusion_level character varying, cd_nomenclature_sensitivity character varying) OWNER TO geonatadmin;

--
-- Name: fct_tri_delete_id_sensitivity_synthese(); Type: FUNCTION; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE FUNCTION gn_sensitivity.fct_tri_delete_id_sensitivity_synthese() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE gn_synthese.synthese AS s
    SET id_nomenclature_sensitivity = gn_synthese.get_default_nomenclature_value('SENSIBILITE'::character varying)
    FROM OLD AS deleted_rows
    WHERE s.unique_id_sinp = deleted_rows.uuid_attached_row;
    RETURN NULL;
END;
$$;


ALTER FUNCTION gn_sensitivity.fct_tri_delete_id_sensitivity_synthese() OWNER TO geonatadmin;

--
-- Name: fct_tri_maj_id_sensitivity_synthese(); Type: FUNCTION; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE FUNCTION gn_sensitivity.fct_tri_maj_id_sensitivity_synthese() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE gn_synthese.synthese AS s
    SET id_nomenclature_sensitivity = updated_rows.id_nomenclature_sensitivity
    FROM NEW AS updated_rows
    WHERE s.unique_id_sinp = updated_rows.uuid_attached_row;
    RETURN NULL;
END;
$$;


ALTER FUNCTION gn_sensitivity.fct_tri_maj_id_sensitivity_synthese() OWNER TO geonatadmin;

--
-- Name: get_id_nomenclature_sensitivity(date, integer, public.geometry, jsonb); Type: FUNCTION; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE FUNCTION gn_sensitivity.get_id_nomenclature_sensitivity(my_date_obs date, my_cd_ref integer, my_geom public.geometry, my_criterias jsonb) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    niv_precis integer;
    niv_precis_null integer;
BEGIN

    niv_precis_null := (SELECT ref_nomenclatures.get_id_nomenclature('SENSIBILITE'::text, '0'::text));

    -- ##########################################
    -- TESTS unicritère
    --    => Permet de voir si un critère est remplis ou non de façon à limiter au maximum
    --      la requete globale qui croise l'ensemble des critères
    -- ##########################################

    -- Paramètres cd_ref
     IF NOT EXISTS (
        SELECT 1
        FROM gn_sensitivity.t_sensitivity_rules_cd_ref s
        WHERE s.cd_ref = my_cd_ref
    ) THEN
        return niv_precis_null;
    END IF;

    -- Paramètres durée de validité de la règle
    IF NOT EXISTS (
        SELECT 1
        FROM gn_sensitivity.t_sensitivity_rules_cd_ref s
        WHERE s.cd_ref = my_cd_ref
        AND (date_part('year', CURRENT_TIMESTAMP) - sensitivity_duration) <= date_part('year', my_date_obs)
    ) THEN
        return niv_precis_null;
    END IF;

    -- Paramètres période d'observation
    IF NOT EXISTS (
        SELECT 1
        FROM gn_sensitivity.t_sensitivity_rules_cd_ref s
        WHERE s.cd_ref = my_cd_ref
        AND (to_char(my_date_obs, 'MMDD') between to_char(s.date_min, 'MMDD') and to_char(s.date_max, 'MMDD') )
    ) THEN
        return niv_precis_null;
    END IF;

    -- Paramètres critères biologiques
    -- S'il existe un critère pour ce taxon
    IF EXISTS (
        SELECT 1
        FROM gn_sensitivity.t_sensitivity_rules_cd_ref s
        JOIN gn_sensitivity.cor_sensitivity_criteria c USING(id_sensitivity)
        WHERE s.cd_ref = my_cd_ref
    ) THEN
        -- Si le critère est remplis
        niv_precis := (

			WITH RECURSIVE h_val(KEY, value, id_broader) AS  (
				SELECT KEY, value::int, id_broader
				FROM (SELECT * FROM jsonb_each_text(my_criterias)) d
				JOIN ref_nomenclatures.t_nomenclatures tn
				ON tn.id_nomenclature = d.value::int
				UNION
				SELECT KEY, id_nomenclature , tn.id_broader
				FROM ref_nomenclatures.t_nomenclatures tn
				JOIN h_val
				ON tn.id_nomenclature = h_val.id_broader
				WHERE NOT id_nomenclature = 0
			)
			SELECT DISTINCT id_nomenclature_sensitivity
			FROM gn_sensitivity.t_sensitivity_rules_cd_ref s
			JOIN gn_sensitivity.cor_sensitivity_criteria c USING(id_sensitivity)
			JOIN h_val a
			ON c.id_criteria = a.value
			WHERE s.cd_ref = my_cd_ref
			LIMIT 1
        );
        IF niv_precis IS NULL THEN
            niv_precis := (SELECT ref_nomenclatures.get_id_nomenclature('SENSIBILITE'::text, '0'::text));
            return niv_precis;
        END IF;
    END IF;



    -- ##########################################
    -- TESTS multicritères
    --    => Permet de voir si l'ensemble des critères sont remplis
    -- ##########################################

    -- Paramètres durée, zone géographique, période de l'observation et critères biologique
	SELECT INTO niv_precis s.id_nomenclature_sensitivity
	FROM (
		SELECT s.*, l.geom, c.id_criteria, c.id_type_nomenclature
		FROM gn_sensitivity.t_sensitivity_rules_cd_ref s
		LEFT OUTER JOIN gn_sensitivity.cor_sensitivity_area  USING(id_sensitivity)
        LEFT OUTER JOIN gn_sensitivity.cor_sensitivity_criteria c USING(id_sensitivity)
		LEFT OUTER JOIN ref_geo.l_areas l USING(id_area)
	) s
	WHERE my_cd_ref = s.cd_ref
		AND (st_intersects(my_geom, s.geom) OR s.geom IS NULL) -- paramètre géographique
		AND (-- paramètre période
			(to_char(my_date_obs, 'MMDD') between to_char(s.date_min, 'MMDD') and to_char(s.date_max, 'MMDD') )
		)
		AND ( -- paramètre duré de validité de la règle
			(date_part('year', CURRENT_TIMESTAMP) - sensitivity_duration) <= date_part('year', my_date_obs)
		)
		AND ( -- paramètre critères
            s.id_criteria IN (SELECT  value::int FROM jsonb_each_text(my_criterias)) OR s.id_criteria IS NULL
		);

	IF niv_precis IS NULL THEN
		niv_precis := niv_precis_null;
	END IF;


	return niv_precis;

END;
$$;


ALTER FUNCTION gn_sensitivity.get_id_nomenclature_sensitivity(my_date_obs date, my_cd_ref integer, my_geom public.geometry, my_criterias jsonb) OWNER TO geonatadmin;

--
-- Name: fct_calculate_min_max_for_taxon(integer); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_calculate_min_max_for_taxon(mycdnom integer) RETURNS TABLE(cd_ref integer, nbobs bigint, daymin integer, daymax integer, altitudemin integer, altitudemax integer, bbox4326 public.geometry)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    --USAGE (getting all fields): SELECT * FROM gn_synthese.fct_calculate_min_max_for_taxon(351);
    --USAGE (getting one or more field) : SELECT cd_ref, bbox4326 FROM gn_synthese.fct_calculate_min_max_for_taxon(351)
    --See field names and types in TABLE declaration above
    --RETURN one row for the supplied cd_ref or cd_nom
    --This function can be use in a FROM clause, like a table or a view
	RETURN QUERY SELECT * FROM gn_synthese.vm_min_max_for_taxons WHERE cd_ref = taxonomie.find_cdref(mycdnom);
  END;
$$;


ALTER FUNCTION gn_synthese.fct_calculate_min_max_for_taxon(mycdnom integer) OWNER TO geonatadmin;

--
-- Name: fct_tri_cal_sensi_diff_level_on_each_row(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_tri_cal_sensi_diff_level_on_each_row() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
  -- Calculate sensitivity and diffusion level on update in synthese
  DECLARE calculated_id_sensi integer;
    BEGIN
        SELECT 
        gn_sensitivity.get_id_nomenclature_sensitivity(
          NEW.date_min::date, 
          taxonomie.find_cdref(NEW.cd_nom), 
          NEW.the_geom_local,
          ('{"STATUT_BIO": ' || NEW.id_nomenclature_bio_status::text || '}')::jsonb
        ) INTO calculated_id_sensi;
      UPDATE gn_synthese.synthese 
      SET 
      id_nomenclature_sensitivity = calculated_id_sensi,
      -- On ne met pas à jour le niveau de diffusion s'il a déjà une valeur
      id_nomenclature_diffusion_level = CASE WHEN OLD.id_nomenclature_diffusion_level IS NULL THEN (
        SELECT ref_nomenclatures.get_id_nomenclature(
            'NIV_PRECIS',
            gn_sensitivity.calculate_cd_diffusion_level(
              ref_nomenclatures.get_cd_nomenclature(OLD.id_nomenclature_diffusion_level),
              ref_nomenclatures.get_cd_nomenclature(calculated_id_sensi)
          )
      	)
      )
      ELSE OLD.id_nomenclature_diffusion_level
      END
      WHERE id_synthese = OLD.id_synthese
      ;
      RETURN NULL;
    END;
  $$;


ALTER FUNCTION gn_synthese.fct_tri_cal_sensi_diff_level_on_each_row() OWNER TO geonatadmin;

--
-- Name: fct_tri_cal_sensi_diff_level_on_each_statement(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_tri_cal_sensi_diff_level_on_each_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
  -- Calculate sensitivity and diffusion level on insert in synthese
    BEGIN
    WITH cte AS (
        SELECT 
        gn_sensitivity.get_id_nomenclature_sensitivity(
          updated_rows.date_min::date, 
          taxonomie.find_cdref(updated_rows.cd_nom), 
          updated_rows.the_geom_local,
          ('{"STATUT_BIO": ' || updated_rows.id_nomenclature_bio_status::text || '}')::jsonb
        ) AS id_nomenclature_sensitivity,
        id_synthese,
        t_diff.cd_nomenclature as cd_nomenclature_diffusion_level
      FROM NEW AS updated_rows
      LEFT JOIN ref_nomenclatures.t_nomenclatures t_diff ON t_diff.id_nomenclature = updated_rows.id_nomenclature_diffusion_level
      WHERE updated_rows.id_nomenclature_sensitivity IS NULL
    )
    UPDATE gn_synthese.synthese AS s
    SET 
      id_nomenclature_sensitivity = c.id_nomenclature_sensitivity,
      id_nomenclature_diffusion_level = ref_nomenclatures.get_id_nomenclature(
        'NIV_PRECIS',
        gn_sensitivity.calculate_cd_diffusion_level(
          c.cd_nomenclature_diffusion_level, 
          t_sensi.cd_nomenclature
        )
        
      )
    FROM cte AS c
    LEFT JOIN ref_nomenclatures.t_nomenclatures t_sensi ON t_sensi.id_nomenclature = c.id_nomenclature_sensitivity
    WHERE c.id_synthese = s.id_synthese
  ;
    RETURN NULL;
    END;
  $$;


ALTER FUNCTION gn_synthese.fct_tri_cal_sensi_diff_level_on_each_statement() OWNER TO geonatadmin;

--
-- Name: fct_tri_maj_observers_txt(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_tri_maj_observers_txt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  theobservers text;
  theidsynthese integer;
BEGIN
  IF (TG_OP = 'UPDATE') OR (TG_OP = 'INSERT') THEN
    theidsynthese = NEW.id_synthese;
  END IF;
  IF (TG_OP = 'DELETE') THEN
    theidsynthese = OLD.id_synthese;
  END IF;
  --Construire le texte pour le champ observers de la synthese
  SELECT INTO theobservers array_to_string(array_agg(r.nom_role || ' ' || r.prenom_role), ', ')
  FROM utilisateurs.t_roles r
  WHERE r.id_role IN(SELECT id_role FROM gn_synthese.cor_observer_synthese WHERE id_synthese = theidsynthese);
  --mise à jour du champ observers dans la table synthese
  UPDATE gn_synthese.synthese
  SET observers = theobservers
  WHERE id_synthese =  theidsynthese;
RETURN NULL;
END;
$$;


ALTER FUNCTION gn_synthese.fct_tri_maj_observers_txt() OWNER TO geonatadmin;

--
-- Name: fct_trig_insert_in_cor_area_synthese_on_each_statement(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_trig_insert_in_cor_area_synthese_on_each_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
  BEGIN
  -- Intersection avec toutes les areas et écriture dans cor_area_synthese
      INSERT INTO gn_synthese.cor_area_synthese 
        SELECT
          updated_rows.id_synthese AS id_synthese,
          a.id_area AS id_area
        FROM NEW as updated_rows
        JOIN ref_geo.l_areas a
          ON public.ST_INTERSECTS(updated_rows.the_geom_local, a.geom)  
        WHERE a.enable IS TRUE AND (ST_GeometryType(updated_rows.the_geom_local) = 'ST_Point' OR NOT public.ST_TOUCHES(updated_rows.the_geom_local,a.geom));
  RETURN NULL;
  END;
  $$;


ALTER FUNCTION gn_synthese.fct_trig_insert_in_cor_area_synthese_on_each_statement() OWNER TO geonatadmin;

--
-- Name: fct_trig_update_in_cor_area_synthese(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_trig_update_in_cor_area_synthese() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
  geom_change boolean;
  BEGIN
	DELETE FROM gn_synthese.cor_area_synthese WHERE id_synthese = NEW.id_synthese;

  -- Intersection avec toutes les areas et écriture dans cor_area_synthese
    INSERT INTO gn_synthese.cor_area_synthese SELECT
      s.id_synthese AS id_synthese,
      a.id_area AS id_area
      FROM ref_geo.l_areas a
      JOIN gn_synthese.synthese s
        ON public.ST_INTERSECTS(s.the_geom_local, a.geom)
      WHERE a.enable IS TRUE AND s.id_synthese = NEW.id_synthese AND (ST_GeometryType(NEW.the_geom_local) = 'ST_Point' OR NOT public.ST_TOUCHES(NEW.the_geom_local,a.geom));
  RETURN NULL;
  END;
  $$;


ALTER FUNCTION gn_synthese.fct_trig_update_in_cor_area_synthese() OWNER TO geonatadmin;

--
-- Name: get_default_nomenclature_value(character varying, integer, character varying, character varying); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.get_default_nomenclature_value(myidtype character varying, myidorganism integer DEFAULT 0, myregne character varying DEFAULT '0'::character varying, mygroup2inpn character varying DEFAULT '0'::character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that return the default nomenclature id with wanteds nomenclature type, organism id, regne, group2_inpn
--Return -1 if nothing matche with given parameters
  DECLARE
    theidnomenclature integer;
  BEGIN
      SELECT INTO theidnomenclature id_nomenclature
      FROM gn_synthese.defaults_nomenclatures_value
      WHERE mnemonique_type = myidtype
      AND (id_organism = 0 OR id_organism = myidorganism)
      AND (regne = '0' OR regne = myregne)
      AND (group2_inpn = '0' OR group2_inpn = mygroup2inpn)
      ORDER BY group2_inpn DESC, regne DESC, id_organism DESC LIMIT 1;
    IF (theidnomenclature IS NOT NULL) THEN
      RETURN theidnomenclature;
    END IF;
    RETURN NULL;
  END;
$$;


ALTER FUNCTION gn_synthese.get_default_nomenclature_value(myidtype character varying, myidorganism integer, myregne character varying, mygroup2inpn character varying) OWNER TO geonatadmin;

--
-- Name: get_ids_synthese_for_user_action(integer, text); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.get_ids_synthese_for_user_action(myuser integer, myaction text) RETURNS integer[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
-- The fonction return a array of id_synthese for the given id_role and CRUVED action
-- USAGE : SELECT gn_synthese.get_ids_synthese_for_user_action(1,'U');
DECLARE
  idssynthese integer[];
BEGIN
WITH apps_avalaible AS(
	SELECT id_application, max(tag_object_code) AS portee FROM (
	  SELECT a.id_application, v.tag_object_code
	  FROM utilisateurs.t_applications a
	  JOIN utilisateurs.v_usersaction_forall_gn_modules v ON a.id_parent = v.id_application
	  WHERE id_role = myuser
	  AND tag_action_code = myaction
	  UNION
	  SELECT id_application, tag_object_code
	  FROM utilisateurs.v_usersaction_forall_gn_modules
	  WHERE id_role = myuser
	  AND tag_action_code = myaction
	) a
	GROUP BY id_application
)
SELECT INTO idssynthese array_agg(DISTINCT s.id_synthese)
FROM gn_synthese.synthese s
LEFT JOIN gn_synthese.cor_observer_synthese cos ON cos.id_synthese = s.id_synthese
LEFT JOIN gn_meta.cor_dataset_actor cda ON cda.id_dataset = s.id_dataset
--JOIN apps_avalaible a ON a.id_application = s.id_module
WHERE s.id_module IN (SELECT id_application FROM apps_avalaible WHERE portee = 3::text)
OR (cda.id_organism = (SELECT id_organisme FROM utilisateurs.t_roles WHERE id_role = myuser) AND s.id_module IN (SELECT id_application FROM apps_avalaible WHERE portee = 2::text))
OR (s.id_digitiser = myuser AND s.id_module IN (SELECT id_application FROM apps_avalaible WHERE portee = 1::text))
OR (cos.id_role = myuser AND s.id_module IN (SELECT id_application FROM apps_avalaible WHERE portee = 1::text))
OR (cda.id_role = myuser AND s.id_module IN (SELECT id_application FROM apps_avalaible WHERE portee = 1::text))
;

RETURN idssynthese;
END;
$$;


ALTER FUNCTION gn_synthese.get_ids_synthese_for_user_action(myuser integer, myaction text) OWNER TO geonatadmin;

--
-- Name: import_json_row(jsonb, text); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.import_json_row(datain jsonb, datageojson text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    insert_columns text;
    select_columns text;
    update_columns text;

    geom geometry;
    geom_data jsonb;
    local_srid int;

   postgis_maj_num_version int;
BEGIN


  -- Import des données dans une table temporaire pour faciliter le traitement
  DROP TABLE IF EXISTS tmp_process_import;
  CREATE TABLE tmp_process_import (
      id_synthese int,
      datain jsonb,
      action char(1)
  );
  INSERT INTO tmp_process_import (datain)
  SELECT datain;

  postgis_maj_num_version := (SELECT split_part(version, '.', 1)::int FROM pg_available_extension_versions WHERE name = 'postgis' AND installed = true);

  -- Cas ou la geométrie est passée en geojson
  IF NOT datageojson IS NULL THEN
    geom := (SELECT ST_setsrid(ST_GeomFromGeoJSON(datageojson), 4326));
    local_srid := (SELECT parameter_value FROM gn_commons.t_parameters WHERE parameter_name = 'local_srid');
    geom_data := (
        SELECT json_build_object(
            'the_geom_4326',geom,
            'the_geom_point',(SELECT ST_centroid(geom)),
            'the_geom_local',(SELECT ST_transform(geom, local_srid))
        )
    );

    UPDATE tmp_process_import d
      SET datain = d.datain || geom_data;
  END IF;

-- ############ TEST

  -- colonne unique_id_sinp exists
  IF EXISTS (
        SELECT 1 FROM jsonb_object_keys(datain) column_name WHERE column_name =  'unique_id_sinp'
    ) IS FALSE THEN
        RAISE NOTICE 'Column unique_id_sinp is mandatory';
        RETURN FALSE;
  END IF ;

-- ############ mapping colonnes

  WITH import_col AS (
    SELECT jsonb_object_keys(datain) AS column_name
  ), synt_col AS (
      SELECT column_name, column_default, CASE WHEN data_type = 'USER-DEFINED' THEN udt_name ELSE data_type END as data_type
      FROM information_schema.columns
      WHERE table_schema || '.' || table_name = 'gn_synthese.synthese'
  )
  SELECT
      string_agg(s.column_name, ',')  as insert_columns,
      string_agg(
          CASE
              WHEN NOT column_default IS NULL THEN
              'COALESCE(' || gn_synthese.import_json_row_format_insert_data(i.column_name, data_type::varchar, postgis_maj_num_version) || ', ' || column_default || ') as ' || i.column_name
          ELSE gn_synthese.import_json_row_format_insert_data(i.column_name, data_type::varchar, postgis_maj_num_version)
          END, ','
      ) as select_columns ,
      string_agg(
          s.column_name || '=' ||
          CASE
            WHEN NOT column_default IS NULL
            	THEN  'COALESCE(' || gn_synthese.import_json_row_format_insert_data(i.column_name, data_type::varchar, postgis_maj_num_version) || ', ' || column_default || ') '
  			ELSE gn_synthese.import_json_row_format_insert_data(i.column_name, data_type::varchar, postgis_maj_num_version)
          END
      , ',')
  INTO insert_columns, select_columns, update_columns
  FROM synt_col s
  JOIN import_col i
  ON i.column_name = s.column_name;

  -- ############# IMPORT DATA
  IF EXISTS (
      SELECT 1
      FROM   gn_synthese.synthese
      WHERE  unique_id_sinp = (datain->>'unique_id_sinp')::uuid
  ) IS TRUE THEN
    -- Update
    EXECUTE ' WITH i_row AS (
          UPDATE gn_synthese.synthese s SET ' || update_columns ||
          ' FROM  tmp_process_import
          WHERE s.unique_id_sinp =  (datain->>''unique_id_sinp'')::uuid
          RETURNING s.id_synthese, s.unique_id_sinp
          )
          UPDATE tmp_process_import d SET id_synthese = i_row.id_synthese
          FROM i_row
          WHERE unique_id_sinp = i_row.unique_id_sinp
          ' ;
  ELSE
    -- Insert
    EXECUTE 'WITH i_row AS (
          INSERT INTO gn_synthese.synthese ( ' || insert_columns || ')
          SELECT ' || select_columns ||
          ' FROM tmp_process_import
          RETURNING id_synthese, unique_id_sinp
          )
          UPDATE tmp_process_import d SET id_synthese = i_row.id_synthese
          FROM i_row
          WHERE unique_id_sinp = i_row.unique_id_sinp
          ' ;
  END IF;

  -- Import des cor_observers
  DELETE FROM gn_synthese.cor_observer_synthese
  USING tmp_process_import
  WHERE cor_observer_synthese.id_synthese = tmp_process_import.id_synthese;

  IF jsonb_typeof(datain->'ids_observers') = 'array' THEN
    INSERT INTO gn_synthese.cor_observer_synthese (id_synthese, id_role)
    SELECT DISTINCT id_synthese, (jsonb_array_elements(t.datain->'ids_observers'))::text::int
    FROM tmp_process_import t;
  END IF;

  RETURN TRUE;
  END;
$$;


ALTER FUNCTION gn_synthese.import_json_row(datain jsonb, datageojson text) OWNER TO geonatadmin;

--
-- Name: import_json_row_format_insert_data(character varying, character varying, integer); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.import_json_row_format_insert_data(column_name character varying, data_type character varying, postgis_maj_num_version integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	col_srid int;
BEGIN
	-- Gestion de postgis 3
	IF ((postgis_maj_num_version > 2) AND (data_type = 'geometry')) THEN
		col_srid := (SELECT find_srid('gn_synthese', 'synthese', column_name));
		RETURN '(st_setsrid(ST_GeomFromGeoJSON(datain->>''' || column_name  || '''), ' || col_srid::text || '))' || COALESCE('::' || data_type, '');
	ELSE
		RETURN '(datain->>''' || column_name  || ''')' || COALESCE('::' || data_type, '');
	END IF;

END;
$$;


ALTER FUNCTION gn_synthese.import_json_row_format_insert_data(column_name character varying, data_type character varying, postgis_maj_num_version integer) OWNER TO geonatadmin;

--
-- Name: import_row_from_table(character varying, character varying, character varying, integer, integer); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.import_row_from_table(select_col_name character varying, select_col_val character varying, tbl_name character varying, limit_ integer, offset_ integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    DECLARE
      select_sql text;
      import_rec record;
    BEGIN

      --test que la table/vue existe bien
      --42P01         undefined_table
      IF EXISTS (
          SELECT 1 FROM information_schema.tables t  WHERE t.table_schema ||'.'|| t.table_name = LOWER(tbl_name)
      ) IS FALSE THEN
          RAISE 'Undefined table: %', tbl_name USING ERRCODE = '42P01';
      END IF ;

      --test que la colonne existe bien
      --42703         undefined_column
      IF EXISTS (
          SELECT * FROM information_schema.columns  t  WHERE  t.table_schema ||'.'|| t.table_name = LOWER(tbl_name) AND column_name = select_col_name
      ) IS FALSE THEN
          RAISE 'Undefined column: %', select_col_name USING ERRCODE = '42703';
      END IF ;

        -- TODO transtypage en text pour des questions de généricité. A réflechir
        select_sql := 'SELECT row_to_json(c)::jsonb d
            FROM ' || LOWER(tbl_name) || ' c
            WHERE ' ||  select_col_name|| '::text = ''' || select_col_val || '''
            LIMIT ' || limit_ || '
            OFFSET ' || offset_ ;

        FOR import_rec IN EXECUTE select_sql LOOP
            PERFORM gn_synthese.import_json_row(import_rec.d);
        END LOOP;

      RETURN TRUE;
      END;
    $$;


ALTER FUNCTION gn_synthese.import_row_from_table(select_col_name character varying, select_col_val character varying, tbl_name character varying, limit_ integer, offset_ integer) OWNER TO geonatadmin;

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

--
-- Name: is_communitarian(integer); Type: FUNCTION; Schema: ref_habitats; Owner: geonatadmin
--

CREATE FUNCTION ref_habitats.is_communitarian(my_cd_hab integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de savoir si un habitat est communautaire
  DECLARE is_com integer;
  BEGIN
    SELECT INTO is_com count(*)
    FROM ref_habitats.habref hab
    JOIN ref_habitats.typoref typ ON hab.cd_typo = typ.cd_typo
    WHERE typ.cd_table = 'TYPO_HIC' 
    AND hab.cd_hab = my_cd_hab;
    RETURN is_com = 1;
 END;
$$;


ALTER FUNCTION ref_habitats.is_communitarian(my_cd_hab integer) OWNER TO geonatadmin;

--
-- Name: check_nomenclature_type_by_cd_nomenclature(character varying, character varying); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.check_nomenclature_type_by_cd_nomenclature(mycdnomenclature character varying, mytype character varying) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that checks if an id_nomenclature matches with wanted nomenclature type (use mnemonique type)
  BEGIN
    IF (mycdnomenclature IN (SELECT cd_nomenclature FROM ref_nomenclatures.t_nomenclatures WHERE id_type = ref_nomenclatures.get_id_nomenclature_type(mytype))
        OR mycdnomenclature IS NULL) THEN
      RETURN true;
    ELSE
	    RAISE EXCEPTION 'Error : cd_nomenclature --> % and nomenclature type --> % didn''t match.', mycdnomenclature, mytype
	    USING HINT = 'Use cd_nomenclature in corresponding type (mnemonique field). See ref_nomenclatures.t_nomenclatures.id_type and ref_nomenclatures.bib_nomenclatures_types.mnemonique';
    END IF;
    RETURN false;
  END;
$$;


ALTER FUNCTION ref_nomenclatures.check_nomenclature_type_by_cd_nomenclature(mycdnomenclature character varying, mytype character varying) OWNER TO geonatadmin;

--
-- Name: check_nomenclature_type_by_id(integer, integer); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.check_nomenclature_type_by_id(id integer, myidtype integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that checks if an id_nomenclature matches with wanted nomenclature type (use id_type)
  BEGIN
    IF (id IN (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures WHERE id_type = myidtype )
        OR id IS NULL) THEN
      RETURN true;
    ELSE
	    RAISE EXCEPTION 'Error : id_nomenclature --> (%) and id_type --> (%) didn''t match. Use nomenclature with corresponding type (id_type). See ref_nomenclatures.t_nomenclatures.id_type and ref_nomenclatures.bib_nomenclatures_types.id_type.', id, myidtype ;
    END IF;
    RETURN false;
  END;
$$;


ALTER FUNCTION ref_nomenclatures.check_nomenclature_type_by_id(id integer, myidtype integer) OWNER TO geonatadmin;

--
-- Name: check_nomenclature_type_by_mnemonique(integer, character varying); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.check_nomenclature_type_by_mnemonique(id integer, mytype character varying) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that checks if an id_nomenclature matches with wanted nomenclature type (use mnemonique type)
  BEGIN
    IF (id IN (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures WHERE id_type = ref_nomenclatures.get_id_nomenclature_type(mytype))
        OR id IS NULL) THEN
      RETURN true;
    ELSE
	    RAISE EXCEPTION 'Error : id_nomenclature --> (%) and nomenclature --> (%) type didn''t match. Use id_nomenclature in corresponding type (mnemonique field). See ref_nomenclatures.t_nomenclatures.id_type.', id,mytype;
    END IF;
    RETURN false;
  END;
$$;


ALTER FUNCTION ref_nomenclatures.check_nomenclature_type_by_mnemonique(id integer, mytype character varying) OWNER TO geonatadmin;

--
-- Name: get_cd_nomenclature(integer); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.get_cd_nomenclature(myidnomenclature integer) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function which return the cd_nomenclature from an id_nomenclature
DECLARE thecdnomenclature character varying;
  BEGIN
SELECT INTO thecdnomenclature cd_nomenclature
FROM ref_nomenclatures.t_nomenclatures n
WHERE myidnomenclature = n.id_nomenclature;
return thecdnomenclature;
  END;
$$;


ALTER FUNCTION ref_nomenclatures.get_cd_nomenclature(myidnomenclature integer) OWNER TO geonatadmin;

--
-- Name: get_default_nomenclature_value(character varying, integer); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.get_default_nomenclature_value(mytype character varying, myidorganism integer DEFAULT 0) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that return the default nomenclature id with wanted nomenclature type (mnemonique), organism id
--Return -1 if nothing matches with given parameters
  DECLARE
    thenomenclatureid integer;
  BEGIN
      SELECT INTO thenomenclatureid id_nomenclature
      FROM ref_nomenclatures.defaults_nomenclatures_value
      WHERE mnemonique_type = mytype
      AND (id_organism = myidorganism OR id_organism = 0)
      ORDER BY id_organism DESC LIMIT 1;
    IF (thenomenclatureid IS NOT NULL) THEN
      RETURN thenomenclatureid;
    END IF;
    RETURN -1;
  END;
$$;


ALTER FUNCTION ref_nomenclatures.get_default_nomenclature_value(mytype character varying, myidorganism integer) OWNER TO geonatadmin;

--
-- Name: get_filtered_nomenclature(character varying, character varying, character varying); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.get_filtered_nomenclature(mytype character varying, myregne character varying, mygroup character varying) RETURNS SETOF integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function that returns a list of id_nomenclature depending on regne and/or group2_inpn sent with parameters.
  DECLARE
    thegroup character varying(255);
    theregne character varying(255);
    r integer;

BEGIN
  thegroup = NULL;
  theregne = NULL;

  IF mygroup IS NOT NULL THEN
      SELECT INTO thegroup DISTINCT group2_inpn
      FROM ref_nomenclatures.cor_taxref_nomenclature ctn
      JOIN ref_nomenclatures.t_nomenclatures n ON n.id_nomenclature = ctn.id_nomenclature
      WHERE n.id_type = ref_nomenclatures.get_id_nomenclature_type(mytype)
      AND group2_inpn = mygroup;
  END IF;

  IF myregne IS NOT NULL THEN
    SELECT INTO theregne DISTINCT regne
    FROM ref_nomenclatures.cor_taxref_nomenclature ctn
    JOIN ref_nomenclatures.t_nomenclatures n ON n.id_nomenclature = ctn.id_nomenclature
    WHERE n.id_type = ref_nomenclatures.get_id_nomenclature_type(mytype)
    AND regne = myregne;
  END IF;

  IF theregne IS NOT NULL THEN
    IF thegroup IS NOT NULL THEN
      FOR r IN
        SELECT DISTINCT ctn.id_nomenclature
        FROM taxonomie.cor_taxref_nomenclature ctn
        JOIN ref_nomenclatures.t_nomenclatures n ON n.id_nomenclature = ctn.id_nomenclature
        WHERE n.id_type = ref_nomenclatures.get_id_nomenclature_type(mytype)
        AND regne = theregne
        AND group2_inpn = mygroup
      LOOP
        RETURN NEXT r;
      END LOOP;
      RETURN;
    ELSE
      FOR r IN
        SELECT DISTINCT ctn.id_nomenclature
        FROM taxonomie.cor_taxref_nomenclature ctn
        JOIN ref_nomenclatures.t_nomenclatures n ON n.id_nomenclature = ctn.id_nomenclature
        WHERE n.id_type = ref_nomenclatures.get_id_nomenclature_type(mytype)
        AND regne = theregne
      LOOP
        RETURN NEXT r;
      END LOOP;
      RETURN;
    END IF;
  ELSE
    FOR r IN
      SELECT DISTINCT ctn.id_nomenclature
      FROM taxonomie.cor_taxref_nomenclature ctn
      JOIN ref_nomenclatures.t_nomenclatures n ON n.id_nomenclature = ctn.id_nomenclature
      WHERE n.id_type = ref_nomenclatures.get_id_nomenclature_type(mytype)
    LOOP
      RETURN NEXT r;
    END LOOP;
    RETURN;
  END IF;
END;
$$;


ALTER FUNCTION ref_nomenclatures.get_filtered_nomenclature(mytype character varying, myregne character varying, mygroup character varying) OWNER TO geonatadmin;

--
-- Name: get_id_nomenclature(character varying, character varying); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.get_id_nomenclature(mytype character varying, mycdnomenclature character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function which return the id_nomenclature from an mnemonique_type and an cd_nomenclature
DECLARE theidnomenclature integer;
  BEGIN
SELECT INTO theidnomenclature id_nomenclature
FROM ref_nomenclatures.t_nomenclatures n
WHERE n.id_type = ref_nomenclatures.get_id_nomenclature_type(mytype) AND mycdnomenclature = n.cd_nomenclature;
return theidnomenclature;
  END;
$$;


ALTER FUNCTION ref_nomenclatures.get_id_nomenclature(mytype character varying, mycdnomenclature character varying) OWNER TO geonatadmin;

--
-- Name: get_id_nomenclature_type(character varying); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.get_id_nomenclature_type(mytype character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--Function which return the id_type from the mnemonique of a nomenclature type
DECLARE theidtype character varying;
  BEGIN
SELECT INTO theidtype id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = mytype;
return theidtype;
  END;
$$;


ALTER FUNCTION ref_nomenclatures.get_id_nomenclature_type(mytype character varying) OWNER TO geonatadmin;

--
-- Name: get_nomenclature_label(integer, character varying); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.get_nomenclature_label(myidnomenclature integer DEFAULT NULL::integer, mylanguage character varying DEFAULT 'fr'::character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
--Function which return the label from the id_nomenclature and the language
DECLARE
	labelfield character varying;
	thelabel character varying;
  BEGIN
  labelfield = 'label_'||mylanguage;
  EXECUTE format( ' SELECT  %s
  FROM ref_nomenclatures.t_nomenclatures n
  WHERE id_nomenclature = $1',labelfield)INTO thelabel USING myidnomenclature;
return thelabel;
  END;
$_$;


ALTER FUNCTION ref_nomenclatures.get_nomenclature_label(myidnomenclature integer, mylanguage character varying) OWNER TO geonatadmin;

--
-- Name: get_nomenclature_label_by_cdnom_mnemonique(character varying, character varying); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.get_nomenclature_label_by_cdnom_mnemonique(mytype character varying, mycdnomenclature character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
--Function which return the label from the id_nomenclature and the language
DECLARE
	labelfield character varying;
	thelabel character varying;
  BEGIN
  EXECUTE format( ' SELECT  label_default
  FROM ref_nomenclatures.t_nomenclatures n
  WHERE cd_nomenclature = $1 AND id_type = ref_nomenclatures.get_id_nomenclature_type($2)' )INTO thelabel USING mycdnomenclature, mytype;
return thelabel;
  END;
$_$;


ALTER FUNCTION ref_nomenclatures.get_nomenclature_label_by_cdnom_mnemonique(mytype character varying, mycdnomenclature character varying) OWNER TO geonatadmin;

--
-- Name: get_nomenclature_label_by_cdnom_mnemonique_and_language(character varying, character varying, character varying); Type: FUNCTION; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE FUNCTION ref_nomenclatures.get_nomenclature_label_by_cdnom_mnemonique_and_language(mytype character varying, mycdnomenclature character varying, mylanguage character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
--Function which return the label from the cd_nomenclature, the code_type and the language
DECLARE
	labelfield character varying;
	thelabel character varying;
  BEGIN
  labelfield = 'label_'||mylanguage;
  EXECUTE format( ' SELECT  %s
  FROM ref_nomenclatures.t_nomenclatures n
  WHERE cd_nomenclature = $1 AND id_type = ref_nomenclatures.get_id_nomenclature_type($2)',labelfield )INTO thelabel USING mycdnomenclature, mytype;
return thelabel;
  END;
$_$;


ALTER FUNCTION ref_nomenclatures.get_nomenclature_label_by_cdnom_mnemonique_and_language(mytype character varying, mycdnomenclature character varying, mylanguage character varying) OWNER TO geonatadmin;

--
-- Name: check_is_group2inpn(text); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.check_is_group2inpn(mygroup text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de vérifier si un texte proposé correspond à un group2_inpn dans la table taxref
  BEGIN
    IF mygroup IN(SELECT group2_inpn FROM taxonomie.vm_group2_inpn) OR mygroup IS NULL THEN
      RETURN true;
    ELSE
      RETURN false;
    END IF;
  END;
$$;


ALTER FUNCTION taxonomie.check_is_group2inpn(mygroup text) OWNER TO geonatadmin;

--
-- Name: check_is_inbibnoms(integer); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.check_is_inbibnoms(mycdnom integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de vérifier si un texte proposé correspond à un group2_inpn dans la table taxref
  BEGIN
    IF mycdnom IN(SELECT cd_nom FROM taxonomie.bib_noms) THEN
      RETURN true;
    ELSE
      RETURN false;
    END IF;
  END;
$$;


ALTER FUNCTION taxonomie.check_is_inbibnoms(mycdnom integer) OWNER TO geonatadmin;

--
-- Name: check_is_regne(text); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.check_is_regne(myregne text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de vérifier si un texte proposé correspond à un regne dans la table taxref
  BEGIN
    IF myregne IN(SELECT regne FROM taxonomie.vm_regne) OR myregne IS NULL THEN
      return true;
    ELSE
      RETURN false;
    END IF;
  END;
$$;


ALTER FUNCTION taxonomie.check_is_regne(myregne text) OWNER TO geonatadmin;

--
-- Name: fct_build_bibtaxon_attributs_view(character varying); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.fct_build_bibtaxon_attributs_view(sregne character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    r taxonomie.bib_attributs%rowtype;
    sql_select text;
    sql_join text;
    sql_where text;
BEGIN
	sql_join :=' FROM taxonomie.bib_noms b JOIN taxonomie.taxref taxref USING(cd_nom) ';
	sql_select := 'SELECT b.* ';
	sql_where := ' WHERE regne=''' ||$1 || '''';
	FOR r IN
		SELECT id_attribut, nom_attribut, label_attribut, liste_valeur_attribut,
		       obligatoire, desc_attribut, type_attribut, type_widget, regne,
		       group2_inpn
		FROM taxonomie.bib_attributs
		WHERE regne IS NULL OR regne=sregne
	LOOP
		sql_select := sql_select || ', ' || r.nom_attribut || '.valeur_attribut::' || r.type_attribut || ' as ' || r.nom_attribut;
		sql_join := sql_join || ' LEFT OUTER JOIN (SELECT valeur_attribut, cd_ref FROM taxonomie.cor_taxon_attribut WHERE id_attribut= '
			|| r.id_attribut || ') as  ' || r.nom_attribut || '  ON b.cd_ref= ' || r.nom_attribut || '.cd_ref ';

	--RETURN NEXT r; -- return current row of SELECT
	END LOOP;
	EXECUTE 'DROP VIEW IF EXISTS taxonomie.v_bibtaxon_attributs_' || sregne ;
	EXECUTE 'CREATE OR REPLACE VIEW taxonomie.v_bibtaxon_attributs_' || sregne ||  ' AS ' || sql_select || sql_join || sql_where ;
END
$_$;


ALTER FUNCTION taxonomie.fct_build_bibtaxon_attributs_view(sregne character varying) OWNER TO geonatadmin;

--
-- Name: find_all_taxons_children(integer[]); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.find_all_taxons_children(ids integer[]) RETURNS TABLE(cd_nom integer, cd_ref integer)
    LANGUAGE plpgsql IMMUTABLE
    AS $$
 --Param : cd_nom ou cd_ref d'un taxon quelque soit son rang
 --Retourne le cd_nom de tous les taxons enfants sous forme d'un jeu de données utilisable comme une table
 --Usage SELECT taxonomie.find_all_taxons_children(197047);
 --ou SELECT * FROM atlas.vm_taxons WHERE cd_ref IN(SELECT * FROM taxonomie.find_all_taxons_children(197047))
  BEGIN
      RETURN QUERY
      WITH RECURSIVE descendants AS (
        SELECT tx1.cd_nom, tx1.cd_ref FROM taxonomie.taxref tx1 WHERE tx1.cd_sup = ANY(ids)
      UNION ALL
      SELECT tx2.cd_nom, tx2.cd_ref FROM descendants d JOIN taxonomie.taxref tx2 ON tx2.cd_sup = d.cd_nom
      )
      SELECT * FROM descendants;

  END;
$$;


ALTER FUNCTION taxonomie.find_all_taxons_children(ids integer[]) OWNER TO geonatadmin;

--
-- Name: find_all_taxons_children(integer); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.find_all_taxons_children(id integer) RETURNS TABLE(cd_nom integer, cd_ref integer)
    LANGUAGE plpgsql IMMUTABLE
    AS $$
 --Param : cd_nom ou cd_ref d'un taxon quelque soit son rang
 --Retourne le cd_nom de tous les taxons enfants sous forme d'un jeu de données utilisable comme une table
 --Usage SELECT taxonomie.find_all_taxons_children(197047);
 --ou SELECT * FROM atlas.vm_taxons WHERE cd_ref IN(SELECT * FROM taxonomie.find_all_taxons_children(197047))
  BEGIN
      RETURN QUERY
      WITH RECURSIVE descendants AS (
        SELECT tx1.cd_nom, tx1.cd_ref FROM taxonomie.taxref tx1 WHERE tx1.cd_sup = id
      UNION ALL
      SELECT tx2.cd_nom, tx2.cd_ref FROM descendants d JOIN taxonomie.taxref tx2 ON tx2.cd_sup = d.cd_nom
      )
      SELECT * FROM descendants;

  END;
$$;


ALTER FUNCTION taxonomie.find_all_taxons_children(id integer) OWNER TO geonatadmin;

--
-- Name: find_cdref(integer); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.find_cdref(id integer) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de renvoyer le cd_ref d'un taxon à partir de son cd_nom
--
--Gil DELUERMOZ septembre 2011

  DECLARE ref integer;
  BEGIN
	SELECT INTO ref cd_ref FROM taxonomie.taxref WHERE cd_nom = id;
	return ref;
  END;
$$;


ALTER FUNCTION taxonomie.find_cdref(id integer) OWNER TO geonatadmin;

--
-- Name: find_group2inpn(integer); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.find_group2inpn(mycdnom integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de renvoyer le group2_inpn d'un taxon à partir de son cd_nom
  DECLARE group2 character varying(255);
  BEGIN
    SELECT INTO group2 group2_inpn FROM taxonomie.taxref WHERE cd_nom = mycdnom;
    return group2;
  END;
$$;


ALTER FUNCTION taxonomie.find_group2inpn(mycdnom integer) OWNER TO geonatadmin;

--
-- Name: find_regne(integer); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.find_regne(mycdnom integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de renvoyer le regne d'un taxon à partir de son cd_nom
  DECLARE theregne character varying(255);
  BEGIN
    SELECT INTO theregne regne FROM taxonomie.taxref WHERE cd_nom = mycdnom;
    return theregne;
  END;
$$;


ALTER FUNCTION taxonomie.find_regne(mycdnom integer) OWNER TO geonatadmin;

--
-- Name: insert_t_medias(); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.insert_t_medias() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    trimtitre text;
BEGIN
    new.date_media = now();
    trimtitre = replace(new.titre, ' ', '');
    --new.url = new.chemin || new.cd_ref || '_' || trimtitre || '.jpg';
    RETURN NEW;
END;
$$;


ALTER FUNCTION taxonomie.insert_t_medias() OWNER TO geonatadmin;

--
-- Name: trg_fct_refresh_attributesviews_per_kingdom(); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.trg_fct_refresh_attributesviews_per_kingdom() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   sregne text;
BEGIN
	if NEW.regne IS NULL THEN
		FOR sregne IN
			SELECT DISTINCT regne
			FROM taxonomie.taxref t
			JOIN taxonomie.bib_noms n
			ON t.cd_nom = n.cd_nom
			WHERE t.regne IS NOT NULL
		LOOP
			PERFORM taxonomie.fct_build_bibtaxon_attributs_view(sregne);
		END LOOP;
	ELSE
		PERFORM taxonomie.fct_build_bibtaxon_attributs_view(NEW.regne);
	END IF;
   RETURN NEW;
END
$$;


ALTER FUNCTION taxonomie.trg_fct_refresh_attributesviews_per_kingdom() OWNER TO geonatadmin;

--
-- Name: unique_type1(); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.unique_type1() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    nbimgprincipale integer;
    mymedia record;
BEGIN
  IF new.id_type = 1 THEN
    SELECT count(*) INTO nbimgprincipale FROM taxonomie.t_medias WHERE cd_ref = new.cd_ref AND id_type = 1 AND NOT id_media = NEW.id_media;
    IF nbimgprincipale > 0 THEN
      FOR mymedia  IN SELECT * FROM taxonomie.t_medias WHERE cd_ref = new.cd_ref AND id_type = 1 LOOP
        UPDATE taxonomie.t_medias SET id_type = 2 WHERE id_media = mymedia.id_media;
        RAISE NOTICE USING MESSAGE =
        'La photo principale a été mise à jour pour le cd_ref ' || new.cd_ref ||
        '. La photo avec l''id_media ' || mymedia.id_media  || ' n''est plus la photo principale.';
      END LOOP;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION taxonomie.unique_type1() OWNER TO geonatadmin;

--
-- Name: check_is_default_group_for_app_is_grp_and_unique(integer, integer, boolean); Type: FUNCTION; Schema: utilisateurs; Owner: geonatadmin
--

CREATE FUNCTION utilisateurs.check_is_default_group_for_app_is_grp_and_unique(id_app integer, id_grp integer, is_default boolean) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    -- Fonction de vérification
    -- Test : si le role est un groupe et qu'il n'y a qu'un seul groupe par défaut définit par application
    IF is_default IS TRUE THEN
        IF (
            SELECT DISTINCT TRUE
            FROM utilisateurs.cor_role_app_profil
            WHERE id_application = id_app AND is_default_group_for_app IS TRUE
        ) IS TRUE THEN
            RETURN FALSE;
        ELSIF (SELECT TRUE FROM utilisateurs.t_roles WHERE id_role = id_grp AND groupe IS TRUE) IS NULL THEN
            RETURN FALSE;
        ELSE
          RETURN TRUE;
        END IF;
    END IF;
    RETURN TRUE;
  END
$$;


ALTER FUNCTION utilisateurs.check_is_default_group_for_app_is_grp_and_unique(id_app integer, id_grp integer, is_default boolean) OWNER TO geonatadmin;

--
-- Name: modify_date_insert(); Type: FUNCTION; Schema: utilisateurs; Owner: geonatadmin
--

CREATE FUNCTION utilisateurs.modify_date_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.date_insert := now();
    NEW.date_update := now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION utilisateurs.modify_date_insert() OWNER TO geonatadmin;

--
-- Name: modify_date_update(); Type: FUNCTION; Schema: utilisateurs; Owner: geonatadmin
--

CREATE FUNCTION utilisateurs.modify_date_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.date_update := now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION utilisateurs.modify_date_update() OWNER TO geonatadmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bib_tables_location; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.bib_tables_location (
    id_table_location integer NOT NULL,
    table_desc character varying(255),
    schema_name character varying(50) NOT NULL,
    table_name character varying(50) NOT NULL,
    pk_field character varying(50) NOT NULL,
    uuid_field_name character varying(50) NOT NULL
);


ALTER TABLE gn_commons.bib_tables_location OWNER TO geonatadmin;

--
-- Name: bib_tables_location_id_table_location_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.bib_tables_location_id_table_location_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.bib_tables_location_id_table_location_seq OWNER TO geonatadmin;

--
-- Name: bib_tables_location_id_table_location_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.bib_tables_location_id_table_location_seq OWNED BY gn_commons.bib_tables_location.id_table_location;


--
-- Name: bib_widgets; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.bib_widgets (
    id_widget integer NOT NULL,
    widget_name character varying(50) NOT NULL
);


ALTER TABLE gn_commons.bib_widgets OWNER TO geonatadmin;

--
-- Name: bib_widgets_id_widget_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.bib_widgets_id_widget_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.bib_widgets_id_widget_seq OWNER TO geonatadmin;

--
-- Name: bib_widgets_id_widget_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.bib_widgets_id_widget_seq OWNED BY gn_commons.bib_widgets.id_widget;


--
-- Name: cor_field_dataset; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.cor_field_dataset (
    id_field integer NOT NULL,
    id_dataset integer NOT NULL
);


ALTER TABLE gn_commons.cor_field_dataset OWNER TO geonatadmin;

--
-- Name: cor_field_module; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.cor_field_module (
    id_field integer NOT NULL,
    id_module integer NOT NULL
);


ALTER TABLE gn_commons.cor_field_module OWNER TO geonatadmin;

--
-- Name: cor_field_object; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.cor_field_object (
    id_field integer NOT NULL,
    id_object integer NOT NULL
);


ALTER TABLE gn_commons.cor_field_object OWNER TO geonatadmin;

--
-- Name: cor_module_dataset; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.cor_module_dataset (
    id_module integer NOT NULL,
    id_dataset integer NOT NULL
);


ALTER TABLE gn_commons.cor_module_dataset OWNER TO geonatadmin;

--
-- Name: TABLE cor_module_dataset; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON TABLE gn_commons.cor_module_dataset IS 'Define which datasets can be used in modules';


--
-- Name: t_additional_fields; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.t_additional_fields (
    id_field integer NOT NULL,
    field_name character varying(255) NOT NULL,
    field_label character varying(50) NOT NULL,
    required boolean DEFAULT false NOT NULL,
    description text,
    id_widget integer NOT NULL,
    quantitative boolean DEFAULT false,
    unity character varying(50),
    additional_attributes jsonb,
    code_nomenclature_type character varying(255),
    field_values jsonb,
    multiselect boolean,
    id_list integer,
    key_label character varying(250),
    key_value character varying(250),
    api character varying(250),
    exportable boolean DEFAULT true,
    field_order integer
);


ALTER TABLE gn_commons.t_additional_fields OWNER TO geonatadmin;

--
-- Name: t_additional_fields_id_field_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.t_additional_fields_id_field_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.t_additional_fields_id_field_seq OWNER TO geonatadmin;

--
-- Name: t_additional_fields_id_field_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.t_additional_fields_id_field_seq OWNED BY gn_commons.t_additional_fields.id_field;


--
-- Name: t_history_actions; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.t_history_actions (
    id_history_action integer NOT NULL,
    id_table_location integer NOT NULL,
    uuid_attached_row uuid NOT NULL,
    operation_type character(1),
    operation_date timestamp without time zone,
    table_content json,
    CONSTRAINT check_t_history_actions_operation_type CHECK ((operation_type = ANY (ARRAY['I'::bpchar, 'U'::bpchar, 'D'::bpchar])))
);


ALTER TABLE gn_commons.t_history_actions OWNER TO geonatadmin;

--
-- Name: COLUMN t_history_actions.id_table_location; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_history_actions.id_table_location IS 'FK vers la table où se trouve l''enregistrement tracé';


--
-- Name: COLUMN t_history_actions.uuid_attached_row; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_history_actions.uuid_attached_row IS 'Uuid de l''enregistrement tracé';


--
-- Name: COLUMN t_history_actions.operation_type; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_history_actions.operation_type IS 'Type d''événement tracé (Create, Update, Delete)';


--
-- Name: COLUMN t_history_actions.operation_date; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_history_actions.operation_date IS 'Date de l''événement';


--
-- Name: COLUMN t_history_actions.table_content; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_history_actions.table_content IS 'Contenu au format json de l''événement tracé. On enregistre le NEW pour CREATE et UPDATE. LE OLD (ou rien?) pour le DELETE.';


--
-- Name: t_history_actions_id_history_action_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.t_history_actions_id_history_action_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.t_history_actions_id_history_action_seq OWNER TO geonatadmin;

--
-- Name: t_history_actions_id_history_action_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.t_history_actions_id_history_action_seq OWNED BY gn_commons.t_history_actions.id_history_action;


--
-- Name: t_medias; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.t_medias (
    id_media integer NOT NULL,
    unique_id_media uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    id_nomenclature_media_type integer NOT NULL,
    id_table_location integer NOT NULL,
    uuid_attached_row uuid,
    title_fr character varying(255),
    title_en character varying(255),
    title_it character varying(255),
    title_es character varying(255),
    title_de character varying(255),
    media_url character varying(255),
    media_path character varying(255),
    author character varying(100),
    description_fr text,
    description_en text,
    description_it text,
    description_es text,
    description_de text,
    is_public boolean DEFAULT true NOT NULL,
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now()
);


ALTER TABLE gn_commons.t_medias OWNER TO geonatadmin;

--
-- Name: COLUMN t_medias.id_nomenclature_media_type; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_medias.id_nomenclature_media_type IS 'Correspondance nomenclature GEONATURE = TYPE_MEDIA (117)';


--
-- Name: t_medias_id_media_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.t_medias_id_media_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.t_medias_id_media_seq OWNER TO geonatadmin;

--
-- Name: t_medias_id_media_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.t_medias_id_media_seq OWNED BY gn_commons.t_medias.id_media;


--
-- Name: t_mobile_apps; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.t_mobile_apps (
    id_mobile_app integer NOT NULL,
    app_code character varying(30),
    relative_path_apk character varying(255),
    url_apk character varying(255),
    package character varying(255),
    version_code character varying(10)
);


ALTER TABLE gn_commons.t_mobile_apps OWNER TO geonatadmin;

--
-- Name: COLUMN t_mobile_apps.app_code; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_mobile_apps.app_code IS 'Code de l''application mobile. Pas de FK vers t_modules car une application mobile ne correspond pas forcement à un module GN';


--
-- Name: t_mobile_apps_id_mobile_app_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.t_mobile_apps_id_mobile_app_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.t_mobile_apps_id_mobile_app_seq OWNER TO geonatadmin;

--
-- Name: t_mobile_apps_id_mobile_app_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.t_mobile_apps_id_mobile_app_seq OWNED BY gn_commons.t_mobile_apps.id_mobile_app;


--
-- Name: t_modules; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.t_modules (
    id_module integer NOT NULL,
    module_code character varying(50) NOT NULL,
    module_label character varying(255) NOT NULL,
    module_picto character varying(255),
    module_desc text,
    module_group character varying(50),
    module_path character varying(255),
    module_external_url character varying(255),
    module_target character varying(10),
    module_comment text,
    active_frontend boolean NOT NULL,
    active_backend boolean NOT NULL,
    module_doc_url character varying(255),
    module_order integer,
    type character varying(255),
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now(),
    CONSTRAINT check_urls_not_null CHECK (((module_path IS NOT NULL) OR (module_external_url IS NOT NULL)))
);


ALTER TABLE gn_commons.t_modules OWNER TO geonatadmin;

--
-- Name: COLUMN t_modules.id_module; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_modules.id_module IS 'PK mais aussi FK vers la table "utilisateurs.t_applications". ATTENTION de ne pas utiliser l''identifiant d''une application existante dans cette table et qui ne serait pas un module de GeoNature';


--
-- Name: COLUMN t_modules.module_path; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_modules.module_path IS 'url relative vers le module - si module interne';


--
-- Name: COLUMN t_modules.module_external_url; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_modules.module_external_url IS 'url absolue vers le module - si module externe (active_frontend = false)';


--
-- Name: COLUMN t_modules.module_target; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_modules.module_target IS 'Value = NULL ou "blank". On peux ainsi référencer des modules externes et les ouvrir dans un nouvel onglet.';


--
-- Name: t_modules_id_module_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.t_modules_id_module_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.t_modules_id_module_seq OWNER TO geonatadmin;

--
-- Name: t_modules_id_module_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.t_modules_id_module_seq OWNED BY gn_commons.t_modules.id_module;


--
-- Name: t_parameters; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.t_parameters (
    id_parameter integer NOT NULL,
    id_organism integer,
    parameter_name character varying(100) NOT NULL,
    parameter_desc text,
    parameter_value text NOT NULL,
    parameter_extra_value character varying(255)
);


ALTER TABLE gn_commons.t_parameters OWNER TO geonatadmin;

--
-- Name: TABLE t_parameters; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON TABLE gn_commons.t_parameters IS 'Allow to manage content configuration depending on organism or not (CRUD depending on privileges).';


--
-- Name: t_parameters_id_parameter_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.t_parameters_id_parameter_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.t_parameters_id_parameter_seq OWNER TO geonatadmin;

--
-- Name: t_parameters_id_parameter_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.t_parameters_id_parameter_seq OWNED BY gn_commons.t_parameters.id_parameter;


--
-- Name: t_places; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.t_places (
    id_place integer NOT NULL,
    id_role integer NOT NULL,
    place_name character varying(100),
    place_geom public.geometry
);


ALTER TABLE gn_commons.t_places OWNER TO geonatadmin;

--
-- Name: COLUMN t_places.id_place; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_places.id_place IS 'Clé primaire autoincrémente de la table t_places';


--
-- Name: COLUMN t_places.id_role; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_places.id_role IS 'Clé étrangère vers la table utilisateurs.t_roles, chaque lieu est associé à un utilisateur';


--
-- Name: COLUMN t_places.place_name; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_places.place_name IS 'Nom du lieu';


--
-- Name: COLUMN t_places.place_geom; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_places.place_geom IS 'Géométrie du lieu';


--
-- Name: t_places_id_place_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.t_places_id_place_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.t_places_id_place_seq OWNER TO geonatadmin;

--
-- Name: t_places_id_place_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.t_places_id_place_seq OWNED BY gn_commons.t_places.id_place;


--
-- Name: t_validations; Type: TABLE; Schema: gn_commons; Owner: geonatadmin
--

CREATE TABLE gn_commons.t_validations (
    id_validation integer NOT NULL,
    uuid_attached_row uuid NOT NULL,
    id_nomenclature_valid_status integer,
    validation_auto boolean DEFAULT true NOT NULL,
    id_validator integer,
    validation_comment text,
    validation_date timestamp without time zone
);


ALTER TABLE gn_commons.t_validations OWNER TO geonatadmin;

--
-- Name: COLUMN t_validations.uuid_attached_row; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_validations.uuid_attached_row IS 'Uuid de l''enregistrement validé';


--
-- Name: COLUMN t_validations.id_nomenclature_valid_status; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_validations.id_nomenclature_valid_status IS 'Correspondance nomenclature INPN = statut_valid (101)';


--
-- Name: COLUMN t_validations.id_validator; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_validations.id_validator IS 'Fk vers l''id_role (utilisateurs.t_roles) du validateur';


--
-- Name: COLUMN t_validations.validation_comment; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_validations.validation_comment IS 'Commentaire concernant la validation';


--
-- Name: COLUMN t_validations.validation_date; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON COLUMN gn_commons.t_validations.validation_date IS 'Date de la validation';


--
-- Name: t_validations_id_validation_seq; Type: SEQUENCE; Schema: gn_commons; Owner: geonatadmin
--

CREATE SEQUENCE gn_commons.t_validations_id_validation_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_commons.t_validations_id_validation_seq OWNER TO geonatadmin;

--
-- Name: t_validations_id_validation_seq; Type: SEQUENCE OWNED BY; Schema: gn_commons; Owner: geonatadmin
--

ALTER SEQUENCE gn_commons.t_validations_id_validation_seq OWNED BY gn_commons.t_validations.id_validation;


--
-- Name: v_latest_validation; Type: VIEW; Schema: gn_commons; Owner: geonatadmin
--

CREATE VIEW gn_commons.v_latest_validation AS
 SELECT v.id_validation,
    v.uuid_attached_row,
    v.id_nomenclature_valid_status,
    v.validation_auto,
    v.id_validator,
    v.validation_comment,
    v.validation_date
   FROM (gn_commons.t_validations v
     JOIN ( SELECT t_validations.uuid_attached_row,
            max(t_validations.validation_date) AS max_date
           FROM gn_commons.t_validations
          GROUP BY t_validations.uuid_attached_row) last_val ON (((v.uuid_attached_row = last_val.uuid_attached_row) AND (v.validation_date = last_val.max_date))));


ALTER TABLE gn_commons.v_latest_validation OWNER TO geonatadmin;

--
-- Name: v_meta_actions_on_object; Type: VIEW; Schema: gn_commons; Owner: geonatadmin
--

CREATE VIEW gn_commons.v_meta_actions_on_object AS
 WITH insert_a AS (
         SELECT t_history_actions.id_history_action,
            t_history_actions.id_table_location,
            t_history_actions.uuid_attached_row,
            t_history_actions.operation_type,
            t_history_actions.operation_date,
            ((t_history_actions.table_content ->> 'id_digitiser'::text))::integer AS id_creator
           FROM gn_commons.t_history_actions
          WHERE (t_history_actions.operation_type = 'I'::bpchar)
        ), delete_a AS (
         SELECT t_history_actions.id_history_action,
            t_history_actions.id_table_location,
            t_history_actions.uuid_attached_row,
            t_history_actions.operation_type,
            t_history_actions.operation_date
           FROM gn_commons.t_history_actions
          WHERE (t_history_actions.operation_type = 'D'::bpchar)
        ), last_update_a AS (
         SELECT DISTINCT ON (t_history_actions.uuid_attached_row) t_history_actions.id_history_action,
            t_history_actions.id_table_location,
            t_history_actions.uuid_attached_row,
            t_history_actions.operation_type,
            t_history_actions.operation_date
           FROM gn_commons.t_history_actions
          WHERE (t_history_actions.operation_type = 'U'::bpchar)
          ORDER BY t_history_actions.uuid_attached_row, t_history_actions.operation_date DESC
        )
 SELECT i.id_table_location,
    i.uuid_attached_row,
    i.operation_date AS meta_create_date,
    i.id_creator,
    u.operation_date AS meta_update_date,
    d.operation_date AS meta_delete_date
   FROM ((insert_a i
     LEFT JOIN last_update_a u ON ((i.uuid_attached_row = u.uuid_attached_row)))
     LEFT JOIN delete_a d ON ((i.uuid_attached_row = d.uuid_attached_row)));


ALTER TABLE gn_commons.v_meta_actions_on_object OWNER TO geonatadmin;

--
-- Name: t_datasets; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.t_datasets (
    id_dataset integer NOT NULL,
    unique_dataset_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    id_acquisition_framework integer NOT NULL,
    dataset_name character varying(255) NOT NULL,
    dataset_shortname character varying(255) NOT NULL,
    dataset_desc text NOT NULL,
    id_nomenclature_data_type integer DEFAULT ref_nomenclatures.get_default_nomenclature_value('DATA_TYP'::character varying) NOT NULL,
    keywords text,
    marine_domain boolean NOT NULL,
    terrestrial_domain boolean NOT NULL,
    id_nomenclature_dataset_objectif integer DEFAULT ref_nomenclatures.get_default_nomenclature_value('JDD_OBJECTIFS'::character varying) NOT NULL,
    bbox_west real,
    bbox_east real,
    bbox_south real,
    bbox_north real,
    id_nomenclature_collecting_method integer DEFAULT ref_nomenclatures.get_default_nomenclature_value('METHO_RECUEIL'::character varying) NOT NULL,
    id_nomenclature_data_origin integer DEFAULT ref_nomenclatures.get_default_nomenclature_value('DS_PUBLIQUE'::character varying) NOT NULL,
    id_nomenclature_source_status integer DEFAULT ref_nomenclatures.get_default_nomenclature_value('STATUT_SOURCE'::character varying) NOT NULL,
    id_nomenclature_resource_type integer DEFAULT ref_nomenclatures.get_default_nomenclature_value('RESOURCE_TYP'::character varying) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    validable boolean DEFAULT true,
    id_digitizer integer,
    id_taxa_list integer,
    meta_create_date timestamp without time zone NOT NULL,
    meta_update_date timestamp without time zone
);


ALTER TABLE gn_meta.t_datasets OWNER TO geonatadmin;

--
-- Name: TABLE t_datasets; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.t_datasets IS 'A dataset is a dataset or a survey and each observation is attached to a dataset. A lot allows to qualify datas to which it is attached (producer, owner, manager, gestionnaire, financer, public data yes/no). A dataset can be attached to a program. GeoNature V2 backoffice allows to manage datasets.';


--
-- Name: COLUMN t_datasets.id_dataset; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.id_dataset IS 'Internal value for primary and foreign keys.';


--
-- Name: COLUMN t_datasets.unique_dataset_id; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.unique_dataset_id IS 'Correspondance standard SINP = identifiantJdd : Identifiant unique du jeu de données sous la forme d''un UUID. Il devra être sous la forme d''un UUID - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.id_acquisition_framework; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.id_acquisition_framework IS ' Internal value for foreign keys with t_acquisition_frameworks table';


--
-- Name: COLUMN t_datasets.dataset_name; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.dataset_name IS 'Correspondance standard SINP = libelle : Nom du jeu de données (150 caractères) - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.dataset_shortname; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.dataset_shortname IS 'Correspondance standard SINP = libelleCourt : Libellé court (30 caractères) du jeu de données - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.dataset_desc; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.dataset_desc IS 'Correspondance standard SINP = description : Description du jeu de données - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.id_nomenclature_data_type; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.id_nomenclature_data_type IS 'Correspondance standard SINP = typeDonnees : Type de données du jeu de données tel que défini dans la nomenclature TypeDonneesValue - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.keywords; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.keywords IS 'Correspondance standard SINP = motCle : Mot(s)-clé(s) représentatifs du jeu de données, séparés par des virgules - FACULTATIF';


--
-- Name: COLUMN t_datasets.marine_domain; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.marine_domain IS 'Correspondance standard SINP = domaineMarin : Indique si le jeu de données concerne le domaine marin - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.terrestrial_domain; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.terrestrial_domain IS 'Correspondance standard SINP = domaineTerrestre : Indique si le jeu de données concerne le domaine terrestre - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.id_nomenclature_dataset_objectif; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.id_nomenclature_dataset_objectif IS 'Correspondance standard SINP = objectifJdd : Objectif du jeu de données tel que défini par la nomenclature ObjectifJeuDonneesValue - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.bbox_west; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.bbox_west IS 'Correspondance standard SINP = empriseGeographique::borneOuest : Point le plus à l''ouest de la zone géographique délimitant le jeu de données - FACULTATIF';


--
-- Name: COLUMN t_datasets.bbox_east; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.bbox_east IS 'Correspondance standard SINP = empriseGeographique::borneEst : Point le plus à l''est de la zone géographique délimitant le jeu de données - FACULTATIF';


--
-- Name: COLUMN t_datasets.bbox_south; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.bbox_south IS 'Correspondance standard SINP = empriseGeographique::borneSud : Point le plus au sud de la zone géographique délimitant le jeu de données - FACULTATIF';


--
-- Name: COLUMN t_datasets.bbox_north; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.bbox_north IS 'Correspondance standard SINP = empriseGeographique::borneNord : Point le plus au nord de la zone géographique délimitant le jeu de données - FACULTATIF';


--
-- Name: COLUMN t_datasets.id_nomenclature_collecting_method; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.id_nomenclature_collecting_method IS 'Correspondance standard SINP = methodeRecueil : Méthode de recueil des données : Ensemble de techniques, savoir-faire et outils mobilisés pour collecter des données - RECOMMANDE';


--
-- Name: COLUMN t_datasets.id_nomenclature_data_origin; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.id_nomenclature_data_origin IS 'Public, privée, etc... Dans le standard SINP cette information se situe au niveau de chaque occurrence de taxon. On considère ici qu''elle doit être homoogène pour un même jeu de données - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.id_nomenclature_source_status; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.id_nomenclature_source_status IS 'Terrain, littérature, etc... Dans le standard SINP cette information se situe au niveau de chaque occurrence de taxon. On considère ici qu''elle doit être homoogène pour un même jeu de données - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.id_nomenclature_resource_type; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.id_nomenclature_resource_type IS 'jeu de données ou série de jeu de données. Dans le standard SINP cette information se situe au niveau de chaque occurrence de taxon. On considère ici qu''elle doit être homoogène pour un même jeu de données - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.meta_create_date; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.meta_create_date IS 'Correspondance standard SINP = dateCreation : Date de création de la fiche de métadonnées du jeu de données, format AAAA-MM-JJ - OBLIGATOIRE';


--
-- Name: COLUMN t_datasets.meta_update_date; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_datasets.meta_update_date IS 'Identifiant de la liste de taxon associé au JDD. FK: taxonomie.bib_liste';


--
-- Name: synthese; Type: TABLE; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TABLE gn_synthese.synthese (
    id_synthese integer NOT NULL,
    unique_id_sinp uuid,
    unique_id_sinp_grp uuid,
    id_source integer,
    id_module integer,
    entity_source_pk_value character varying,
    id_dataset integer,
    id_nomenclature_geo_object_nature integer DEFAULT gn_synthese.get_default_nomenclature_value('NAT_OBJ_GEO'::character varying),
    id_nomenclature_grp_typ integer DEFAULT gn_synthese.get_default_nomenclature_value('TYP_GRP'::character varying),
    grp_method character varying(255),
    id_nomenclature_obs_technique integer DEFAULT gn_synthese.get_default_nomenclature_value('METH_OBS'::character varying),
    id_nomenclature_bio_status integer DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_BIO'::character varying),
    id_nomenclature_bio_condition integer DEFAULT gn_synthese.get_default_nomenclature_value('ETA_BIO'::character varying),
    id_nomenclature_naturalness integer DEFAULT gn_synthese.get_default_nomenclature_value('NATURALITE'::character varying),
    id_nomenclature_exist_proof integer DEFAULT gn_synthese.get_default_nomenclature_value('PREUVE_EXIST'::character varying),
    id_nomenclature_valid_status integer DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_VALID'::character varying),
    id_nomenclature_diffusion_level integer,
    id_nomenclature_life_stage integer DEFAULT gn_synthese.get_default_nomenclature_value('STADE_VIE'::character varying),
    id_nomenclature_sex integer DEFAULT gn_synthese.get_default_nomenclature_value('SEXE'::character varying),
    id_nomenclature_obj_count integer DEFAULT gn_synthese.get_default_nomenclature_value('OBJ_DENBR'::character varying),
    id_nomenclature_type_count integer DEFAULT gn_synthese.get_default_nomenclature_value('TYP_DENBR'::character varying),
    id_nomenclature_sensitivity integer,
    id_nomenclature_observation_status integer DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_OBS'::character varying),
    id_nomenclature_blurring integer DEFAULT gn_synthese.get_default_nomenclature_value('DEE_FLOU'::character varying),
    id_nomenclature_source_status integer DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_SOURCE'::character varying),
    id_nomenclature_info_geo_type integer DEFAULT gn_synthese.get_default_nomenclature_value('TYP_INF_GEO'::character varying),
    id_nomenclature_behaviour integer DEFAULT gn_synthese.get_default_nomenclature_value('OCC_COMPORTEMENT'::character varying),
    id_nomenclature_biogeo_status integer DEFAULT gn_synthese.get_default_nomenclature_value('STAT_BIOGEO'::character varying),
    reference_biblio character varying(5000),
    count_min integer,
    count_max integer,
    cd_nom integer,
    cd_hab integer,
    nom_cite character varying(1000) NOT NULL,
    meta_v_taxref character varying(50) DEFAULT gn_commons.get_default_parameter('taxref_version'::text, NULL::integer),
    sample_number_proof text,
    digital_proof text,
    non_digital_proof text,
    altitude_min integer,
    altitude_max integer,
    depth_min integer,
    depth_max integer,
    place_name character varying(500),
    the_geom_4326 public.geometry(Geometry,4326),
    the_geom_point public.geometry(Point,4326),
    the_geom_local public.geometry(Geometry,2154),
    "precision" integer,
    id_area_attachment integer,
    date_min timestamp without time zone NOT NULL,
    date_max timestamp without time zone NOT NULL,
    validator character varying(1000),
    validation_comment text,
    observers character varying(1000),
    determiner character varying(1000),
    id_digitiser integer,
    id_nomenclature_determination_method integer DEFAULT gn_synthese.get_default_nomenclature_value('METH_DETERMIN'::character varying),
    comment_context text,
    comment_description text,
    additional_data jsonb,
    meta_validation_date timestamp without time zone,
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now(),
    last_action character(1),
    CONSTRAINT check_synthese_altitude_max CHECK ((altitude_max >= altitude_min)),
    CONSTRAINT check_synthese_count_max CHECK ((count_max >= count_min)),
    CONSTRAINT check_synthese_date_max CHECK ((date_max >= date_min)),
    CONSTRAINT check_synthese_depth_max CHECK ((depth_max >= depth_min)),
    CONSTRAINT enforce_dims_the_geom_4326 CHECK ((public.st_ndims(the_geom_4326) = 2)),
    CONSTRAINT enforce_dims_the_geom_local CHECK ((public.st_ndims(the_geom_local) = 2)),
    CONSTRAINT enforce_dims_the_geom_point CHECK ((public.st_ndims(the_geom_point) = 2)),
    CONSTRAINT enforce_geotype_the_geom_point CHECK (((public.geometrytype(the_geom_point) = 'POINT'::text) OR (the_geom_point IS NULL))),
    CONSTRAINT enforce_srid_the_geom_4326 CHECK ((public.st_srid(the_geom_4326) = 4326)),
    CONSTRAINT enforce_srid_the_geom_local CHECK ((public.st_srid(the_geom_local) = 2154)),
    CONSTRAINT enforce_srid_the_geom_point CHECK ((public.st_srid(the_geom_point) = 4326))
);


ALTER TABLE gn_synthese.synthese OWNER TO geonatadmin;

--
-- Name: TABLE synthese; Type: COMMENT; Schema: gn_synthese; Owner: geonatadmin
--

COMMENT ON TABLE gn_synthese.synthese IS 'Table de synthèse destinée à recevoir les données de tous les protocoles. Pour consultation uniquement';


--
-- Name: COLUMN synthese.id_source; Type: COMMENT; Schema: gn_synthese; Owner: geonatadmin
--

COMMENT ON COLUMN gn_synthese.synthese.id_source IS 'Permet d''identifier la localisation de l''enregistrement correspondant dans les schémas et tables de la base';


--
-- Name: COLUMN synthese.id_module; Type: COMMENT; Schema: gn_synthese; Owner: geonatadmin
--

COMMENT ON COLUMN gn_synthese.synthese.id_module IS 'Permet d''identifier le module qui a permis la création de l''enregistrement. Ce champ est en lien avec utilisateurs.t_applications et permet de gérer le CRUVED grace à la table utilisateurs.cor_app_privileges';


--
-- Name: COLUMN synthese.id_nomenclature_obs_technique; Type: COMMENT; Schema: gn_synthese; Owner: geonatadmin
--

COMMENT ON COLUMN gn_synthese.synthese.id_nomenclature_obs_technique IS 'Correspondance champs standard occtax = obsTechnique. En raison d''un changement de nom, le code nomenclature associé reste ''METH_OBS'' ';


--
-- Name: COLUMN synthese.id_area_attachment; Type: COMMENT; Schema: gn_synthese; Owner: geonatadmin
--

COMMENT ON COLUMN gn_synthese.synthese.id_area_attachment IS 'Id area du rattachement géographique - cas des observations sans géométrie précise';


--
-- Name: COLUMN synthese.comment_context; Type: COMMENT; Schema: gn_synthese; Owner: geonatadmin
--

COMMENT ON COLUMN gn_synthese.synthese.comment_context IS 'Commentaire du releve (ou regroupement)';


--
-- Name: COLUMN synthese.comment_description; Type: COMMENT; Schema: gn_synthese; Owner: geonatadmin
--

COMMENT ON COLUMN gn_synthese.synthese.comment_description IS 'Commentaire de l''occurrence';


--
-- Name: t_nomenclatures; Type: TABLE; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TABLE ref_nomenclatures.t_nomenclatures (
    id_nomenclature integer NOT NULL,
    id_type integer NOT NULL,
    cd_nomenclature character varying(255) NOT NULL,
    mnemonique character varying(255),
    label_default character varying(255) NOT NULL,
    definition_default text,
    label_fr character varying(255) NOT NULL,
    definition_fr text,
    label_en character varying(255),
    definition_en text,
    label_es character varying(255),
    definition_es text,
    label_de character varying(255),
    definition_de text,
    label_it character varying(255),
    definition_it text,
    source character varying(50),
    statut character varying(20),
    id_broader integer,
    hierarchy character varying(255),
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE ref_nomenclatures.t_nomenclatures OWNER TO geonatadmin;

--
-- Name: taxref; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.taxref (
    cd_nom integer NOT NULL,
    id_statut character(1),
    id_habitat integer,
    id_rang character varying(10),
    regne character varying(20),
    phylum character varying(50),
    classe character varying(50),
    ordre character varying(50),
    famille character varying(50),
    sous_famille character varying(50),
    tribu character varying(50),
    cd_taxsup integer,
    cd_sup integer,
    cd_ref integer,
    lb_nom character varying(250),
    lb_auteur character varying(500),
    nom_complet character varying(500),
    nom_complet_html character varying(500),
    nom_valide character varying(500),
    nom_vern character varying(1000),
    nom_vern_eng character varying(500),
    group1_inpn character varying(50),
    group2_inpn character varying(50),
    url text
);


ALTER TABLE taxonomie.taxref OWNER TO geonatadmin;

--
-- Name: v_synthese_validation_forwebapp; Type: VIEW; Schema: gn_commons; Owner: geonatadmin
--

CREATE VIEW gn_commons.v_synthese_validation_forwebapp WITH (security_barrier='false') AS
 SELECT s.id_synthese,
    s.unique_id_sinp,
    s.unique_id_sinp_grp,
    s.id_source,
    s.entity_source_pk_value,
    s.count_min,
    s.count_max,
    s.nom_cite,
    s.meta_v_taxref,
    s.sample_number_proof,
    s.digital_proof,
    s.non_digital_proof,
    s.altitude_min,
    s.altitude_max,
    s.the_geom_4326,
    s.date_min,
    s.date_max,
    s.depth_min,
    s.depth_max,
    s.place_name,
    s."precision",
    s.validator,
    s.observers,
    s.id_digitiser,
    s.determiner,
    s.comment_context,
    s.comment_description,
    s.meta_validation_date,
    s.meta_create_date,
    s.meta_update_date,
    s.last_action,
    d.id_dataset,
    d.dataset_name,
    d.id_acquisition_framework,
    s.id_nomenclature_geo_object_nature,
    s.id_nomenclature_info_geo_type,
    s.id_nomenclature_grp_typ,
    s.id_nomenclature_obs_technique,
    s.id_nomenclature_bio_status,
    s.id_nomenclature_bio_condition,
    s.id_nomenclature_naturalness,
    s.id_nomenclature_exist_proof,
    s.id_nomenclature_diffusion_level,
    s.id_nomenclature_life_stage,
    s.id_nomenclature_sex,
    s.id_nomenclature_obj_count,
    s.id_nomenclature_type_count,
    s.id_nomenclature_sensitivity,
    s.id_nomenclature_observation_status,
    s.id_nomenclature_blurring,
    s.id_nomenclature_source_status,
    s.id_nomenclature_valid_status,
    s.id_nomenclature_behaviour,
    s.reference_biblio,
    t.cd_nom,
    t.cd_ref,
    t.nom_valide,
    t.lb_nom,
    t.nom_vern,
    n.mnemonique,
    n.cd_nomenclature AS cd_nomenclature_validation_status,
    n.label_default,
    v.validation_auto,
    v.validation_date,
    public.st_asgeojson(s.the_geom_4326) AS geojson,
    COALESCE(t.nom_vern, t.lb_nom) AS nom_vern_or_lb_nom
   FROM ((((gn_synthese.synthese s
     JOIN taxonomie.taxref t ON ((t.cd_nom = s.cd_nom)))
     JOIN gn_meta.t_datasets d ON ((d.id_dataset = s.id_dataset)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n ON ((n.id_nomenclature = s.id_nomenclature_valid_status)))
     LEFT JOIN LATERAL ( SELECT v_1.validation_auto,
            v_1.validation_date
           FROM gn_commons.t_validations v_1
          WHERE (v_1.uuid_attached_row = s.unique_id_sinp)
          ORDER BY v_1.validation_date DESC
         LIMIT 1) v ON (true))
  WHERE ((d.validable = true) AND (NOT (s.unique_id_sinp IS NULL)));


ALTER TABLE gn_commons.v_synthese_validation_forwebapp OWNER TO geonatadmin;

--
-- Name: VIEW v_synthese_validation_forwebapp; Type: COMMENT; Schema: gn_commons; Owner: geonatadmin
--

COMMENT ON VIEW gn_commons.v_synthese_validation_forwebapp IS 'Vue utilisée pour le module validation. Prend l''id_nomenclature dans la table synthese ainsi que toutes les colonnes de la synthese pour les filtres. On JOIN sur la vue latest_validation pour voir si la validation est auto';


--
-- Name: matching_fields; Type: TABLE; Schema: gn_imports; Owner: geonatadmin
--

CREATE TABLE gn_imports.matching_fields (
    id_matching_field integer NOT NULL,
    source_field text,
    source_default_value text,
    target_field text NOT NULL,
    target_field_type text,
    field_comments text,
    id_matching_table integer NOT NULL,
    CONSTRAINT check_source_exists CHECK (((source_field IS NOT NULL) OR (source_default_value IS NOT NULL)))
);


ALTER TABLE gn_imports.matching_fields OWNER TO geonatadmin;

--
-- Name: COLUMN matching_fields.source_default_value; Type: COMMENT; Schema: gn_imports; Owner: geonatadmin
--

COMMENT ON COLUMN gn_imports.matching_fields.source_default_value IS 'Valeur par défaut à insérer si la valeur attendue dans le champ de la table de destination n''existe pas dans la table source';


--
-- Name: matching_fields_id_matching_field_seq; Type: SEQUENCE; Schema: gn_imports; Owner: geonatadmin
--

CREATE SEQUENCE gn_imports.matching_fields_id_matching_field_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_imports.matching_fields_id_matching_field_seq OWNER TO geonatadmin;

--
-- Name: matching_fields_id_matching_field_seq; Type: SEQUENCE OWNED BY; Schema: gn_imports; Owner: geonatadmin
--

ALTER SEQUENCE gn_imports.matching_fields_id_matching_field_seq OWNED BY gn_imports.matching_fields.id_matching_field;


--
-- Name: matching_geoms; Type: TABLE; Schema: gn_imports; Owner: geonatadmin
--

CREATE TABLE gn_imports.matching_geoms (
    id_matching_geom integer NOT NULL,
    source_x_field text,
    source_y_field text,
    source_geom_field text,
    source_geom_format text,
    source_srid integer,
    target_geom_field text,
    target_geom_srid integer,
    geom_comments text,
    id_matching_table integer NOT NULL
);


ALTER TABLE gn_imports.matching_geoms OWNER TO geonatadmin;

--
-- Name: matching_geoms_id_matching_geom_seq; Type: SEQUENCE; Schema: gn_imports; Owner: geonatadmin
--

CREATE SEQUENCE gn_imports.matching_geoms_id_matching_geom_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_imports.matching_geoms_id_matching_geom_seq OWNER TO geonatadmin;

--
-- Name: matching_geoms_id_matching_geom_seq; Type: SEQUENCE OWNED BY; Schema: gn_imports; Owner: geonatadmin
--

ALTER SEQUENCE gn_imports.matching_geoms_id_matching_geom_seq OWNED BY gn_imports.matching_geoms.id_matching_geom;


--
-- Name: matching_tables; Type: TABLE; Schema: gn_imports; Owner: geonatadmin
--

CREATE TABLE gn_imports.matching_tables (
    id_matching_table integer NOT NULL,
    source_schema text NOT NULL,
    source_table text NOT NULL,
    target_schema text NOT NULL,
    target_table text NOT NULL,
    matching_comments text
);


ALTER TABLE gn_imports.matching_tables OWNER TO geonatadmin;

--
-- Name: matching_tables_id_matching_table_seq; Type: SEQUENCE; Schema: gn_imports; Owner: geonatadmin
--

CREATE SEQUENCE gn_imports.matching_tables_id_matching_table_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_imports.matching_tables_id_matching_table_seq OWNER TO geonatadmin;

--
-- Name: matching_tables_id_matching_table_seq; Type: SEQUENCE OWNED BY; Schema: gn_imports; Owner: geonatadmin
--

ALTER SEQUENCE gn_imports.matching_tables_id_matching_table_seq OWNED BY gn_imports.matching_tables.id_matching_table;


--
-- Name: cor_acquisition_framework_actor; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.cor_acquisition_framework_actor (
    id_cafa integer NOT NULL,
    id_acquisition_framework integer NOT NULL,
    id_role integer,
    id_organism integer,
    id_nomenclature_actor_role integer NOT NULL,
    CONSTRAINT check_id_role_not_group CHECK ((NOT gn_commons.role_is_group(id_role))),
    CONSTRAINT check_is_actor_in_cor_acquisition_framework_actor CHECK (((id_role IS NOT NULL) OR (id_organism IS NOT NULL)))
);


ALTER TABLE gn_meta.cor_acquisition_framework_actor OWNER TO geonatadmin;

--
-- Name: TABLE cor_acquisition_framework_actor; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.cor_acquisition_framework_actor IS 'A acquisition framework must have a principal actor "acteurPrincipal" and can have 0 or n other actor "acteurAutre". Implement 1.3.10 SINP metadata standard : Contact principal pour le cadre d''acquisition (Règle : RoleActeur prendra la valeur 1) - OBLIGATOIRE. Autres contacts pour le cadre d''acquisition (exemples : maître d''oeuvre, d''ouvrage...).- RECOMMANDE';


--
-- Name: COLUMN cor_acquisition_framework_actor.id_nomenclature_actor_role; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.cor_acquisition_framework_actor.id_nomenclature_actor_role IS 'Correspondance standard SINP = roleActeur : Rôle de l''acteur tel que défini dans la nomenclature RoleActeurValue - OBLIGATOIRE';


--
-- Name: cor_acquisition_framework_actor_id_cafa_seq; Type: SEQUENCE; Schema: gn_meta; Owner: geonatadmin
--

CREATE SEQUENCE gn_meta.cor_acquisition_framework_actor_id_cafa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_meta.cor_acquisition_framework_actor_id_cafa_seq OWNER TO geonatadmin;

--
-- Name: cor_acquisition_framework_actor_id_cafa_seq; Type: SEQUENCE OWNED BY; Schema: gn_meta; Owner: geonatadmin
--

ALTER SEQUENCE gn_meta.cor_acquisition_framework_actor_id_cafa_seq OWNED BY gn_meta.cor_acquisition_framework_actor.id_cafa;


--
-- Name: cor_acquisition_framework_objectif; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.cor_acquisition_framework_objectif (
    id_acquisition_framework integer NOT NULL,
    id_nomenclature_objectif integer NOT NULL
);


ALTER TABLE gn_meta.cor_acquisition_framework_objectif OWNER TO geonatadmin;

--
-- Name: TABLE cor_acquisition_framework_objectif; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.cor_acquisition_framework_objectif IS 'A acquisition framework can have 1 or n "objectif". Implement 1.3.10 SINP metadata standard : Objectif du cadre d''acquisition, tel que défini par la nomenclature TypeDispositifValue - OBLIGATOIRE';


--
-- Name: cor_acquisition_framework_publication; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.cor_acquisition_framework_publication (
    id_acquisition_framework integer NOT NULL,
    id_publication integer NOT NULL
);


ALTER TABLE gn_meta.cor_acquisition_framework_publication OWNER TO geonatadmin;

--
-- Name: TABLE cor_acquisition_framework_publication; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.cor_acquisition_framework_publication IS 'A acquisition framework can have 0 or n "publication". Implement 1.3.10 SINP metadata standard : Référence(s) bibliographique(s) éventuelle(s) concernant le cadre d''acquisition - RECOMMANDE';


--
-- Name: cor_acquisition_framework_territory; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.cor_acquisition_framework_territory (
    id_acquisition_framework integer NOT NULL,
    id_nomenclature_territory integer NOT NULL
);


ALTER TABLE gn_meta.cor_acquisition_framework_territory OWNER TO geonatadmin;

--
-- Name: TABLE cor_acquisition_framework_territory; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.cor_acquisition_framework_territory IS 'A acquisition_framework must have 1 or n "territoire". Implement 1.3.10 SINP metadata standard : Cible géographique du jeu de données, ou zone géographique visée par le jeu. Défini par une valeur dans la nomenclature TerritoireValue. - OBLIGATOIRE';


--
-- Name: cor_acquisition_framework_voletsinp; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.cor_acquisition_framework_voletsinp (
    id_acquisition_framework integer NOT NULL,
    id_nomenclature_voletsinp integer NOT NULL
);


ALTER TABLE gn_meta.cor_acquisition_framework_voletsinp OWNER TO geonatadmin;

--
-- Name: TABLE cor_acquisition_framework_voletsinp; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.cor_acquisition_framework_voletsinp IS 'A acquisition framework can have 0 or n "voletSINP". Implement 1.3.10 SINP metadata standard : Volet du SINP concerné par le dispositif de collecte, tel que défini dans la nomenclature voletSINPValue - FACULTATIF';


--
-- Name: cor_dataset_actor; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.cor_dataset_actor (
    id_cda integer NOT NULL,
    id_dataset integer NOT NULL,
    id_role integer,
    id_organism integer,
    id_nomenclature_actor_role integer NOT NULL,
    CONSTRAINT check_id_role_not_group CHECK ((NOT gn_commons.role_is_group(id_role))),
    CONSTRAINT check_is_actor_in_cor_dataset_actor CHECK (((id_role IS NOT NULL) OR (id_organism IS NOT NULL)))
);


ALTER TABLE gn_meta.cor_dataset_actor OWNER TO geonatadmin;

--
-- Name: TABLE cor_dataset_actor; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.cor_dataset_actor IS 'A dataset must have 1 or n actor ""pointContactJdd"". Implement 1.3.10 SINP metadata standard : Point de contact principal pour les données du jeu de données, et autres éventuels contacts (fournisseur ou producteur). (Règle : Un contact au moins devra avoir roleActeur à 1 - Les autres types possibles pour roleActeur sont 5 et 6 (fournisseur et producteur)) - OBLIGATOIRE';


--
-- Name: COLUMN cor_dataset_actor.id_nomenclature_actor_role; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.cor_dataset_actor.id_nomenclature_actor_role IS 'Correspondance standard SINP = roleActeur : Rôle de l''acteur tel que défini dans la nomenclature RoleActeurValue - OBLIGATOIRE';


--
-- Name: cor_dataset_actor_id_cda_seq; Type: SEQUENCE; Schema: gn_meta; Owner: geonatadmin
--

CREATE SEQUENCE gn_meta.cor_dataset_actor_id_cda_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_meta.cor_dataset_actor_id_cda_seq OWNER TO geonatadmin;

--
-- Name: cor_dataset_actor_id_cda_seq; Type: SEQUENCE OWNED BY; Schema: gn_meta; Owner: geonatadmin
--

ALTER SEQUENCE gn_meta.cor_dataset_actor_id_cda_seq OWNED BY gn_meta.cor_dataset_actor.id_cda;


--
-- Name: cor_dataset_protocol; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.cor_dataset_protocol (
    id_dataset integer NOT NULL,
    id_protocol integer NOT NULL
);


ALTER TABLE gn_meta.cor_dataset_protocol OWNER TO geonatadmin;

--
-- Name: TABLE cor_dataset_protocol; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.cor_dataset_protocol IS 'A dataset can have 0 or n "protocole". Implement 1.3.10 SINP metadata standard : Protocole(s) rattaché(s) au jeu de données (protocole de synthèse et/ou de collecte). On se rapportera au type "Protocole Type". - RECOMMANDE';


--
-- Name: cor_dataset_territory; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.cor_dataset_territory (
    id_dataset integer NOT NULL,
    id_nomenclature_territory integer NOT NULL,
    territory_desc text
);


ALTER TABLE gn_meta.cor_dataset_territory OWNER TO geonatadmin;

--
-- Name: TABLE cor_dataset_territory; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.cor_dataset_territory IS 'A dataset must have 1 or n "territoire". Implement 1.3.10 SINP metadata standard : Cible géographique du jeu de données, ou zone géographique visée par le jeu. Défini par une valeur dans la nomenclature TerritoireValue. - OBLIGATOIRE';


--
-- Name: COLUMN cor_dataset_territory.territory_desc; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.cor_dataset_territory.territory_desc IS 'Correspondance standard SINP = precisionGeographique : Précisions sur le territoire visé - FACULTATIF';


--
-- Name: sinp_datatype_protocols; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.sinp_datatype_protocols (
    id_protocol integer NOT NULL,
    unique_protocol_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    protocol_name character varying(255) NOT NULL,
    protocol_desc text,
    id_nomenclature_protocol_type integer NOT NULL,
    protocol_url character varying(255)
);


ALTER TABLE gn_meta.sinp_datatype_protocols OWNER TO geonatadmin;

--
-- Name: TABLE sinp_datatype_protocols; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.sinp_datatype_protocols IS 'Define a SINP datatype Types::ProtocoleType.';


--
-- Name: COLUMN sinp_datatype_protocols.id_protocol; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_protocols.id_protocol IS 'Internal value for primary and foreign keys';


--
-- Name: COLUMN sinp_datatype_protocols.unique_protocol_id; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_protocols.unique_protocol_id IS 'Internal value to reference external protocol id value';


--
-- Name: COLUMN sinp_datatype_protocols.protocol_name; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_protocols.protocol_name IS 'Correspondance standard SINP = libelle : Libellé du protocole : donne le nom du protocole en quelques mots - OBLIGATOIRE';


--
-- Name: COLUMN sinp_datatype_protocols.protocol_desc; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_protocols.protocol_desc IS 'Correspondance standard SINP = description : Description du protocole : décrit le contenu du protocole - FACULTATIF.';


--
-- Name: COLUMN sinp_datatype_protocols.id_nomenclature_protocol_type; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_protocols.id_nomenclature_protocol_type IS 'Correspondance standard SINP = typeProtocole : Type du protocole, tel que défini dans la nomenclature TypeProtocoleValue - OBLIGATOIRE';


--
-- Name: COLUMN sinp_datatype_protocols.protocol_url; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_protocols.protocol_url IS 'Correspondance standard SINP = uRL : URL d''accès à un document permettant de décrire le protocole - RECOMMANDE.';


--
-- Name: sinp_datatype_protocols_id_protocol_seq; Type: SEQUENCE; Schema: gn_meta; Owner: geonatadmin
--

CREATE SEQUENCE gn_meta.sinp_datatype_protocols_id_protocol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_meta.sinp_datatype_protocols_id_protocol_seq OWNER TO geonatadmin;

--
-- Name: sinp_datatype_protocols_id_protocol_seq; Type: SEQUENCE OWNED BY; Schema: gn_meta; Owner: geonatadmin
--

ALTER SEQUENCE gn_meta.sinp_datatype_protocols_id_protocol_seq OWNED BY gn_meta.sinp_datatype_protocols.id_protocol;


--
-- Name: sinp_datatype_publications; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.sinp_datatype_publications (
    id_publication integer NOT NULL,
    unique_publication_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    publication_reference text NOT NULL,
    publication_url text
);


ALTER TABLE gn_meta.sinp_datatype_publications OWNER TO geonatadmin;

--
-- Name: TABLE sinp_datatype_publications; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.sinp_datatype_publications IS 'Define a SINP datatype Concepts::Publication.';


--
-- Name: COLUMN sinp_datatype_publications.id_publication; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_publications.id_publication IS 'Internal value for primary and foreign keys';


--
-- Name: COLUMN sinp_datatype_publications.unique_publication_id; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_publications.unique_publication_id IS 'Internal value to reference external publication id value';


--
-- Name: COLUMN sinp_datatype_publications.publication_reference; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_publications.publication_reference IS 'Correspondance standard SINP = referencePublication : Référence complète de la publication suivant la nomenclature ISO 690 - OBLIGATOIRE';


--
-- Name: COLUMN sinp_datatype_publications.publication_url; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.sinp_datatype_publications.publication_url IS 'Correspondance standard SINP = URLPublication : Adresse à laquelle trouver la publication - RECOMMANDE.';


--
-- Name: sinp_datatype_publications_id_publication_seq; Type: SEQUENCE; Schema: gn_meta; Owner: geonatadmin
--

CREATE SEQUENCE gn_meta.sinp_datatype_publications_id_publication_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_meta.sinp_datatype_publications_id_publication_seq OWNER TO geonatadmin;

--
-- Name: sinp_datatype_publications_id_publication_seq; Type: SEQUENCE OWNED BY; Schema: gn_meta; Owner: geonatadmin
--

ALTER SEQUENCE gn_meta.sinp_datatype_publications_id_publication_seq OWNED BY gn_meta.sinp_datatype_publications.id_publication;


--
-- Name: t_acquisition_frameworks; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.t_acquisition_frameworks (
    id_acquisition_framework integer NOT NULL,
    unique_acquisition_framework_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    acquisition_framework_name character varying(255) NOT NULL,
    acquisition_framework_desc text NOT NULL,
    id_nomenclature_territorial_level integer DEFAULT ref_nomenclatures.get_default_nomenclature_value('NIVEAU_TERRITORIAL'::character varying),
    territory_desc text,
    keywords text,
    id_nomenclature_financing_type integer DEFAULT ref_nomenclatures.get_default_nomenclature_value('TYPE_FINANCEMENT'::character varying),
    target_description text,
    ecologic_or_geologic_target text,
    acquisition_framework_parent_id integer,
    is_parent boolean,
    opened boolean DEFAULT true,
    id_digitizer integer,
    acquisition_framework_start_date date NOT NULL,
    acquisition_framework_end_date date,
    meta_create_date timestamp without time zone NOT NULL,
    meta_update_date timestamp without time zone,
    initial_closing_date timestamp without time zone
);


ALTER TABLE gn_meta.t_acquisition_frameworks OWNER TO geonatadmin;

--
-- Name: TABLE t_acquisition_frameworks; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.t_acquisition_frameworks IS 'Define a acquisition framework that embed datasets. Implement 1.3.10 SINP metadata standard';


--
-- Name: COLUMN t_acquisition_frameworks.id_acquisition_framework; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.id_acquisition_framework IS 'Internal value for primary and foreign keys';


--
-- Name: COLUMN t_acquisition_frameworks.unique_acquisition_framework_id; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.unique_acquisition_framework_id IS 'Correspondance standard SINP = identifiantCadre';


--
-- Name: COLUMN t_acquisition_frameworks.acquisition_framework_name; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.acquisition_framework_name IS 'Correspondance standard SINP = libelle';


--
-- Name: COLUMN t_acquisition_frameworks.acquisition_framework_desc; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.acquisition_framework_desc IS 'Correspondance standard SINP = description';


--
-- Name: COLUMN t_acquisition_frameworks.id_nomenclature_territorial_level; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.id_nomenclature_territorial_level IS 'Correspondance standard SINP = niveauTerritorial';


--
-- Name: COLUMN t_acquisition_frameworks.keywords; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.keywords IS 'Correspondance standard SINP = motCle : Mot(s)-clé(s) représentatifs du cadre d''acquisition, séparés par des virgules - FACULTATIF';


--
-- Name: COLUMN t_acquisition_frameworks.id_nomenclature_financing_type; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.id_nomenclature_financing_type IS 'Correspondance standard SINP = typeFinancement : Type de financement pour le cadre d''acquisition, tel que défini dans la nomenclature TypeFinancementValue - RECOMMANDE';


--
-- Name: COLUMN t_acquisition_frameworks.target_description; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.target_description IS 'Correspondance standard SINP = descriptionCible : Description de la cible taxonomique ou géologique pour le cadre d''acquisition. (ex : pteridophyta) - RECOMMANDE';


--
-- Name: COLUMN t_acquisition_frameworks.ecologic_or_geologic_target; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.ecologic_or_geologic_target IS 'Correspondance standard SINP = cibleEcologiqueOuGeologique : Cet attribut sera composé de CD_NOM de TAXREF, séparés par des points virgules, s''il s''agit de taxons, ou de CD_HAB de HABREF, séparés par des points virgules, s''il s''agit d''habitats. - FACULTATIF';


--
-- Name: COLUMN t_acquisition_frameworks.acquisition_framework_parent_id; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.acquisition_framework_parent_id IS 'Correspondance standard SINP = idMetaCadreParent : Indique, par le biais de l''existence d''un identifiant unique de métacadre parent, si le cadre d''acquisition ici présent est contenu dans un autre cadre d''acquisition. S''il y un cadre parent, c''est son identifiant qui doit être renseigné ici. - RECOMMANDE';


--
-- Name: COLUMN t_acquisition_frameworks.is_parent; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.is_parent IS 'Correspondance standard SINP = estMetaCadre : Indique si ce dispositif est un métacadre, et donc s''il contient d''autres cadres d''acquisition. Cet attribut est un booléen : 0 pour false (n''est pas un métacadre), 1 pour true (est un métacadre) - OBLIGATOIRE.';


--
-- Name: COLUMN t_acquisition_frameworks.acquisition_framework_start_date; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.acquisition_framework_start_date IS 'Correspondance standard SINP = ReferenceTemporelle:dateLancement : Date de lancement du cadre d''acquisition - OBLIGATOIRE.';


--
-- Name: COLUMN t_acquisition_frameworks.acquisition_framework_end_date; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.acquisition_framework_end_date IS 'Correspondance standard SINP = ReferenceTemporelle:dateCloture : Date de clôture du cadre d''acquisition. Si elle n''est pas remplie, on considère que le cadre est toujours en activité. - RECOMMANDE';


--
-- Name: COLUMN t_acquisition_frameworks.meta_create_date; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.meta_create_date IS 'Correspondance standard SINP = dateCreationMtd : Date de création de la fiche de métadonnées du cadre d''acquisition. - OBLIGATOIRE';


--
-- Name: COLUMN t_acquisition_frameworks.meta_update_date; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON COLUMN gn_meta.t_acquisition_frameworks.meta_update_date IS 'Correspondance standard SINP = dateMiseAJourMtd : Date de mise à jour de la fiche de métadonnées du cadre d''acquisition. - FACULTATIF';


--
-- Name: t_acquisition_frameworks_id_acquisition_framework_seq; Type: SEQUENCE; Schema: gn_meta; Owner: geonatadmin
--

CREATE SEQUENCE gn_meta.t_acquisition_frameworks_id_acquisition_framework_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_meta.t_acquisition_frameworks_id_acquisition_framework_seq OWNER TO geonatadmin;

--
-- Name: t_acquisition_frameworks_id_acquisition_framework_seq; Type: SEQUENCE OWNED BY; Schema: gn_meta; Owner: geonatadmin
--

ALTER SEQUENCE gn_meta.t_acquisition_frameworks_id_acquisition_framework_seq OWNED BY gn_meta.t_acquisition_frameworks.id_acquisition_framework;


--
-- Name: t_bibliographical_references_id_bibliographic_reference_seq; Type: SEQUENCE; Schema: gn_meta; Owner: geonatadmin
--

CREATE SEQUENCE gn_meta.t_bibliographical_references_id_bibliographic_reference_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_meta.t_bibliographical_references_id_bibliographic_reference_seq OWNER TO geonatadmin;

--
-- Name: t_bibliographical_references; Type: TABLE; Schema: gn_meta; Owner: geonatadmin
--

CREATE TABLE gn_meta.t_bibliographical_references (
    id_bibliographic_reference bigint DEFAULT nextval('gn_meta.t_bibliographical_references_id_bibliographic_reference_seq'::regclass) NOT NULL,
    id_acquisition_framework integer NOT NULL,
    publication_url character varying,
    publication_reference character varying NOT NULL
);


ALTER TABLE gn_meta.t_bibliographical_references OWNER TO geonatadmin;

--
-- Name: TABLE t_bibliographical_references; Type: COMMENT; Schema: gn_meta; Owner: geonatadmin
--

COMMENT ON TABLE gn_meta.t_bibliographical_references IS 'A acquisition_framework must have 0 or n "publical references". Implement 1.3.10 SINP metadata standard : Référence(s) bibliographique(s) éventuelle(s) concernant le cadre d''acquisition. - RECOMMANDE';


--
-- Name: t_datasets_id_dataset_seq; Type: SEQUENCE; Schema: gn_meta; Owner: geonatadmin
--

CREATE SEQUENCE gn_meta.t_datasets_id_dataset_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_meta.t_datasets_id_dataset_seq OWNER TO geonatadmin;

--
-- Name: t_datasets_id_dataset_seq; Type: SEQUENCE OWNED BY; Schema: gn_meta; Owner: geonatadmin
--

ALTER SEQUENCE gn_meta.t_datasets_id_dataset_seq OWNED BY gn_meta.t_datasets.id_dataset;


--
-- Name: v_acquisition_frameworks_protocols; Type: VIEW; Schema: gn_meta; Owner: geonatadmin
--

CREATE VIEW gn_meta.v_acquisition_frameworks_protocols AS
 SELECT d.id_acquisition_framework,
    cdp.id_protocol
   FROM ((gn_meta.t_acquisition_frameworks taf
     JOIN gn_meta.t_datasets d ON ((d.id_acquisition_framework = taf.id_acquisition_framework)))
     JOIN gn_meta.cor_dataset_protocol cdp ON ((cdp.id_dataset = d.id_dataset)));


ALTER TABLE gn_meta.v_acquisition_frameworks_protocols OWNER TO geonatadmin;

--
-- Name: v_acquisition_frameworks_territories; Type: VIEW; Schema: gn_meta; Owner: geonatadmin
--

CREATE VIEW gn_meta.v_acquisition_frameworks_territories AS
 SELECT d.id_acquisition_framework,
    cdt.id_nomenclature_territory,
    cdt.territory_desc
   FROM ((gn_meta.t_acquisition_frameworks taf
     JOIN gn_meta.t_datasets d ON ((d.id_acquisition_framework = taf.id_acquisition_framework)))
     JOIN gn_meta.cor_dataset_territory cdt ON ((cdt.id_dataset = d.id_dataset)));


ALTER TABLE gn_meta.v_acquisition_frameworks_territories OWNER TO geonatadmin;

--
-- Name: cor_site_area; Type: TABLE; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TABLE gn_monitoring.cor_site_area (
    id_base_site integer NOT NULL,
    id_area integer NOT NULL
);


ALTER TABLE gn_monitoring.cor_site_area OWNER TO geonatadmin;

--
-- Name: cor_site_module; Type: TABLE; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TABLE gn_monitoring.cor_site_module (
    id_base_site integer NOT NULL,
    id_module integer NOT NULL
);


ALTER TABLE gn_monitoring.cor_site_module OWNER TO geonatadmin;

--
-- Name: cor_visit_observer; Type: TABLE; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TABLE gn_monitoring.cor_visit_observer (
    id_base_visit integer NOT NULL,
    id_role integer NOT NULL,
    unique_id_core_visit_observer uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


ALTER TABLE gn_monitoring.cor_visit_observer OWNER TO geonatadmin;

--
-- Name: t_base_sites; Type: TABLE; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TABLE gn_monitoring.t_base_sites (
    id_base_site integer NOT NULL,
    id_inventor integer,
    id_digitiser integer,
    id_nomenclature_type_site integer NOT NULL,
    base_site_name character varying(255) NOT NULL,
    base_site_description text,
    base_site_code character varying(25) DEFAULT NULL::character varying,
    first_use_date date,
    geom public.geometry(Geometry,4326) NOT NULL,
    geom_local public.geometry(Geometry,2154),
    altitude_min integer,
    altitude_max integer,
    uuid_base_site uuid DEFAULT public.uuid_generate_v4(),
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now(),
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 4326))
);


ALTER TABLE gn_monitoring.t_base_sites OWNER TO geonatadmin;

--
-- Name: t_base_sites_id_base_site_seq; Type: SEQUENCE; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE SEQUENCE gn_monitoring.t_base_sites_id_base_site_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_monitoring.t_base_sites_id_base_site_seq OWNER TO geonatadmin;

--
-- Name: t_base_sites_id_base_site_seq; Type: SEQUENCE OWNED BY; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER SEQUENCE gn_monitoring.t_base_sites_id_base_site_seq OWNED BY gn_monitoring.t_base_sites.id_base_site;


--
-- Name: t_base_visits; Type: TABLE; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TABLE gn_monitoring.t_base_visits (
    id_base_visit integer NOT NULL,
    id_base_site integer,
    id_dataset integer NOT NULL,
    id_module integer NOT NULL,
    id_digitiser integer,
    visit_date_min date NOT NULL,
    visit_date_max date,
    id_nomenclature_tech_collect_campanule integer DEFAULT ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS'::character varying, '133'::character varying),
    id_nomenclature_grp_typ integer DEFAULT ref_nomenclatures.get_id_nomenclature('TYP_GRP'::character varying, 'PASS'::character varying),
    comments text,
    uuid_base_visit uuid DEFAULT public.uuid_generate_v4(),
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now()
);


ALTER TABLE gn_monitoring.t_base_visits OWNER TO geonatadmin;

--
-- Name: t_base_visits_id_base_visit_seq; Type: SEQUENCE; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE SEQUENCE gn_monitoring.t_base_visits_id_base_visit_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_monitoring.t_base_visits_id_base_visit_seq OWNER TO geonatadmin;

--
-- Name: t_base_visits_id_base_visit_seq; Type: SEQUENCE OWNED BY; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER SEQUENCE gn_monitoring.t_base_visits_id_base_visit_seq OWNED BY gn_monitoring.t_base_visits.id_base_visit;


--
-- Name: bib_filters_type; Type: TABLE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE TABLE gn_permissions.bib_filters_type (
    id_filter_type integer NOT NULL,
    code_filter_type character varying(50) NOT NULL,
    label_filter_type character varying(255) NOT NULL,
    description_filter_type text
);


ALTER TABLE gn_permissions.bib_filters_type OWNER TO geonatadmin;

--
-- Name: bib_filters_type_id_filter_type_seq; Type: SEQUENCE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE SEQUENCE gn_permissions.bib_filters_type_id_filter_type_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_permissions.bib_filters_type_id_filter_type_seq OWNER TO geonatadmin;

--
-- Name: bib_filters_type_id_filter_type_seq; Type: SEQUENCE OWNED BY; Schema: gn_permissions; Owner: geonatadmin
--

ALTER SEQUENCE gn_permissions.bib_filters_type_id_filter_type_seq OWNED BY gn_permissions.bib_filters_type.id_filter_type;


--
-- Name: cor_filter_type_module; Type: TABLE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE TABLE gn_permissions.cor_filter_type_module (
    id_filter_type integer NOT NULL,
    id_module integer NOT NULL
);


ALTER TABLE gn_permissions.cor_filter_type_module OWNER TO geonatadmin;

--
-- Name: cor_object_module; Type: TABLE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE TABLE gn_permissions.cor_object_module (
    id_cor_object_module integer NOT NULL,
    id_object integer NOT NULL,
    id_module integer NOT NULL
);


ALTER TABLE gn_permissions.cor_object_module OWNER TO geonatadmin;

--
-- Name: cor_object_module_id_cor_object_module_seq; Type: SEQUENCE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE SEQUENCE gn_permissions.cor_object_module_id_cor_object_module_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_permissions.cor_object_module_id_cor_object_module_seq OWNER TO geonatadmin;

--
-- Name: cor_object_module_id_cor_object_module_seq; Type: SEQUENCE OWNED BY; Schema: gn_permissions; Owner: geonatadmin
--

ALTER SEQUENCE gn_permissions.cor_object_module_id_cor_object_module_seq OWNED BY gn_permissions.cor_object_module.id_cor_object_module;


--
-- Name: cor_role_action_filter_module_object; Type: TABLE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE TABLE gn_permissions.cor_role_action_filter_module_object (
    id_permission integer NOT NULL,
    id_role integer NOT NULL,
    id_action integer NOT NULL,
    id_filter integer NOT NULL,
    id_module integer NOT NULL,
    id_object integer DEFAULT gn_permissions.get_id_object('ALL'::character varying) NOT NULL
);


ALTER TABLE gn_permissions.cor_role_action_filter_module_object OWNER TO geonatadmin;

--
-- Name: cor_role_action_filter_module_object_id_permission_seq; Type: SEQUENCE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE SEQUENCE gn_permissions.cor_role_action_filter_module_object_id_permission_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_permissions.cor_role_action_filter_module_object_id_permission_seq OWNER TO geonatadmin;

--
-- Name: cor_role_action_filter_module_object_id_permission_seq; Type: SEQUENCE OWNED BY; Schema: gn_permissions; Owner: geonatadmin
--

ALTER SEQUENCE gn_permissions.cor_role_action_filter_module_object_id_permission_seq OWNED BY gn_permissions.cor_role_action_filter_module_object.id_permission;


--
-- Name: t_actions; Type: TABLE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE TABLE gn_permissions.t_actions (
    id_action integer NOT NULL,
    code_action character varying(50) NOT NULL,
    description_action text
);


ALTER TABLE gn_permissions.t_actions OWNER TO geonatadmin;

--
-- Name: t_actions_id_action_seq; Type: SEQUENCE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE SEQUENCE gn_permissions.t_actions_id_action_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_permissions.t_actions_id_action_seq OWNER TO geonatadmin;

--
-- Name: t_actions_id_action_seq; Type: SEQUENCE OWNED BY; Schema: gn_permissions; Owner: geonatadmin
--

ALTER SEQUENCE gn_permissions.t_actions_id_action_seq OWNED BY gn_permissions.t_actions.id_action;


--
-- Name: t_filters; Type: TABLE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE TABLE gn_permissions.t_filters (
    id_filter integer NOT NULL,
    label_filter character varying(255) NOT NULL,
    value_filter text NOT NULL,
    description_filter text,
    id_filter_type integer NOT NULL
);


ALTER TABLE gn_permissions.t_filters OWNER TO geonatadmin;

--
-- Name: t_filters_id_filter_seq; Type: SEQUENCE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE SEQUENCE gn_permissions.t_filters_id_filter_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_permissions.t_filters_id_filter_seq OWNER TO geonatadmin;

--
-- Name: t_filters_id_filter_seq; Type: SEQUENCE OWNED BY; Schema: gn_permissions; Owner: geonatadmin
--

ALTER SEQUENCE gn_permissions.t_filters_id_filter_seq OWNED BY gn_permissions.t_filters.id_filter;


--
-- Name: t_objects; Type: TABLE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE TABLE gn_permissions.t_objects (
    id_object integer NOT NULL,
    code_object character varying(50) NOT NULL,
    description_object text
);


ALTER TABLE gn_permissions.t_objects OWNER TO geonatadmin;

--
-- Name: t_objects_id_object_seq; Type: SEQUENCE; Schema: gn_permissions; Owner: geonatadmin
--

CREATE SEQUENCE gn_permissions.t_objects_id_object_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_permissions.t_objects_id_object_seq OWNER TO geonatadmin;

--
-- Name: t_objects_id_object_seq; Type: SEQUENCE OWNED BY; Schema: gn_permissions; Owner: geonatadmin
--

ALTER SEQUENCE gn_permissions.t_objects_id_object_seq OWNED BY gn_permissions.t_objects.id_object;


--
-- Name: cor_roles; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.cor_roles (
    id_role_groupe integer NOT NULL,
    id_role_utilisateur integer NOT NULL
);


ALTER TABLE utilisateurs.cor_roles OWNER TO geonatadmin;

--
-- Name: t_roles; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.t_roles (
    groupe boolean DEFAULT false NOT NULL,
    id_role integer NOT NULL,
    uuid_role uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    identifiant character varying(100),
    nom_role character varying(50),
    prenom_role character varying(50),
    desc_role text,
    pass character varying(100),
    pass_plus text,
    email character varying(250),
    id_organisme integer,
    remarques text,
    active boolean DEFAULT true,
    champs_addi jsonb,
    date_insert timestamp without time zone,
    date_update timestamp without time zone
);


ALTER TABLE utilisateurs.t_roles OWNER TO geonatadmin;

--
-- Name: v_roles_permissions; Type: VIEW; Schema: gn_permissions; Owner: geonatadmin
--

CREATE VIEW gn_permissions.v_roles_permissions AS
 WITH p_user_permission AS (
         SELECT u.id_role,
            u.nom_role,
            u.prenom_role,
            u.groupe,
            u.id_organisme,
            c_1.id_action,
            c_1.id_filter,
            c_1.id_module,
            c_1.id_object,
            c_1.id_permission
           FROM (utilisateurs.t_roles u
             JOIN gn_permissions.cor_role_action_filter_module_object c_1 ON ((c_1.id_role = u.id_role)))
          WHERE (u.groupe = false)
        ), p_groupe_permission AS (
         SELECT u.id_role,
            u.nom_role,
            u.prenom_role,
            u.groupe,
            u.id_organisme,
            c_1.id_action,
            c_1.id_filter,
            c_1.id_module,
            c_1.id_object,
            c_1.id_permission
           FROM ((utilisateurs.t_roles u
             JOIN utilisateurs.cor_roles g ON (((g.id_role_utilisateur = u.id_role) OR (g.id_role_groupe = u.id_role))))
             JOIN gn_permissions.cor_role_action_filter_module_object c_1 ON ((c_1.id_role = g.id_role_groupe)))
        ), all_user_permission AS (
         SELECT p_user_permission.id_role,
            p_user_permission.nom_role,
            p_user_permission.prenom_role,
            p_user_permission.groupe,
            p_user_permission.id_organisme,
            p_user_permission.id_action,
            p_user_permission.id_filter,
            p_user_permission.id_module,
            p_user_permission.id_object,
            p_user_permission.id_permission
           FROM p_user_permission
        UNION
         SELECT p_groupe_permission.id_role,
            p_groupe_permission.nom_role,
            p_groupe_permission.prenom_role,
            p_groupe_permission.groupe,
            p_groupe_permission.id_organisme,
            p_groupe_permission.id_action,
            p_groupe_permission.id_filter,
            p_groupe_permission.id_module,
            p_groupe_permission.id_object,
            p_groupe_permission.id_permission
           FROM p_groupe_permission
        )
 SELECT v.id_role,
    v.nom_role,
    v.prenom_role,
    v.id_organisme,
    v.id_module,
    modules.module_code,
    obj.code_object,
    v.id_action,
    v.id_filter,
    actions.code_action,
    actions.description_action,
    filters.value_filter,
    filters.label_filter,
    filter_type.code_filter_type,
    filter_type.id_filter_type,
    v.id_permission
   FROM (((((all_user_permission v
     JOIN gn_permissions.t_actions actions ON ((actions.id_action = v.id_action)))
     JOIN gn_permissions.t_filters filters ON ((filters.id_filter = v.id_filter)))
     JOIN gn_permissions.t_objects obj ON ((obj.id_object = v.id_object)))
     JOIN gn_permissions.bib_filters_type filter_type ON ((filters.id_filter_type = filter_type.id_filter_type)))
     JOIN gn_commons.t_modules modules ON ((modules.id_module = v.id_module)));


ALTER TABLE gn_permissions.v_roles_permissions OWNER TO geonatadmin;

--
-- Name: cor_sensitivity_area; Type: TABLE; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TABLE gn_sensitivity.cor_sensitivity_area (
    id_sensitivity integer,
    id_area integer
);


ALTER TABLE gn_sensitivity.cor_sensitivity_area OWNER TO geonatadmin;

--
-- Name: TABLE cor_sensitivity_area; Type: COMMENT; Schema: gn_sensitivity; Owner: geonatadmin
--

COMMENT ON TABLE gn_sensitivity.cor_sensitivity_area IS 'Specifies where a sensitivity rule applies';


--
-- Name: cor_sensitivity_area_type; Type: TABLE; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TABLE gn_sensitivity.cor_sensitivity_area_type (
    id_nomenclature_sensitivity integer,
    id_area_type integer
);


ALTER TABLE gn_sensitivity.cor_sensitivity_area_type OWNER TO geonatadmin;

--
-- Name: cor_sensitivity_criteria; Type: TABLE; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TABLE gn_sensitivity.cor_sensitivity_criteria (
    id_sensitivity integer,
    id_criteria integer,
    id_type_nomenclature integer
);


ALTER TABLE gn_sensitivity.cor_sensitivity_criteria OWNER TO geonatadmin;

--
-- Name: TABLE cor_sensitivity_criteria; Type: COMMENT; Schema: gn_sensitivity; Owner: geonatadmin
--

COMMENT ON TABLE gn_sensitivity.cor_sensitivity_criteria IS 'Specifies extra criteria for a sensitivity rule';


--
-- Name: cor_sensitivity_synthese; Type: TABLE; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TABLE gn_sensitivity.cor_sensitivity_synthese (
    uuid_attached_row uuid NOT NULL,
    id_nomenclature_sensitivity integer NOT NULL,
    computation_auto boolean DEFAULT true NOT NULL,
    id_digitizer integer,
    sensitivity_comment text,
    meta_create_date timestamp without time zone,
    meta_update_date timestamp without time zone
);


ALTER TABLE gn_sensitivity.cor_sensitivity_synthese OWNER TO geonatadmin;

--
-- Name: t_sensitivity_rules; Type: TABLE; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TABLE gn_sensitivity.t_sensitivity_rules (
    id_sensitivity integer NOT NULL,
    cd_nom integer NOT NULL,
    nom_cite character varying(1000),
    id_nomenclature_sensitivity integer NOT NULL,
    sensitivity_duration integer NOT NULL,
    sensitivity_territory character varying(1000),
    id_territory character varying(50),
    date_min date,
    date_max date,
    source character varying(250),
    active boolean DEFAULT true,
    comments character varying(500),
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone
);


ALTER TABLE gn_sensitivity.t_sensitivity_rules OWNER TO geonatadmin;

--
-- Name: TABLE t_sensitivity_rules; Type: COMMENT; Schema: gn_sensitivity; Owner: geonatadmin
--

COMMENT ON TABLE gn_sensitivity.t_sensitivity_rules IS 'List of sensitivity rules per taxon. Compilation of national and regional list. If you whant to disable one ou several rules you can set false to enable.';


--
-- Name: t_sensitivity_rules_cd_ref; Type: MATERIALIZED VIEW; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW gn_sensitivity.t_sensitivity_rules_cd_ref AS
 WITH RECURSIVE r(cd_ref) AS (
         SELECT t.cd_ref,
            r_1.id_sensitivity,
            r_1.cd_nom,
            r_1.nom_cite,
            r_1.id_nomenclature_sensitivity,
            r_1.sensitivity_duration,
            r_1.sensitivity_territory,
            r_1.id_territory,
            COALESCE(r_1.date_min, '1900-01-01'::date) AS date_min,
            COALESCE(r_1.date_max, '1900-12-31'::date) AS date_max,
            r_1.active,
            r_1.comments,
            r_1.meta_create_date,
            r_1.meta_update_date
           FROM (gn_sensitivity.t_sensitivity_rules r_1
             JOIN taxonomie.taxref t ON ((t.cd_nom = r_1.cd_nom)))
          WHERE (r_1.active = true)
        UNION ALL
         SELECT t.cd_ref,
            r_1.id_sensitivity,
            t.cd_nom,
            r_1.nom_cite,
            r_1.id_nomenclature_sensitivity,
            r_1.sensitivity_duration,
            r_1.sensitivity_territory,
            r_1.id_territory,
            r_1.date_min,
            r_1.date_max,
            r_1.active,
            r_1.comments,
            r_1.meta_create_date,
            r_1.meta_update_date
           FROM taxonomie.taxref t,
            r r_1
          WHERE (t.cd_taxsup = r_1.cd_ref)
        )
 SELECT r.cd_ref,
    r.id_sensitivity,
    r.cd_nom,
    r.nom_cite,
    r.id_nomenclature_sensitivity,
    r.sensitivity_duration,
    r.sensitivity_territory,
    r.id_territory,
    r.date_min,
    r.date_max,
    r.active,
    r.comments,
    r.meta_create_date,
    r.meta_update_date
   FROM r
  WITH NO DATA;


ALTER TABLE gn_sensitivity.t_sensitivity_rules_cd_ref OWNER TO geonatadmin;

--
-- Name: t_sensitivity_rules_id_sensitivity_seq; Type: SEQUENCE; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE SEQUENCE gn_sensitivity.t_sensitivity_rules_id_sensitivity_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_sensitivity.t_sensitivity_rules_id_sensitivity_seq OWNER TO geonatadmin;

--
-- Name: t_sensitivity_rules_id_sensitivity_seq; Type: SEQUENCE OWNED BY; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER SEQUENCE gn_sensitivity.t_sensitivity_rules_id_sensitivity_seq OWNED BY gn_sensitivity.t_sensitivity_rules.id_sensitivity;


--
-- Name: cor_area_synthese; Type: TABLE; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TABLE gn_synthese.cor_area_synthese (
    id_synthese integer NOT NULL,
    id_area integer NOT NULL
);


ALTER TABLE gn_synthese.cor_area_synthese OWNER TO geonatadmin;

--
-- Name: cor_observer_synthese; Type: TABLE; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TABLE gn_synthese.cor_observer_synthese (
    id_synthese integer NOT NULL,
    id_role integer NOT NULL
);


ALTER TABLE gn_synthese.cor_observer_synthese OWNER TO geonatadmin;

--
-- Name: defaults_nomenclatures_value; Type: TABLE; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TABLE gn_synthese.defaults_nomenclatures_value (
    mnemonique_type character varying(50) NOT NULL,
    id_organism integer DEFAULT 0 NOT NULL,
    regne character varying(20) DEFAULT '0'::character varying NOT NULL,
    group2_inpn character varying(255) DEFAULT '0'::character varying NOT NULL,
    id_nomenclature integer NOT NULL
);


ALTER TABLE gn_synthese.defaults_nomenclatures_value OWNER TO geonatadmin;

--
-- Name: synthese_id_synthese_seq; Type: SEQUENCE; Schema: gn_synthese; Owner: geonatadmin
--

CREATE SEQUENCE gn_synthese.synthese_id_synthese_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_synthese.synthese_id_synthese_seq OWNER TO geonatadmin;

--
-- Name: synthese_id_synthese_seq; Type: SEQUENCE OWNED BY; Schema: gn_synthese; Owner: geonatadmin
--

ALTER SEQUENCE gn_synthese.synthese_id_synthese_seq OWNED BY gn_synthese.synthese.id_synthese;


--
-- Name: t_sources; Type: TABLE; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TABLE gn_synthese.t_sources (
    id_source integer NOT NULL,
    name_source character varying(255) NOT NULL,
    desc_source text,
    entity_source_pk_field character varying(255),
    url_source character varying(255),
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now()
);


ALTER TABLE gn_synthese.t_sources OWNER TO geonatadmin;

--
-- Name: t_sources_id_source_seq; Type: SEQUENCE; Schema: gn_synthese; Owner: geonatadmin
--

CREATE SEQUENCE gn_synthese.t_sources_id_source_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_synthese.t_sources_id_source_seq OWNER TO geonatadmin;

--
-- Name: t_sources_id_source_seq; Type: SEQUENCE OWNED BY; Schema: gn_synthese; Owner: geonatadmin
--

ALTER SEQUENCE gn_synthese.t_sources_id_source_seq OWNED BY gn_synthese.t_sources.id_source;


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
-- Name: v_area_taxon; Type: VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE VIEW gn_synthese.v_area_taxon AS
 SELECT s.cd_nom,
    c.id_area,
    count(s.id_synthese) AS nb_obs,
    max(s.date_min) AS last_date
   FROM ((((gn_synthese.synthese s
     JOIN gn_synthese.cor_area_synthese c ON ((s.id_synthese = c.id_synthese)))
     JOIN ref_geo.l_areas la ON ((la.id_area = c.id_area)))
     JOIN ref_geo.bib_areas_types bat ON ((bat.id_type = la.id_type)))
     JOIN gn_commons.t_parameters tp ON ((((tp.parameter_name)::text = 'occtaxmobile_area_type'::text) AND (tp.parameter_value = (bat.type_code)::text))))
  GROUP BY c.id_area, s.cd_nom;


ALTER TABLE gn_synthese.v_area_taxon OWNER TO geonatadmin;

--
-- Name: v_color_taxon_area; Type: VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE VIEW gn_synthese.v_color_taxon_area AS
 SELECT v_area_taxon.cd_nom,
    v_area_taxon.id_area,
    v_area_taxon.nb_obs,
    v_area_taxon.last_date,
        CASE
            WHEN (date_part('day'::text, (now() - (v_area_taxon.last_date)::timestamp with time zone)) < (365)::double precision) THEN 'grey'::text
            ELSE 'red'::text
        END AS color
   FROM gn_synthese.v_area_taxon;


ALTER TABLE gn_synthese.v_color_taxon_area OWNER TO geonatadmin;

--
-- Name: bib_organismes; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.bib_organismes (
    id_organisme integer NOT NULL,
    uuid_organisme uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nom_organisme character varying(500) NOT NULL,
    adresse_organisme character varying(128),
    cp_organisme character varying(5),
    ville_organisme character varying(100),
    tel_organisme character varying(14),
    fax_organisme character varying(14),
    email_organisme character varying(100),
    url_organisme character varying(255),
    url_logo character varying(255),
    id_parent integer
);


ALTER TABLE utilisateurs.bib_organismes OWNER TO geonatadmin;

--
-- Name: v_metadata_for_export; Type: VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE VIEW gn_synthese.v_metadata_for_export AS
 WITH count_nb_obs AS (
         SELECT count(*) AS nb_obs,
            synthese.id_dataset
           FROM gn_synthese.synthese
          GROUP BY synthese.id_dataset
        )
 SELECT d.dataset_name AS jeu_donnees,
    d.id_dataset AS jdd_id,
    d.unique_dataset_id AS jdd_uuid,
    af.acquisition_framework_name AS cadre_acquisition,
    af.unique_acquisition_framework_id AS ca_uuid,
    string_agg(DISTINCT concat(COALESCE(orga.nom_organisme, ((((roles.nom_role)::text || ' '::text) || (roles.prenom_role)::text))::character varying), ' (', nomencl.label_default, ')'), ', '::text) AS acteurs,
    count_nb_obs.nb_obs AS nombre_obs
   FROM ((((((gn_meta.t_datasets d
     JOIN gn_meta.t_acquisition_frameworks af ON ((af.id_acquisition_framework = d.id_acquisition_framework)))
     LEFT JOIN gn_meta.cor_dataset_actor act ON ((act.id_dataset = d.id_dataset)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures nomencl ON ((nomencl.id_nomenclature = act.id_nomenclature_actor_role)))
     LEFT JOIN utilisateurs.bib_organismes orga ON ((orga.id_organisme = act.id_organism)))
     LEFT JOIN utilisateurs.t_roles roles ON ((roles.id_role = act.id_role)))
     JOIN count_nb_obs ON ((count_nb_obs.id_dataset = d.id_dataset)))
  GROUP BY d.id_dataset, d.unique_dataset_id, d.dataset_name, af.acquisition_framework_name, af.unique_acquisition_framework_id, count_nb_obs.nb_obs;


ALTER TABLE gn_synthese.v_metadata_for_export OWNER TO geonatadmin;

--
-- Name: v_synthese_decode_nomenclatures; Type: VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE VIEW gn_synthese.v_synthese_decode_nomenclatures AS
 SELECT s.id_synthese,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_geo_object_nature) AS nat_obj_geo,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_grp_typ) AS grp_typ,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_obs_technique) AS obs_technique,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_bio_status) AS bio_status,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_bio_condition) AS bio_condition,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_naturalness) AS naturalness,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_exist_proof) AS exist_proof,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_valid_status) AS valid_status,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_diffusion_level) AS diffusion_level,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_life_stage) AS life_stage,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_sex) AS sex,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_obj_count) AS obj_count,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_type_count) AS type_count,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_sensitivity) AS sensitivity,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_observation_status) AS observation_status,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_blurring) AS blurring,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_source_status) AS source_status,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_info_geo_type) AS info_geo_type,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_determination_method) AS determination_method,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_behaviour) AS occ_behaviour,
    ref_nomenclatures.get_nomenclature_label(s.id_nomenclature_biogeo_status) AS occ_stat_biogeo
   FROM gn_synthese.synthese s;


ALTER TABLE gn_synthese.v_synthese_decode_nomenclatures OWNER TO geonatadmin;

--
-- Name: habref; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.habref (
    cd_hab integer NOT NULL,
    fg_validite character varying(20) NOT NULL,
    cd_typo integer NOT NULL,
    lb_code character varying(50),
    lb_hab_fr character varying(500),
    lb_hab_fr_complet character varying(500),
    lb_hab_en character varying(500),
    lb_auteur character varying(500),
    niveau integer,
    lb_niveau character varying(100),
    cd_hab_sup integer,
    path_cd_hab character varying(2000),
    france character varying(5),
    lb_description character varying(4000)
);


ALTER TABLE ref_habitats.habref OWNER TO geonatadmin;

--
-- Name: TABLE habref; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.habref IS 'habref, table HABREF référentiel HABREF 4.0 INPN';


--
-- Name: v_synthese_for_export; Type: VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE VIEW gn_synthese.v_synthese_for_export AS
 SELECT s.id_synthese,
    (s.date_min)::date AS date_debut,
    (s.date_max)::date AS date_fin,
    (s.date_min)::time without time zone AS heure_debut,
    (s.date_max)::time without time zone AS heure_fin,
    t.cd_nom,
    t.cd_ref,
    t.nom_valide,
    t.nom_vern AS nom_vernaculaire,
    s.nom_cite,
    t.regne,
    t.group1_inpn,
    t.group2_inpn,
    t.classe,
    t.ordre,
    t.famille,
    t.id_rang AS rang_taxo,
    s.count_min AS nombre_min,
    s.count_max AS nombre_max,
    s.altitude_min AS alti_min,
    s.altitude_max AS alti_max,
    s.depth_min AS prof_min,
    s.depth_max AS prof_max,
    s.observers AS observateurs,
    s.id_digitiser,
    s.determiner AS determinateur,
    sa.communes,
    public.st_astext(s.the_geom_4326) AS geometrie_wkt_4326,
    public.st_x(s.the_geom_point) AS x_centroid_4326,
    public.st_y(s.the_geom_point) AS y_centroid_4326,
    public.st_asgeojson(s.the_geom_4326) AS geojson_4326,
    public.st_asgeojson(s.the_geom_local) AS geojson_local,
    s.place_name AS nom_lieu,
    s.comment_context AS comment_releve,
    s.comment_description AS comment_occurrence,
    s.validator AS validateur,
    n21.label_default AS niveau_validation,
    s.meta_validation_date AS date_validation,
    s.validation_comment AS comment_validation,
    s.digital_proof AS preuve_numerique_url,
    s.non_digital_proof AS preuve_non_numerique,
    d.dataset_name AS jdd_nom,
    d.unique_dataset_id AS jdd_uuid,
    d.id_dataset AS jdd_id,
    af.acquisition_framework_name AS ca_nom,
    af.unique_acquisition_framework_id AS ca_uuid,
    d.id_acquisition_framework AS ca_id,
    s.cd_hab AS cd_habref,
    hab.lb_code AS cd_habitat,
    hab.lb_hab_fr AS nom_habitat,
    s."precision" AS precision_geographique,
    n1.label_default AS nature_objet_geo,
    n2.label_default AS type_regroupement,
    s.grp_method AS methode_regroupement,
    n3.label_default AS technique_observation,
    n5.label_default AS biologique_statut,
    n6.label_default AS etat_biologique,
    n22.label_default AS biogeographique_statut,
    n7.label_default AS naturalite,
    n8.label_default AS preuve_existante,
    n9.label_default AS niveau_precision_diffusion,
    n10.label_default AS stade_vie,
    n11.label_default AS sexe,
    n12.label_default AS objet_denombrement,
    n13.label_default AS type_denombrement,
    n14.label_default AS niveau_sensibilite,
    n15.label_default AS statut_observation,
    n16.label_default AS floutage_dee,
    n17.label_default AS statut_source,
    n18.label_default AS type_info_geo,
    n19.label_default AS methode_determination,
    n20.label_default AS comportement,
    s.reference_biblio,
    s.entity_source_pk_value AS id_origine,
    s.unique_id_sinp AS uuid_perm_sinp,
    s.unique_id_sinp_grp AS uuid_perm_grp_sinp,
    s.meta_create_date AS date_creation,
    s.meta_update_date AS date_modification,
    s.additional_data AS champs_additionnels,
    COALESCE(s.meta_update_date, s.meta_create_date) AS derniere_action
   FROM ((((((((((((((((((((((((((gn_synthese.synthese s
     JOIN taxonomie.taxref t ON ((t.cd_nom = s.cd_nom)))
     JOIN gn_meta.t_datasets d ON ((d.id_dataset = s.id_dataset)))
     JOIN gn_meta.t_acquisition_frameworks af ON ((d.id_acquisition_framework = af.id_acquisition_framework)))
     LEFT JOIN ( SELECT cas.id_synthese,
            string_agg(DISTINCT (a_1.area_name)::text, ', '::text) AS communes
           FROM ((gn_synthese.cor_area_synthese cas
             LEFT JOIN ref_geo.l_areas a_1 ON ((cas.id_area = a_1.id_area)))
             JOIN ref_geo.bib_areas_types ta ON (((ta.id_type = a_1.id_type) AND ((ta.type_code)::text = 'COM'::text))))
          GROUP BY cas.id_synthese) sa ON ((sa.id_synthese = s.id_synthese)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n1 ON ((s.id_nomenclature_geo_object_nature = n1.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n2 ON ((s.id_nomenclature_grp_typ = n2.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n3 ON ((s.id_nomenclature_obs_technique = n3.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n5 ON ((s.id_nomenclature_bio_status = n5.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n6 ON ((s.id_nomenclature_bio_condition = n6.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n7 ON ((s.id_nomenclature_naturalness = n7.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n8 ON ((s.id_nomenclature_exist_proof = n8.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n9 ON ((s.id_nomenclature_diffusion_level = n9.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n10 ON ((s.id_nomenclature_life_stage = n10.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n11 ON ((s.id_nomenclature_sex = n11.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n12 ON ((s.id_nomenclature_obj_count = n12.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n13 ON ((s.id_nomenclature_type_count = n13.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n14 ON ((s.id_nomenclature_sensitivity = n14.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n15 ON ((s.id_nomenclature_observation_status = n15.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n16 ON ((s.id_nomenclature_blurring = n16.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n17 ON ((s.id_nomenclature_source_status = n17.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n18 ON ((s.id_nomenclature_info_geo_type = n18.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n19 ON ((s.id_nomenclature_determination_method = n19.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n20 ON ((s.id_nomenclature_behaviour = n20.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n21 ON ((s.id_nomenclature_valid_status = n21.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n22 ON ((s.id_nomenclature_biogeo_status = n22.id_nomenclature)))
     LEFT JOIN ref_habitats.habref hab ON ((hab.cd_hab = s.cd_hab)));


ALTER TABLE gn_synthese.v_synthese_for_export OWNER TO geonatadmin;

--
-- Name: v_synthese_for_web_app; Type: VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE VIEW gn_synthese.v_synthese_for_web_app AS
 SELECT s.id_synthese,
    s.unique_id_sinp,
    s.unique_id_sinp_grp,
    s.id_source,
    s.entity_source_pk_value,
    s.count_min,
    s.count_max,
    s.nom_cite,
    s.meta_v_taxref,
    s.sample_number_proof,
    s.digital_proof,
    s.non_digital_proof,
    s.altitude_min,
    s.altitude_max,
    s.depth_min,
    s.depth_max,
    s.place_name,
    s."precision",
    s.the_geom_4326,
    public.st_asgeojson(s.the_geom_4326) AS st_asgeojson,
    s.date_min,
    s.date_max,
    s.validator,
    s.validation_comment,
    s.observers,
    s.id_digitiser,
    s.determiner,
    s.comment_context,
    s.comment_description,
    s.meta_validation_date,
    s.meta_create_date,
    s.meta_update_date,
    s.last_action,
    d.id_dataset,
    d.dataset_name,
    d.id_acquisition_framework,
    s.id_nomenclature_geo_object_nature,
    s.id_nomenclature_info_geo_type,
    s.id_nomenclature_grp_typ,
    s.grp_method,
    s.id_nomenclature_obs_technique,
    s.id_nomenclature_bio_status,
    s.id_nomenclature_bio_condition,
    s.id_nomenclature_naturalness,
    s.id_nomenclature_exist_proof,
    s.id_nomenclature_valid_status,
    s.id_nomenclature_diffusion_level,
    s.id_nomenclature_life_stage,
    s.id_nomenclature_sex,
    s.id_nomenclature_obj_count,
    s.id_nomenclature_type_count,
    s.id_nomenclature_sensitivity,
    s.id_nomenclature_observation_status,
    s.id_nomenclature_blurring,
    s.id_nomenclature_source_status,
    s.id_nomenclature_determination_method,
    s.id_nomenclature_behaviour,
    s.reference_biblio,
    sources.name_source,
    sources.url_source,
    t.cd_nom,
    t.cd_ref,
    t.nom_valide,
    t.lb_nom,
    t.nom_vern
   FROM (((gn_synthese.synthese s
     JOIN taxonomie.taxref t ON ((t.cd_nom = s.cd_nom)))
     JOIN gn_meta.t_datasets d ON ((d.id_dataset = s.id_dataset)))
     JOIN gn_synthese.t_sources sources ON ((sources.id_source = s.id_source)));


ALTER TABLE gn_synthese.v_synthese_for_web_app OWNER TO geonatadmin;

--
-- Name: v_synthese_taxon_for_export_view; Type: VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE VIEW gn_synthese.v_synthese_taxon_for_export_view AS
 SELECT DISTINCT ref.nom_valide,
    ref.cd_ref,
    ref.nom_vern,
    ref.group1_inpn,
    ref.group2_inpn,
    ref.regne,
    ref.phylum,
    ref.classe,
    ref.ordre,
    ref.famille,
    ref.id_rang
   FROM ((gn_synthese.synthese s
     JOIN taxonomie.taxref t ON ((s.cd_nom = t.cd_nom)))
     JOIN taxonomie.taxref ref ON ((t.cd_ref = ref.cd_nom)));


ALTER TABLE gn_synthese.v_synthese_taxon_for_export_view OWNER TO geonatadmin;

--
-- Name: v_tree_taxons_synthese; Type: VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE VIEW gn_synthese.v_tree_taxons_synthese AS
 WITH cd_famille AS (
         SELECT t_1.cd_ref,
            t_1.lb_nom AS nom_latin,
            t_1.nom_vern AS nom_francais,
            t_1.cd_nom,
            t_1.id_rang,
            t_1.regne,
            t_1.phylum,
            t_1.classe,
            t_1.ordre,
            t_1.famille,
            t_1.lb_nom
           FROM taxonomie.taxref t_1
          WHERE ((t_1.lb_nom)::text IN ( SELECT DISTINCT t_2.famille
                   FROM (gn_synthese.synthese s
                     JOIN taxonomie.taxref t_2 ON ((t_2.cd_nom = s.cd_nom)))))
        ), cd_regne AS (
         SELECT DISTINCT taxref.cd_nom,
            taxref.regne
           FROM taxonomie.taxref
          WHERE (((taxref.id_rang)::text = 'KD'::text) AND (taxref.cd_nom = taxref.cd_ref))
        )
 SELECT t.cd_ref,
    t.nom_latin,
    t.nom_francais,
    t.id_regne,
    t.nom_regne,
    COALESCE(t.id_embranchement, t.id_regne) AS id_embranchement,
    COALESCE(t.nom_embranchement, ' Sans embranchement dans taxref'::character varying) AS nom_embranchement,
    COALESCE(t.id_classe, t.id_embranchement) AS id_classe,
    COALESCE(t.nom_classe, ' Sans classe dans taxref'::character varying) AS nom_classe,
    COALESCE(t.desc_classe, ' Sans classe dans taxref'::character varying) AS desc_classe,
    COALESCE(t.id_ordre, t.id_classe) AS id_ordre,
    COALESCE(t.nom_ordre, ' Sans ordre dans taxref'::character varying) AS nom_ordre
   FROM ( SELECT DISTINCT t_1.cd_ref,
            t_1.nom_latin,
            t_1.nom_francais,
            ( SELECT DISTINCT r.cd_nom
                   FROM cd_regne r
                  WHERE ((r.regne)::text = (t_1.regne)::text)) AS id_regne,
            t_1.regne AS nom_regne,
            ph.cd_nom AS id_embranchement,
            t_1.phylum AS nom_embranchement,
            t_1.phylum AS desc_embranchement,
            cl.cd_nom AS id_classe,
            t_1.classe AS nom_classe,
            t_1.classe AS desc_classe,
            ord.cd_nom AS id_ordre,
            t_1.ordre AS nom_ordre
           FROM (((cd_famille t_1
             LEFT JOIN taxonomie.taxref ph ON ((((ph.id_rang)::text = 'PH'::text) AND (ph.cd_nom = ph.cd_ref) AND ((ph.lb_nom)::text = (t_1.phylum)::text) AND (NOT (t_1.phylum IS NULL)))))
             LEFT JOIN taxonomie.taxref cl ON ((((cl.id_rang)::text = 'CL'::text) AND (cl.cd_nom = cl.cd_ref) AND ((cl.lb_nom)::text = (t_1.classe)::text) AND (NOT (t_1.classe IS NULL)))))
             LEFT JOIN taxonomie.taxref ord ON ((((ord.id_rang)::text = 'OR'::text) AND (ord.cd_nom = ord.cd_ref) AND ((ord.lb_nom)::text = (t_1.ordre)::text) AND (NOT (t_1.ordre IS NULL)))))) t
  ORDER BY t.id_regne, COALESCE(t.id_embranchement, t.id_regne), COALESCE(t.id_classe, t.id_embranchement), COALESCE(t.id_ordre, t.id_classe);


ALTER TABLE gn_synthese.v_tree_taxons_synthese OWNER TO geonatadmin;

--
-- Name: VIEW v_tree_taxons_synthese; Type: COMMENT; Schema: gn_synthese; Owner: geonatadmin
--

COMMENT ON VIEW gn_synthese.v_tree_taxons_synthese IS 'Vue destinée à l''arbre taxonomique de la synthese. S''arrête  à la famille pour des questions de performances';


--
-- Name: vm_min_max_for_taxons; Type: MATERIALIZED VIEW; Schema: gn_synthese; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW gn_synthese.vm_min_max_for_taxons AS
 WITH s AS (
         SELECT synt.cd_nom,
            t.cd_ref,
            synt.the_geom_local,
            synt.date_min,
            synt.date_max,
            synt.altitude_min,
            synt.altitude_max
           FROM (gn_synthese.synthese synt
             LEFT JOIN taxonomie.taxref t ON ((t.cd_nom = synt.cd_nom)))
          WHERE (synt.id_nomenclature_valid_status = ANY (ARRAY[1, 2]))
        ), loc AS (
         SELECT s.cd_ref,
            count(*) AS nbobs,
            public.st_transform(public.st_setsrid((public.st_extent(s.the_geom_local))::public.geometry, 2154), 4326) AS bbox4326
           FROM s
          GROUP BY s.cd_ref
        ), dat AS (
         SELECT s.cd_ref,
            min((to_char(s.date_min, 'DDD'::text))::integer) AS daymin,
            max((to_char(s.date_max, 'DDD'::text))::integer) AS daymax
           FROM s
          GROUP BY s.cd_ref
        ), alt AS (
         SELECT s.cd_ref,
            min(s.altitude_min) AS altitudemin,
            max(s.altitude_max) AS altitudemax
           FROM s
          GROUP BY s.cd_ref
        )
 SELECT loc.cd_ref,
    loc.nbobs,
    dat.daymin,
    dat.daymax,
    alt.altitudemin,
    alt.altitudemax,
    loc.bbox4326
   FROM ((loc
     LEFT JOIN alt ON ((alt.cd_ref = loc.cd_ref)))
     LEFT JOIN dat ON ((dat.cd_ref = loc.cd_ref)))
  ORDER BY loc.cd_ref
  WITH NO DATA;


ALTER TABLE gn_synthese.vm_min_max_for_taxons OWNER TO geonatadmin;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: geonatadmin
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO geonatadmin;

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
-- Name: autocomplete_habitat; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.autocomplete_habitat (
    cd_hab integer NOT NULL,
    cd_typo integer NOT NULL,
    lb_code character varying(50),
    lb_nom_typo character varying(100) NOT NULL,
    search_name character varying(1000) NOT NULL
);


ALTER TABLE ref_habitats.autocomplete_habitat OWNER TO geonatadmin;

--
-- Name: bib_habref_statuts; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.bib_habref_statuts (
    statut character varying(1) NOT NULL,
    description character varying(50) NOT NULL,
    definition character varying(500) NOT NULL,
    ordre integer
);


ALTER TABLE ref_habitats.bib_habref_statuts OWNER TO geonatadmin;

--
-- Name: TABLE bib_habref_statuts; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.bib_habref_statuts IS 'Bibliothèque des types statut d''habitat - Présence, absence ... - Table habref_status de HABREF';


--
-- Name: bib_habref_typo_rel; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.bib_habref_typo_rel (
    cd_type_rel integer NOT NULL,
    lb_type_rel character varying(200),
    lb_rel character varying(1000),
    corresp_hab boolean,
    corresp_esp boolean,
    corresp_syn boolean,
    date_crea text,
    date_modif text
);


ALTER TABLE ref_habitats.bib_habref_typo_rel OWNER TO geonatadmin;

--
-- Name: TABLE bib_habref_typo_rel; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.bib_habref_typo_rel IS 'Bibliothèque des types de relations entre habitats - Table habref_typo_rel de HABREF';


--
-- Name: bib_list_habitat; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.bib_list_habitat (
    id_list integer NOT NULL,
    list_name character varying(255) NOT NULL
);


ALTER TABLE ref_habitats.bib_list_habitat OWNER TO geonatadmin;

--
-- Name: TABLE bib_list_habitat; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.bib_list_habitat IS 'Table des listes des habitats';


--
-- Name: bib_list_habitat_id_list_seq; Type: SEQUENCE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE SEQUENCE ref_habitats.bib_list_habitat_id_list_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_habitats.bib_list_habitat_id_list_seq OWNER TO geonatadmin;

--
-- Name: bib_list_habitat_id_list_seq; Type: SEQUENCE OWNED BY; Schema: ref_habitats; Owner: geonatadmin
--

ALTER SEQUENCE ref_habitats.bib_list_habitat_id_list_seq OWNED BY ref_habitats.bib_list_habitat.id_list;


--
-- Name: cor_hab_source; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.cor_hab_source (
    cd_hab_lien_source integer NOT NULL,
    cd integer NOT NULL,
    type_lien character varying(7) NOT NULL,
    cd_source integer NOT NULL,
    origine character varying(5),
    date_crea text,
    date_modif text
);


ALTER TABLE ref_habitats.cor_hab_source OWNER TO geonatadmin;

--
-- Name: TABLE cor_hab_source; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.cor_hab_source IS 'Table de corespondance entre une unité (cd_hab, cd_coresp_hab, cd_coresp_taxon) et une source - Table habref_lien_source de HABREF';


--
-- Name: cor_habref_description; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.cor_habref_description (
    cd_hab_description integer NOT NULL,
    cd_hab integer NOT NULL,
    cd_hab_field integer NOT NULL,
    cd_typo integer,
    lb_code character varying(50),
    lb_hab_field character varying(200),
    valeurs text
);


ALTER TABLE ref_habitats.cor_habref_description OWNER TO geonatadmin;

--
-- Name: TABLE cor_habref_description; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.cor_habref_description IS 'Table de correspondance entre un habitat et les champs additionnels décrit dans la table typoref_fields - Table habref_description de HABREF';


--
-- Name: cor_habref_terr_statut; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.cor_habref_terr_statut (
    cd_hab_ter integer NOT NULL,
    cd_hab integer NOT NULL,
    cd_sig_terr character varying(20) NOT NULL,
    cd_statut_presence character varying(1),
    date_crea text,
    date_modif text
);


ALTER TABLE ref_habitats.cor_habref_terr_statut OWNER TO geonatadmin;

--
-- Name: TABLE cor_habref_terr_statut; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.cor_habref_terr_statut IS 'Table de descritpion des champs additionnels de chaque typologie.';


--
-- Name: cor_list_habitat; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.cor_list_habitat (
    id_cor_list integer NOT NULL,
    id_list integer NOT NULL,
    cd_hab integer NOT NULL
);


ALTER TABLE ref_habitats.cor_list_habitat OWNER TO geonatadmin;

--
-- Name: TABLE cor_list_habitat; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.cor_list_habitat IS 'Habitat de chaque liste';


--
-- Name: cor_list_habitat_id_cor_list_seq; Type: SEQUENCE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE SEQUENCE ref_habitats.cor_list_habitat_id_cor_list_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_habitats.cor_list_habitat_id_cor_list_seq OWNER TO geonatadmin;

--
-- Name: cor_list_habitat_id_cor_list_seq; Type: SEQUENCE OWNED BY; Schema: ref_habitats; Owner: geonatadmin
--

ALTER SEQUENCE ref_habitats.cor_list_habitat_id_cor_list_seq OWNED BY ref_habitats.cor_list_habitat.id_cor_list;


--
-- Name: habref_corresp_hab; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.habref_corresp_hab (
    cd_corresp_hab integer NOT NULL,
    cd_hab_entre integer NOT NULL,
    cd_hab_sortie integer,
    cd_type_relation integer,
    lb_condition character varying(1000),
    lb_remarques character varying(4000),
    validite boolean,
    cd_typo_entre integer,
    cd_typo_sortie integer,
    date_crea text,
    date_modif text,
    diffusion boolean
);


ALTER TABLE ref_habitats.habref_corresp_hab OWNER TO geonatadmin;

--
-- Name: TABLE habref_corresp_hab; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.habref_corresp_hab IS 'Table de corespondances entres les habitats de differentes typologie';


--
-- Name: habref_corresp_taxon; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.habref_corresp_taxon (
    cd_corresp_tax integer NOT NULL,
    cd_hab_entre integer NOT NULL,
    cd_nom integer,
    cd_type_relation integer,
    lb_condition character varying(1000),
    lb_remarques character varying(4000),
    nom_cite character varying(500),
    validite boolean,
    date_crea text,
    date_modif text
);


ALTER TABLE ref_habitats.habref_corresp_taxon OWNER TO geonatadmin;

--
-- Name: TABLE habref_corresp_taxon; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.habref_corresp_taxon IS 'Table de corespondances entres les habitats les taxon (table taxref)';


--
-- Name: habref_sources; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.habref_sources (
    cd_source integer NOT NULL,
    cd_doc integer,
    type_source character varying(1),
    auteur_source character varying(255),
    date_source integer,
    lb_source character varying(1000),
    lb_source_complet character varying(2000),
    titre character varying(1000),
    link character varying(1000),
    date_crea text,
    date_modif text
);


ALTER TABLE ref_habitats.habref_sources OWNER TO geonatadmin;

--
-- Name: TABLE habref_sources; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.habref_sources IS 'Table des sources décrivant les habitats';


--
-- Name: typoref; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.typoref (
    cd_typo integer NOT NULL,
    cd_table character varying(255),
    lb_nom_typo character varying(100),
    nom_jeu_donnees character varying(255),
    date_creation character varying(255),
    date_mise_jour_table character varying(255),
    date_mise_jour_metadonnees character varying(255),
    auteur_typo character varying(4000),
    auteur_table character varying(4000),
    territoire character varying(4000),
    organisme character varying(255),
    langue character varying(255),
    presentation character varying(4000),
    description character varying(4000),
    origine character varying(4000),
    ref_biblio character varying(4000),
    mots_cles character varying(255),
    referencement character varying(4000),
    diffusion character varying(4000),
    derniere_modif character varying(4000),
    type_table character varying(6),
    cd_typo_entre integer,
    cd_typo_sortie integer,
    niveau_inpn character varying(255)
);


ALTER TABLE ref_habitats.typoref OWNER TO geonatadmin;

--
-- Name: TABLE typoref; Type: COMMENT; Schema: ref_habitats; Owner: geonatadmin
--

COMMENT ON TABLE ref_habitats.typoref IS 'typoref, table TYPOREF du référentiel HABREF 4.0';


--
-- Name: typoref_cd_typo_seq; Type: SEQUENCE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE SEQUENCE ref_habitats.typoref_cd_typo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_habitats.typoref_cd_typo_seq OWNER TO geonatadmin;

--
-- Name: typoref_cd_typo_seq; Type: SEQUENCE OWNED BY; Schema: ref_habitats; Owner: geonatadmin
--

ALTER SEQUENCE ref_habitats.typoref_cd_typo_seq OWNED BY ref_habitats.typoref.cd_typo;


--
-- Name: typoref_fields; Type: TABLE; Schema: ref_habitats; Owner: geonatadmin
--

CREATE TABLE ref_habitats.typoref_fields (
    cd_hab_field integer NOT NULL,
    cd_typo integer NOT NULL,
    lb_hab_field character varying(30) NOT NULL,
    format_hab_field character varying(200),
    descript_hab_field character varying(3000),
    ordre_hab_field integer,
    length_hab_field integer,
    lb_label character varying(200),
    date_crea text,
    date_modif text
);


ALTER TABLE ref_habitats.typoref_fields OWNER TO geonatadmin;

--
-- Name: bib_nomenclatures_types; Type: TABLE; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TABLE ref_nomenclatures.bib_nomenclatures_types (
    id_type integer NOT NULL,
    mnemonique character varying(255),
    label_default character varying(255) NOT NULL,
    definition_default text,
    label_fr character varying(255) NOT NULL,
    definition_fr text,
    label_en character varying(255),
    definition_en text,
    label_es character varying(255),
    definition_es text,
    label_de character varying(255),
    definition_de text,
    label_it character varying(255),
    definition_it text,
    source character varying(50),
    statut character varying(20),
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_nomenclatures.bib_nomenclatures_types OWNER TO geonatadmin;

--
-- Name: TABLE bib_nomenclatures_types; Type: COMMENT; Schema: ref_nomenclatures; Owner: geonatadmin
--

COMMENT ON TABLE ref_nomenclatures.bib_nomenclatures_types IS 'Types of nomenclature (SINP, CAMPanule, GeoNature...)';


--
-- Name: bib_nomenclatures_types_id_type_seq; Type: SEQUENCE; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE SEQUENCE ref_nomenclatures.bib_nomenclatures_types_id_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_nomenclatures.bib_nomenclatures_types_id_type_seq OWNER TO geonatadmin;

--
-- Name: bib_nomenclatures_types_id_type_seq; Type: SEQUENCE OWNED BY; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER SEQUENCE ref_nomenclatures.bib_nomenclatures_types_id_type_seq OWNED BY ref_nomenclatures.bib_nomenclatures_types.id_type;


--
-- Name: cor_application_nomenclature; Type: TABLE; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TABLE ref_nomenclatures.cor_application_nomenclature (
    id_nomenclature integer NOT NULL,
    id_application integer NOT NULL
);


ALTER TABLE ref_nomenclatures.cor_application_nomenclature OWNER TO geonatadmin;

--
-- Name: TABLE cor_application_nomenclature; Type: COMMENT; Schema: ref_nomenclatures; Owner: geonatadmin
--

COMMENT ON TABLE ref_nomenclatures.cor_application_nomenclature IS 'Allow to create specific list per module for one nomenclature.';


--
-- Name: cor_nomenclatures_relations; Type: TABLE; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TABLE ref_nomenclatures.cor_nomenclatures_relations (
    id_nomenclature_l integer NOT NULL,
    id_nomenclature_r integer NOT NULL,
    relation_type character varying(250) NOT NULL
);


ALTER TABLE ref_nomenclatures.cor_nomenclatures_relations OWNER TO geonatadmin;

--
-- Name: cor_taxref_nomenclature; Type: TABLE; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TABLE ref_nomenclatures.cor_taxref_nomenclature (
    id_nomenclature integer NOT NULL,
    regne character varying(255) NOT NULL,
    group2_inpn character varying(255) NOT NULL,
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone
);


ALTER TABLE ref_nomenclatures.cor_taxref_nomenclature OWNER TO geonatadmin;

--
-- Name: defaults_nomenclatures_value; Type: TABLE; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TABLE ref_nomenclatures.defaults_nomenclatures_value (
    mnemonique_type character varying(255) NOT NULL,
    id_organism integer NOT NULL,
    id_nomenclature integer NOT NULL
);


ALTER TABLE ref_nomenclatures.defaults_nomenclatures_value OWNER TO geonatadmin;

--
-- Name: t_nomenclatures_id_nomenclature_seq; Type: SEQUENCE; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE SEQUENCE ref_nomenclatures.t_nomenclatures_id_nomenclature_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ref_nomenclatures.t_nomenclatures_id_nomenclature_seq OWNER TO geonatadmin;

--
-- Name: t_nomenclatures_id_nomenclature_seq; Type: SEQUENCE OWNED BY; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER SEQUENCE ref_nomenclatures.t_nomenclatures_id_nomenclature_seq OWNED BY ref_nomenclatures.t_nomenclatures.id_nomenclature;


--
-- Name: v_data_typ; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_data_typ AS
 SELECT n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM (ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'DATA_TYP'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_data_typ OWNER TO geonatadmin;

--
-- Name: v_eta_bio; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_eta_bio AS
 SELECT n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM (ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'ETA_BIO'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_eta_bio OWNER TO geonatadmin;

--
-- Name: v_meth_determin; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_meth_determin AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'METH_DETERMIN'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_meth_determin OWNER TO geonatadmin;

--
-- Name: v_meth_obs; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_meth_obs AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'METH_OBS'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_meth_obs OWNER TO geonatadmin;

--
-- Name: v_naturalite; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_naturalite AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'NATURALITE'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_naturalite OWNER TO geonatadmin;

--
-- Name: v_niv_precis; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_niv_precis AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'NIV_PRECIS'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_niv_precis OWNER TO geonatadmin;

--
-- Name: v_nomenclature_taxonomie; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_nomenclature_taxonomie AS
 SELECT tn.id_type,
    tn.label_default AS type_label,
    tn.definition_default AS type_definition,
    tn.label_fr AS type_label_fr,
    tn.definition_fr AS type_definition_fr,
    tn.label_en AS type_label_en,
    tn.definition_en AS type_definition_en,
    tn.label_es AS type_label_es,
    tn.definition_es AS type_definition_es,
    tn.label_de AS type_label_de,
    tn.definition_de AS type_definition_de,
    tn.label_it AS type_label_it,
    tn.definition_it AS type_definition_it,
    ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS nomenclature_label,
    n.definition_default AS nomenclature_definition,
    n.label_fr AS nomenclature_label_fr,
    n.definition_fr AS nomenclature_definition_fr,
    n.label_en AS nomenclature_label_en,
    n.definition_en AS nomenclature_definition_en,
    n.label_es AS nomenclature_label_es,
    n.definition_es AS nomenclature_definition_es,
    n.label_de AS nomenclature_label_de,
    n.definition_de AS nomenclature_definition_de,
    n.label_it AS nomenclature_label_it,
    n.definition_it AS nomenclature_definition_it,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     JOIN ref_nomenclatures.bib_nomenclatures_types tn ON ((tn.id_type = n.id_type)))
     JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
  WHERE (n.active = true)
  ORDER BY tn.id_type, ctn.regne, ctn.group2_inpn, n.id_nomenclature;


ALTER TABLE ref_nomenclatures.v_nomenclature_taxonomie OWNER TO geonatadmin;

--
-- Name: v_objet_denbr; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_objet_denbr AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'OBJ_DENBR'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_objet_denbr OWNER TO geonatadmin;

--
-- Name: v_preuve_exist; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_preuve_exist AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM (ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
  WHERE (((n.mnemonique)::text = 'PREUVE_EXIST'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_preuve_exist OWNER TO geonatadmin;

--
-- Name: v_resource_typ; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_resource_typ AS
 SELECT n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM (ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'RESOURCE_TYP'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_resource_typ OWNER TO geonatadmin;

--
-- Name: v_sampling_plan_typ; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_sampling_plan_typ AS
 SELECT n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM (ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'SAMPLING_PLAN_TYP'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_sampling_plan_typ OWNER TO geonatadmin;

--
-- Name: v_sampling_units_typ; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_sampling_units_typ AS
 SELECT n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM (ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'SAMPLING_UNITS_TYP'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_sampling_units_typ OWNER TO geonatadmin;

--
-- Name: v_sexe; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_sexe AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'SEXE'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_sexe OWNER TO geonatadmin;

--
-- Name: v_stade_vie; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_stade_vie AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'STADE_VIE'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_stade_vie OWNER TO geonatadmin;

--
-- Name: v_statut_bio; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_statut_bio AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'STATUT_BIO'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_statut_bio OWNER TO geonatadmin;

--
-- Name: v_statut_obs; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_statut_obs AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'STATUT_OBS'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_statut_obs OWNER TO geonatadmin;

--
-- Name: v_statut_valid; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_statut_valid AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'STATUT_VALID'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_statut_valid OWNER TO geonatadmin;

--
-- Name: v_technique_obs; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_technique_obs AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM (ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
  WHERE ((n.mnemonique)::text = 'TECHNIQUE_OBS'::text);


ALTER TABLE ref_nomenclatures.v_technique_obs OWNER TO geonatadmin;

--
-- Name: v_type_denbr; Type: VIEW; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE VIEW ref_nomenclatures.v_type_denbr AS
 SELECT ctn.regne,
    ctn.group2_inpn,
    n.id_nomenclature,
    n.mnemonique,
    n.label_default AS label,
    n.definition_default AS definition,
    n.id_broader,
    n.hierarchy
   FROM ((ref_nomenclatures.t_nomenclatures n
     LEFT JOIN ref_nomenclatures.cor_taxref_nomenclature ctn ON ((ctn.id_nomenclature = n.id_nomenclature)))
     LEFT JOIN ref_nomenclatures.bib_nomenclatures_types t ON ((t.id_type = n.id_type)))
  WHERE (((t.mnemonique)::text = 'TYP_DENBR'::text) AND (n.active = true));


ALTER TABLE ref_nomenclatures.v_type_denbr OWNER TO geonatadmin;

--
-- Name: bdc_statut; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bdc_statut (
    id integer NOT NULL,
    cd_nom integer NOT NULL,
    cd_ref integer NOT NULL,
    cd_sup integer,
    cd_type_statut character varying(50) NOT NULL,
    lb_type_statut character varying(250),
    regroupement_type character varying(250),
    code_statut character varying(250),
    label_statut character varying(1000),
    rq_statut text,
    cd_sig character varying(100),
    cd_doc integer,
    lb_nom character varying(1000),
    lb_auteur character varying(1000),
    nom_complet_html character varying(1000),
    nom_valide_html character varying(1000),
    regne character varying(250),
    phylum character varying(250),
    classe character varying(250),
    ordre character varying(250),
    famille character varying(250),
    group1_inpn character varying(255),
    group2_inpn character varying(255),
    lb_adm_tr character varying(100),
    niveau_admin character varying(250),
    cd_iso3166_1 character varying(50),
    cd_iso3166_2 character varying(50),
    full_citation text,
    doc_url text,
    thematique character varying(100),
    type_value character varying(100)
);


ALTER TABLE taxonomie.bdc_statut OWNER TO geonatadmin;

--
-- Name: TABLE bdc_statut; Type: COMMENT; Schema: taxonomie; Owner: geonatadmin
--

COMMENT ON TABLE taxonomie.bdc_statut IS 'Table initialement fournie par l''INPN. Contient tout les statuts sous leur forme brute';


--
-- Name: bdc_statut_cor_text_values; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bdc_statut_cor_text_values (
    id_value_text integer NOT NULL,
    id_value integer NOT NULL,
    id_text integer NOT NULL
);


ALTER TABLE taxonomie.bdc_statut_cor_text_values OWNER TO geonatadmin;

--
-- Name: TABLE bdc_statut_cor_text_values; Type: COMMENT; Schema: taxonomie; Owner: geonatadmin
--

COMMENT ON TABLE taxonomie.bdc_statut_cor_text_values IS 'Table d''association entre les textes, les taxons et la valeur';


--
-- Name: bdc_statut_cor_text_values_id_value_text_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.bdc_statut_cor_text_values_id_value_text_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.bdc_statut_cor_text_values_id_value_text_seq OWNER TO geonatadmin;

--
-- Name: bdc_statut_cor_text_values_id_value_text_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.bdc_statut_cor_text_values_id_value_text_seq OWNED BY taxonomie.bdc_statut_cor_text_values.id_value_text;


--
-- Name: bdc_statut_id_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.bdc_statut_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.bdc_statut_id_seq OWNER TO geonatadmin;

--
-- Name: bdc_statut_id_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.bdc_statut_id_seq OWNED BY taxonomie.bdc_statut.id;


--
-- Name: bdc_statut_taxons; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bdc_statut_taxons (
    id integer NOT NULL,
    id_value_text integer NOT NULL,
    cd_nom integer NOT NULL,
    cd_ref integer NOT NULL,
    rq_statut character varying(1000)
);


ALTER TABLE taxonomie.bdc_statut_taxons OWNER TO geonatadmin;

--
-- Name: TABLE bdc_statut_taxons; Type: COMMENT; Schema: taxonomie; Owner: geonatadmin
--

COMMENT ON TABLE taxonomie.bdc_statut_taxons IS 'Table d''association entre les textes et les taxons';


--
-- Name: bdc_statut_text; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bdc_statut_text (
    id_text integer NOT NULL,
    cd_st_text character varying(50),
    cd_type_statut character varying(50) NOT NULL,
    cd_sig character varying(50),
    cd_doc integer,
    niveau_admin character varying(250),
    cd_iso3166_1 character varying(50),
    cd_iso3166_2 character varying(50),
    lb_adm_tr character varying(250),
    full_citation text,
    doc_url text,
    enable boolean DEFAULT true
);


ALTER TABLE taxonomie.bdc_statut_text OWNER TO geonatadmin;

--
-- Name: TABLE bdc_statut_text; Type: COMMENT; Schema: taxonomie; Owner: geonatadmin
--

COMMENT ON TABLE taxonomie.bdc_statut_text IS 'Table contenant les textes et leur zone d''application';


--
-- Name: bdc_statut_text_id_text_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.bdc_statut_text_id_text_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.bdc_statut_text_id_text_seq OWNER TO geonatadmin;

--
-- Name: bdc_statut_text_id_text_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.bdc_statut_text_id_text_seq OWNED BY taxonomie.bdc_statut_text.id_text;


--
-- Name: bdc_statut_type; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bdc_statut_type (
    cd_type_statut character varying(50) NOT NULL,
    lb_type_statut character varying(250),
    regroupement_type character varying(250),
    thematique character varying(100),
    type_value character varying(100)
);


ALTER TABLE taxonomie.bdc_statut_type OWNER TO geonatadmin;

--
-- Name: TABLE bdc_statut_type; Type: COMMENT; Schema: taxonomie; Owner: geonatadmin
--

COMMENT ON TABLE taxonomie.bdc_statut_type IS 'Table des grands type de statuts';


--
-- Name: bdc_statut_values; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bdc_statut_values (
    id_value integer NOT NULL,
    code_statut character varying(50) NOT NULL,
    label_statut character varying(250)
);


ALTER TABLE taxonomie.bdc_statut_values OWNER TO geonatadmin;

--
-- Name: TABLE bdc_statut_values; Type: COMMENT; Schema: taxonomie; Owner: geonatadmin
--

COMMENT ON TABLE taxonomie.bdc_statut_values IS 'Table contenant la liste des valeurs possible pour les textes';


--
-- Name: bdc_statut_values_id_value_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.bdc_statut_values_id_value_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.bdc_statut_values_id_value_seq OWNER TO geonatadmin;

--
-- Name: bdc_statut_values_id_value_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.bdc_statut_values_id_value_seq OWNED BY taxonomie.bdc_statut_values.id_value;


--
-- Name: bib_attributs_id_attribut_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.bib_attributs_id_attribut_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.bib_attributs_id_attribut_seq OWNER TO geonatadmin;

--
-- Name: bib_attributs; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_attributs (
    id_attribut integer DEFAULT nextval('taxonomie.bib_attributs_id_attribut_seq'::regclass) NOT NULL,
    nom_attribut character varying(255) NOT NULL,
    label_attribut character varying(50) NOT NULL,
    liste_valeur_attribut text NOT NULL,
    obligatoire boolean DEFAULT false NOT NULL,
    desc_attribut text,
    type_attribut character varying(50),
    type_widget character varying(50),
    regne character varying(20),
    group2_inpn character varying(255),
    id_theme integer NOT NULL,
    ordre integer
);


ALTER TABLE taxonomie.bib_attributs OWNER TO geonatadmin;

--
-- Name: bib_listes; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_listes (
    id_liste integer NOT NULL,
    code_liste character varying(50) NOT NULL,
    nom_liste character varying(255) NOT NULL,
    desc_liste text,
    picto character varying(50) DEFAULT 'images/pictos/nopicto.gif'::character varying NOT NULL,
    regne character varying(20),
    group2_inpn character varying(255)
);


ALTER TABLE taxonomie.bib_listes OWNER TO geonatadmin;

--
-- Name: COLUMN bib_listes.picto; Type: COMMENT; Schema: taxonomie; Owner: geonatadmin
--

COMMENT ON COLUMN taxonomie.bib_listes.picto IS 'Indique le chemin vers l''image du picto représentant le groupe taxonomique dans les menus déroulants de taxons';


--
-- Name: bib_listes_id_liste_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.bib_listes_id_liste_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.bib_listes_id_liste_seq OWNER TO geonatadmin;

--
-- Name: bib_listes_id_liste_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.bib_listes_id_liste_seq OWNED BY taxonomie.bib_listes.id_liste;


--
-- Name: bib_noms; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_noms (
    id_nom integer NOT NULL,
    cd_nom integer,
    cd_ref integer,
    nom_francais character varying(1000),
    comments character varying(1000),
    CONSTRAINT check_is_valid_cd_ref CHECK ((cd_ref = taxonomie.find_cdref(cd_ref)))
);


ALTER TABLE taxonomie.bib_noms OWNER TO geonatadmin;

--
-- Name: bib_noms_id_nom_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.bib_noms_id_nom_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.bib_noms_id_nom_seq OWNER TO geonatadmin;

--
-- Name: bib_noms_id_nom_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.bib_noms_id_nom_seq OWNED BY taxonomie.bib_noms.id_nom;


--
-- Name: bib_taxref_categories_lr; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_taxref_categories_lr (
    id_categorie_france character(2) NOT NULL,
    categorie_lr character varying(50) NOT NULL,
    nom_categorie_lr character varying(255) NOT NULL,
    desc_categorie_lr character varying(255)
);


ALTER TABLE taxonomie.bib_taxref_categories_lr OWNER TO geonatadmin;

--
-- Name: bib_taxref_habitats; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_taxref_habitats (
    id_habitat integer NOT NULL,
    nom_habitat character varying(50) NOT NULL,
    desc_habitat text
);


ALTER TABLE taxonomie.bib_taxref_habitats OWNER TO geonatadmin;

--
-- Name: bib_taxref_rangs; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_taxref_rangs (
    id_rang character(4) NOT NULL,
    nom_rang character varying(50) NOT NULL,
    nom_rang_en character varying(50) NOT NULL,
    tri_rang integer
);


ALTER TABLE taxonomie.bib_taxref_rangs OWNER TO geonatadmin;

--
-- Name: bib_taxref_statuts; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_taxref_statuts (
    id_statut character(1) NOT NULL,
    nom_statut character varying(50) NOT NULL
);


ALTER TABLE taxonomie.bib_taxref_statuts OWNER TO geonatadmin;

--
-- Name: bib_themes; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_themes (
    id_theme integer NOT NULL,
    nom_theme character varying(20),
    desc_theme character varying(255),
    ordre integer,
    id_droit integer DEFAULT 0 NOT NULL,
    CONSTRAINT is_valid_id_droit_theme CHECK (((id_droit >= 0) AND (id_droit <= 6)))
);


ALTER TABLE taxonomie.bib_themes OWNER TO geonatadmin;

--
-- Name: bib_themes_id_theme_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.bib_themes_id_theme_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.bib_themes_id_theme_seq OWNER TO geonatadmin;

--
-- Name: bib_themes_id_theme_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.bib_themes_id_theme_seq OWNED BY taxonomie.bib_themes.id_theme;


--
-- Name: bib_types_media; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.bib_types_media (
    id_type integer NOT NULL,
    nom_type_media character varying(100) NOT NULL,
    desc_type_media text
);


ALTER TABLE taxonomie.bib_types_media OWNER TO geonatadmin;

--
-- Name: cor_nom_liste; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.cor_nom_liste (
    id_liste integer NOT NULL,
    id_nom integer NOT NULL
);


ALTER TABLE taxonomie.cor_nom_liste OWNER TO geonatadmin;

--
-- Name: cor_taxon_attribut; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.cor_taxon_attribut (
    id_attribut integer NOT NULL,
    valeur_attribut text NOT NULL,
    cd_ref integer NOT NULL,
    CONSTRAINT check_is_cd_ref CHECK ((cd_ref = taxonomie.find_cdref(cd_ref)))
);


ALTER TABLE taxonomie.cor_taxon_attribut OWNER TO geonatadmin;

--
-- Name: t_medias; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.t_medias (
    id_media integer NOT NULL,
    cd_ref integer,
    titre character varying(255) NOT NULL,
    url character varying(255),
    chemin character varying(255),
    auteur character varying(1000),
    desc_media text,
    date_media date,
    is_public boolean DEFAULT true NOT NULL,
    supprime boolean DEFAULT false NOT NULL,
    id_type integer NOT NULL,
    source character varying(25),
    licence character varying(100),
    CONSTRAINT check_cd_ref_is_ref CHECK ((cd_ref = taxonomie.find_cdref(cd_ref)))
);


ALTER TABLE taxonomie.t_medias OWNER TO geonatadmin;

--
-- Name: t_medias_id_media_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.t_medias_id_media_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.t_medias_id_media_seq OWNER TO geonatadmin;

--
-- Name: t_medias_id_media_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.t_medias_id_media_seq OWNED BY taxonomie.t_medias.id_media;


--
-- Name: taxhub_admin_log; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.taxhub_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone DEFAULT now() NOT NULL,
    id_role integer,
    object_type character varying(50),
    object_id integer,
    object_repr character varying(200) NOT NULL,
    change_type character varying(250),
    change_message character varying(250)
);


ALTER TABLE taxonomie.taxhub_admin_log OWNER TO geonatadmin;

--
-- Name: taxhub_admin_log_id_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.taxhub_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.taxhub_admin_log_id_seq OWNER TO geonatadmin;

--
-- Name: taxhub_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.taxhub_admin_log_id_seq OWNED BY taxonomie.taxhub_admin_log.id;


--
-- Name: taxref_changes; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.taxref_changes (
    cd_nom integer NOT NULL,
    num_version_init character varying(5),
    num_version_final character varying(5),
    champ character varying(50) NOT NULL,
    valeur_init character varying(255),
    valeur_final character varying(255),
    type_change character varying(25)
);


ALTER TABLE taxonomie.taxref_changes OWNER TO geonatadmin;

--
-- Name: taxref_liste_rouge_fr; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.taxref_liste_rouge_fr (
    id_lr integer NOT NULL,
    ordre_statut integer,
    vide character varying(255),
    cd_nom integer,
    cd_ref integer,
    nomcite character varying(255),
    nom_scientifique character varying(255),
    auteur character varying(255),
    nom_vernaculaire character varying(255),
    nom_commun character varying(255),
    rang character(4),
    famille character varying(50),
    endemisme character varying(255),
    population character varying(255),
    commentaire text,
    id_categorie_france character(2) NOT NULL,
    criteres_france character varying(255),
    liste_rouge character varying(255),
    fiche_espece character varying(255),
    tendance character varying(255),
    liste_rouge_source character varying(255),
    annee_publication integer,
    categorie_lr_europe character varying(2),
    categorie_lr_mondiale character varying(5)
);


ALTER TABLE taxonomie.taxref_liste_rouge_fr OWNER TO geonatadmin;

--
-- Name: taxref_liste_rouge_fr_id_lr_seq; Type: SEQUENCE; Schema: taxonomie; Owner: geonatadmin
--

CREATE SEQUENCE taxonomie.taxref_liste_rouge_fr_id_lr_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taxonomie.taxref_liste_rouge_fr_id_lr_seq OWNER TO geonatadmin;

--
-- Name: taxref_liste_rouge_fr_id_lr_seq; Type: SEQUENCE OWNED BY; Schema: taxonomie; Owner: geonatadmin
--

ALTER SEQUENCE taxonomie.taxref_liste_rouge_fr_id_lr_seq OWNED BY taxonomie.taxref_liste_rouge_fr.id_lr;


--
-- Name: taxref_protection_articles; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.taxref_protection_articles (
    cd_protection character varying(20) NOT NULL,
    article character varying(100),
    intitule text,
    arrete text,
    cd_arrete integer,
    url_inpn character varying(250),
    cd_doc integer,
    url character varying(250),
    date_arrete integer,
    type_protection character varying(250),
    concerne_mon_territoire boolean
);


ALTER TABLE taxonomie.taxref_protection_articles OWNER TO geonatadmin;

--
-- Name: taxref_protection_articles_structure; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.taxref_protection_articles_structure (
    cd_protection character varying(50) NOT NULL,
    alias_statut character varying(10),
    concerne_structure boolean
);


ALTER TABLE taxonomie.taxref_protection_articles_structure OWNER TO geonatadmin;

--
-- Name: taxref_protection_especes; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.taxref_protection_especes (
    cd_nom integer NOT NULL,
    cd_protection character varying(20) NOT NULL,
    nom_cite character varying(200),
    syn_cite character varying(200),
    nom_francais_cite character varying(100),
    precisions text,
    cd_nom_cite character varying(255) NOT NULL
);


ALTER TABLE taxonomie.taxref_protection_especes OWNER TO geonatadmin;

--
-- Name: v_taxref_all_listes; Type: VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE VIEW taxonomie.v_taxref_all_listes AS
 WITH bib_nom_lst AS (
         SELECT cor_nom_liste.id_nom,
            bib_noms.cd_nom,
            bib_noms.nom_francais,
            cor_nom_liste.id_liste
           FROM (taxonomie.cor_nom_liste
             JOIN taxonomie.bib_noms USING (id_nom))
        )
 SELECT t.regne,
    t.phylum,
    t.classe,
    t.ordre,
    t.famille,
    t.group1_inpn,
    t.group2_inpn,
    t.cd_nom,
    t.cd_ref,
    t.nom_complet,
    t.nom_valide,
    d.nom_francais AS nom_vern,
    t.lb_nom,
    d.id_liste
   FROM (taxonomie.taxref t
     JOIN bib_nom_lst d ON ((t.cd_nom = d.cd_nom)));


ALTER TABLE taxonomie.v_taxref_all_listes OWNER TO geonatadmin;

--
-- Name: v_taxref_hierarchie_bibtaxons; Type: VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE VIEW taxonomie.v_taxref_hierarchie_bibtaxons AS
 WITH mestaxons AS (
         SELECT tx_1.cd_nom,
            tx_1.id_statut,
            tx_1.id_habitat,
            tx_1.id_rang,
            tx_1.regne,
            tx_1.phylum,
            tx_1.classe,
            tx_1.ordre,
            tx_1.famille,
            tx_1.cd_taxsup,
            tx_1.cd_sup,
            tx_1.cd_ref,
            tx_1.lb_nom,
            tx_1.lb_auteur,
            tx_1.nom_complet,
            tx_1.nom_complet_html,
            tx_1.nom_valide,
            tx_1.nom_vern,
            tx_1.nom_vern_eng,
            tx_1.group1_inpn,
            tx_1.group2_inpn
           FROM (taxonomie.taxref tx_1
             JOIN taxonomie.bib_noms t ON ((t.cd_nom = tx_1.cd_nom)))
        )
 SELECT DISTINCT tx.regne,
    tx.phylum,
    tx.classe,
    tx.ordre,
    tx.famille,
    tx.cd_nom,
    tx.cd_ref,
    tx.lb_nom,
    btrim((tx.id_rang)::text) AS id_rang,
    f.nb_tx_fm,
    o.nb_tx_or,
    c.nb_tx_cl,
    p.nb_tx_ph,
    r.nb_tx_kd
   FROM ((((((taxonomie.taxref tx
     JOIN ( SELECT DISTINCT tx_1.regne,
            tx_1.phylum,
            tx_1.classe,
            tx_1.ordre,
            tx_1.famille
           FROM mestaxons tx_1) a ON (((((a.regne)::text = (tx.regne)::text) AND ((tx.id_rang)::text = 'KD'::text)) OR (((a.phylum)::text = (tx.phylum)::text) AND ((tx.id_rang)::text = 'PH'::text)) OR (((a.classe)::text = (tx.classe)::text) AND ((tx.id_rang)::text = 'CL'::text)) OR (((a.ordre)::text = (tx.ordre)::text) AND ((tx.id_rang)::text = 'OR'::text)) OR (((a.famille)::text = (tx.famille)::text) AND ((tx.id_rang)::text = 'FM'::text)))))
     LEFT JOIN ( SELECT mestaxons.famille,
            count(*) AS nb_tx_fm
           FROM mestaxons
          WHERE ((mestaxons.id_rang)::text <> 'FM'::text)
          GROUP BY mestaxons.famille) f ON (((f.famille)::text = (tx.famille)::text)))
     LEFT JOIN ( SELECT mestaxons.ordre,
            count(*) AS nb_tx_or
           FROM mestaxons
          WHERE ((mestaxons.id_rang)::text <> 'OR'::text)
          GROUP BY mestaxons.ordre) o ON (((o.ordre)::text = (tx.ordre)::text)))
     LEFT JOIN ( SELECT mestaxons.classe,
            count(*) AS nb_tx_cl
           FROM mestaxons
          WHERE ((mestaxons.id_rang)::text <> 'CL'::text)
          GROUP BY mestaxons.classe) c ON (((c.classe)::text = (tx.classe)::text)))
     LEFT JOIN ( SELECT mestaxons.phylum,
            count(*) AS nb_tx_ph
           FROM mestaxons
          WHERE ((mestaxons.id_rang)::text <> 'PH'::text)
          GROUP BY mestaxons.phylum) p ON (((p.phylum)::text = (tx.phylum)::text)))
     LEFT JOIN ( SELECT mestaxons.regne,
            count(*) AS nb_tx_kd
           FROM mestaxons
          WHERE ((mestaxons.id_rang)::text <> 'KD'::text)
          GROUP BY mestaxons.regne) r ON (((r.regne)::text = (tx.regne)::text)))
  WHERE (((tx.id_rang)::text = ANY (ARRAY[('KD'::character varying)::text, ('PH'::character varying)::text, ('CL'::character varying)::text, ('OR'::character varying)::text, ('FM'::character varying)::text])) AND (tx.cd_nom = tx.cd_ref));


ALTER TABLE taxonomie.v_taxref_hierarchie_bibtaxons OWNER TO geonatadmin;

--
-- Name: vm_classe; Type: MATERIALIZED VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW taxonomie.vm_classe AS
 SELECT DISTINCT tx.classe
   FROM taxonomie.taxref tx
  WITH NO DATA;


ALTER TABLE taxonomie.vm_classe OWNER TO geonatadmin;

--
-- Name: vm_famille; Type: MATERIALIZED VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW taxonomie.vm_famille AS
 SELECT DISTINCT tx.famille
   FROM taxonomie.taxref tx
  WITH NO DATA;


ALTER TABLE taxonomie.vm_famille OWNER TO geonatadmin;

--
-- Name: vm_group1_inpn; Type: MATERIALIZED VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW taxonomie.vm_group1_inpn AS
 SELECT DISTINCT tx.group1_inpn
   FROM taxonomie.taxref tx
  WITH NO DATA;


ALTER TABLE taxonomie.vm_group1_inpn OWNER TO geonatadmin;

--
-- Name: vm_group2_inpn; Type: MATERIALIZED VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW taxonomie.vm_group2_inpn AS
 SELECT DISTINCT tx.group2_inpn
   FROM taxonomie.taxref tx
  WITH NO DATA;


ALTER TABLE taxonomie.vm_group2_inpn OWNER TO geonatadmin;

--
-- Name: vm_ordre; Type: MATERIALIZED VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW taxonomie.vm_ordre AS
 SELECT DISTINCT tx.ordre
   FROM taxonomie.taxref tx
  WITH NO DATA;


ALTER TABLE taxonomie.vm_ordre OWNER TO geonatadmin;

--
-- Name: vm_phylum; Type: MATERIALIZED VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW taxonomie.vm_phylum AS
 SELECT DISTINCT tx.phylum
   FROM taxonomie.taxref tx
  WITH NO DATA;


ALTER TABLE taxonomie.vm_phylum OWNER TO geonatadmin;

--
-- Name: vm_regne; Type: MATERIALIZED VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW taxonomie.vm_regne AS
 SELECT DISTINCT tx.regne
   FROM taxonomie.taxref tx
  WITH NO DATA;


ALTER TABLE taxonomie.vm_regne OWNER TO geonatadmin;

--
-- Name: vm_taxref_hierarchie; Type: TABLE; Schema: taxonomie; Owner: geonatadmin
--

CREATE TABLE taxonomie.vm_taxref_hierarchie (
    regne character varying(20),
    phylum character varying(50),
    classe character varying(50),
    ordre character varying(50),
    famille character varying(50),
    cd_nom integer NOT NULL,
    cd_ref integer,
    lb_nom character varying(250),
    id_rang text,
    nb_tx_fm bigint,
    nb_tx_or bigint,
    nb_tx_cl bigint,
    nb_tx_ph bigint,
    nb_tx_kd bigint
);


ALTER TABLE taxonomie.vm_taxref_hierarchie OWNER TO geonatadmin;

--
-- Name: vm_taxref_list_forautocomplete; Type: MATERIALIZED VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW taxonomie.vm_taxref_list_forautocomplete AS
 SELECT row_number() OVER () AS gid,
    t.cd_nom,
    t.cd_ref,
    t.search_name,
    t.nom_valide,
    t.lb_nom,
    t.nom_vern,
    t.regne,
    t.group2_inpn
   FROM ( SELECT t_1.cd_nom,
            t_1.cd_ref,
            concat(t_1.lb_nom, ' =  <i> ', t_1.nom_valide, '</i>', ' - [', t_1.id_rang, ' - ', t_1.cd_nom, ']') AS search_name,
            t_1.nom_valide,
            t_1.lb_nom,
            t_1.nom_vern,
            t_1.regne,
            t_1.group2_inpn
           FROM taxonomie.taxref t_1
        UNION
         SELECT DISTINCT t_1.cd_nom,
            t_1.cd_ref,
            concat(split_part((t_1.nom_vern)::text, ','::text, 1), ' =  <i> ', t_1.nom_valide, '</i>', ' - [', t_1.id_rang, ' - ', t_1.cd_ref, ']') AS search_name,
            t_1.nom_valide,
            t_1.lb_nom,
            t_1.nom_vern,
            t_1.regne,
            t_1.group2_inpn
           FROM taxonomie.taxref t_1
          WHERE ((t_1.nom_vern IS NOT NULL) AND (t_1.cd_nom = t_1.cd_ref))) t
  WITH NO DATA;


ALTER TABLE taxonomie.vm_taxref_list_forautocomplete OWNER TO geonatadmin;

--
-- Name: MATERIALIZED VIEW vm_taxref_list_forautocomplete; Type: COMMENT; Schema: taxonomie; Owner: geonatadmin
--

COMMENT ON MATERIALIZED VIEW taxonomie.vm_taxref_list_forautocomplete IS 'Vue matérialisée permettant de faire des autocomplete construite à partir d''une requete sur tout taxref.';


--
-- Name: bib_organismes_id_organisme_seq; Type: SEQUENCE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE SEQUENCE utilisateurs.bib_organismes_id_organisme_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE utilisateurs.bib_organismes_id_organisme_seq OWNER TO geonatadmin;

--
-- Name: bib_organismes_id_organisme_seq; Type: SEQUENCE OWNED BY; Schema: utilisateurs; Owner: geonatadmin
--

ALTER SEQUENCE utilisateurs.bib_organismes_id_organisme_seq OWNED BY utilisateurs.bib_organismes.id_organisme;


--
-- Name: cor_profil_for_app; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.cor_profil_for_app (
    id_profil integer NOT NULL,
    id_application integer NOT NULL
);


ALTER TABLE utilisateurs.cor_profil_for_app OWNER TO geonatadmin;

--
-- Name: TABLE cor_profil_for_app; Type: COMMENT; Schema: utilisateurs; Owner: geonatadmin
--

COMMENT ON TABLE utilisateurs.cor_profil_for_app IS 'Permet d''attribuer et limiter les profils disponibles pour chacune des applications';


--
-- Name: cor_role_app_profil; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.cor_role_app_profil (
    id_role integer NOT NULL,
    id_application integer NOT NULL,
    id_profil integer NOT NULL,
    is_default_group_for_app boolean DEFAULT false NOT NULL
);


ALTER TABLE utilisateurs.cor_role_app_profil OWNER TO geonatadmin;

--
-- Name: TABLE cor_role_app_profil; Type: COMMENT; Schema: utilisateurs; Owner: geonatadmin
--

COMMENT ON TABLE utilisateurs.cor_role_app_profil IS 'Cette table centrale, permet d''associer des roles à des profils par application';


--
-- Name: cor_role_liste; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.cor_role_liste (
    id_role integer NOT NULL,
    id_liste integer NOT NULL
);


ALTER TABLE utilisateurs.cor_role_liste OWNER TO geonatadmin;

--
-- Name: TABLE cor_role_liste; Type: COMMENT; Schema: utilisateurs; Owner: geonatadmin
--

COMMENT ON TABLE utilisateurs.cor_role_liste IS 'Equivalent de l''ancienne cor_role_menu. Permet de créer des listes de roles (observateurs par ex.), sans notion de permission';


--
-- Name: cor_role_token; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.cor_role_token (
    id_role integer NOT NULL,
    token text
);


ALTER TABLE utilisateurs.cor_role_token OWNER TO geonatadmin;

--
-- Name: t_applications; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.t_applications (
    id_application integer NOT NULL,
    code_application character varying(20) NOT NULL,
    nom_application character varying(50) NOT NULL,
    desc_application text,
    id_parent integer
);


ALTER TABLE utilisateurs.t_applications OWNER TO geonatadmin;

--
-- Name: t_applications_id_application_seq; Type: SEQUENCE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE SEQUENCE utilisateurs.t_applications_id_application_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE utilisateurs.t_applications_id_application_seq OWNER TO geonatadmin;

--
-- Name: t_applications_id_application_seq; Type: SEQUENCE OWNED BY; Schema: utilisateurs; Owner: geonatadmin
--

ALTER SEQUENCE utilisateurs.t_applications_id_application_seq OWNED BY utilisateurs.t_applications.id_application;


--
-- Name: t_listes; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.t_listes (
    id_liste integer NOT NULL,
    code_liste character varying(20) NOT NULL,
    nom_liste character varying(50) NOT NULL,
    desc_liste text
);


ALTER TABLE utilisateurs.t_listes OWNER TO geonatadmin;

--
-- Name: TABLE t_listes; Type: COMMENT; Schema: utilisateurs; Owner: geonatadmin
--

COMMENT ON TABLE utilisateurs.t_listes IS 'Table des listes déroulantes des applications. Les roles (groupes ou utilisateurs) devant figurer dans une liste sont gérés dans la table cor_role_liste';


--
-- Name: t_listes_id_liste_seq; Type: SEQUENCE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE SEQUENCE utilisateurs.t_listes_id_liste_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE utilisateurs.t_listes_id_liste_seq OWNER TO geonatadmin;

--
-- Name: t_listes_id_liste_seq; Type: SEQUENCE OWNED BY; Schema: utilisateurs; Owner: geonatadmin
--

ALTER SEQUENCE utilisateurs.t_listes_id_liste_seq OWNED BY utilisateurs.t_listes.id_liste;


--
-- Name: t_profils; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.t_profils (
    id_profil integer NOT NULL,
    code_profil character varying(20),
    nom_profil character varying(255),
    desc_profil text
);


ALTER TABLE utilisateurs.t_profils OWNER TO geonatadmin;

--
-- Name: TABLE t_profils; Type: COMMENT; Schema: utilisateurs; Owner: geonatadmin
--

COMMENT ON TABLE utilisateurs.t_profils IS 'Table des profils d''utilisateurs génériques ou applicatifs, qui seront ensuite attachés à des roles et des applications';


--
-- Name: t_profils_id_profil_seq; Type: SEQUENCE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE SEQUENCE utilisateurs.t_profils_id_profil_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE utilisateurs.t_profils_id_profil_seq OWNER TO geonatadmin;

--
-- Name: t_profils_id_profil_seq; Type: SEQUENCE OWNED BY; Schema: utilisateurs; Owner: geonatadmin
--

ALTER SEQUENCE utilisateurs.t_profils_id_profil_seq OWNED BY utilisateurs.t_profils.id_profil;


--
-- Name: t_roles_id_role_seq; Type: SEQUENCE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE SEQUENCE utilisateurs.t_roles_id_role_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE utilisateurs.t_roles_id_role_seq OWNER TO geonatadmin;

--
-- Name: t_roles_id_role_seq; Type: SEQUENCE OWNED BY; Schema: utilisateurs; Owner: geonatadmin
--

ALTER SEQUENCE utilisateurs.t_roles_id_role_seq OWNED BY utilisateurs.t_roles.id_role;


--
-- Name: temp_users; Type: TABLE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TABLE utilisateurs.temp_users (
    id_temp_user integer NOT NULL,
    token_role text,
    organisme character(32),
    id_application integer NOT NULL,
    confirmation_url character varying(250),
    groupe boolean DEFAULT false NOT NULL,
    identifiant character varying(100),
    nom_role character varying(50),
    prenom_role character varying(50),
    desc_role text,
    pass_md5 text,
    password text,
    email character varying(250),
    id_organisme integer,
    remarques text,
    champs_addi jsonb,
    date_insert timestamp without time zone,
    date_update timestamp without time zone
);


ALTER TABLE utilisateurs.temp_users OWNER TO geonatadmin;

--
-- Name: temp_users_id_temp_user_seq; Type: SEQUENCE; Schema: utilisateurs; Owner: geonatadmin
--

CREATE SEQUENCE utilisateurs.temp_users_id_temp_user_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE utilisateurs.temp_users_id_temp_user_seq OWNER TO geonatadmin;

--
-- Name: temp_users_id_temp_user_seq; Type: SEQUENCE OWNED BY; Schema: utilisateurs; Owner: geonatadmin
--

ALTER SEQUENCE utilisateurs.temp_users_id_temp_user_seq OWNED BY utilisateurs.temp_users.id_temp_user;


--
-- Name: v_roleslist_forall_applications; Type: VIEW; Schema: utilisateurs; Owner: geonatadmin
--

CREATE VIEW utilisateurs.v_roleslist_forall_applications AS
 SELECT a.groupe,
    a.active,
    a.id_role,
    a.identifiant,
    a.nom_role,
    a.prenom_role,
    a.desc_role,
    a.pass,
    a.pass_plus,
    a.email,
    a.id_organisme,
    a.organisme,
    a.id_unite,
    a.remarques,
    a.date_insert,
    a.date_update,
    max(a.id_droit) AS id_droit_max,
    a.id_application
   FROM ( SELECT u.groupe,
            u.id_role,
            u.identifiant,
            u.nom_role,
            u.prenom_role,
            u.desc_role,
            u.pass,
            u.pass_plus,
            u.email,
            u.id_organisme,
            u.active,
            o.nom_organisme AS organisme,
            0 AS id_unite,
            u.remarques,
            u.date_insert,
            u.date_update,
            c.id_profil AS id_droit,
            c.id_application
           FROM ((utilisateurs.t_roles u
             JOIN utilisateurs.cor_role_app_profil c ON ((c.id_role = u.id_role)))
             JOIN utilisateurs.bib_organismes o ON ((o.id_organisme = u.id_organisme)))
        UNION
         SELECT u.groupe,
            u.id_role,
            u.identifiant,
            u.nom_role,
            u.prenom_role,
            u.desc_role,
            u.pass,
            u.pass_plus,
            u.email,
            u.id_organisme,
            u.active,
            o.nom_organisme AS organisme,
            0 AS id_unite,
            u.remarques,
            u.date_insert,
            u.date_update,
            c.id_profil AS id_droit,
            c.id_application
           FROM (((utilisateurs.t_roles u
             JOIN utilisateurs.cor_roles g ON (((g.id_role_utilisateur = u.id_role) OR (g.id_role_groupe = u.id_role))))
             JOIN utilisateurs.cor_role_app_profil c ON ((c.id_role = g.id_role_groupe)))
             LEFT JOIN utilisateurs.bib_organismes o ON ((o.id_organisme = u.id_organisme)))) a
  WHERE (a.active = true)
  GROUP BY a.groupe, a.active, a.id_role, a.identifiant, a.nom_role, a.prenom_role, a.desc_role, a.pass, a.pass_plus, a.email, a.id_organisme, a.organisme, a.id_unite, a.remarques, a.date_insert, a.date_update, a.id_application;


ALTER TABLE utilisateurs.v_roleslist_forall_applications OWNER TO geonatadmin;

--
-- Name: v_userslist_forall_applications; Type: VIEW; Schema: utilisateurs; Owner: geonatadmin
--

CREATE VIEW utilisateurs.v_userslist_forall_applications AS
 SELECT v_roleslist_forall_applications.groupe,
    v_roleslist_forall_applications.active,
    v_roleslist_forall_applications.id_role,
    v_roleslist_forall_applications.identifiant,
    v_roleslist_forall_applications.nom_role,
    v_roleslist_forall_applications.prenom_role,
    v_roleslist_forall_applications.desc_role,
    v_roleslist_forall_applications.pass,
    v_roleslist_forall_applications.pass_plus,
    v_roleslist_forall_applications.email,
    v_roleslist_forall_applications.id_organisme,
    v_roleslist_forall_applications.organisme,
    v_roleslist_forall_applications.id_unite,
    v_roleslist_forall_applications.remarques,
    v_roleslist_forall_applications.date_insert,
    v_roleslist_forall_applications.date_update,
    v_roleslist_forall_applications.id_droit_max,
    v_roleslist_forall_applications.id_application
   FROM utilisateurs.v_roleslist_forall_applications
  WHERE (v_roleslist_forall_applications.groupe = false);


ALTER TABLE utilisateurs.v_userslist_forall_applications OWNER TO geonatadmin;

--
-- Name: v_userslist_forall_menu; Type: VIEW; Schema: utilisateurs; Owner: geonatadmin
--

CREATE VIEW utilisateurs.v_userslist_forall_menu AS
 SELECT a.groupe,
    a.id_role,
    a.uuid_role,
    a.identifiant,
    a.nom_role,
    a.prenom_role,
    ((upper((a.nom_role)::text) || ' '::text) || (a.prenom_role)::text) AS nom_complet,
    a.desc_role,
    a.pass,
    a.pass_plus,
    a.email,
    a.id_organisme,
    a.organisme,
    a.id_unite,
    a.remarques,
    a.date_insert,
    a.date_update,
    a.id_menu
   FROM ( SELECT u.groupe,
            u.id_role,
            u.uuid_role,
            u.identifiant,
            u.nom_role,
            u.prenom_role,
            u.desc_role,
            u.pass,
            u.pass_plus,
            u.email,
            u.id_organisme,
            o.nom_organisme AS organisme,
            0 AS id_unite,
            u.remarques,
            u.date_insert,
            u.date_update,
            c.id_liste AS id_menu
           FROM ((utilisateurs.t_roles u
             JOIN utilisateurs.cor_role_liste c ON ((c.id_role = u.id_role)))
             LEFT JOIN utilisateurs.bib_organismes o ON ((o.id_organisme = u.id_organisme)))
          WHERE ((u.groupe = false) AND (u.active = true))
        UNION
         SELECT u.groupe,
            u.id_role,
            u.uuid_role,
            u.identifiant,
            u.nom_role,
            u.prenom_role,
            u.desc_role,
            u.pass,
            u.pass_plus,
            u.email,
            u.id_organisme,
            o.nom_organisme AS organisme,
            0 AS id_unite,
            u.remarques,
            u.date_insert,
            u.date_update,
            c.id_liste AS id_menu
           FROM (((utilisateurs.t_roles u
             JOIN utilisateurs.cor_roles g ON ((g.id_role_utilisateur = u.id_role)))
             JOIN utilisateurs.cor_role_liste c ON ((c.id_role = g.id_role_groupe)))
             LEFT JOIN utilisateurs.bib_organismes o ON ((o.id_organisme = u.id_organisme)))
          WHERE ((u.groupe = false) AND (u.active = true))) a;


ALTER TABLE utilisateurs.v_userslist_forall_menu OWNER TO geonatadmin;

--
-- Name: bib_tables_location id_table_location; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.bib_tables_location ALTER COLUMN id_table_location SET DEFAULT nextval('gn_commons.bib_tables_location_id_table_location_seq'::regclass);


--
-- Name: bib_widgets id_widget; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.bib_widgets ALTER COLUMN id_widget SET DEFAULT nextval('gn_commons.bib_widgets_id_widget_seq'::regclass);


--
-- Name: t_additional_fields id_field; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_additional_fields ALTER COLUMN id_field SET DEFAULT nextval('gn_commons.t_additional_fields_id_field_seq'::regclass);


--
-- Name: t_history_actions id_history_action; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_history_actions ALTER COLUMN id_history_action SET DEFAULT nextval('gn_commons.t_history_actions_id_history_action_seq'::regclass);


--
-- Name: t_medias id_media; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_medias ALTER COLUMN id_media SET DEFAULT nextval('gn_commons.t_medias_id_media_seq'::regclass);


--
-- Name: t_mobile_apps id_mobile_app; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_mobile_apps ALTER COLUMN id_mobile_app SET DEFAULT nextval('gn_commons.t_mobile_apps_id_mobile_app_seq'::regclass);


--
-- Name: t_modules id_module; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_modules ALTER COLUMN id_module SET DEFAULT nextval('gn_commons.t_modules_id_module_seq'::regclass);


--
-- Name: t_parameters id_parameter; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_parameters ALTER COLUMN id_parameter SET DEFAULT nextval('gn_commons.t_parameters_id_parameter_seq'::regclass);


--
-- Name: t_places id_place; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_places ALTER COLUMN id_place SET DEFAULT nextval('gn_commons.t_places_id_place_seq'::regclass);


--
-- Name: t_validations id_validation; Type: DEFAULT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_validations ALTER COLUMN id_validation SET DEFAULT nextval('gn_commons.t_validations_id_validation_seq'::regclass);


--
-- Name: matching_fields id_matching_field; Type: DEFAULT; Schema: gn_imports; Owner: geonatadmin
--

ALTER TABLE ONLY gn_imports.matching_fields ALTER COLUMN id_matching_field SET DEFAULT nextval('gn_imports.matching_fields_id_matching_field_seq'::regclass);


--
-- Name: matching_geoms id_matching_geom; Type: DEFAULT; Schema: gn_imports; Owner: geonatadmin
--

ALTER TABLE ONLY gn_imports.matching_geoms ALTER COLUMN id_matching_geom SET DEFAULT nextval('gn_imports.matching_geoms_id_matching_geom_seq'::regclass);


--
-- Name: matching_tables id_matching_table; Type: DEFAULT; Schema: gn_imports; Owner: geonatadmin
--

ALTER TABLE ONLY gn_imports.matching_tables ALTER COLUMN id_matching_table SET DEFAULT nextval('gn_imports.matching_tables_id_matching_table_seq'::regclass);


--
-- Name: cor_acquisition_framework_actor id_cafa; Type: DEFAULT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor ALTER COLUMN id_cafa SET DEFAULT nextval('gn_meta.cor_acquisition_framework_actor_id_cafa_seq'::regclass);


--
-- Name: cor_dataset_actor id_cda; Type: DEFAULT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_actor ALTER COLUMN id_cda SET DEFAULT nextval('gn_meta.cor_dataset_actor_id_cda_seq'::regclass);


--
-- Name: sinp_datatype_protocols id_protocol; Type: DEFAULT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.sinp_datatype_protocols ALTER COLUMN id_protocol SET DEFAULT nextval('gn_meta.sinp_datatype_protocols_id_protocol_seq'::regclass);


--
-- Name: sinp_datatype_publications id_publication; Type: DEFAULT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.sinp_datatype_publications ALTER COLUMN id_publication SET DEFAULT nextval('gn_meta.sinp_datatype_publications_id_publication_seq'::regclass);


--
-- Name: t_acquisition_frameworks id_acquisition_framework; Type: DEFAULT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_acquisition_frameworks ALTER COLUMN id_acquisition_framework SET DEFAULT nextval('gn_meta.t_acquisition_frameworks_id_acquisition_framework_seq'::regclass);


--
-- Name: t_datasets id_dataset; Type: DEFAULT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets ALTER COLUMN id_dataset SET DEFAULT nextval('gn_meta.t_datasets_id_dataset_seq'::regclass);


--
-- Name: t_base_sites id_base_site; Type: DEFAULT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_sites ALTER COLUMN id_base_site SET DEFAULT nextval('gn_monitoring.t_base_sites_id_base_site_seq'::regclass);


--
-- Name: t_base_visits id_base_visit; Type: DEFAULT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_visits ALTER COLUMN id_base_visit SET DEFAULT nextval('gn_monitoring.t_base_visits_id_base_visit_seq'::regclass);


--
-- Name: bib_filters_type id_filter_type; Type: DEFAULT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.bib_filters_type ALTER COLUMN id_filter_type SET DEFAULT nextval('gn_permissions.bib_filters_type_id_filter_type_seq'::regclass);


--
-- Name: cor_object_module id_cor_object_module; Type: DEFAULT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_object_module ALTER COLUMN id_cor_object_module SET DEFAULT nextval('gn_permissions.cor_object_module_id_cor_object_module_seq'::regclass);


--
-- Name: cor_role_action_filter_module_object id_permission; Type: DEFAULT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_role_action_filter_module_object ALTER COLUMN id_permission SET DEFAULT nextval('gn_permissions.cor_role_action_filter_module_object_id_permission_seq'::regclass);


--
-- Name: t_actions id_action; Type: DEFAULT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.t_actions ALTER COLUMN id_action SET DEFAULT nextval('gn_permissions.t_actions_id_action_seq'::regclass);


--
-- Name: t_filters id_filter; Type: DEFAULT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.t_filters ALTER COLUMN id_filter SET DEFAULT nextval('gn_permissions.t_filters_id_filter_seq'::regclass);


--
-- Name: t_objects id_object; Type: DEFAULT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.t_objects ALTER COLUMN id_object SET DEFAULT nextval('gn_permissions.t_objects_id_object_seq'::regclass);


--
-- Name: t_sensitivity_rules id_sensitivity; Type: DEFAULT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.t_sensitivity_rules ALTER COLUMN id_sensitivity SET DEFAULT nextval('gn_sensitivity.t_sensitivity_rules_id_sensitivity_seq'::regclass);


--
-- Name: synthese id_synthese; Type: DEFAULT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese ALTER COLUMN id_synthese SET DEFAULT nextval('gn_synthese.synthese_id_synthese_seq'::regclass);


--
-- Name: t_sources id_source; Type: DEFAULT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.t_sources ALTER COLUMN id_source SET DEFAULT nextval('gn_synthese.t_sources_id_source_seq'::regclass);


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
-- Name: bib_list_habitat id_list; Type: DEFAULT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.bib_list_habitat ALTER COLUMN id_list SET DEFAULT nextval('ref_habitats.bib_list_habitat_id_list_seq'::regclass);


--
-- Name: cor_list_habitat id_cor_list; Type: DEFAULT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_list_habitat ALTER COLUMN id_cor_list SET DEFAULT nextval('ref_habitats.cor_list_habitat_id_cor_list_seq'::regclass);


--
-- Name: typoref cd_typo; Type: DEFAULT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.typoref ALTER COLUMN cd_typo SET DEFAULT nextval('ref_habitats.typoref_cd_typo_seq'::regclass);


--
-- Name: bib_nomenclatures_types id_type; Type: DEFAULT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.bib_nomenclatures_types ALTER COLUMN id_type SET DEFAULT nextval('ref_nomenclatures.bib_nomenclatures_types_id_type_seq'::regclass);


--
-- Name: t_nomenclatures id_nomenclature; Type: DEFAULT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.t_nomenclatures ALTER COLUMN id_nomenclature SET DEFAULT nextval('ref_nomenclatures.t_nomenclatures_id_nomenclature_seq'::regclass);


--
-- Name: bdc_statut id; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut ALTER COLUMN id SET DEFAULT nextval('taxonomie.bdc_statut_id_seq'::regclass);


--
-- Name: bdc_statut_cor_text_values id_value_text; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_cor_text_values ALTER COLUMN id_value_text SET DEFAULT nextval('taxonomie.bdc_statut_cor_text_values_id_value_text_seq'::regclass);


--
-- Name: bdc_statut_text id_text; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_text ALTER COLUMN id_text SET DEFAULT nextval('taxonomie.bdc_statut_text_id_text_seq'::regclass);


--
-- Name: bdc_statut_values id_value; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_values ALTER COLUMN id_value SET DEFAULT nextval('taxonomie.bdc_statut_values_id_value_seq'::regclass);


--
-- Name: bib_noms id_nom; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_noms ALTER COLUMN id_nom SET DEFAULT nextval('taxonomie.bib_noms_id_nom_seq'::regclass);


--
-- Name: bib_themes id_theme; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_themes ALTER COLUMN id_theme SET DEFAULT nextval('taxonomie.bib_themes_id_theme_seq'::regclass);


--
-- Name: t_medias id_media; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.t_medias ALTER COLUMN id_media SET DEFAULT nextval('taxonomie.t_medias_id_media_seq'::regclass);


--
-- Name: taxhub_admin_log id; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxhub_admin_log ALTER COLUMN id SET DEFAULT nextval('taxonomie.taxhub_admin_log_id_seq'::regclass);


--
-- Name: taxref_liste_rouge_fr id_lr; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_liste_rouge_fr ALTER COLUMN id_lr SET DEFAULT nextval('taxonomie.taxref_liste_rouge_fr_id_lr_seq'::regclass);


--
-- Name: bib_organismes id_organisme; Type: DEFAULT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.bib_organismes ALTER COLUMN id_organisme SET DEFAULT nextval('utilisateurs.bib_organismes_id_organisme_seq'::regclass);


--
-- Name: t_applications id_application; Type: DEFAULT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_applications ALTER COLUMN id_application SET DEFAULT nextval('utilisateurs.t_applications_id_application_seq'::regclass);


--
-- Name: t_listes id_liste; Type: DEFAULT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_listes ALTER COLUMN id_liste SET DEFAULT nextval('utilisateurs.t_listes_id_liste_seq'::regclass);


--
-- Name: t_profils id_profil; Type: DEFAULT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_profils ALTER COLUMN id_profil SET DEFAULT nextval('utilisateurs.t_profils_id_profil_seq'::regclass);


--
-- Name: t_roles id_role; Type: DEFAULT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_roles ALTER COLUMN id_role SET DEFAULT nextval('utilisateurs.t_roles_id_role_seq'::regclass);


--
-- Name: temp_users id_temp_user; Type: DEFAULT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.temp_users ALTER COLUMN id_temp_user SET DEFAULT nextval('utilisateurs.temp_users_id_temp_user_seq'::regclass);


--
-- Name: t_medias check_t_medias_media_type; Type: CHECK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE gn_commons.t_medias
    ADD CONSTRAINT check_t_medias_media_type CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_media_type, 'TYPE_MEDIA'::character varying)) NOT VALID;


--
-- Name: t_validations check_t_validations_valid_status; Type: CHECK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE gn_commons.t_validations
    ADD CONSTRAINT check_t_validations_valid_status CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_valid_status, 'STATUT_VALID'::character varying)) NOT VALID;


--
-- Name: bib_tables_location pk_bib_tables_location; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.bib_tables_location
    ADD CONSTRAINT pk_bib_tables_location PRIMARY KEY (id_table_location);


--
-- Name: bib_widgets pk_bib_widgets; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.bib_widgets
    ADD CONSTRAINT pk_bib_widgets PRIMARY KEY (id_widget);


--
-- Name: cor_field_dataset pk_cor_field_dataset; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_dataset
    ADD CONSTRAINT pk_cor_field_dataset PRIMARY KEY (id_field, id_dataset);


--
-- Name: cor_field_module pk_cor_field_module; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_module
    ADD CONSTRAINT pk_cor_field_module PRIMARY KEY (id_field, id_module);


--
-- Name: cor_field_object pk_cor_field_object; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_object
    ADD CONSTRAINT pk_cor_field_object PRIMARY KEY (id_field, id_object);


--
-- Name: cor_module_dataset pk_cor_module_dataset; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_module_dataset
    ADD CONSTRAINT pk_cor_module_dataset PRIMARY KEY (id_module, id_dataset);


--
-- Name: t_additional_fields pk_t_additional_fields; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_additional_fields
    ADD CONSTRAINT pk_t_additional_fields PRIMARY KEY (id_field);


--
-- Name: t_history_actions pk_t_history_actions; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_history_actions
    ADD CONSTRAINT pk_t_history_actions PRIMARY KEY (id_history_action);


--
-- Name: t_medias pk_t_medias; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_medias
    ADD CONSTRAINT pk_t_medias PRIMARY KEY (id_media);


--
-- Name: t_modules pk_t_modules; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_modules
    ADD CONSTRAINT pk_t_modules PRIMARY KEY (id_module);


--
-- Name: t_mobile_apps pk_t_moobile_apps; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_mobile_apps
    ADD CONSTRAINT pk_t_moobile_apps PRIMARY KEY (id_mobile_app);


--
-- Name: t_parameters pk_t_parameters; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_parameters
    ADD CONSTRAINT pk_t_parameters PRIMARY KEY (id_parameter);


--
-- Name: t_places pk_t_places; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_places
    ADD CONSTRAINT pk_t_places PRIMARY KEY (id_place);


--
-- Name: t_validations pk_t_validations; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_validations
    ADD CONSTRAINT pk_t_validations PRIMARY KEY (id_validation);


--
-- Name: bib_tables_location unique_bib_tables_location_schema_name_table_name; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.bib_tables_location
    ADD CONSTRAINT unique_bib_tables_location_schema_name_table_name UNIQUE (schema_name, table_name);


--
-- Name: t_mobile_apps unique_t_mobile_apps_app_code; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_mobile_apps
    ADD CONSTRAINT unique_t_mobile_apps_app_code UNIQUE (app_code);


--
-- Name: t_modules unique_t_modules_module_code; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_modules
    ADD CONSTRAINT unique_t_modules_module_code UNIQUE (module_code);


--
-- Name: t_modules unique_t_modules_module_path; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_modules
    ADD CONSTRAINT unique_t_modules_module_path UNIQUE (module_path);


--
-- Name: t_parameters unique_t_parameters_id_organism_parameter_name; Type: CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_parameters
    ADD CONSTRAINT unique_t_parameters_id_organism_parameter_name UNIQUE (id_organism, parameter_name);


--
-- Name: matching_fields pk_matching_fields; Type: CONSTRAINT; Schema: gn_imports; Owner: geonatadmin
--

ALTER TABLE ONLY gn_imports.matching_fields
    ADD CONSTRAINT pk_matching_fields PRIMARY KEY (id_matching_field);


--
-- Name: matching_geoms pk_matching_synthese; Type: CONSTRAINT; Schema: gn_imports; Owner: geonatadmin
--

ALTER TABLE ONLY gn_imports.matching_geoms
    ADD CONSTRAINT pk_matching_synthese PRIMARY KEY (id_matching_geom);


--
-- Name: matching_tables pk_matching_tables; Type: CONSTRAINT; Schema: gn_imports; Owner: geonatadmin
--

ALTER TABLE ONLY gn_imports.matching_tables
    ADD CONSTRAINT pk_matching_tables PRIMARY KEY (id_matching_table);


--
-- Name: cor_acquisition_framework_actor check_cor_acquisition_framework_actor; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT check_cor_acquisition_framework_actor CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_actor_role, 'ROLE_ACTEUR'::character varying)) NOT VALID;


--
-- Name: cor_acquisition_framework_objectif check_cor_acquisition_framework_objectif; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.cor_acquisition_framework_objectif
    ADD CONSTRAINT check_cor_acquisition_framework_objectif CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_objectif, 'CA_OBJECTIFS'::character varying)) NOT VALID;


--
-- Name: cor_acquisition_framework_voletsinp check_cor_acquisition_framework_voletsinp; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.cor_acquisition_framework_voletsinp
    ADD CONSTRAINT check_cor_acquisition_framework_voletsinp CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_voletsinp, 'VOLET_SINP'::character varying)) NOT VALID;


--
-- Name: cor_acquisition_framework_territory check_cor_af_territory; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.cor_acquisition_framework_territory
    ADD CONSTRAINT check_cor_af_territory CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_territory, 'TERRITOIRE'::character varying)) NOT VALID;


--
-- Name: cor_dataset_actor check_cor_dataset_actor; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.cor_dataset_actor
    ADD CONSTRAINT check_cor_dataset_actor CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_actor_role, 'ROLE_ACTEUR'::character varying)) NOT VALID;


--
-- Name: cor_dataset_territory check_cor_dataset_territory; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.cor_dataset_territory
    ADD CONSTRAINT check_cor_dataset_territory CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_territory, 'TERRITOIRE'::character varying)) NOT VALID;


--
-- Name: cor_acquisition_framework_actor check_is_unique_cor_acquisition_framework_actor_organism; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT check_is_unique_cor_acquisition_framework_actor_organism UNIQUE (id_acquisition_framework, id_organism, id_nomenclature_actor_role);


--
-- Name: cor_acquisition_framework_actor check_is_unique_cor_acquisition_framework_actor_role; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT check_is_unique_cor_acquisition_framework_actor_role UNIQUE (id_acquisition_framework, id_role, id_nomenclature_actor_role);


--
-- Name: cor_dataset_actor check_is_unique_cor_dataset_actor_organism; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_actor
    ADD CONSTRAINT check_is_unique_cor_dataset_actor_organism UNIQUE (id_dataset, id_organism, id_nomenclature_actor_role);


--
-- Name: cor_dataset_actor check_is_unique_cor_dataset_actor_role; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_actor
    ADD CONSTRAINT check_is_unique_cor_dataset_actor_role UNIQUE (id_dataset, id_role, id_nomenclature_actor_role);


--
-- Name: sinp_datatype_protocols check_sinp_datatype_protocol_type; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.sinp_datatype_protocols
    ADD CONSTRAINT check_sinp_datatype_protocol_type CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_protocol_type, 'TYPE_PROTOCOLE'::character varying)) NOT VALID;


--
-- Name: t_acquisition_frameworks check_t_acquisition_financing_type; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.t_acquisition_frameworks
    ADD CONSTRAINT check_t_acquisition_financing_type CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_financing_type, 'TYPE_FINANCEMENT'::character varying)) NOT VALID;


--
-- Name: t_acquisition_frameworks check_t_acquisition_frameworks_territorial_level; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.t_acquisition_frameworks
    ADD CONSTRAINT check_t_acquisition_frameworks_territorial_level CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_territorial_level, 'NIVEAU_TERRITORIAL'::character varying)) NOT VALID;


--
-- Name: t_datasets check_t_datasets_collecting_method; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.t_datasets
    ADD CONSTRAINT check_t_datasets_collecting_method CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_collecting_method, 'METHO_RECUEIL'::character varying)) NOT VALID;


--
-- Name: t_datasets check_t_datasets_data_origin; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.t_datasets
    ADD CONSTRAINT check_t_datasets_data_origin CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_data_origin, 'DS_PUBLIQUE'::character varying)) NOT VALID;


--
-- Name: t_datasets check_t_datasets_data_type; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.t_datasets
    ADD CONSTRAINT check_t_datasets_data_type CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_data_type, 'DATA_TYP'::character varying)) NOT VALID;


--
-- Name: t_datasets check_t_datasets_objectif; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.t_datasets
    ADD CONSTRAINT check_t_datasets_objectif CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_dataset_objectif, 'JDD_OBJECTIFS'::character varying)) NOT VALID;


--
-- Name: t_datasets check_t_datasets_resource_type; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.t_datasets
    ADD CONSTRAINT check_t_datasets_resource_type CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_resource_type, 'RESOURCE_TYP'::character varying)) NOT VALID;


--
-- Name: t_datasets check_t_datasets_source_status; Type: CHECK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE gn_meta.t_datasets
    ADD CONSTRAINT check_t_datasets_source_status CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_source_status, 'STATUT_SOURCE'::character varying)) NOT VALID;


--
-- Name: cor_acquisition_framework_actor pk_cor_acquisition_framework_actor; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT pk_cor_acquisition_framework_actor PRIMARY KEY (id_cafa);


--
-- Name: cor_acquisition_framework_objectif pk_cor_acquisition_framework_objectif; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_objectif
    ADD CONSTRAINT pk_cor_acquisition_framework_objectif PRIMARY KEY (id_acquisition_framework, id_nomenclature_objectif);


--
-- Name: cor_acquisition_framework_publication pk_cor_acquisition_framework_publication; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_publication
    ADD CONSTRAINT pk_cor_acquisition_framework_publication PRIMARY KEY (id_acquisition_framework, id_publication);


--
-- Name: cor_acquisition_framework_territory pk_cor_acquisition_framework_territory; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_territory
    ADD CONSTRAINT pk_cor_acquisition_framework_territory PRIMARY KEY (id_acquisition_framework, id_nomenclature_territory);


--
-- Name: cor_acquisition_framework_voletsinp pk_cor_acquisition_framework_voletsinp; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_voletsinp
    ADD CONSTRAINT pk_cor_acquisition_framework_voletsinp PRIMARY KEY (id_acquisition_framework, id_nomenclature_voletsinp);


--
-- Name: cor_dataset_actor pk_cor_dataset_actor; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_actor
    ADD CONSTRAINT pk_cor_dataset_actor PRIMARY KEY (id_cda);


--
-- Name: cor_dataset_protocol pk_cor_dataset_protocol; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_protocol
    ADD CONSTRAINT pk_cor_dataset_protocol PRIMARY KEY (id_dataset, id_protocol);


--
-- Name: cor_dataset_territory pk_cor_dataset_territory; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_territory
    ADD CONSTRAINT pk_cor_dataset_territory PRIMARY KEY (id_dataset, id_nomenclature_territory);


--
-- Name: sinp_datatype_protocols pk_sinp_datatype_protocols; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.sinp_datatype_protocols
    ADD CONSTRAINT pk_sinp_datatype_protocols PRIMARY KEY (id_protocol);


--
-- Name: sinp_datatype_publications pk_sinp_datatype_publications; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.sinp_datatype_publications
    ADD CONSTRAINT pk_sinp_datatype_publications PRIMARY KEY (id_publication);


--
-- Name: t_acquisition_frameworks pk_t_acquisition_frameworks; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_acquisition_frameworks
    ADD CONSTRAINT pk_t_acquisition_frameworks PRIMARY KEY (id_acquisition_framework);


--
-- Name: t_datasets pk_t_datasets; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT pk_t_datasets PRIMARY KEY (id_dataset);


--
-- Name: t_bibliographical_references t_bibliographical_references_pkey; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_bibliographical_references
    ADD CONSTRAINT t_bibliographical_references_pkey PRIMARY KEY (id_bibliographic_reference);


--
-- Name: t_acquisition_frameworks unique_acquisition_frameworks_uuid; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_acquisition_frameworks
    ADD CONSTRAINT unique_acquisition_frameworks_uuid UNIQUE (unique_acquisition_framework_id);


--
-- Name: t_datasets unique_dataset_uuid; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT unique_dataset_uuid UNIQUE (unique_dataset_id);


--
-- Name: sinp_datatype_protocols unique_sinp_datatype_protocols_uuid; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.sinp_datatype_protocols
    ADD CONSTRAINT unique_sinp_datatype_protocols_uuid UNIQUE (unique_protocol_id);


--
-- Name: sinp_datatype_publications unique_sinp_datatype_publications_uuid; Type: CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.sinp_datatype_publications
    ADD CONSTRAINT unique_sinp_datatype_publications_uuid UNIQUE (unique_publication_id);


--
-- Name: t_base_sites check_t_base_sites_type_site; Type: CHECK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE gn_monitoring.t_base_sites
    ADD CONSTRAINT check_t_base_sites_type_site CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_type_site, 'TYPE_SITE'::character varying)) NOT VALID;


--
-- Name: t_base_visits check_t_base_visits_id_nomenclature_grp_typ; Type: CHECK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE gn_monitoring.t_base_visits
    ADD CONSTRAINT check_t_base_visits_id_nomenclature_grp_typ CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_grp_typ, 'TYP_GRP'::character varying)) NOT VALID;


--
-- Name: t_base_visits check_t_base_visits_id_nomenclature_tech_collect_campanule; Type: CHECK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE gn_monitoring.t_base_visits
    ADD CONSTRAINT check_t_base_visits_id_nomenclature_tech_collect_campanule CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_tech_collect_campanule, 'TECHNIQUE_OBS'::character varying)) NOT VALID;


--
-- Name: cor_site_area pk_cor_site_area; Type: CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_site_area
    ADD CONSTRAINT pk_cor_site_area PRIMARY KEY (id_base_site, id_area);


--
-- Name: cor_site_module pk_cor_site_module; Type: CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_site_module
    ADD CONSTRAINT pk_cor_site_module PRIMARY KEY (id_base_site, id_module);


--
-- Name: cor_visit_observer pk_cor_visit_observer; Type: CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_visit_observer
    ADD CONSTRAINT pk_cor_visit_observer PRIMARY KEY (id_base_visit, id_role);


--
-- Name: t_base_sites pk_t_base_sites; Type: CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_sites
    ADD CONSTRAINT pk_t_base_sites PRIMARY KEY (id_base_site);


--
-- Name: t_base_visits pk_t_base_visits; Type: CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_visits
    ADD CONSTRAINT pk_t_base_visits PRIMARY KEY (id_base_visit);


--
-- Name: bib_filters_type pk_bib_filters_type; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.bib_filters_type
    ADD CONSTRAINT pk_bib_filters_type PRIMARY KEY (id_filter_type);


--
-- Name: cor_filter_type_module pk_cor_filter_module; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_filter_type_module
    ADD CONSTRAINT pk_cor_filter_module PRIMARY KEY (id_filter_type, id_module);


--
-- Name: cor_object_module pk_cor_object_module; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_object_module
    ADD CONSTRAINT pk_cor_object_module PRIMARY KEY (id_cor_object_module);


--
-- Name: cor_role_action_filter_module_object pk_cor_r_a_f_m_o; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_role_action_filter_module_object
    ADD CONSTRAINT pk_cor_r_a_f_m_o PRIMARY KEY (id_permission);


--
-- Name: t_actions pk_t_actions; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.t_actions
    ADD CONSTRAINT pk_t_actions PRIMARY KEY (id_action);


--
-- Name: t_filters pk_t_filters; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.t_filters
    ADD CONSTRAINT pk_t_filters PRIMARY KEY (id_filter);


--
-- Name: t_objects pk_t_objects; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.t_objects
    ADD CONSTRAINT pk_t_objects PRIMARY KEY (id_object);


--
-- Name: cor_object_module unique_cor_object_module; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_object_module
    ADD CONSTRAINT unique_cor_object_module UNIQUE (id_object, id_module);


--
-- Name: t_objects unique_t_objects; Type: CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.t_objects
    ADD CONSTRAINT unique_t_objects UNIQUE (code_object);


--
-- Name: cor_sensitivity_synthese check_synthese_sensitivity; Type: CHECK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE gn_sensitivity.cor_sensitivity_synthese
    ADD CONSTRAINT check_synthese_sensitivity CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_sensitivity, 'SENSIBILITE'::character varying)) NOT VALID;


--
-- Name: t_sensitivity_rules check_t_sensitivity_rules_niv_precis; Type: CHECK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE gn_sensitivity.t_sensitivity_rules
    ADD CONSTRAINT check_t_sensitivity_rules_niv_precis CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_sensitivity, 'SENSIBILITE'::character varying)) NOT VALID;


--
-- Name: cor_sensitivity_synthese cor_sensitivity_synthese_pk; Type: CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_synthese
    ADD CONSTRAINT cor_sensitivity_synthese_pk PRIMARY KEY (uuid_attached_row, id_nomenclature_sensitivity);


--
-- Name: t_sensitivity_rules t_sensitivity_rules_pkey; Type: CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.t_sensitivity_rules
    ADD CONSTRAINT t_sensitivity_rules_pkey PRIMARY KEY (id_sensitivity);


--
-- Name: defaults_nomenclatures_value check_gn_synthese_defaults_nomenclatures_value_is_nomenclature_; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.defaults_nomenclatures_value
    ADD CONSTRAINT check_gn_synthese_defaults_nomenclatures_value_is_nomenclature_ CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature, mnemonique_type)) NOT VALID;


--
-- Name: defaults_nomenclatures_value check_gn_synthese_defaults_nomenclatures_value_isgroup2inpn; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.defaults_nomenclatures_value
    ADD CONSTRAINT check_gn_synthese_defaults_nomenclatures_value_isgroup2inpn CHECK ((taxonomie.check_is_group2inpn((group2_inpn)::text) OR ((group2_inpn)::text = '0'::text))) NOT VALID;


--
-- Name: defaults_nomenclatures_value check_gn_synthese_defaults_nomenclatures_value_isregne; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.defaults_nomenclatures_value
    ADD CONSTRAINT check_gn_synthese_defaults_nomenclatures_value_isregne CHECK ((taxonomie.check_is_regne((regne)::text) OR ((regne)::text = '0'::text))) NOT VALID;


--
-- Name: synthese check_synthese_bio_condition; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_bio_condition CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_bio_condition, 'ETA_BIO'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_bio_status; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_bio_status CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_bio_status, 'STATUT_BIO'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_biogeo_status; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_biogeo_status CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_biogeo_status, 'STAT_BIOGEO'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_blurring; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_blurring CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_blurring, 'DEE_FLOU'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_diffusion_level; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_diffusion_level CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_diffusion_level, 'NIV_PRECIS'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_exist_proof; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_exist_proof CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_exist_proof, 'PREUVE_EXIST'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_geo_object_nature; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_geo_object_nature CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_geo_object_nature, 'NAT_OBJ_GEO'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_info_geo_type_id_area_attachment; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_info_geo_type_id_area_attachment CHECK ((NOT (((ref_nomenclatures.get_cd_nomenclature(id_nomenclature_info_geo_type))::text = '2'::text) AND (id_area_attachment IS NULL)))) NOT VALID;


--
-- Name: synthese check_synthese_life_stage; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_life_stage CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_life_stage, 'STADE_VIE'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_naturalness; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_naturalness CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_naturalness, 'NATURALITE'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_obj_count; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_obj_count CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_obj_count, 'OBJ_DENBR'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_obs_meth; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_obs_meth CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_obs_technique, 'METH_OBS'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_observation_status; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_observation_status CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_observation_status, 'STATUT_OBS'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_sensitivity; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_sensitivity CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_sensitivity, 'SENSIBILITE'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_sex; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_sex CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_sex, 'SEXE'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_source_status; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_source_status CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_source_status, 'STATUT_SOURCE'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_typ_grp; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_typ_grp CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_grp_typ, 'TYP_GRP'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_type_count; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_type_count CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_type_count, 'TYP_DENBR'::character varying)) NOT VALID;


--
-- Name: synthese check_synthese_valid_status; Type: CHECK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE gn_synthese.synthese
    ADD CONSTRAINT check_synthese_valid_status CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_valid_status, 'STATUT_VALID'::character varying)) NOT VALID;


--
-- Name: cor_area_synthese pk_cor_area_synthese; Type: CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.cor_area_synthese
    ADD CONSTRAINT pk_cor_area_synthese PRIMARY KEY (id_synthese, id_area);


--
-- Name: cor_observer_synthese pk_cor_observer_synthese; Type: CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.cor_observer_synthese
    ADD CONSTRAINT pk_cor_observer_synthese PRIMARY KEY (id_synthese, id_role);


--
-- Name: defaults_nomenclatures_value pk_gn_synthese_defaults_nomenclatures_value; Type: CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.defaults_nomenclatures_value
    ADD CONSTRAINT pk_gn_synthese_defaults_nomenclatures_value PRIMARY KEY (mnemonique_type, id_organism, regne, group2_inpn);


--
-- Name: synthese pk_synthese; Type: CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT pk_synthese PRIMARY KEY (id_synthese);


--
-- Name: t_sources pk_t_sources; Type: CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.t_sources
    ADD CONSTRAINT pk_t_sources PRIMARY KEY (id_source);


--
-- Name: synthese unique_id_sinp_unique; Type: CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT unique_id_sinp_unique UNIQUE (unique_id_sinp);


--
-- Name: t_sources unique_name_source; Type: CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.t_sources
    ADD CONSTRAINT unique_name_source UNIQUE (name_source);


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
-- Name: autocomplete_habitat pk_autocomplete_habitat; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.autocomplete_habitat
    ADD CONSTRAINT pk_autocomplete_habitat PRIMARY KEY (cd_hab);


--
-- Name: bib_habref_statuts pk_bib_habref_statuts; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.bib_habref_statuts
    ADD CONSTRAINT pk_bib_habref_statuts PRIMARY KEY (statut);


--
-- Name: bib_habref_typo_rel pk_bib_habref_typo_rel; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.bib_habref_typo_rel
    ADD CONSTRAINT pk_bib_habref_typo_rel PRIMARY KEY (cd_type_rel);


--
-- Name: bib_list_habitat pk_bib_list_habitat; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.bib_list_habitat
    ADD CONSTRAINT pk_bib_list_habitat PRIMARY KEY (id_list);


--
-- Name: cor_hab_source pk_cor_hab_source; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_hab_source
    ADD CONSTRAINT pk_cor_hab_source PRIMARY KEY (cd_hab_lien_source);


--
-- Name: cor_habref_description pk_cor_habref_description; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_habref_description
    ADD CONSTRAINT pk_cor_habref_description PRIMARY KEY (cd_hab_description);


--
-- Name: cor_habref_terr_statut pk_cor_habref_terr_statut; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_habref_terr_statut
    ADD CONSTRAINT pk_cor_habref_terr_statut PRIMARY KEY (cd_hab_ter);


--
-- Name: cor_list_habitat pk_cor_list_habitat; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_list_habitat
    ADD CONSTRAINT pk_cor_list_habitat PRIMARY KEY (id_cor_list);


--
-- Name: habref pk_habref; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref
    ADD CONSTRAINT pk_habref PRIMARY KEY (cd_hab);


--
-- Name: habref_corresp_hab pk_habref_corresp_hab; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref_corresp_hab
    ADD CONSTRAINT pk_habref_corresp_hab PRIMARY KEY (cd_corresp_hab);


--
-- Name: habref_corresp_taxon pk_habref_corresp_taxon; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref_corresp_taxon
    ADD CONSTRAINT pk_habref_corresp_taxon PRIMARY KEY (cd_corresp_tax);


--
-- Name: habref_sources pk_habref_sources; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref_sources
    ADD CONSTRAINT pk_habref_sources PRIMARY KEY (cd_source);


--
-- Name: typoref pk_typoref; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.typoref
    ADD CONSTRAINT pk_typoref PRIMARY KEY (cd_typo);


--
-- Name: typoref_fields pk_typoref_fields; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.typoref_fields
    ADD CONSTRAINT pk_typoref_fields PRIMARY KEY (cd_hab_field);


--
-- Name: cor_list_habitat unique_cor_list_habitat; Type: CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_list_habitat
    ADD CONSTRAINT unique_cor_list_habitat UNIQUE (id_list, cd_hab);


--
-- Name: cor_taxref_nomenclature check_cor_taxref_nomenclature_isgroup2inpn; Type: CHECK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ref_nomenclatures.cor_taxref_nomenclature
    ADD CONSTRAINT check_cor_taxref_nomenclature_isgroup2inpn CHECK ((taxonomie.check_is_group2inpn((group2_inpn)::text) OR ((group2_inpn)::text = 'all'::text))) NOT VALID;


--
-- Name: cor_taxref_nomenclature check_cor_taxref_nomenclature_isregne; Type: CHECK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ref_nomenclatures.cor_taxref_nomenclature
    ADD CONSTRAINT check_cor_taxref_nomenclature_isregne CHECK ((taxonomie.check_is_regne((regne)::text) OR ((regne)::text = 'all'::text))) NOT VALID;


--
-- Name: defaults_nomenclatures_value check_defaults_nomenclatures_value_is_nomenclature_in_type; Type: CHECK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ref_nomenclatures.defaults_nomenclatures_value
    ADD CONSTRAINT check_defaults_nomenclatures_value_is_nomenclature_in_type CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature, mnemonique_type)) NOT VALID;


--
-- Name: bib_nomenclatures_types pk_bib_nomenclatures_types; Type: CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.bib_nomenclatures_types
    ADD CONSTRAINT pk_bib_nomenclatures_types PRIMARY KEY (id_type);


--
-- Name: cor_application_nomenclature pk_cor_application_nomenclature; Type: CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.cor_application_nomenclature
    ADD CONSTRAINT pk_cor_application_nomenclature PRIMARY KEY (id_nomenclature, id_application);


--
-- Name: cor_nomenclatures_relations pk_cor_nomenclatures_relations; Type: CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.cor_nomenclatures_relations
    ADD CONSTRAINT pk_cor_nomenclatures_relations PRIMARY KEY (id_nomenclature_l, id_nomenclature_r, relation_type);


--
-- Name: cor_taxref_nomenclature pk_cor_taxref_nomenclature; Type: CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.cor_taxref_nomenclature
    ADD CONSTRAINT pk_cor_taxref_nomenclature PRIMARY KEY (id_nomenclature, regne, group2_inpn);


--
-- Name: defaults_nomenclatures_value pk_defaults_nomenclatures_value; Type: CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.defaults_nomenclatures_value
    ADD CONSTRAINT pk_defaults_nomenclatures_value PRIMARY KEY (mnemonique_type, id_organism);


--
-- Name: t_nomenclatures pk_t_nomenclatures; Type: CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.t_nomenclatures
    ADD CONSTRAINT pk_t_nomenclatures PRIMARY KEY (id_nomenclature);


--
-- Name: bib_nomenclatures_types unique_bib_nomenclatures_types_mnemonique; Type: CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.bib_nomenclatures_types
    ADD CONSTRAINT unique_bib_nomenclatures_types_mnemonique UNIQUE (mnemonique);


--
-- Name: t_nomenclatures unique_id_type_cd_nomenclature; Type: CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.t_nomenclatures
    ADD CONSTRAINT unique_id_type_cd_nomenclature UNIQUE (id_type, cd_nomenclature);


--
-- Name: bdc_statut_cor_text_values bdc_statut_cor_text_values_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_cor_text_values
    ADD CONSTRAINT bdc_statut_cor_text_values_pkey PRIMARY KEY (id_value_text);


--
-- Name: bdc_statut_taxons bdc_statut_taxons_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_taxons
    ADD CONSTRAINT bdc_statut_taxons_pkey PRIMARY KEY (id);


--
-- Name: bdc_statut_text bdc_statut_text_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_text
    ADD CONSTRAINT bdc_statut_text_pkey PRIMARY KEY (id_text);


--
-- Name: bdc_statut_type bdc_statut_type_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_type
    ADD CONSTRAINT bdc_statut_type_pkey PRIMARY KEY (cd_type_statut);


--
-- Name: bdc_statut_values bdc_statut_values_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_values
    ADD CONSTRAINT bdc_statut_values_pkey PRIMARY KEY (id_value);


--
-- Name: bib_noms bib_noms_cd_nom_key; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_noms
    ADD CONSTRAINT bib_noms_cd_nom_key UNIQUE (cd_nom);


--
-- Name: bib_noms bib_noms_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_noms
    ADD CONSTRAINT bib_noms_pkey PRIMARY KEY (id_nom);


--
-- Name: bib_themes bib_themes_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_themes
    ADD CONSTRAINT bib_themes_pkey PRIMARY KEY (id_theme);


--
-- Name: cor_nom_liste cor_nom_liste_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.cor_nom_liste
    ADD CONSTRAINT cor_nom_liste_pkey PRIMARY KEY (id_nom, id_liste);


--
-- Name: cor_taxon_attribut cor_taxon_attribut_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.cor_taxon_attribut
    ADD CONSTRAINT cor_taxon_attribut_pkey PRIMARY KEY (id_attribut, cd_ref);


--
-- Name: bib_types_media id; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_types_media
    ADD CONSTRAINT id PRIMARY KEY (id_type);


--
-- Name: t_medias id_media; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.t_medias
    ADD CONSTRAINT id_media PRIMARY KEY (id_media);


--
-- Name: bib_attributs pk_bib_attributs; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_attributs
    ADD CONSTRAINT pk_bib_attributs PRIMARY KEY (id_attribut);


--
-- Name: bib_listes pk_bib_listes; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_listes
    ADD CONSTRAINT pk_bib_listes PRIMARY KEY (id_liste);


--
-- Name: bib_taxref_habitats pk_bib_taxref_habitats; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_taxref_habitats
    ADD CONSTRAINT pk_bib_taxref_habitats PRIMARY KEY (id_habitat);


--
-- Name: bib_taxref_categories_lr pk_bib_taxref_id_categorie_france; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_taxref_categories_lr
    ADD CONSTRAINT pk_bib_taxref_id_categorie_france PRIMARY KEY (id_categorie_france);


--
-- Name: bib_taxref_rangs pk_bib_taxref_rangs; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_taxref_rangs
    ADD CONSTRAINT pk_bib_taxref_rangs PRIMARY KEY (id_rang);


--
-- Name: bib_taxref_statuts pk_bib_taxref_statuts; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_taxref_statuts
    ADD CONSTRAINT pk_bib_taxref_statuts PRIMARY KEY (id_statut);


--
-- Name: taxref pk_taxref; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref
    ADD CONSTRAINT pk_taxref PRIMARY KEY (cd_nom);


--
-- Name: taxref_changes pk_taxref_changes; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_changes
    ADD CONSTRAINT pk_taxref_changes PRIMARY KEY (cd_nom, champ);


--
-- Name: taxref_liste_rouge_fr pk_taxref_liste_rouge_fr; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_liste_rouge_fr
    ADD CONSTRAINT pk_taxref_liste_rouge_fr PRIMARY KEY (id_lr);


--
-- Name: taxhub_admin_log taxhub_admin_log_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxhub_admin_log
    ADD CONSTRAINT taxhub_admin_log_pkey PRIMARY KEY (id);


--
-- Name: taxref_protection_articles taxref_protection_articles_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_protection_articles
    ADD CONSTRAINT taxref_protection_articles_pkey PRIMARY KEY (cd_protection);


--
-- Name: taxref_protection_articles_structure taxref_protection_articles_structure_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_protection_articles_structure
    ADD CONSTRAINT taxref_protection_articles_structure_pkey PRIMARY KEY (cd_protection);


--
-- Name: taxref_protection_especes taxref_protection_especes_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_protection_especes
    ADD CONSTRAINT taxref_protection_especes_pkey PRIMARY KEY (cd_nom, cd_protection, cd_nom_cite);


--
-- Name: bib_listes unique_bib_listes_code_liste; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_listes
    ADD CONSTRAINT unique_bib_listes_code_liste UNIQUE (code_liste);


--
-- Name: bib_listes unique_bib_listes_nom_liste; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_listes
    ADD CONSTRAINT unique_bib_listes_nom_liste UNIQUE (nom_liste);


--
-- Name: vm_taxref_hierarchie vm_taxref_hierarchie_pkey; Type: CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.vm_taxref_hierarchie
    ADD CONSTRAINT vm_taxref_hierarchie_pkey PRIMARY KEY (cd_nom);


--
-- Name: cor_role_app_profil check_is_default_group_for_app_is_grp_and_unique; Type: CHECK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE utilisateurs.cor_role_app_profil
    ADD CONSTRAINT check_is_default_group_for_app_is_grp_and_unique CHECK (utilisateurs.check_is_default_group_for_app_is_grp_and_unique(id_application, id_role, is_default_group_for_app)) NOT VALID;


--
-- Name: cor_role_token cor_role_token_pk_id_role; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_token
    ADD CONSTRAINT cor_role_token_pk_id_role PRIMARY KEY (id_role);


--
-- Name: cor_roles cor_roles_pkey; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_roles
    ADD CONSTRAINT cor_roles_pkey PRIMARY KEY (id_role_groupe, id_role_utilisateur);


--
-- Name: bib_organismes pk_bib_organismes; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.bib_organismes
    ADD CONSTRAINT pk_bib_organismes PRIMARY KEY (id_organisme);


--
-- Name: cor_profil_for_app pk_cor_profil_for_app; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_profil_for_app
    ADD CONSTRAINT pk_cor_profil_for_app PRIMARY KEY (id_application, id_profil);


--
-- Name: cor_role_app_profil pk_cor_role_app_profil; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_app_profil
    ADD CONSTRAINT pk_cor_role_app_profil PRIMARY KEY (id_role, id_application, id_profil);


--
-- Name: cor_role_liste pk_cor_role_liste; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_liste
    ADD CONSTRAINT pk_cor_role_liste PRIMARY KEY (id_liste, id_role);


--
-- Name: t_applications pk_t_applications; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_applications
    ADD CONSTRAINT pk_t_applications PRIMARY KEY (id_application);


--
-- Name: t_listes pk_t_listes; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_listes
    ADD CONSTRAINT pk_t_listes PRIMARY KEY (id_liste);


--
-- Name: t_profils pk_t_profils; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_profils
    ADD CONSTRAINT pk_t_profils PRIMARY KEY (id_profil);


--
-- Name: t_roles pk_t_roles; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_roles
    ADD CONSTRAINT pk_t_roles PRIMARY KEY (id_role);


--
-- Name: temp_users pk_temp_users; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.temp_users
    ADD CONSTRAINT pk_temp_users PRIMARY KEY (id_temp_user);


--
-- Name: i_t_validations_uuid_attached_row; Type: INDEX; Schema: gn_commons; Owner: geonatadmin
--

CREATE INDEX i_t_validations_uuid_attached_row ON gn_commons.t_validations USING btree (uuid_attached_row);


--
-- Name: i_unique_t_parameters_parameter_name_with_id_organism_null; Type: INDEX; Schema: gn_commons; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_t_parameters_parameter_name_with_id_organism_null ON gn_commons.t_parameters USING btree (parameter_name) WHERE (id_organism IS NULL);


--
-- Name: i_t_datasets_id_acquisition_framework; Type: INDEX; Schema: gn_meta; Owner: geonatadmin
--

CREATE INDEX i_t_datasets_id_acquisition_framework ON gn_meta.t_datasets USING btree (id_acquisition_framework);


--
-- Name: i_unique_t_acquisition_framework_unique_id; Type: INDEX; Schema: gn_meta; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_t_acquisition_framework_unique_id ON gn_meta.t_acquisition_frameworks USING btree (unique_acquisition_framework_id);


--
-- Name: i_unique_t_datasets_unique_id; Type: INDEX; Schema: gn_meta; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_t_datasets_unique_id ON gn_meta.t_datasets USING btree (unique_dataset_id);


--
-- Name: idx_t_base_sites_geom; Type: INDEX; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE INDEX idx_t_base_sites_geom ON gn_monitoring.t_base_sites USING gist (geom);


--
-- Name: idx_t_base_sites_id_inventor; Type: INDEX; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE INDEX idx_t_base_sites_id_inventor ON gn_monitoring.t_base_sites USING btree (id_inventor);


--
-- Name: idx_t_base_sites_type_site; Type: INDEX; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE INDEX idx_t_base_sites_type_site ON gn_monitoring.t_base_sites USING btree (id_nomenclature_type_site);


--
-- Name: idx_t_base_visits_fk_bs_id; Type: INDEX; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE INDEX idx_t_base_visits_fk_bs_id ON gn_monitoring.t_base_visits USING btree (id_base_site);


--
-- Name: i_synthese_altitude_max; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_altitude_max ON gn_synthese.synthese USING btree (altitude_max);


--
-- Name: i_synthese_altitude_min; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_altitude_min ON gn_synthese.synthese USING btree (altitude_min);


--
-- Name: i_synthese_cd_nom; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_cd_nom ON gn_synthese.synthese USING btree (cd_nom);


--
-- Name: i_synthese_date_max; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_date_max ON gn_synthese.synthese USING btree (date_max DESC);


--
-- Name: i_synthese_date_min; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_date_min ON gn_synthese.synthese USING btree (date_min DESC);


--
-- Name: i_synthese_id_dataset; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_id_dataset ON gn_synthese.synthese USING btree (id_dataset);


--
-- Name: i_synthese_t_sources; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_t_sources ON gn_synthese.synthese USING btree (id_source);


--
-- Name: i_synthese_the_geom_4326; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_the_geom_4326 ON gn_synthese.synthese USING gist (the_geom_4326);


--
-- Name: i_synthese_the_geom_local; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_the_geom_local ON gn_synthese.synthese USING gist (the_geom_local);


--
-- Name: i_synthese_the_geom_point; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE INDEX i_synthese_the_geom_point ON gn_synthese.synthese USING gist (the_geom_point);


--
-- Name: i_unique_cd_ref_vm_min_max_for_taxons; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_cd_ref_vm_min_max_for_taxons ON gn_synthese.vm_min_max_for_taxons USING btree (cd_ref);


--
-- Name: i_unique_t_sources_name_source; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_t_sources_name_source ON gn_synthese.t_sources USING btree (name_source);


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
-- Name: index_t_nomenclatures_bib_nomenclatures_types_fkey; Type: INDEX; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE INDEX index_t_nomenclatures_bib_nomenclatures_types_fkey ON ref_nomenclatures.t_nomenclatures USING btree (id_type);


--
-- Name: bdc_statut_code_statut_idx; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX bdc_statut_code_statut_idx ON taxonomie.bdc_statut USING btree (code_statut);


--
-- Name: bdc_statut_id_idx; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX bdc_statut_id_idx ON taxonomie.bdc_statut USING btree (id);


--
-- Name: bdc_statut_label_statut_idx; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX bdc_statut_label_statut_idx ON taxonomie.bdc_statut USING btree (label_statut);


--
-- Name: fki_cd_nom_taxref_protection_especes; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX fki_cd_nom_taxref_protection_especes ON taxonomie.taxref_protection_especes USING btree (cd_nom);


--
-- Name: fki_cor_taxon_attribut; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX fki_cor_taxon_attribut ON taxonomie.cor_taxon_attribut USING btree (valeur_attribut);


--
-- Name: i_bib_noms_cd_ref; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_bib_noms_cd_ref ON taxonomie.bib_noms USING btree (cd_ref);


--
-- Name: i_fk_taxref_bib_taxref_habitat; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_fk_taxref_bib_taxref_habitat ON taxonomie.taxref USING btree (id_habitat);


--
-- Name: i_fk_taxref_bib_taxref_rangs; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_fk_taxref_bib_taxref_rangs ON taxonomie.taxref USING btree (id_rang);


--
-- Name: i_fk_taxref_bib_taxref_statuts; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_fk_taxref_bib_taxref_statuts ON taxonomie.taxref USING btree (id_statut);


--
-- Name: i_fk_taxref_group1_inpn; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_fk_taxref_group1_inpn ON taxonomie.taxref USING btree (group1_inpn);


--
-- Name: i_fk_taxref_group2_inpn; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_fk_taxref_group2_inpn ON taxonomie.taxref USING btree (group2_inpn);


--
-- Name: i_fk_taxref_nom_vern; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_fk_taxref_nom_vern ON taxonomie.taxref USING btree (nom_vern);


--
-- Name: i_taxref_cd_ref; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_taxref_cd_ref ON taxonomie.taxref USING btree (cd_ref);


--
-- Name: i_taxref_cd_sup; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_taxref_cd_sup ON taxonomie.taxref USING btree (cd_sup);


--
-- Name: i_taxref_hierarchy; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_taxref_hierarchy ON taxonomie.taxref USING btree (regne, phylum, classe, ordre, famille);


--
-- Name: i_tri_vm_taxref_list_forautocomplete_search_name; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_tri_vm_taxref_list_forautocomplete_search_name ON taxonomie.vm_taxref_list_forautocomplete USING gist (search_name public.gist_trgm_ops);


--
-- Name: i_unique_classe; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_classe ON taxonomie.vm_classe USING btree (classe);


--
-- Name: i_unique_famille; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_famille ON taxonomie.vm_famille USING btree (famille);


--
-- Name: i_unique_group1_inpn; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_group1_inpn ON taxonomie.vm_group1_inpn USING btree (group1_inpn);


--
-- Name: i_unique_group2_inpn; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_group2_inpn ON taxonomie.vm_group2_inpn USING btree (group2_inpn);


--
-- Name: i_unique_ordre; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_ordre ON taxonomie.vm_ordre USING btree (ordre);


--
-- Name: i_unique_phylum; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_phylum ON taxonomie.vm_phylum USING btree (phylum);


--
-- Name: i_unique_regne; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_regne ON taxonomie.vm_regne USING btree (regne);


--
-- Name: i_vm_taxref_list_forautocomplete_cd_nom; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_vm_taxref_list_forautocomplete_cd_nom ON taxonomie.vm_taxref_list_forautocomplete USING btree (cd_nom);


--
-- Name: i_vm_taxref_list_forautocomplete_gid; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_vm_taxref_list_forautocomplete_gid ON taxonomie.vm_taxref_list_forautocomplete USING btree (gid);


--
-- Name: i_vm_taxref_list_forautocomplete_search_name; Type: INDEX; Schema: taxonomie; Owner: geonatadmin
--

CREATE INDEX i_vm_taxref_list_forautocomplete_search_name ON taxonomie.vm_taxref_list_forautocomplete USING btree (search_name);


--
-- Name: i_utilisateurs_active; Type: INDEX; Schema: utilisateurs; Owner: geonatadmin
--

CREATE INDEX i_utilisateurs_active ON utilisateurs.t_roles USING btree (active);


--
-- Name: i_utilisateurs_groupe; Type: INDEX; Schema: utilisateurs; Owner: geonatadmin
--

CREATE INDEX i_utilisateurs_groupe ON utilisateurs.t_roles USING btree (groupe);


--
-- Name: i_utilisateurs_nom_prenom; Type: INDEX; Schema: utilisateurs; Owner: geonatadmin
--

CREATE INDEX i_utilisateurs_nom_prenom ON utilisateurs.t_roles USING btree (nom_role, prenom_role);


--
-- Name: t_validations tri_insert_synthese_update_validation_status; Type: TRIGGER; Schema: gn_commons; Owner: geonatadmin
--

CREATE TRIGGER tri_insert_synthese_update_validation_status AFTER INSERT ON gn_commons.t_validations FOR EACH ROW EXECUTE FUNCTION gn_commons.fct_trg_update_synthese_validation_status();


--
-- Name: t_medias tri_log_changes_t_medias; Type: TRIGGER; Schema: gn_commons; Owner: geonatadmin
--

CREATE TRIGGER tri_log_changes_t_medias AFTER INSERT OR DELETE OR UPDATE ON gn_commons.t_medias FOR EACH ROW EXECUTE FUNCTION gn_commons.fct_trg_log_changes();


--
-- Name: t_medias tri_meta_dates_change_t_medias; Type: TRIGGER; Schema: gn_commons; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_t_medias BEFORE INSERT OR UPDATE ON gn_commons.t_medias FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_modules tri_meta_dates_change_t_modules; Type: TRIGGER; Schema: gn_commons; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_t_modules BEFORE INSERT OR UPDATE ON gn_commons.t_modules FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_acquisition_frameworks tri_meta_dates_change_t_acquisition_frameworks; Type: TRIGGER; Schema: gn_meta; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_t_acquisition_frameworks BEFORE INSERT OR UPDATE ON gn_meta.t_acquisition_frameworks FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_datasets tri_meta_dates_change_t_datasets; Type: TRIGGER; Schema: gn_meta; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_t_datasets BEFORE INSERT OR UPDATE ON gn_meta.t_datasets FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_base_sites trg_cor_site_area; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER trg_cor_site_area AFTER INSERT OR UPDATE OF geom ON gn_monitoring.t_base_sites FOR EACH ROW EXECUTE FUNCTION gn_monitoring.fct_trg_cor_site_area();


--
-- Name: t_base_sites tri_calculate_geom_local; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER tri_calculate_geom_local BEFORE INSERT OR UPDATE ON gn_monitoring.t_base_sites FOR EACH ROW EXECUTE FUNCTION ref_geo.fct_trg_calculate_geom_local('geom', 'geom_local');


--
-- Name: t_base_sites tri_log_changes; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER tri_log_changes AFTER INSERT OR DELETE OR UPDATE ON gn_monitoring.t_base_sites FOR EACH ROW EXECUTE FUNCTION gn_commons.fct_trg_log_changes();


--
-- Name: t_base_visits tri_log_changes; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER tri_log_changes AFTER INSERT OR DELETE OR UPDATE ON gn_monitoring.t_base_visits FOR EACH ROW EXECUTE FUNCTION gn_commons.fct_trg_log_changes();


--
-- Name: cor_visit_observer tri_log_changes_cor_visit_observer; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER tri_log_changes_cor_visit_observer AFTER INSERT OR DELETE OR UPDATE ON gn_monitoring.cor_visit_observer FOR EACH ROW EXECUTE FUNCTION gn_commons.fct_trg_log_changes();


--
-- Name: t_base_sites tri_meta_dates_change_t_base_sites; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_t_base_sites BEFORE INSERT OR UPDATE ON gn_monitoring.t_base_sites FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_base_visits tri_meta_dates_change_t_base_visits; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_t_base_visits BEFORE INSERT OR UPDATE ON gn_monitoring.t_base_visits FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_base_sites tri_t_base_sites_calculate_alt; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER tri_t_base_sites_calculate_alt BEFORE INSERT OR UPDATE ON gn_monitoring.t_base_sites FOR EACH ROW EXECUTE FUNCTION ref_geo.fct_trg_calculate_alt_minmax('geom');


--
-- Name: t_base_visits tri_visite_date_max; Type: TRIGGER; Schema: gn_monitoring; Owner: geonatadmin
--

CREATE TRIGGER tri_visite_date_max BEFORE INSERT OR UPDATE OF visit_date_min ON gn_monitoring.t_base_visits FOR EACH ROW EXECUTE FUNCTION gn_monitoring.fct_trg_visite_date_max();


--
-- Name: cor_role_action_filter_module_object tri_check_no_multiple_scope_perm; Type: TRIGGER; Schema: gn_permissions; Owner: geonatadmin
--

CREATE TRIGGER tri_check_no_multiple_scope_perm BEFORE INSERT OR UPDATE ON gn_permissions.cor_role_action_filter_module_object FOR EACH ROW EXECUTE FUNCTION gn_permissions.fct_tri_does_user_have_already_scope_filter();


--
-- Name: cor_sensitivity_synthese tri_delete_id_sensitivity_synthese; Type: TRIGGER; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TRIGGER tri_delete_id_sensitivity_synthese AFTER DELETE ON gn_sensitivity.cor_sensitivity_synthese REFERENCING OLD TABLE AS old FOR EACH STATEMENT EXECUTE FUNCTION gn_sensitivity.fct_tri_delete_id_sensitivity_synthese();


--
-- Name: cor_sensitivity_synthese tri_insert_id_sensitivity_synthese; Type: TRIGGER; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TRIGGER tri_insert_id_sensitivity_synthese AFTER INSERT ON gn_sensitivity.cor_sensitivity_synthese REFERENCING NEW TABLE AS new FOR EACH STATEMENT EXECUTE FUNCTION gn_sensitivity.fct_tri_maj_id_sensitivity_synthese();


--
-- Name: cor_sensitivity_synthese tri_maj_id_sensitivity_synthese; Type: TRIGGER; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TRIGGER tri_maj_id_sensitivity_synthese AFTER UPDATE ON gn_sensitivity.cor_sensitivity_synthese REFERENCING NEW TABLE AS new FOR EACH STATEMENT EXECUTE FUNCTION gn_sensitivity.fct_tri_maj_id_sensitivity_synthese();


--
-- Name: cor_sensitivity_synthese tri_meta_dates_change_cor_sensitivity_synthese; Type: TRIGGER; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_cor_sensitivity_synthese BEFORE INSERT OR UPDATE ON gn_sensitivity.cor_sensitivity_synthese FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_sensitivity_rules tri_meta_dates_change_t_sensitivity_rules; Type: TRIGGER; Schema: gn_sensitivity; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_t_sensitivity_rules BEFORE INSERT OR UPDATE ON gn_sensitivity.t_sensitivity_rules FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: cor_observer_synthese trg_maj_synthese_observers_txt; Type: TRIGGER; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TRIGGER trg_maj_synthese_observers_txt AFTER INSERT OR DELETE OR UPDATE ON gn_synthese.cor_observer_synthese FOR EACH ROW EXECUTE FUNCTION gn_synthese.fct_tri_maj_observers_txt();


--
-- Name: synthese tri_insert_calculate_sensitivity; Type: TRIGGER; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TRIGGER tri_insert_calculate_sensitivity AFTER INSERT ON gn_synthese.synthese REFERENCING NEW TABLE AS new FOR EACH STATEMENT EXECUTE FUNCTION gn_synthese.fct_tri_cal_sensi_diff_level_on_each_statement();


--
-- Name: synthese tri_insert_cor_area_synthese; Type: TRIGGER; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TRIGGER tri_insert_cor_area_synthese AFTER INSERT ON gn_synthese.synthese REFERENCING NEW TABLE AS new FOR EACH STATEMENT EXECUTE FUNCTION gn_synthese.fct_trig_insert_in_cor_area_synthese_on_each_statement();


--
-- Name: synthese tri_meta_dates_change_synthese; Type: TRIGGER; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_synthese BEFORE INSERT OR UPDATE ON gn_synthese.synthese FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_sources tri_meta_dates_t_sources; Type: TRIGGER; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_t_sources BEFORE INSERT OR UPDATE ON gn_synthese.t_sources FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: synthese tri_update_calculate_sensitivity; Type: TRIGGER; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TRIGGER tri_update_calculate_sensitivity AFTER UPDATE OF date_min, date_max, cd_nom, the_geom_local, id_nomenclature_bio_status ON gn_synthese.synthese FOR EACH ROW EXECUTE FUNCTION gn_synthese.fct_tri_cal_sensi_diff_level_on_each_row();


--
-- Name: synthese tri_update_cor_area_synthese; Type: TRIGGER; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TRIGGER tri_update_cor_area_synthese AFTER UPDATE OF the_geom_local, the_geom_4326 ON gn_synthese.synthese FOR EACH ROW EXECUTE FUNCTION gn_synthese.fct_trig_update_in_cor_area_synthese();


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
-- Name: bib_nomenclatures_types tri_meta_dates_change_bib_nomenclatures_types; Type: TRIGGER; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_bib_nomenclatures_types BEFORE INSERT OR UPDATE ON ref_nomenclatures.bib_nomenclatures_types FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: cor_taxref_nomenclature tri_meta_dates_change_cor_taxref_nomenclature; Type: TRIGGER; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_cor_taxref_nomenclature BEFORE INSERT OR UPDATE ON ref_nomenclatures.cor_taxref_nomenclature FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: t_nomenclatures tri_meta_dates_change_t_nomenclatures; Type: TRIGGER; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE TRIGGER tri_meta_dates_change_t_nomenclatures BEFORE INSERT OR UPDATE ON ref_nomenclatures.t_nomenclatures FOR EACH ROW EXECUTE FUNCTION public.fct_trg_meta_dates_change();


--
-- Name: bib_attributs trg_refresh_attributes_views_per_kingdom; Type: TRIGGER; Schema: taxonomie; Owner: geonatadmin
--

CREATE TRIGGER trg_refresh_attributes_views_per_kingdom AFTER INSERT OR DELETE OR UPDATE ON taxonomie.bib_attributs FOR EACH ROW EXECUTE FUNCTION taxonomie.trg_fct_refresh_attributesviews_per_kingdom();


--
-- Name: t_medias tri_insert_t_medias; Type: TRIGGER; Schema: taxonomie; Owner: geonatadmin
--

CREATE TRIGGER tri_insert_t_medias BEFORE INSERT ON taxonomie.t_medias FOR EACH ROW EXECUTE FUNCTION taxonomie.insert_t_medias();


--
-- Name: t_medias tri_unique_type1; Type: TRIGGER; Schema: taxonomie; Owner: geonatadmin
--

CREATE TRIGGER tri_unique_type1 AFTER INSERT OR UPDATE ON taxonomie.t_medias FOR EACH ROW EXECUTE FUNCTION taxonomie.unique_type1();


--
-- Name: t_roles tri_modify_date_insert_t_roles; Type: TRIGGER; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TRIGGER tri_modify_date_insert_t_roles BEFORE INSERT ON utilisateurs.t_roles FOR EACH ROW EXECUTE FUNCTION utilisateurs.modify_date_insert();


--
-- Name: temp_users tri_modify_date_insert_temp_roles; Type: TRIGGER; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TRIGGER tri_modify_date_insert_temp_roles BEFORE INSERT ON utilisateurs.temp_users FOR EACH ROW EXECUTE FUNCTION utilisateurs.modify_date_insert();


--
-- Name: t_roles tri_modify_date_update_t_roles; Type: TRIGGER; Schema: utilisateurs; Owner: geonatadmin
--

CREATE TRIGGER tri_modify_date_update_t_roles BEFORE UPDATE ON utilisateurs.t_roles FOR EACH ROW EXECUTE FUNCTION utilisateurs.modify_date_update();


--
-- Name: cor_field_dataset fk_cor_field_dataset; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_dataset
    ADD CONSTRAINT fk_cor_field_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_field_dataset fk_cor_field_dataset_field; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_dataset
    ADD CONSTRAINT fk_cor_field_dataset_field FOREIGN KEY (id_field) REFERENCES gn_commons.t_additional_fields(id_field) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_field_module fk_cor_field_module; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_module
    ADD CONSTRAINT fk_cor_field_module FOREIGN KEY (id_module) REFERENCES gn_commons.t_modules(id_module) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_field_module fk_cor_field_module_field; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_module
    ADD CONSTRAINT fk_cor_field_module_field FOREIGN KEY (id_field) REFERENCES gn_commons.t_additional_fields(id_field) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_field_object fk_cor_field_obj_field; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_object
    ADD CONSTRAINT fk_cor_field_obj_field FOREIGN KEY (id_field) REFERENCES gn_commons.t_additional_fields(id_field) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_field_object fk_cor_field_object; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_field_object
    ADD CONSTRAINT fk_cor_field_object FOREIGN KEY (id_object) REFERENCES gn_permissions.t_objects(id_object) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_module_dataset fk_cor_module_dataset_id_dataset; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_module_dataset
    ADD CONSTRAINT fk_cor_module_dataset_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_module_dataset fk_cor_module_dataset_id_module; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.cor_module_dataset
    ADD CONSTRAINT fk_cor_module_dataset_id_module FOREIGN KEY (id_module) REFERENCES gn_commons.t_modules(id_module) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_additional_fields fk_t_additional_fields_id_widget; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_additional_fields
    ADD CONSTRAINT fk_t_additional_fields_id_widget FOREIGN KEY (id_widget) REFERENCES gn_commons.bib_widgets(id_widget) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_history_actions fk_t_history_actions_bib_tables_location; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_history_actions
    ADD CONSTRAINT fk_t_history_actions_bib_tables_location FOREIGN KEY (id_table_location) REFERENCES gn_commons.bib_tables_location(id_table_location) ON UPDATE CASCADE;


--
-- Name: t_medias fk_t_medias_bib_tables_location; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_medias
    ADD CONSTRAINT fk_t_medias_bib_tables_location FOREIGN KEY (id_table_location) REFERENCES gn_commons.bib_tables_location(id_table_location) ON UPDATE CASCADE;


--
-- Name: t_medias fk_t_medias_media_type; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_medias
    ADD CONSTRAINT fk_t_medias_media_type FOREIGN KEY (id_nomenclature_media_type) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_parameters fk_t_parameters_bib_organismes; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_parameters
    ADD CONSTRAINT fk_t_parameters_bib_organismes FOREIGN KEY (id_organism) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE;


--
-- Name: t_places fk_t_places_t_roles; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_places
    ADD CONSTRAINT fk_t_places_t_roles FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_validations fk_t_validations_t_roles; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_validations
    ADD CONSTRAINT fk_t_validations_t_roles FOREIGN KEY (id_validator) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_validations fk_t_validations_valid_status; Type: FK CONSTRAINT; Schema: gn_commons; Owner: geonatadmin
--

ALTER TABLE ONLY gn_commons.t_validations
    ADD CONSTRAINT fk_t_validations_valid_status FOREIGN KEY (id_nomenclature_valid_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: matching_fields fk_matching_fields_matching_tables; Type: FK CONSTRAINT; Schema: gn_imports; Owner: geonatadmin
--

ALTER TABLE ONLY gn_imports.matching_fields
    ADD CONSTRAINT fk_matching_fields_matching_tables FOREIGN KEY (id_matching_table) REFERENCES gn_imports.matching_tables(id_matching_table) ON UPDATE CASCADE;


--
-- Name: matching_geoms fk_matching_geoms_matching_tables; Type: FK CONSTRAINT; Schema: gn_imports; Owner: geonatadmin
--

ALTER TABLE ONLY gn_imports.matching_geoms
    ADD CONSTRAINT fk_matching_geoms_matching_tables FOREIGN KEY (id_matching_table) REFERENCES gn_imports.matching_tables(id_matching_table) ON UPDATE CASCADE;


--
-- Name: cor_acquisition_framework_actor fk_cor_acquisition_framework_actor_id_acquisition_framework; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT fk_cor_acquisition_framework_actor_id_acquisition_framework FOREIGN KEY (id_acquisition_framework) REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_acquisition_framework_actor fk_cor_acquisition_framework_actor_id_nomenclature_actor_role; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT fk_cor_acquisition_framework_actor_id_nomenclature_actor_role FOREIGN KEY (id_nomenclature_actor_role) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: cor_acquisition_framework_actor fk_cor_acquisition_framework_actor_id_organism; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT fk_cor_acquisition_framework_actor_id_organism FOREIGN KEY (id_organism) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_acquisition_framework_actor fk_cor_acquisition_framework_actor_id_role; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT fk_cor_acquisition_framework_actor_id_role FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_acquisition_framework_objectif fk_cor_acquisition_framework_objectif_id_acquisition_framework; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_objectif
    ADD CONSTRAINT fk_cor_acquisition_framework_objectif_id_acquisition_framework FOREIGN KEY (id_acquisition_framework) REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_acquisition_framework_objectif fk_cor_acquisition_framework_objectif_id_nomenclature_objectif; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_objectif
    ADD CONSTRAINT fk_cor_acquisition_framework_objectif_id_nomenclature_objectif FOREIGN KEY (id_nomenclature_objectif) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: cor_acquisition_framework_publication fk_cor_acquisition_framework_publication_id_acquisition_framewo; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_publication
    ADD CONSTRAINT fk_cor_acquisition_framework_publication_id_acquisition_framewo FOREIGN KEY (id_acquisition_framework) REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_acquisition_framework_publication fk_cor_acquisition_framework_publication_id_publication; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_publication
    ADD CONSTRAINT fk_cor_acquisition_framework_publication_id_publication FOREIGN KEY (id_publication) REFERENCES gn_meta.sinp_datatype_publications(id_publication) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_acquisition_framework_voletsinp fk_cor_acquisition_framework_voletsinp_id_acquisition_framework; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_voletsinp
    ADD CONSTRAINT fk_cor_acquisition_framework_voletsinp_id_acquisition_framework FOREIGN KEY (id_acquisition_framework) REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_acquisition_framework_voletsinp fk_cor_acquisition_framework_voletsinp_id_nomenclature_voletsin; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_voletsinp
    ADD CONSTRAINT fk_cor_acquisition_framework_voletsinp_id_nomenclature_voletsin FOREIGN KEY (id_nomenclature_voletsinp) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: cor_acquisition_framework_territory fk_cor_af_territory_id_af; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_territory
    ADD CONSTRAINT fk_cor_af_territory_id_af FOREIGN KEY (id_acquisition_framework) REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_acquisition_framework_territory fk_cor_af_territory_id_nomenclature_territory; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_territory
    ADD CONSTRAINT fk_cor_af_territory_id_nomenclature_territory FOREIGN KEY (id_nomenclature_territory) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: cor_dataset_actor fk_cor_dataset_actor_id_dataset; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_actor
    ADD CONSTRAINT fk_cor_dataset_actor_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_dataset_actor fk_cor_dataset_actor_id_nomenclature_actor_role; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_actor
    ADD CONSTRAINT fk_cor_dataset_actor_id_nomenclature_actor_role FOREIGN KEY (id_nomenclature_actor_role) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: cor_dataset_protocol fk_cor_dataset_protocol_id_dataset; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_protocol
    ADD CONSTRAINT fk_cor_dataset_protocol_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE;


--
-- Name: cor_dataset_protocol fk_cor_dataset_protocol_id_protocol; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_protocol
    ADD CONSTRAINT fk_cor_dataset_protocol_id_protocol FOREIGN KEY (id_protocol) REFERENCES gn_meta.sinp_datatype_protocols(id_protocol) ON UPDATE CASCADE;


--
-- Name: cor_dataset_territory fk_cor_dataset_territory_id_dataset; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_territory
    ADD CONSTRAINT fk_cor_dataset_territory_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE;


--
-- Name: cor_dataset_territory fk_cor_dataset_territory_id_nomenclature_territory; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_territory
    ADD CONSTRAINT fk_cor_dataset_territory_id_nomenclature_territory FOREIGN KEY (id_nomenclature_territory) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: cor_dataset_actor fk_dataset_actor_id_organism; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_actor
    ADD CONSTRAINT fk_dataset_actor_id_organism FOREIGN KEY (id_organism) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE;


--
-- Name: cor_dataset_actor fk_dataset_actor_id_role; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_actor
    ADD CONSTRAINT fk_dataset_actor_id_role FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_acquisition_frameworks fk_t_acquisition_frameworks_id_digitizer; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_acquisition_frameworks
    ADD CONSTRAINT fk_t_acquisition_frameworks_id_digitizer FOREIGN KEY (id_digitizer) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_datasets fk_t_datasets_collecting_method; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_collecting_method FOREIGN KEY (id_nomenclature_collecting_method) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_datasets fk_t_datasets_data_origin; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_data_origin FOREIGN KEY (id_nomenclature_data_origin) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_datasets fk_t_datasets_data_type; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_data_type FOREIGN KEY (id_nomenclature_data_type) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_datasets fk_t_datasets_id_digitizer; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_id_digitizer FOREIGN KEY (id_digitizer) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_datasets fk_t_datasets_objectif; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_objectif FOREIGN KEY (id_nomenclature_dataset_objectif) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_datasets fk_t_datasets_resource_type; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_resource_type FOREIGN KEY (id_nomenclature_resource_type) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_datasets fk_t_datasets_source_status; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_source_status FOREIGN KEY (id_nomenclature_source_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_datasets fk_t_datasets_t_acquisition_frameworks; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_t_acquisition_frameworks FOREIGN KEY (id_acquisition_framework) REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE;


--
-- Name: t_bibliographical_references t_bibliographical_references_id_acquisition_framework_fkey; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.t_bibliographical_references
    ADD CONSTRAINT t_bibliographical_references_id_acquisition_framework_fkey FOREIGN KEY (id_acquisition_framework) REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON DELETE CASCADE;


--
-- Name: cor_site_area fk_cor_site_area_id_area; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_site_area
    ADD CONSTRAINT fk_cor_site_area_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area);


--
-- Name: cor_site_area fk_cor_site_area_id_base_site; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_site_area
    ADD CONSTRAINT fk_cor_site_area_id_base_site FOREIGN KEY (id_base_site) REFERENCES gn_monitoring.t_base_sites(id_base_site) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_site_module fk_cor_site_module_id_base_site; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_site_module
    ADD CONSTRAINT fk_cor_site_module_id_base_site FOREIGN KEY (id_base_site) REFERENCES gn_monitoring.t_base_sites(id_base_site) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_site_module fk_cor_site_module_id_module; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_site_module
    ADD CONSTRAINT fk_cor_site_module_id_module FOREIGN KEY (id_module) REFERENCES gn_commons.t_modules(id_module);


--
-- Name: cor_visit_observer fk_cor_visit_observer_id_base_visit; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_visit_observer
    ADD CONSTRAINT fk_cor_visit_observer_id_base_visit FOREIGN KEY (id_base_visit) REFERENCES gn_monitoring.t_base_visits(id_base_visit) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_visit_observer fk_cor_visit_observer_id_role; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.cor_visit_observer
    ADD CONSTRAINT fk_cor_visit_observer_id_role FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_base_sites fk_t_base_sites_id_digitiser; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_sites
    ADD CONSTRAINT fk_t_base_sites_id_digitiser FOREIGN KEY (id_digitiser) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_base_sites fk_t_base_sites_id_inventor; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_sites
    ADD CONSTRAINT fk_t_base_sites_id_inventor FOREIGN KEY (id_inventor) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_base_sites fk_t_base_sites_type_site; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_sites
    ADD CONSTRAINT fk_t_base_sites_type_site FOREIGN KEY (id_nomenclature_type_site) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_base_visits fk_t_base_visits_id_base_site; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_visits
    ADD CONSTRAINT fk_t_base_visits_id_base_site FOREIGN KEY (id_base_site) REFERENCES gn_monitoring.t_base_sites(id_base_site) ON DELETE CASCADE;


--
-- Name: t_base_visits fk_t_base_visits_id_digitiser; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_visits
    ADD CONSTRAINT fk_t_base_visits_id_digitiser FOREIGN KEY (id_digitiser) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_base_visits fk_t_base_visits_id_module; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_visits
    ADD CONSTRAINT fk_t_base_visits_id_module FOREIGN KEY (id_module) REFERENCES gn_commons.t_modules(id_module) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_base_visits fk_t_base_visits_id_nomenclature_grp_typ; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_visits
    ADD CONSTRAINT fk_t_base_visits_id_nomenclature_grp_typ FOREIGN KEY (id_nomenclature_grp_typ) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_base_visits fk_t_base_visits_id_nomenclature_tech_collect_campanule; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_visits
    ADD CONSTRAINT fk_t_base_visits_id_nomenclature_tech_collect_campanule FOREIGN KEY (id_nomenclature_tech_collect_campanule) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: t_base_visits fk_t_base_visits_t_datasets; Type: FK CONSTRAINT; Schema: gn_monitoring; Owner: geonatadmin
--

ALTER TABLE ONLY gn_monitoring.t_base_visits
    ADD CONSTRAINT fk_t_base_visits_t_datasets FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE;


--
-- Name: cor_filter_type_module fk_cor_filter_module_id_filter; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_filter_type_module
    ADD CONSTRAINT fk_cor_filter_module_id_filter FOREIGN KEY (id_filter_type) REFERENCES gn_permissions.bib_filters_type(id_filter_type) ON UPDATE CASCADE;


--
-- Name: cor_filter_type_module fk_cor_filter_module_id_module; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_filter_type_module
    ADD CONSTRAINT fk_cor_filter_module_id_module FOREIGN KEY (id_module) REFERENCES gn_commons.t_modules(id_module) ON UPDATE CASCADE;


--
-- Name: cor_object_module fk_cor_object_module_id_module; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_object_module
    ADD CONSTRAINT fk_cor_object_module_id_module FOREIGN KEY (id_module) REFERENCES gn_commons.t_modules(id_module) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_object_module fk_cor_object_module_id_object; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_object_module
    ADD CONSTRAINT fk_cor_object_module_id_object FOREIGN KEY (id_object) REFERENCES gn_permissions.t_objects(id_object) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_role_action_filter_module_object fk_cor_r_a_f_m_o_id_action; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_role_action_filter_module_object
    ADD CONSTRAINT fk_cor_r_a_f_m_o_id_action FOREIGN KEY (id_action) REFERENCES gn_permissions.t_actions(id_action) ON UPDATE CASCADE;


--
-- Name: cor_role_action_filter_module_object fk_cor_r_a_f_m_o_id_filter; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_role_action_filter_module_object
    ADD CONSTRAINT fk_cor_r_a_f_m_o_id_filter FOREIGN KEY (id_filter) REFERENCES gn_permissions.t_filters(id_filter) ON UPDATE CASCADE;


--
-- Name: cor_role_action_filter_module_object fk_cor_r_a_f_m_o_id_object; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_role_action_filter_module_object
    ADD CONSTRAINT fk_cor_r_a_f_m_o_id_object FOREIGN KEY (id_object) REFERENCES gn_permissions.t_objects(id_object) ON UPDATE CASCADE;


--
-- Name: cor_role_action_filter_module_object fk_cor_r_a_f_m_o_id_role; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.cor_role_action_filter_module_object
    ADD CONSTRAINT fk_cor_r_a_f_m_o_id_role FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_filters fk_t_filters_id_filter_type; Type: FK CONSTRAINT; Schema: gn_permissions; Owner: geonatadmin
--

ALTER TABLE ONLY gn_permissions.t_filters
    ADD CONSTRAINT fk_t_filters_id_filter_type FOREIGN KEY (id_filter_type) REFERENCES gn_permissions.bib_filters_type(id_filter_type) ON UPDATE CASCADE;


--
-- Name: cor_sensitivity_area_type cor_sensitivity_area_type_id_area_type_fkey; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_area_type
    ADD CONSTRAINT cor_sensitivity_area_type_id_area_type_fkey FOREIGN KEY (id_area_type) REFERENCES ref_geo.bib_areas_types(id_type);


--
-- Name: cor_sensitivity_area_type cor_sensitivity_area_type_id_nomenclature_sensitivity_fkey; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_area_type
    ADD CONSTRAINT cor_sensitivity_area_type_id_nomenclature_sensitivity_fkey FOREIGN KEY (id_nomenclature_sensitivity) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature);


--
-- Name: cor_sensitivity_synthese cor_sensitivity_synthese_id_nomenclature_sensitivity_fkey; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_synthese
    ADD CONSTRAINT cor_sensitivity_synthese_id_nomenclature_sensitivity_fkey FOREIGN KEY (id_nomenclature_sensitivity) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature);


--
-- Name: cor_sensitivity_criteria criteria_id_criteria_fkey; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_criteria
    ADD CONSTRAINT criteria_id_criteria_fkey FOREIGN KEY (id_criteria) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature);


--
-- Name: cor_sensitivity_criteria criteria_id_sensitivity_fkey; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_criteria
    ADD CONSTRAINT criteria_id_sensitivity_fkey FOREIGN KEY (id_sensitivity) REFERENCES gn_sensitivity.t_sensitivity_rules(id_sensitivity);


--
-- Name: cor_sensitivity_criteria criteria_id_type_nomenclature_fkey; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_criteria
    ADD CONSTRAINT criteria_id_type_nomenclature_fkey FOREIGN KEY (id_type_nomenclature) REFERENCES ref_nomenclatures.bib_nomenclatures_types(id_type);


--
-- Name: cor_sensitivity_area fk_cor_sensitivity_area_id_area_fkey; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_area
    ADD CONSTRAINT fk_cor_sensitivity_area_id_area_fkey FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area);


--
-- Name: cor_sensitivity_area fk_cor_sensitivity_area_id_sensitivity_fkey; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.cor_sensitivity_area
    ADD CONSTRAINT fk_cor_sensitivity_area_id_sensitivity_fkey FOREIGN KEY (id_sensitivity) REFERENCES gn_sensitivity.t_sensitivity_rules(id_sensitivity);


--
-- Name: t_sensitivity_rules fk_t_sensitivity_rules_cd_nom; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.t_sensitivity_rules
    ADD CONSTRAINT fk_t_sensitivity_rules_cd_nom FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE;


--
-- Name: t_sensitivity_rules fk_t_sensitivity_rules_id_nomenclature_sensitivity; Type: FK CONSTRAINT; Schema: gn_sensitivity; Owner: geonatadmin
--

ALTER TABLE ONLY gn_sensitivity.t_sensitivity_rules
    ADD CONSTRAINT fk_t_sensitivity_rules_id_nomenclature_sensitivity FOREIGN KEY (id_nomenclature_sensitivity) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: cor_area_synthese fk_cor_area_synthese_id_area; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.cor_area_synthese
    ADD CONSTRAINT fk_cor_area_synthese_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE;


--
-- Name: cor_area_synthese fk_cor_area_synthese_id_synthese; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.cor_area_synthese
    ADD CONSTRAINT fk_cor_area_synthese_id_synthese FOREIGN KEY (id_synthese) REFERENCES gn_synthese.synthese(id_synthese) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: defaults_nomenclatures_value fk_gn_synthese_defaults_nomenclatures_value_id_organism; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.defaults_nomenclatures_value
    ADD CONSTRAINT fk_gn_synthese_defaults_nomenclatures_value_id_organism FOREIGN KEY (id_organism) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE;


--
-- Name: defaults_nomenclatures_value fk_gn_synthese_defaults_nomenclatures_value_mnemonique_type; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.defaults_nomenclatures_value
    ADD CONSTRAINT fk_gn_synthese_defaults_nomenclatures_value_mnemonique_type FOREIGN KEY (mnemonique_type) REFERENCES ref_nomenclatures.bib_nomenclatures_types(mnemonique) ON UPDATE CASCADE;


--
-- Name: cor_observer_synthese fk_gn_synthese_id_role; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.cor_observer_synthese
    ADD CONSTRAINT fk_gn_synthese_id_role FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: cor_observer_synthese fk_gn_synthese_id_synthese; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.cor_observer_synthese
    ADD CONSTRAINT fk_gn_synthese_id_synthese FOREIGN KEY (id_synthese) REFERENCES gn_synthese.synthese(id_synthese) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: synthese fk_synthese_cd_hab; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_cd_hab FOREIGN KEY (cd_hab) REFERENCES ref_habitats.habref(cd_hab) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_cd_nom; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_cd_nom FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_area_attachment; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_area_attachment FOREIGN KEY (id_area_attachment) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_dataset; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_digitiser; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_digitiser FOREIGN KEY (id_digitiser) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_module; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_module FOREIGN KEY (id_module) REFERENCES gn_commons.t_modules(id_module) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_bio_condition; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_bio_condition FOREIGN KEY (id_nomenclature_bio_condition) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_bio_status; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_bio_status FOREIGN KEY (id_nomenclature_bio_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_biogeo_status; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_biogeo_status FOREIGN KEY (id_nomenclature_biogeo_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_blurring; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_blurring FOREIGN KEY (id_nomenclature_blurring) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_determination_method; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_determination_method FOREIGN KEY (id_nomenclature_determination_method) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_diffusion_level; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_diffusion_level FOREIGN KEY (id_nomenclature_diffusion_level) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_exist_proof; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_exist_proof FOREIGN KEY (id_nomenclature_exist_proof) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_geo_object_nature; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_geo_object_nature FOREIGN KEY (id_nomenclature_geo_object_nature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_id_nomenclature_grp_typ; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_id_nomenclature_grp_typ FOREIGN KEY (id_nomenclature_grp_typ) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_info_geo_type; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_info_geo_type FOREIGN KEY (id_nomenclature_info_geo_type) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_life_stage; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_life_stage FOREIGN KEY (id_nomenclature_life_stage) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_obj_count; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_obj_count FOREIGN KEY (id_nomenclature_obj_count) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_obs_technique; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_obs_technique FOREIGN KEY (id_nomenclature_obs_technique) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_observation_status; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_observation_status FOREIGN KEY (id_nomenclature_observation_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_sensitivity; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_sensitivity FOREIGN KEY (id_nomenclature_sensitivity) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_sex; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_sex FOREIGN KEY (id_nomenclature_sex) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_source_status; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_source_status FOREIGN KEY (id_nomenclature_source_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_type_count; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_type_count FOREIGN KEY (id_nomenclature_type_count) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_nomenclature_valid_status; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_nomenclature_valid_status FOREIGN KEY (id_nomenclature_valid_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: synthese fk_synthese_id_source; Type: FK CONSTRAINT; Schema: gn_synthese; Owner: geonatadmin
--

ALTER TABLE ONLY gn_synthese.synthese
    ADD CONSTRAINT fk_synthese_id_source FOREIGN KEY (id_source) REFERENCES gn_synthese.t_sources(id_source) ON UPDATE CASCADE;


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
-- Name: cor_hab_source fk_cor_cor_hab_source_cd_source; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_hab_source
    ADD CONSTRAINT fk_cor_cor_hab_source_cd_source FOREIGN KEY (cd_source) REFERENCES ref_habitats.habref_sources(cd_source) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_habref_description fk_cor_habref_description_cd_hab; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_habref_description
    ADD CONSTRAINT fk_cor_habref_description_cd_hab FOREIGN KEY (cd_hab) REFERENCES ref_habitats.habref(cd_hab) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_habref_description fk_cor_habref_description_cd_hab_field; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_habref_description
    ADD CONSTRAINT fk_cor_habref_description_cd_hab_field FOREIGN KEY (cd_hab_field) REFERENCES ref_habitats.typoref_fields(cd_hab_field) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_habref_terr_statut fk_cor_habref_terr_statut_cd_hab; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_habref_terr_statut
    ADD CONSTRAINT fk_cor_habref_terr_statut_cd_hab FOREIGN KEY (cd_hab) REFERENCES ref_habitats.habref(cd_hab) ON UPDATE CASCADE;


--
-- Name: cor_habref_terr_statut fk_cor_habref_terr_statut_cd_statut_presence; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_habref_terr_statut
    ADD CONSTRAINT fk_cor_habref_terr_statut_cd_statut_presence FOREIGN KEY (cd_statut_presence) REFERENCES ref_habitats.bib_habref_statuts(statut) ON UPDATE CASCADE;


--
-- Name: cor_list_habitat fk_cor_list_habitat_cd_hab; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_list_habitat
    ADD CONSTRAINT fk_cor_list_habitat_cd_hab FOREIGN KEY (cd_hab) REFERENCES ref_habitats.habref(cd_hab) ON UPDATE CASCADE;


--
-- Name: cor_list_habitat fk_cor_list_habitat_id_list; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.cor_list_habitat
    ADD CONSTRAINT fk_cor_list_habitat_id_list FOREIGN KEY (id_list) REFERENCES ref_habitats.bib_list_habitat(id_list) ON UPDATE CASCADE;


--
-- Name: habref_corresp_hab fk_habref_corresp_hab_cd_hab_entre; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref_corresp_hab
    ADD CONSTRAINT fk_habref_corresp_hab_cd_hab_entre FOREIGN KEY (cd_hab_entre) REFERENCES ref_habitats.habref(cd_hab) ON UPDATE CASCADE;


--
-- Name: habref_corresp_hab fk_habref_corresp_hab_cd_hab_sortie; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref_corresp_hab
    ADD CONSTRAINT fk_habref_corresp_hab_cd_hab_sortie FOREIGN KEY (cd_hab_sortie) REFERENCES ref_habitats.habref(cd_hab) ON UPDATE CASCADE;


--
-- Name: habref_corresp_hab fk_habref_corresp_hab_cd_type_rel; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref_corresp_hab
    ADD CONSTRAINT fk_habref_corresp_hab_cd_type_rel FOREIGN KEY (cd_type_relation) REFERENCES ref_habitats.bib_habref_typo_rel(cd_type_rel) ON UPDATE CASCADE;


--
-- Name: habref_corresp_taxon fk_habref_corresp_tax_cd_hab_entre; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref_corresp_taxon
    ADD CONSTRAINT fk_habref_corresp_tax_cd_hab_entre FOREIGN KEY (cd_hab_entre) REFERENCES ref_habitats.habref(cd_hab) ON UPDATE CASCADE;


--
-- Name: habref_corresp_taxon fk_habref_corresp_tax_cd_typ_rel; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref_corresp_taxon
    ADD CONSTRAINT fk_habref_corresp_tax_cd_typ_rel FOREIGN KEY (cd_type_relation) REFERENCES ref_habitats.bib_habref_typo_rel(cd_type_rel) ON UPDATE CASCADE;


--
-- Name: habref fk_typoref; Type: FK CONSTRAINT; Schema: ref_habitats; Owner: geonatadmin
--

ALTER TABLE ONLY ref_habitats.habref
    ADD CONSTRAINT fk_typoref FOREIGN KEY (cd_typo) REFERENCES ref_habitats.typoref(cd_typo) ON UPDATE CASCADE;


--
-- Name: cor_application_nomenclature fk_cor_application_nomenclature_id_application; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.cor_application_nomenclature
    ADD CONSTRAINT fk_cor_application_nomenclature_id_application FOREIGN KEY (id_application) REFERENCES utilisateurs.t_applications(id_application) ON UPDATE CASCADE;


--
-- Name: cor_application_nomenclature fk_cor_application_nomenclature_id_nomenclature; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.cor_application_nomenclature
    ADD CONSTRAINT fk_cor_application_nomenclature_id_nomenclature FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: cor_nomenclatures_relations fk_cor_nomenclatures_relations_id_nomenclature_l; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.cor_nomenclatures_relations
    ADD CONSTRAINT fk_cor_nomenclatures_relations_id_nomenclature_l FOREIGN KEY (id_nomenclature_l) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature);


--
-- Name: cor_nomenclatures_relations fk_cor_nomenclatures_relations_id_nomenclature_r; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.cor_nomenclatures_relations
    ADD CONSTRAINT fk_cor_nomenclatures_relations_id_nomenclature_r FOREIGN KEY (id_nomenclature_r) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature);


--
-- Name: cor_taxref_nomenclature fk_cor_taxref_nomenclature_id_nomenclature; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.cor_taxref_nomenclature
    ADD CONSTRAINT fk_cor_taxref_nomenclature_id_nomenclature FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: defaults_nomenclatures_value fk_defaults_nomenclatures_value_id_nomenclature; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.defaults_nomenclatures_value
    ADD CONSTRAINT fk_defaults_nomenclatures_value_id_nomenclature FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--
-- Name: defaults_nomenclatures_value fk_defaults_nomenclatures_value_id_organism; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.defaults_nomenclatures_value
    ADD CONSTRAINT fk_defaults_nomenclatures_value_id_organism FOREIGN KEY (id_organism) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE;


--
-- Name: defaults_nomenclatures_value fk_defaults_nomenclatures_value_mnemonique_type; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.defaults_nomenclatures_value
    ADD CONSTRAINT fk_defaults_nomenclatures_value_mnemonique_type FOREIGN KEY (mnemonique_type) REFERENCES ref_nomenclatures.bib_nomenclatures_types(mnemonique) ON UPDATE CASCADE;


--
-- Name: t_nomenclatures fk_t_nomenclatures_id_broader; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.t_nomenclatures
    ADD CONSTRAINT fk_t_nomenclatures_id_broader FOREIGN KEY (id_broader) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature);


--
-- Name: t_nomenclatures fk_t_nomenclatures_id_type; Type: FK CONSTRAINT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.t_nomenclatures
    ADD CONSTRAINT fk_t_nomenclatures_id_type FOREIGN KEY (id_type) REFERENCES ref_nomenclatures.bib_nomenclatures_types(id_type) ON UPDATE CASCADE;


--
-- Name: bdc_statut_taxons bdc_statut_taxons_cd_nom_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_taxons
    ADD CONSTRAINT bdc_statut_taxons_cd_nom_fkey FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bdc_statut_taxons bdc_statut_taxons_id_value_text_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_taxons
    ADD CONSTRAINT bdc_statut_taxons_id_value_text_fkey FOREIGN KEY (id_value_text) REFERENCES taxonomie.bdc_statut_cor_text_values(id_value_text) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bdc_statut_text bdc_statut_text_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_text
    ADD CONSTRAINT bdc_statut_text_fkey FOREIGN KEY (cd_type_statut) REFERENCES taxonomie.bdc_statut_type(cd_type_statut) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bib_attributs bib_attributs_id_theme_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_attributs
    ADD CONSTRAINT bib_attributs_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES taxonomie.bib_themes(id_theme);


--
-- Name: cor_nom_liste cor_nom_listes_bib_listes_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.cor_nom_liste
    ADD CONSTRAINT cor_nom_listes_bib_listes_fkey FOREIGN KEY (id_liste) REFERENCES taxonomie.bib_listes(id_liste) ON UPDATE CASCADE;


--
-- Name: cor_nom_liste cor_nom_listes_bib_noms_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.cor_nom_liste
    ADD CONSTRAINT cor_nom_listes_bib_noms_fkey FOREIGN KEY (id_nom) REFERENCES taxonomie.bib_noms(id_nom);


--
-- Name: cor_taxon_attribut cor_taxon_attrib_bib_attrib_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.cor_taxon_attribut
    ADD CONSTRAINT cor_taxon_attrib_bib_attrib_fkey FOREIGN KEY (id_attribut) REFERENCES taxonomie.bib_attributs(id_attribut);


--
-- Name: bib_noms fk_bib_nom_taxref; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_noms
    ADD CONSTRAINT fk_bib_nom_taxref FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom);


--
-- Name: t_medias fk_t_media_bib_noms; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.t_medias
    ADD CONSTRAINT fk_t_media_bib_noms FOREIGN KEY (cd_ref) REFERENCES taxonomie.bib_noms(cd_nom) MATCH FULL ON UPDATE CASCADE;


--
-- Name: t_medias fk_t_media_bib_types_media; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.t_medias
    ADD CONSTRAINT fk_t_media_bib_types_media FOREIGN KEY (id_type) REFERENCES taxonomie.bib_types_media(id_type) MATCH FULL ON UPDATE CASCADE;


--
-- Name: taxref fk_taxref_bib_taxref_habitats; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref
    ADD CONSTRAINT fk_taxref_bib_taxref_habitats FOREIGN KEY (id_habitat) REFERENCES taxonomie.bib_taxref_habitats(id_habitat) ON UPDATE CASCADE;


--
-- Name: taxref fk_taxref_bib_taxref_rangs; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref
    ADD CONSTRAINT fk_taxref_bib_taxref_rangs FOREIGN KEY (id_rang) REFERENCES taxonomie.bib_taxref_rangs(id_rang) ON UPDATE CASCADE;


--
-- Name: taxref_liste_rouge_fr fk_taxref_lr_bib_taxref_categories; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_liste_rouge_fr
    ADD CONSTRAINT fk_taxref_lr_bib_taxref_categories FOREIGN KEY (id_categorie_france) REFERENCES taxonomie.bib_taxref_categories_lr(id_categorie_france) ON UPDATE CASCADE;


--
-- Name: taxref taxref_id_statut_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref
    ADD CONSTRAINT taxref_id_statut_fkey FOREIGN KEY (id_statut) REFERENCES taxonomie.bib_taxref_statuts(id_statut) ON UPDATE CASCADE;


--
-- Name: taxref_protection_articles_structure taxref_protection_articles_structure_cd_protect_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_protection_articles_structure
    ADD CONSTRAINT taxref_protection_articles_structure_cd_protect_fkey FOREIGN KEY (cd_protection) REFERENCES taxonomie.taxref_protection_articles(cd_protection);


--
-- Name: taxref_protection_especes taxref_protection_especes_cd_nom_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_protection_especes
    ADD CONSTRAINT taxref_protection_especes_cd_nom_fkey FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE;


--
-- Name: taxref_protection_especes taxref_protection_especes_cd_protection_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.taxref_protection_especes
    ADD CONSTRAINT taxref_protection_especes_cd_protection_fkey FOREIGN KEY (cd_protection) REFERENCES taxonomie.taxref_protection_articles(cd_protection);


--
-- Name: bdc_statut_cor_text_values tbdc_statut_cor_text_values_id_text_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_cor_text_values
    ADD CONSTRAINT tbdc_statut_cor_text_values_id_text_fkey FOREIGN KEY (id_text) REFERENCES taxonomie.bdc_statut_text(id_text) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bdc_statut_cor_text_values tbdc_statut_cor_text_values_id_value_fkey; Type: FK CONSTRAINT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bdc_statut_cor_text_values
    ADD CONSTRAINT tbdc_statut_cor_text_values_id_value_fkey FOREIGN KEY (id_value) REFERENCES taxonomie.bdc_statut_values(id_value) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_role_token cor_role_token_fk_id_role; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_token
    ADD CONSTRAINT cor_role_token_fk_id_role FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_roles cor_roles_id_role_groupe_fkey; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_roles
    ADD CONSTRAINT cor_roles_id_role_groupe_fkey FOREIGN KEY (id_role_groupe) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_roles cor_roles_id_role_utilisateur_fkey; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_roles
    ADD CONSTRAINT cor_roles_id_role_utilisateur_fkey FOREIGN KEY (id_role_utilisateur) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bib_organismes fk_bib_organismes_id_parent; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.bib_organismes
    ADD CONSTRAINT fk_bib_organismes_id_parent FOREIGN KEY (id_parent) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE;


--
-- Name: cor_profil_for_app fk_cor_profil_for_app_id_application; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_profil_for_app
    ADD CONSTRAINT fk_cor_profil_for_app_id_application FOREIGN KEY (id_application) REFERENCES utilisateurs.t_applications(id_application) ON UPDATE CASCADE;


--
-- Name: cor_profil_for_app fk_cor_profil_for_app_id_profil; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_profil_for_app
    ADD CONSTRAINT fk_cor_profil_for_app_id_profil FOREIGN KEY (id_profil) REFERENCES utilisateurs.t_profils(id_profil) ON UPDATE CASCADE;


--
-- Name: cor_role_app_profil fk_cor_role_app_profil_id_application; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_app_profil
    ADD CONSTRAINT fk_cor_role_app_profil_id_application FOREIGN KEY (id_application) REFERENCES utilisateurs.t_applications(id_application) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_role_app_profil fk_cor_role_app_profil_id_profil; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_app_profil
    ADD CONSTRAINT fk_cor_role_app_profil_id_profil FOREIGN KEY (id_profil) REFERENCES utilisateurs.t_profils(id_profil) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_role_app_profil fk_cor_role_app_profil_id_role; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_app_profil
    ADD CONSTRAINT fk_cor_role_app_profil_id_role FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_role_liste fk_cor_role_liste_id_liste; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_liste
    ADD CONSTRAINT fk_cor_role_liste_id_liste FOREIGN KEY (id_liste) REFERENCES utilisateurs.t_listes(id_liste) ON UPDATE CASCADE;


--
-- Name: cor_role_liste fk_cor_role_liste_id_role; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.cor_role_liste
    ADD CONSTRAINT fk_cor_role_liste_id_role FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--
-- Name: t_applications fk_t_applications_id_parent; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_applications
    ADD CONSTRAINT fk_t_applications_id_parent FOREIGN KEY (id_parent) REFERENCES utilisateurs.t_applications(id_application) ON UPDATE CASCADE;


--
-- Name: t_roles t_roles_id_organisme_fkey; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.t_roles
    ADD CONSTRAINT t_roles_id_organisme_fkey FOREIGN KEY (id_organisme) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE;


--
-- Name: temp_users temp_user_id_application_fkey; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.temp_users
    ADD CONSTRAINT temp_user_id_application_fkey FOREIGN KEY (id_organisme) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: temp_users temp_user_id_organisme_fkey; Type: FK CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.temp_users
    ADD CONSTRAINT temp_user_id_organisme_fkey FOREIGN KEY (id_application) REFERENCES utilisateurs.t_applications(id_application) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

