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
-- Name: gn_profiles; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA gn_profiles;


ALTER SCHEMA gn_profiles OWNER TO geonatadmin;

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
-- Name: check_profile_altitudes(integer, integer, integer, integer); Type: FUNCTION; Schema: gn_profiles; Owner: geonatadmin
--

CREATE FUNCTION gn_profiles.check_profile_altitudes(in_alt_min integer, in_alt_max integer, profil_altitude_min integer, profil_altitude_max integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
   BEGIN
    RETURN in_alt_min >= profil_altitude_min AND
      in_alt_max <= profil_altitude_max;
  END;
$$;


ALTER FUNCTION gn_profiles.check_profile_altitudes(in_alt_min integer, in_alt_max integer, profil_altitude_min integer, profil_altitude_max integer) OWNER TO geonatadmin;

--
-- Name: check_profile_distribution(public.geometry, public.geometry); Type: FUNCTION; Schema: gn_profiles; Owner: geonatadmin
--

CREATE FUNCTION gn_profiles.check_profile_distribution(in_geom public.geometry, profil_geom public.geometry) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de vérifier la cohérence d'une donnée d'occurrence en s'assurant que sa
--localisation est totalement incluse dans l'aire d'occurrences valide définie par le profil du
--taxon en question
  BEGIN
     RETURN ST_Contains(profil_geom, in_geom);
  END;
$$;


ALTER FUNCTION gn_profiles.check_profile_distribution(in_geom public.geometry, profil_geom public.geometry) OWNER TO geonatadmin;

--
-- Name: check_profile_phenology(integer, date, date, integer, integer, integer, boolean); Type: FUNCTION; Schema: gn_profiles; Owner: geonatadmin
--

CREATE FUNCTION gn_profiles.check_profile_phenology(in_cd_ref integer, in_date_min date, in_date_max date, in_altitude_min integer, in_altitude_max integer, in_id_nomenclature_life_stage integer, check_life_stage boolean) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
  BEGIN


  IF check_life_stage THEN
    -- Suppression des valeurs inconnue et non renseignée
    IF
        in_id_nomenclature_life_stage = ref_nomenclatures.get_id_nomenclature('STADE_VIE', '0')
        OR
        in_id_nomenclature_life_stage = ref_nomenclatures.get_id_nomenclature('STADE_VIE', '1')
    THEN
        in_id_nomenclature_life_stage := NULL;
    END IF;

    RETURN EXISTS (
        SELECT *
        FROM gn_profiles.vm_cor_taxon_phenology c
        WHERE in_cd_ref = c.cd_ref
            AND date_part('doy', in_date_min) >= c.doy_min
            AND date_part('doy', in_date_max) <= c.doy_max
            AND in_altitude_min >= calculated_altitude_min
            AND in_altitude_max <= calculated_altitude_max
            AND in_id_nomenclature_life_stage = c.id_nomenclature_life_stage
    );
  ELSE
      RETURN EXISTS (
        SELECT *
        FROM gn_profiles.vm_cor_taxon_phenology c
        WHERE in_cd_ref = c.cd_ref
            AND date_part('doy', in_date_min) >= c.doy_min
            AND date_part('doy', in_date_max) <= c.doy_max
            AND in_altitude_min >= calculated_altitude_min
            AND in_altitude_max <= calculated_altitude_max
    );
   END IF;
  END;
$$;


ALTER FUNCTION gn_profiles.check_profile_phenology(in_cd_ref integer, in_date_min date, in_date_max date, in_altitude_min integer, in_altitude_max integer, in_id_nomenclature_life_stage integer, check_life_stage boolean) OWNER TO geonatadmin;

--
-- Name: get_parameters(integer); Type: FUNCTION; Schema: gn_profiles; Owner: geonatadmin
--

CREATE FUNCTION gn_profiles.get_parameters(my_cd_nom integer) RETURNS TABLE(cd_ref integer, spatial_precision integer, temporal_precision_days integer, active_life_stage boolean, distance smallint)
    LANGUAGE plpgsql IMMUTABLE
    AS $$
-- fonction permettant de récupérer les paramètres les plus adaptés
-- (définis au plus proche du taxon) pour calculer le profil d'un taxon donné
-- par exemple, s'il existe des paramètres pour les "Animalia" des paramètres pour le renard,
-- les paramètres du renard surcoucheront les paramètres Animalia pour cette espèce
  DECLARE
   my_cd_ref integer := t.cd_ref FROM taxonomie.taxref t WHERE t.cd_nom=my_cd_nom;
  BEGIN
   RETURN QUERY
    WITH all_parameters AS (
     SELECT my_cd_ref, param.spatial_precision, param.temporal_precision_days,
     param.active_life_stage, parents.distance
     FROM gn_profiles.cor_taxons_parameters param
   JOIN taxonomie.find_all_taxons_parents(my_cd_ref) parents ON parents.cd_nom=param.cd_nom)
  SELECT * FROM all_parameters all_param WHERE all_param.distance=(
   SELECT min(all_param2.distance) FROM all_parameters all_param2
  )
   ;
  END;
$$;


ALTER FUNCTION gn_profiles.get_parameters(my_cd_nom integer) OWNER TO geonatadmin;

--
-- Name: refresh_profiles(); Type: FUNCTION; Schema: gn_profiles; Owner: geonatadmin
--

CREATE FUNCTION gn_profiles.refresh_profiles() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- Rafraichissement des vues matérialisées des profils
-- USAGE : SELECT gn_profiles.refresh_profiles()
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY gn_profiles.vm_valid_profiles;
  REFRESH MATERIALIZED VIEW CONCURRENTLY gn_profiles.vm_cor_taxon_phenology;
END
$$;


ALTER FUNCTION gn_profiles.refresh_profiles() OWNER TO geonatadmin;

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
            sensitivity integer;
        BEGIN
            -- Paramètres durée, zone géographique, période de l'observation et critères biologique
            SELECT INTO sensitivity r.id_nomenclature_sensitivity
            FROM gn_sensitivity.t_sensitivity_rules_cd_ref r
            JOIN ref_nomenclatures.t_nomenclatures n ON n.id_nomenclature = r.id_nomenclature_sensitivity
            LEFT OUTER JOIN gn_sensitivity.cor_sensitivity_area USING(id_sensitivity)
            LEFT OUTER JOIN ref_geo.l_areas a USING(id_area)
            LEFT OUTER JOIN gn_sensitivity.cor_sensitivity_criteria c USING(id_sensitivity)
            WHERE
                ( -- taxon
                    my_cd_ref = r.cd_ref
                ) AND ( -- zone géographique de validité
                    a.geom IS NULL -- pas de restriction géographique à la validité de la règle
                    OR
                    st_intersects(my_geom, a.geom)
                ) AND ( -- période de validité
                    to_char(my_date_obs, 'MMDD') between to_char(r.date_min, 'MMDD') and to_char(r.date_max, 'MMDD')
                ) AND ( -- durée de validité
                    (date_part('year', CURRENT_TIMESTAMP) - r.sensitivity_duration) <= date_part('year', my_date_obs)
                ) AND ( -- critère
                    c.id_criteria IS NULL -- règle sans restriction de critère
                    OR
                    -- Note: no need to check criteria type, as we use id_nomenclature which can not conflict
                    c.id_criteria IN (SELECT value::int FROM jsonb_each_text(my_criterias))
                )
            ORDER BY n.cd_nomenclature DESC;

            IF sensitivity IS NULL THEN
                sensitivity := (SELECT ref_nomenclatures.get_id_nomenclature('SENSIBILITE'::text, '0'::text));
            END IF;

            return sensitivity;
        END;
        $$;


ALTER FUNCTION gn_sensitivity.get_id_nomenclature_sensitivity(my_date_obs date, my_cd_ref integer, my_geom public.geometry, my_criterias jsonb) OWNER TO geonatadmin;

--
-- Name: fct_tri_calculate_sensitivity_on_each_statement(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_tri_calculate_sensitivity_on_each_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
            -- Calculate sensitivity on insert in synthese
            BEGIN
            WITH cte AS (
              SELECT 
                id_synthese,
                gn_sensitivity.get_id_nomenclature_sensitivity(
                  new_row.date_min::date, 
                  taxonomie.find_cdref(new_row.cd_nom), 
                  new_row.the_geom_local,
                  jsonb_build_object(
                    'STATUT_BIO', new_row.id_nomenclature_bio_status,
                    'OCC_COMPORTEMENT', new_row.id_nomenclature_behaviour
                  )
                ) AS id_nomenclature_sensitivity
              FROM
                NEW AS new_row
            )
            UPDATE
              gn_synthese.synthese AS s
            SET 
              id_nomenclature_sensitivity = c.id_nomenclature_sensitivity
            FROM
              cte AS c
            WHERE
              c.id_synthese = s.id_synthese
            ;
            RETURN NULL;
            END;
          $$;


ALTER FUNCTION gn_synthese.fct_tri_calculate_sensitivity_on_each_statement() OWNER TO geonatadmin;

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
-- Name: fct_tri_update_sensitivity_on_each_row(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_tri_update_sensitivity_on_each_row() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
            -- Calculate sensitivity on update in synthese
            BEGIN
            NEW.id_nomenclature_sensitivity = gn_sensitivity.get_id_nomenclature_sensitivity(
                NEW.date_min::date, 
                taxonomie.find_cdref(NEW.cd_nom), 
                NEW.the_geom_local,
                jsonb_build_object(
                  'STATUT_BIO', NEW.id_nomenclature_bio_status,
                  'OCC_COMPORTEMENT', NEW.id_nomenclature_behaviour
                )
            );
            RETURN NEW;
            END;
          $$;


ALTER FUNCTION gn_synthese.fct_tri_update_sensitivity_on_each_row() OWNER TO geonatadmin;

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
-- Name: fct_trig_l_areas_insert_cor_area_synthese_on_each_statement(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.fct_trig_l_areas_insert_cor_area_synthese_on_each_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
      BEGIN
      -- Intersection de toutes les observations avec les nouvelles zones et écriture dans cor_area_synthese
          INSERT INTO gn_synthese.cor_area_synthese (id_area, id_synthese)
            SELECT
              new_areas.id_area AS id_area,
              s.id_synthese as id_synthese
            FROM NEW as new_areas
            join gn_synthese.synthese s
              ON public.ST_INTERSECTS(s.the_geom_local, new_areas.geom)
            WHERE new_areas.enable IS true
                AND (
                        ST_GeometryType(s.the_geom_local) = 'ST_Point'
                    OR
                    NOT public.ST_TOUCHES(s.the_geom_local, new_areas.geom)
                );
      RETURN NULL;
      END;
      $$;


ALTER FUNCTION gn_synthese.fct_trig_l_areas_insert_cor_area_synthese_on_each_statement() OWNER TO geonatadmin;

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

CREATE FUNCTION gn_synthese.get_default_nomenclature_value(myidtype character varying, myidorganism integer DEFAULT NULL::integer, myregne character varying DEFAULT '0'::character varying, mygroup2inpn character varying DEFAULT '0'::character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    --Function that return the default nomenclature id with wanteds nomenclature type, organism id, regne, group2_inpn
    --Return -1 if nothing matche with given parameters
      DECLARE
        thenomenclatureid integer;
      BEGIN
          SELECT INTO thenomenclatureid id_nomenclature FROM (
            SELECT
                id_nomenclature,
                regne,
                group2_inpn,
                CASE
                    WHEN n.id_organism = myidorganism THEN 1
                    ELSE 0
                END prio_organisme
            FROM gn_synthese.defaults_nomenclatures_value n
            JOIN utilisateurs.bib_organismes o
            ON o.id_organisme = n.id_organism
            WHERE mnemonique_type = myidtype
            AND (n.id_organism = myidorganism OR n.id_organism = NULL OR o.nom_organisme = 'ALL')
            AND (regne = myregne OR regne = '0')
            AND (group2_inpn = mygroup2inpn OR group2_inpn = '0')
        ) AS defaults_nomenclatures_value
        ORDER BY group2_inpn DESC, regne DESC, prio_organisme DESC LIMIT 1;
        RETURN thenomenclatureid;
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
-- Name: update_sensitivity(); Type: FUNCTION; Schema: gn_synthese; Owner: geonatadmin
--

CREATE FUNCTION gn_synthese.update_sensitivity() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        DECLARE
            affected_rows_count int;
        BEGIN
            WITH cte AS (
                SELECT 
                    id_synthese,
                    id_nomenclature_sensitivity AS old_sensitivity,
                    gn_sensitivity.get_id_nomenclature_sensitivity(
                      date_min::date,
                      taxonomie.find_cdref(cd_nom),
                      the_geom_local,
                      jsonb_build_object(
                        'STATUT_BIO', id_nomenclature_bio_status,
                        'OCC_COMPORTEMENT', id_nomenclature_behaviour
                      )
                    ) AS new_sensitivity
                FROM
                    gn_synthese.synthese
                WHERE
                    id_nomenclature_sensitivity != ref_nomenclatures.get_id_nomenclature('SENSIBILITE', '0') -- non sensible
                OR
                    taxonomie.find_cdref(cd_nom) IN (SELECT DISTINCT cd_ref FROM gn_sensitivity.t_sensitivity_rules_cd_ref)
            )
            UPDATE
                gn_synthese.synthese s
            SET
                id_nomenclature_sensitivity = new_sensitivity
            FROM
                cte
            WHERE
                    s.id_synthese = cte.id_synthese
                AND
                    old_sensitivity != new_sensitivity;
            GET DIAGNOSTICS affected_rows_count = ROW_COUNT;
            RETURN affected_rows_count;
        END;
    $$;


ALTER FUNCTION gn_synthese.update_sensitivity() OWNER TO geonatadmin;

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
-- Name: get_id_role_by_name(character varying); Type: FUNCTION; Schema: utilisateurs; Owner: geonatadmin
--

CREATE FUNCTION utilisateurs.get_id_role_by_name(rolename character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
        BEGIN
            RETURN (
                SELECT id_role
                FROM utilisateurs.t_roles
                WHERE nom_role = roleName
            );
        END;
    $$;


ALTER FUNCTION utilisateurs.get_id_role_by_name(rolename character varying) OWNER TO geonatadmin;

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
    field_order integer,
    default_value text
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
-- Name: cor_taxons_parameters; Type: TABLE; Schema: gn_profiles; Owner: geonatadmin
--

CREATE TABLE gn_profiles.cor_taxons_parameters (
    cd_nom integer NOT NULL,
    spatial_precision integer,
    temporal_precision_days integer,
    active_life_stage boolean DEFAULT false
);


ALTER TABLE gn_profiles.cor_taxons_parameters OWNER TO geonatadmin;

--
-- Name: t_parameters; Type: TABLE; Schema: gn_profiles; Owner: geonatadmin
--

CREATE TABLE gn_profiles.t_parameters (
    id_parameter integer NOT NULL,
    name character varying(100) NOT NULL,
    "desc" text,
    value text NOT NULL
);


ALTER TABLE gn_profiles.t_parameters OWNER TO geonatadmin;

--
-- Name: TABLE t_parameters; Type: COMMENT; Schema: gn_profiles; Owner: geonatadmin
--

COMMENT ON TABLE gn_profiles.t_parameters IS 'Define global parameters for profiles calculation';


--
-- Name: t_parameters_id_parameter_seq; Type: SEQUENCE; Schema: gn_profiles; Owner: geonatadmin
--

CREATE SEQUENCE gn_profiles.t_parameters_id_parameter_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gn_profiles.t_parameters_id_parameter_seq OWNER TO geonatadmin;

--
-- Name: t_parameters_id_parameter_seq; Type: SEQUENCE OWNED BY; Schema: gn_profiles; Owner: geonatadmin
--

ALTER SEQUENCE gn_profiles.t_parameters_id_parameter_seq OWNED BY gn_profiles.t_parameters.id_parameter;


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
-- Name: v_synthese_for_profiles; Type: VIEW; Schema: gn_profiles; Owner: geonatadmin
--

CREATE VIEW gn_profiles.v_synthese_for_profiles AS
 WITH excluded_live_stage AS (
         SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE'::character varying, '0'::character varying) AS id_n_excluded
        UNION
         SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE'::character varying, '1'::character varying) AS id_n_excluded
        )
 SELECT s.id_synthese,
    s.cd_nom,
    s.nom_cite,
    t.cd_ref,
    t.nom_valide,
    t.id_rang,
    s.date_min,
    s.date_max,
    s.the_geom_local,
    s.the_geom_4326,
    s.altitude_min,
    s.altitude_max,
        CASE
            WHEN (s.id_nomenclature_life_stage IN ( SELECT excluded_live_stage.id_n_excluded
               FROM excluded_live_stage)) THEN NULL::integer
            ELSE s.id_nomenclature_life_stage
        END AS id_nomenclature_life_stage,
    s.id_nomenclature_valid_status,
    p.spatial_precision,
    p.temporal_precision_days,
    p.active_life_stage,
    p.distance
   FROM ((gn_synthese.synthese s
     LEFT JOIN taxonomie.taxref t ON ((s.cd_nom = t.cd_nom)))
     CROSS JOIN LATERAL gn_profiles.get_parameters(s.cd_nom) p(cd_ref, spatial_precision, temporal_precision_days, active_life_stage, distance))
  WHERE ((p.spatial_precision IS NOT NULL) AND (public.st_maxdistance(public.st_centroid(s.the_geom_local), s.the_geom_local) < (p.spatial_precision)::double precision) AND (s.altitude_max IS NOT NULL) AND (s.altitude_min IS NOT NULL) AND (s.id_nomenclature_valid_status IN ( SELECT (regexp_split_to_table(t_parameters.value, ','::text))::integer AS regexp_split_to_table
           FROM gn_profiles.t_parameters
          WHERE ((t_parameters.name)::text = 'id_valid_status_for_profiles'::text))) AND ((t.id_rang)::text IN ( SELECT regexp_split_to_table(t_parameters.value, ','::text) AS regexp_split_to_table
           FROM gn_profiles.t_parameters
          WHERE ((t_parameters.name)::text = 'id_rang_for_profiles'::text))));


ALTER TABLE gn_profiles.v_synthese_for_profiles OWNER TO geonatadmin;

--
-- Name: VIEW v_synthese_for_profiles; Type: COMMENT; Schema: gn_profiles; Owner: geonatadmin
--

COMMENT ON VIEW gn_profiles.v_synthese_for_profiles IS 'View containing synthese data feeding profiles calculation.
 cd_ref, date_min, date_max, the_geom_local, altitude_min, altitude_max and
 id_nomenclature_life_stage fields are mandatory.
 WHERE clauses have to apply your t_parameters filters (valid_status)';


--
-- Name: vm_valid_profiles; Type: MATERIALIZED VIEW; Schema: gn_profiles; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW gn_profiles.vm_valid_profiles AS
 SELECT DISTINCT vsfp.cd_ref,
    public.st_union(public.st_buffer(vsfp.the_geom_local, (COALESCE(vsfp.spatial_precision, 1))::double precision)) AS valid_distribution,
    min(vsfp.altitude_min) AS altitude_min,
    max(vsfp.altitude_max) AS altitude_max,
    min(vsfp.date_min) AS first_valid_data,
    max(vsfp.date_max) AS last_valid_data,
    count(vsfp.*) AS count_valid_data,
    vsfp.active_life_stage
   FROM gn_profiles.v_synthese_for_profiles vsfp
  GROUP BY vsfp.cd_ref, vsfp.active_life_stage
  WITH NO DATA;


ALTER TABLE gn_profiles.vm_valid_profiles OWNER TO geonatadmin;

--
-- Name: v_consistancy_data; Type: VIEW; Schema: gn_profiles; Owner: geonatadmin
--

CREATE VIEW gn_profiles.v_consistancy_data AS
 SELECT s.id_synthese,
    s.unique_id_sinp AS id_sinp,
    t.cd_ref,
    t.lb_nom AS valid_name,
    gn_profiles.check_profile_distribution(s.the_geom_local, p.valid_distribution) AS valid_distribution,
    gn_profiles.check_profile_phenology(t.cd_ref, (s.date_min)::date, (s.date_max)::date, s.altitude_min, s.altitude_max, s.id_nomenclature_life_stage, p.active_life_stage) AS valid_phenology,
    gn_profiles.check_profile_altitudes(s.altitude_min, s.altitude_max, p.altitude_min, p.altitude_max) AS valid_altitude,
    n.label_default AS valid_status
   FROM (((gn_synthese.synthese s
     JOIN taxonomie.taxref t ON ((s.cd_nom = t.cd_nom)))
     JOIN gn_profiles.vm_valid_profiles p ON ((p.cd_ref = t.cd_ref)))
     LEFT JOIN ref_nomenclatures.t_nomenclatures n ON ((s.id_nomenclature_valid_status = n.id_nomenclature)));


ALTER TABLE gn_profiles.v_consistancy_data OWNER TO geonatadmin;

--
-- Name: v_decode_profiles_parameters; Type: VIEW; Schema: gn_profiles; Owner: geonatadmin
--

CREATE VIEW gn_profiles.v_decode_profiles_parameters AS
 SELECT t.cd_ref,
    t.lb_nom,
    t.id_rang,
    p.spatial_precision,
    p.temporal_precision_days,
    p.active_life_stage
   FROM (gn_profiles.cor_taxons_parameters p
     LEFT JOIN taxonomie.taxref t ON ((p.cd_nom = t.cd_nom)));


ALTER TABLE gn_profiles.v_decode_profiles_parameters OWNER TO geonatadmin;

--
-- Name: vm_cor_taxon_phenology; Type: MATERIALIZED VIEW; Schema: gn_profiles; Owner: geonatadmin
--

CREATE MATERIALIZED VIEW gn_profiles.vm_cor_taxon_phenology AS
 WITH exlude_live_stage AS (
         SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE'::character varying, '0'::character varying) AS id_n_excluded
        UNION
         SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE'::character varying, '1'::character varying) AS id_n_excluded
        ), params AS (
         SELECT ((parameters.value)::double precision / (100)::double precision) AS proportion_kept_data
           FROM gn_profiles.t_parameters parameters
          WHERE ((parameters.name)::text = 'proportion_kept_data'::text)
        ), classified_data AS (
         SELECT DISTINCT vsfp.cd_ref,
            unnest(ARRAY[(floor((date_part('doy'::text, vsfp.date_min) / (vsfp.temporal_precision_days)::double precision)) * (vsfp.temporal_precision_days)::double precision), (floor((date_part('doy'::text, vsfp.date_max) / (vsfp.temporal_precision_days)::double precision)) * (vsfp.temporal_precision_days)::double precision)]) AS doy_min,
            unnest(ARRAY[((floor((date_part('doy'::text, vsfp.date_min) / (vsfp.temporal_precision_days)::double precision)) * (vsfp.temporal_precision_days)::double precision) + (vsfp.temporal_precision_days)::double precision), ((floor((date_part('doy'::text, vsfp.date_max) / (vsfp.temporal_precision_days)::double precision)) * (vsfp.temporal_precision_days)::double precision) + (vsfp.temporal_precision_days)::double precision)]) AS doy_max,
                CASE
                    WHEN ((vsfp.active_life_stage = true) AND (NOT (vsfp.id_nomenclature_life_stage IN ( SELECT exlude_live_stage.id_n_excluded
                       FROM exlude_live_stage)))) THEN vsfp.id_nomenclature_life_stage
                    ELSE NULL::integer
                END AS id_nomenclature_life_stage,
            count(vsfp.*) AS count_valid_data,
            min(vsfp.altitude_min) AS extreme_altitude_min,
            percentile_disc(( SELECT params.proportion_kept_data
                   FROM params)) WITHIN GROUP (ORDER BY vsfp.altitude_min DESC) AS p_min,
            max(vsfp.altitude_max) AS extreme_altitude_max,
            percentile_disc(( SELECT params.proportion_kept_data
                   FROM params)) WITHIN GROUP (ORDER BY vsfp.altitude_max) AS p_max
           FROM gn_profiles.v_synthese_for_profiles vsfp
          WHERE ((vsfp.temporal_precision_days IS NOT NULL) AND (vsfp.spatial_precision IS NOT NULL) AND (vsfp.active_life_stage IS NOT NULL) AND (date_part('day'::text, (vsfp.date_max - vsfp.date_min)) < (vsfp.temporal_precision_days)::double precision) AND (vsfp.altitude_min IS NOT NULL) AND (vsfp.altitude_max IS NOT NULL))
          GROUP BY vsfp.cd_ref, (unnest(ARRAY[(floor((date_part('doy'::text, vsfp.date_min) / (vsfp.temporal_precision_days)::double precision)) * (vsfp.temporal_precision_days)::double precision), (floor((date_part('doy'::text, vsfp.date_max) / (vsfp.temporal_precision_days)::double precision)) * (vsfp.temporal_precision_days)::double precision)])), (unnest(ARRAY[((floor((date_part('doy'::text, vsfp.date_min) / (vsfp.temporal_precision_days)::double precision)) * (vsfp.temporal_precision_days)::double precision) + (vsfp.temporal_precision_days)::double precision), ((floor((date_part('doy'::text, vsfp.date_max) / (vsfp.temporal_precision_days)::double precision)) * (vsfp.temporal_precision_days)::double precision) + (vsfp.temporal_precision_days)::double precision)])),
                CASE
                    WHEN ((vsfp.active_life_stage = true) AND (NOT (vsfp.id_nomenclature_life_stage IN ( SELECT exlude_live_stage.id_n_excluded
                       FROM exlude_live_stage)))) THEN vsfp.id_nomenclature_life_stage
                    ELSE NULL::integer
                END
        )
 SELECT classified_data.cd_ref,
    classified_data.doy_min,
    classified_data.doy_max,
    classified_data.id_nomenclature_life_stage,
    classified_data.count_valid_data,
    classified_data.extreme_altitude_min,
    classified_data.p_min AS calculated_altitude_min,
    classified_data.extreme_altitude_max,
    classified_data.p_max AS calculated_altitude_max
   FROM classified_data
  WITH NO DATA;


ALTER TABLE gn_profiles.vm_cor_taxon_phenology OWNER TO geonatadmin;

--
-- Name: MATERIALIZED VIEW vm_cor_taxon_phenology; Type: COMMENT; Schema: gn_profiles; Owner: geonatadmin
--

COMMENT ON MATERIALIZED VIEW gn_profiles.vm_cor_taxon_phenology IS 'View containing phenological combinations and corresponding valid data for each taxa';


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
    id_parent integer,
    additional_data jsonb DEFAULT '{}'::jsonb
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
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: geonatadmin
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO geonatadmin;

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
             LEFT JOIN utilisateurs.bib_organismes o ON ((o.id_organisme = u.id_organisme)))
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
 SELECT d.groupe,
    d.active,
    d.id_role,
    d.identifiant,
    d.nom_role,
    d.prenom_role,
    d.desc_role,
    d.pass,
    d.pass_plus,
    d.email,
    d.id_organisme,
    d.organisme,
    d.id_unite,
    d.remarques,
    d.date_insert,
    d.date_update,
    d.id_droit_max,
    d.id_application
   FROM utilisateurs.v_roleslist_forall_applications d
  WHERE (d.groupe = false);


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
-- Name: t_parameters id_parameter; Type: DEFAULT; Schema: gn_profiles; Owner: geonatadmin
--

ALTER TABLE ONLY gn_profiles.t_parameters ALTER COLUMN id_parameter SET DEFAULT nextval('gn_profiles.t_parameters_id_parameter_seq'::regclass);


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
-- Data for Name: bib_tables_location; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.bib_tables_location (id_table_location, table_desc, schema_name, table_name, pk_field, uuid_field_name) FROM stdin;
1	Regroupement de tous les médias de GeoNature	gn_commons	t_medias	id_media	unique_id_media
2	Table centralisant les sites faisant l'objet de protocole de suivis	gn_monitoring	t_base_sites	id_base_site	uuid_base_site
3	Table centralisant les visites réalisées sur un site	gn_monitoring	t_base_visits	id_base_visit	uuid_base_visit
4	Liste des observateurs d'une visite	gn_monitoring	cor_visit_observer	unique_id_core_visit_observer	unique_id_core_visit_observer
\.


--
-- Data for Name: bib_widgets; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.bib_widgets (id_widget, widget_name) FROM stdin;
1	select
2	checkbox
3	nomenclature
4	text
5	textarea
6	radio
7	time
8	bool_radio
9	date
10	multiselect
11	number
12	html
\.


--
-- Data for Name: cor_field_dataset; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.cor_field_dataset (id_field, id_dataset) FROM stdin;
\.


--
-- Data for Name: cor_field_module; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.cor_field_module (id_field, id_module) FROM stdin;
\.


--
-- Data for Name: cor_field_object; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.cor_field_object (id_field, id_object) FROM stdin;
\.


--
-- Data for Name: cor_module_dataset; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.cor_module_dataset (id_module, id_dataset) FROM stdin;
\.


--
-- Data for Name: t_additional_fields; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.t_additional_fields (id_field, field_name, field_label, required, description, id_widget, quantitative, unity, additional_attributes, code_nomenclature_type, field_values, multiselect, id_list, key_label, key_value, api, exportable, field_order, default_value) FROM stdin;
\.


--
-- Data for Name: t_history_actions; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.t_history_actions (id_history_action, id_table_location, uuid_attached_row, operation_type, operation_date, table_content) FROM stdin;
\.


--
-- Data for Name: t_medias; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.t_medias (id_media, unique_id_media, id_nomenclature_media_type, id_table_location, uuid_attached_row, title_fr, title_en, title_it, title_es, title_de, media_url, media_path, author, description_fr, description_en, description_it, description_es, description_de, is_public, meta_create_date, meta_update_date) FROM stdin;
\.


--
-- Data for Name: t_mobile_apps; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.t_mobile_apps (id_mobile_app, app_code, relative_path_apk, url_apk, package, version_code) FROM stdin;
\.


--
-- Data for Name: t_modules; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.t_modules (id_module, module_code, module_label, module_picto, module_desc, module_group, module_path, module_external_url, module_target, module_comment, active_frontend, active_backend, module_doc_url, module_order, type, meta_create_date, meta_update_date) FROM stdin;
0	GEONATURE	GeoNature		Module parent de tous les modules sur lequel on peut associer un CRUVED. NB: mettre active_frontend et active_backend à false pour qu'il ne s'affiche pas dans la barre latérale des modules	\N	/geonature	\N			f	f	http://docs.geonature.fr/user-manual.html	\N	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
1	ADMIN	Admin	fa-cog	Backoffice de GeoNature	\N	admin	\N	_self	Administration des métadonnées et des nomenclatures	t	f	http://docs.geonature.fr/user-manual.html#admin	\N	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
2	METADATA	Metadonnées	fa-book	Module de gestion des métadonnées	\N	metadata	\N	_self	\N	t	t	http://docs.geonature.fr/user-manual.html#metadonnees	\N	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
3	SYNTHESE	Synthese	fa-search	Application synthese	\N	synthese	\N	_self	\N	t	t	http://docs.geonature.fr/user-manual.html#synthese	\N	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
\.


--
-- Data for Name: t_parameters; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.t_parameters (id_parameter, id_organism, parameter_name, parameter_desc, parameter_value, parameter_extra_value) FROM stdin;
1	2	taxref_version	Version du référentiel taxonomique	Taxref V14.0	\N
2	2	local_srid	Valeur du SRID local	2154	\N
3	2	annee_ref_commune	Année du référentiel géographique des communes utilisé	2017	\N
4	2	occtaxmobile_area_type	Type de zonage pour lequel la couleur des taxons est calculée pour Occtax-mobile	M5	\N
\.


--
-- Data for Name: t_places; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.t_places (id_place, id_role, place_name, place_geom) FROM stdin;
\.


--
-- Data for Name: t_validations; Type: TABLE DATA; Schema: gn_commons; Owner: geonatadmin
--

COPY gn_commons.t_validations (id_validation, uuid_attached_row, id_nomenclature_valid_status, validation_auto, id_validator, validation_comment, validation_date) FROM stdin;
\.


--
-- Data for Name: matching_fields; Type: TABLE DATA; Schema: gn_imports; Owner: geonatadmin
--

COPY gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) FROM stdin;
\.


--
-- Data for Name: matching_geoms; Type: TABLE DATA; Schema: gn_imports; Owner: geonatadmin
--

COPY gn_imports.matching_geoms (id_matching_geom, source_x_field, source_y_field, source_geom_field, source_geom_format, source_srid, target_geom_field, target_geom_srid, geom_comments, id_matching_table) FROM stdin;
\.


--
-- Data for Name: matching_tables; Type: TABLE DATA; Schema: gn_imports; Owner: geonatadmin
--

COPY gn_imports.matching_tables (id_matching_table, source_schema, source_table, target_schema, target_table, matching_comments) FROM stdin;
\.


--
-- Data for Name: cor_acquisition_framework_actor; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.cor_acquisition_framework_actor (id_cafa, id_acquisition_framework, id_role, id_organism, id_nomenclature_actor_role) FROM stdin;
\.


--
-- Data for Name: cor_acquisition_framework_objectif; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.cor_acquisition_framework_objectif (id_acquisition_framework, id_nomenclature_objectif) FROM stdin;
\.


--
-- Data for Name: cor_acquisition_framework_publication; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.cor_acquisition_framework_publication (id_acquisition_framework, id_publication) FROM stdin;
\.


--
-- Data for Name: cor_acquisition_framework_territory; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.cor_acquisition_framework_territory (id_acquisition_framework, id_nomenclature_territory) FROM stdin;
\.


--
-- Data for Name: cor_acquisition_framework_voletsinp; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.cor_acquisition_framework_voletsinp (id_acquisition_framework, id_nomenclature_voletsinp) FROM stdin;
\.


--
-- Data for Name: cor_dataset_actor; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.cor_dataset_actor (id_cda, id_dataset, id_role, id_organism, id_nomenclature_actor_role) FROM stdin;
\.


--
-- Data for Name: cor_dataset_protocol; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.cor_dataset_protocol (id_dataset, id_protocol) FROM stdin;
\.


--
-- Data for Name: cor_dataset_territory; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.cor_dataset_territory (id_dataset, id_nomenclature_territory, territory_desc) FROM stdin;
\.


--
-- Data for Name: sinp_datatype_protocols; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.sinp_datatype_protocols (id_protocol, unique_protocol_id, protocol_name, protocol_desc, id_nomenclature_protocol_type, protocol_url) FROM stdin;
\.


--
-- Data for Name: sinp_datatype_publications; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.sinp_datatype_publications (id_publication, unique_publication_id, publication_reference, publication_url) FROM stdin;
\.


--
-- Data for Name: t_acquisition_frameworks; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.t_acquisition_frameworks (id_acquisition_framework, unique_acquisition_framework_id, acquisition_framework_name, acquisition_framework_desc, id_nomenclature_territorial_level, territory_desc, keywords, id_nomenclature_financing_type, target_description, ecologic_or_geologic_target, acquisition_framework_parent_id, is_parent, opened, id_digitizer, acquisition_framework_start_date, acquisition_framework_end_date, meta_create_date, meta_update_date, initial_closing_date) FROM stdin;
\.


--
-- Data for Name: t_bibliographical_references; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.t_bibliographical_references (id_bibliographic_reference, id_acquisition_framework, publication_url, publication_reference) FROM stdin;
\.


--
-- Data for Name: t_datasets; Type: TABLE DATA; Schema: gn_meta; Owner: geonatadmin
--

COPY gn_meta.t_datasets (id_dataset, unique_dataset_id, id_acquisition_framework, dataset_name, dataset_shortname, dataset_desc, id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, active, validable, id_digitizer, id_taxa_list, meta_create_date, meta_update_date) FROM stdin;
\.


--
-- Data for Name: cor_site_area; Type: TABLE DATA; Schema: gn_monitoring; Owner: geonatadmin
--

COPY gn_monitoring.cor_site_area (id_base_site, id_area) FROM stdin;
\.


--
-- Data for Name: cor_site_module; Type: TABLE DATA; Schema: gn_monitoring; Owner: geonatadmin
--

COPY gn_monitoring.cor_site_module (id_base_site, id_module) FROM stdin;
\.


--
-- Data for Name: cor_visit_observer; Type: TABLE DATA; Schema: gn_monitoring; Owner: geonatadmin
--

COPY gn_monitoring.cor_visit_observer (id_base_visit, id_role, unique_id_core_visit_observer) FROM stdin;
\.


--
-- Data for Name: t_base_sites; Type: TABLE DATA; Schema: gn_monitoring; Owner: geonatadmin
--

COPY gn_monitoring.t_base_sites (id_base_site, id_inventor, id_digitiser, id_nomenclature_type_site, base_site_name, base_site_description, base_site_code, first_use_date, geom, geom_local, altitude_min, altitude_max, uuid_base_site, meta_create_date, meta_update_date) FROM stdin;
\.


--
-- Data for Name: t_base_visits; Type: TABLE DATA; Schema: gn_monitoring; Owner: geonatadmin
--

COPY gn_monitoring.t_base_visits (id_base_visit, id_base_site, id_dataset, id_module, id_digitiser, visit_date_min, visit_date_max, id_nomenclature_tech_collect_campanule, id_nomenclature_grp_typ, comments, uuid_base_visit, meta_create_date, meta_update_date) FROM stdin;
\.


--
-- Data for Name: bib_filters_type; Type: TABLE DATA; Schema: gn_permissions; Owner: geonatadmin
--

COPY gn_permissions.bib_filters_type (id_filter_type, code_filter_type, label_filter_type, description_filter_type) FROM stdin;
1	SCOPE	Permissions de type Portée	Filtre de type Portée
2	SENSITIVITY	Permissions de type Sensibilité	Permission de type Sensibilité
3	GEOGRAPHIC	Permissions de type Géographique	Ajouter des id_area séparés par des virgules
4	TAXONOMIC	Permissions de type Taxonomique	Ajouter des cd_nom séparés par des virgules
\.


--
-- Data for Name: cor_filter_type_module; Type: TABLE DATA; Schema: gn_permissions; Owner: geonatadmin
--

COPY gn_permissions.cor_filter_type_module (id_filter_type, id_module) FROM stdin;
\.


--
-- Data for Name: cor_object_module; Type: TABLE DATA; Schema: gn_permissions; Owner: geonatadmin
--

COPY gn_permissions.cor_object_module (id_cor_object_module, id_object, id_module) FROM stdin;
1	2	1
2	3	1
\.


--
-- Data for Name: cor_role_action_filter_module_object; Type: TABLE DATA; Schema: gn_permissions; Owner: geonatadmin
--

COPY gn_permissions.cor_role_action_filter_module_object (id_permission, id_role, id_action, id_filter, id_module, id_object) FROM stdin;
1	2	1	4	0	1
2	2	2	4	0	1
3	2	3	4	0	1
4	2	4	4	0	1
5	2	5	4	0	1
6	2	6	4	0	1
7	7	4	4	0	1
8	1	1	4	0	1
9	1	2	3	0	1
10	1	3	2	0	1
11	1	4	1	0	1
12	1	5	3	0	1
13	1	6	2	0	1
14	2	1	4	2	1
15	2	2	4	2	1
16	2	3	4	2	1
17	2	4	4	2	1
18	2	5	4	2	1
19	2	6	4	2	1
20	1	1	1	2	1
21	1	2	3	2	1
22	1	3	1	2	1
23	1	4	1	2	1
24	1	5	3	2	1
25	1	6	1	2	1
26	1	1	1	1	1
27	1	2	1	1	1
28	1	3	1	1	1
29	1	4	1	1	1
30	1	5	1	1	1
31	1	6	1	1	1
32	2	1	4	1	1
33	2	2	4	1	1
34	2	3	4	1	1
35	2	4	4	1	1
36	2	5	4	1	1
37	2	6	4	1	1
38	2	1	4	1	2
39	2	2	4	1	2
40	2	3	4	1	2
41	2	4	4	1	2
42	2	5	4	1	2
43	2	6	4	1	2
44	2	1	4	1	3
45	2	2	4	1	3
46	2	3	4	1	3
47	2	4	4	1	3
48	2	5	4	1	3
49	2	6	4	1	3
\.


--
-- Data for Name: t_actions; Type: TABLE DATA; Schema: gn_permissions; Owner: geonatadmin
--

COPY gn_permissions.t_actions (id_action, code_action, description_action) FROM stdin;
1	C	Créer (C)
2	R	Lire (R)
3	U	Mettre à jour (U)
4	V	Valider (V)
5	E	Exporter (E)
6	D	Supprimer (D)
\.


--
-- Data for Name: t_filters; Type: TABLE DATA; Schema: gn_permissions; Owner: geonatadmin
--

COPY gn_permissions.t_filters (id_filter, label_filter, value_filter, description_filter, id_filter_type) FROM stdin;
1	Aucune donnée	0	Aucune donnée	1
2	Mes données	1	Mes données	1
3	Les données de mon organisme	2	Les données de mon organisme	1
4	Toutes les données	3	Toutes les données	1
5	Les bouquetins	61098	Filtre taxonomique sur les bouquetins	4
6	Les oiseaux	185961	Filtre taxonomique sur les oiseaux - classe Aves	4
7	Données dégradées	DONNEES_DEGRADEES	Filtre pour afficher les données sensibles dégradées/floutées à l'utilisateur	2
8	Données précises	DONNEES_PRECISES	Filtre qui affiche les données sensibles  précises à l'utilisateur	2
\.


--
-- Data for Name: t_objects; Type: TABLE DATA; Schema: gn_permissions; Owner: geonatadmin
--

COPY gn_permissions.t_objects (id_object, code_object, description_object) FROM stdin;
1	ALL	Représente tous les objets d'un module
2	PERMISSIONS	Gestion du backoffice des permissions
3	NOMENCLATURES	Gestion du backoffice des nomenclatures
\.


--
-- Data for Name: cor_taxons_parameters; Type: TABLE DATA; Schema: gn_profiles; Owner: geonatadmin
--

COPY gn_profiles.cor_taxons_parameters (cd_nom, spatial_precision, temporal_precision_days, active_life_stage) FROM stdin;
183716	2000	10	f
187079	2000	10	f
187496	2000	10	f
187501	2000	10	f
187502	2000	10	f
187538	2000	10	f
187545	2000	10	f
436946	2000	10	f
913990	2000	10	f
\.


--
-- Data for Name: t_parameters; Type: TABLE DATA; Schema: gn_profiles; Owner: geonatadmin
--

COPY gn_profiles.t_parameters (id_parameter, name, "desc", value) FROM stdin;
1	id_valid_status_for_profiles	Liste des id_nomenclature du statut de validation permettant de définir les données à prendre\n\ten compte dans le calcul des profils d'espèces. A renseigner sous forme de liste id1,id2,id3.	315,316
2	id_rang_for_profiles	Liste des id_rang du taxref pour lesquels les profils doivent être calculés. A renseigner sous forme de liste id1,id2,id3.	GN,ES,SSES
3	proportion_kept_data	Pourcentage de données à conserver dans le calcul des profils afin d'exclure les données aux\n\taltitudes extrêmes. Ce paramètre doit être supérieur à 50 pour que la phénologie soit calculée.	95
\.


--
-- Data for Name: cor_sensitivity_area; Type: TABLE DATA; Schema: gn_sensitivity; Owner: geonatadmin
--

COPY gn_sensitivity.cor_sensitivity_area (id_sensitivity, id_area) FROM stdin;
\.


--
-- Data for Name: cor_sensitivity_area_type; Type: TABLE DATA; Schema: gn_sensitivity; Owner: geonatadmin
--

COPY gn_sensitivity.cor_sensitivity_area_type (id_nomenclature_sensitivity, id_area_type) FROM stdin;
66	25
67	27
68	26
\.


--
-- Data for Name: cor_sensitivity_criteria; Type: TABLE DATA; Schema: gn_sensitivity; Owner: geonatadmin
--

COPY gn_sensitivity.cor_sensitivity_criteria (id_sensitivity, id_criteria, id_type_nomenclature) FROM stdin;
\.


--
-- Data for Name: cor_sensitivity_synthese; Type: TABLE DATA; Schema: gn_sensitivity; Owner: geonatadmin
--

COPY gn_sensitivity.cor_sensitivity_synthese (uuid_attached_row, id_nomenclature_sensitivity, computation_auto, id_digitizer, sensitivity_comment, meta_create_date, meta_update_date) FROM stdin;
\.


--
-- Data for Name: t_sensitivity_rules; Type: TABLE DATA; Schema: gn_sensitivity; Owner: geonatadmin
--

COPY gn_sensitivity.t_sensitivity_rules (id_sensitivity, cd_nom, nom_cite, id_nomenclature_sensitivity, sensitivity_duration, sensitivity_territory, id_territory, date_min, date_max, source, active, comments, meta_create_date, meta_update_date) FROM stdin;
\.


--
-- Data for Name: cor_area_synthese; Type: TABLE DATA; Schema: gn_synthese; Owner: geonatadmin
--

COPY gn_synthese.cor_area_synthese (id_synthese, id_area) FROM stdin;
\.


--
-- Data for Name: cor_observer_synthese; Type: TABLE DATA; Schema: gn_synthese; Owner: geonatadmin
--

COPY gn_synthese.cor_observer_synthese (id_synthese, id_role) FROM stdin;
\.


--
-- Data for Name: defaults_nomenclatures_value; Type: TABLE DATA; Schema: gn_synthese; Owner: geonatadmin
--

COPY gn_synthese.defaults_nomenclatures_value (mnemonique_type, id_organism, regne, group2_inpn, id_nomenclature) FROM stdin;
TYP_INF_GEO	2	0	0	123
NAT_OBJ_GEO	2	0	0	170
METH_OBS	2	0	0	58
ETA_BIO	2	0	0	153
STATUT_BIO	2	0	0	30
NATURALITE	2	0	0	156
PREUVE_EXIST	2	0	0	77
STATUT_VALID	2	0	0	458
STADE_VIE	2	0	0	1
SEXE	2	0	0	168
OBJ_DENBR	2	0	0	142
TYP_DENBR	2	0	0	91
STATUT_OBS	2	0	0	84
DEE_FLOU	2	0	0	172
TYP_GRP	2	0	0	129
TECHNIQUE_OBS	2	0	0	314
STATUT_SOURCE	2	0	0	72
METH_DETERMIN	2	0	0	438
OCC_COMPORTEMENT	2	0	0	544
STAT_BIOGEO	2	0	0	176
\.


--
-- Data for Name: synthese; Type: TABLE DATA; Schema: gn_synthese; Owner: geonatadmin
--

COPY gn_synthese.synthese (id_synthese, unique_id_sinp, unique_id_sinp_grp, id_source, id_module, entity_source_pk_value, id_dataset, id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status, id_nomenclature_bio_condition, id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status, id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count, id_nomenclature_type_count, id_nomenclature_sensitivity, id_nomenclature_observation_status, id_nomenclature_blurring, id_nomenclature_source_status, id_nomenclature_info_geo_type, id_nomenclature_behaviour, id_nomenclature_biogeo_status, reference_biblio, count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof, digital_proof, non_digital_proof, altitude_min, altitude_max, depth_min, depth_max, place_name, the_geom_4326, the_geom_point, the_geom_local, "precision", id_area_attachment, date_min, date_max, validator, validation_comment, observers, determiner, id_digitiser, id_nomenclature_determination_method, comment_context, comment_description, additional_data, meta_validation_date, meta_create_date, meta_update_date, last_action) FROM stdin;
\.


--
-- Data for Name: t_sources; Type: TABLE DATA; Schema: gn_synthese; Owner: geonatadmin
--

COPY gn_synthese.t_sources (id_source, name_source, desc_source, entity_source_pk_field, url_source, meta_create_date, meta_update_date) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: geonatadmin
--

COPY public.alembic_version (version_num) FROM stdin;
1dbc45309d6e
805442837a68
10e87bc144cd
b820c66d8daa
4882d6141a41
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: geonatadmin
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: geonatadmin
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: geonatadmin
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: geonatadmin
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: geonatadmin
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: geonatadmin
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: geonatadmin
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Data for Name: bib_organismes; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.bib_organismes (id_organisme, uuid_organisme, nom_organisme, adresse_organisme, cp_organisme, ville_organisme, tel_organisme, fax_organisme, email_organisme, url_organisme, url_logo, id_parent, additional_data) FROM stdin;
-1	69502675-521e-49e1-a2e4-d226adcd14e6	Autre							\N	\N	\N	{}
1	8c1b8d74-d544-4090-9b03-caa83b13eb7b	ma structure test	Rue des bois	00000	VILLE	00-00-99-00-99	\N	\N	\N	\N	\N	{}
2	7d23a660-ab94-431d-b886-b84f51e01c8e	ALL	Représente tous les organismes	\N	\N	\N	\N	\N	\N	\N	\N	{}
\.


--
-- Data for Name: cor_profil_for_app; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.cor_profil_for_app (id_profil, id_application) FROM stdin;
1	1
\.


--
-- Data for Name: cor_role_app_profil; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.cor_role_app_profil (id_role, id_application, id_profil, is_default_group_for_app) FROM stdin;
2	1	1	f
1	1	1	t
\.


--
-- Data for Name: cor_role_liste; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.cor_role_liste (id_role, id_liste) FROM stdin;
\.


--
-- Data for Name: cor_role_token; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.cor_role_token (id_role, token) FROM stdin;
\.


--
-- Data for Name: cor_roles; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.cor_roles (id_role_groupe, id_role_utilisateur) FROM stdin;
1	3
2	3
1	4
1	6
1	7
\.


--
-- Data for Name: t_applications; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.t_applications (id_application, code_application, nom_application, desc_application, id_parent) FROM stdin;
1	GN	GeoNature	Application permettant la consultation et la gestion des relevés faune et flore	\N
\.


--
-- Data for Name: t_listes; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.t_listes (id_liste, code_liste, nom_liste, desc_liste) FROM stdin;
\.


--
-- Data for Name: t_profils; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.t_profils (id_profil, code_profil, nom_profil, desc_profil) FROM stdin;
0	0	Aucun	Aucun droit
1	1	Lecteur	Ne peut que consulter/ou acceder
2	2	Rédacteur	Il possède des droit d'écriture pour créer des enregistrements
3	3	Référent	Utilisateur ayant des droits complémentaires au rédacteur (par exemple exporter des données ou autre)
4	4	Modérateur	Peu utilisé
5	5	Validateur	Il valide bien sur
6	6	Administrateur	Il a tous les droits
\.


--
-- Data for Name: t_roles; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.t_roles (groupe, id_role, uuid_role, identifiant, nom_role, prenom_role, desc_role, pass, pass_plus, email, id_organisme, remarques, active, champs_addi, date_insert, date_update) FROM stdin;
t	1	215b9748-0f70-4122-82c6-d94a3c0e4f8a	\N	Grp_en_poste	\N	Tous les agents en poste dans la structure	\N	\N	\N	\N	Groupe des agents de la structure avec droits d'écriture limité	t	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
t	2	db7f1b29-bd36-4aef-8cb4-bb7c1547e069	\N	Grp_admin	\N	Tous les administrateurs	\N	\N	\N	\N	Groupe à droit total	t	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
f	3	3a80560f-d8ec-4827-8cb1-7ff32c96328c	admin	Administrateur	test	\N	21232f297a57a5a743894a0e4a801fc3	$2y$13$TMuRXgvIg6/aAez0lXLLFu0lyPk4m8N55NDhvLoUHh/Ar3rFzjFT.	\N	-1	utilisateur test à modifier	t	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
f	4	85dd680a-aa5a-4750-b155-8bf33bf7849e	agent	Agent	test	\N	b33aed8f3134996703dc39f9a7c95783	\N	\N	-1	utilisateur test à modifier ou supprimer	t	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
f	5	f948f491-8c09-4379-aa26-61db427d4d92	partenaire	Partenaire	test	\N	5bd40a8524882d75f3083903f2c912fc	\N	\N	-1	utilisateur test à modifier ou supprimer	t	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
f	6	67970559-a784-468c-8a21-2a5bfb3ce52a	pierre.paul	Paul	Pierre	\N	21232f297a57a5a743894a0e4a801fc3	\N	\N	-1	utilisateur test à modifier ou supprimer	t	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
f	7	03555712-f0da-429d-90f0-44b8a144caa2	validateur	Validateur	test	\N	21232f297a57a5a743894a0e4a801fc3	\N	\N	-1	utilisateur test à modifier ou supprimer	t	\N	2022-03-01 23:54:40.43696	2022-03-01 23:54:40.43696
\.


--
-- Data for Name: temp_users; Type: TABLE DATA; Schema: utilisateurs; Owner: geonatadmin
--

COPY utilisateurs.temp_users (id_temp_user, token_role, organisme, id_application, confirmation_url, groupe, identifiant, nom_role, prenom_role, desc_role, pass_md5, password, email, id_organisme, remarques, champs_addi, date_insert, date_update) FROM stdin;
\.


--
-- Name: bib_tables_location_id_table_location_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.bib_tables_location_id_table_location_seq', 4, true);


--
-- Name: bib_widgets_id_widget_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.bib_widgets_id_widget_seq', 12, true);


--
-- Name: t_additional_fields_id_field_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.t_additional_fields_id_field_seq', 1, false);


--
-- Name: t_history_actions_id_history_action_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.t_history_actions_id_history_action_seq', 1, false);


--
-- Name: t_medias_id_media_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.t_medias_id_media_seq', 1, false);


--
-- Name: t_mobile_apps_id_mobile_app_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.t_mobile_apps_id_mobile_app_seq', 1, false);


--
-- Name: t_modules_id_module_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.t_modules_id_module_seq', 3, true);


--
-- Name: t_parameters_id_parameter_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.t_parameters_id_parameter_seq', 4, true);


--
-- Name: t_places_id_place_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.t_places_id_place_seq', 1, false);


--
-- Name: t_validations_id_validation_seq; Type: SEQUENCE SET; Schema: gn_commons; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_commons.t_validations_id_validation_seq', 1, false);


--
-- Name: matching_fields_id_matching_field_seq; Type: SEQUENCE SET; Schema: gn_imports; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_imports.matching_fields_id_matching_field_seq', 1, false);


--
-- Name: matching_geoms_id_matching_geom_seq; Type: SEQUENCE SET; Schema: gn_imports; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_imports.matching_geoms_id_matching_geom_seq', 1, false);


--
-- Name: matching_tables_id_matching_table_seq; Type: SEQUENCE SET; Schema: gn_imports; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_imports.matching_tables_id_matching_table_seq', 1, false);


--
-- Name: cor_acquisition_framework_actor_id_cafa_seq; Type: SEQUENCE SET; Schema: gn_meta; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_meta.cor_acquisition_framework_actor_id_cafa_seq', 1, false);


--
-- Name: cor_dataset_actor_id_cda_seq; Type: SEQUENCE SET; Schema: gn_meta; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_meta.cor_dataset_actor_id_cda_seq', 1, false);


--
-- Name: sinp_datatype_protocols_id_protocol_seq; Type: SEQUENCE SET; Schema: gn_meta; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_meta.sinp_datatype_protocols_id_protocol_seq', 1, false);


--
-- Name: sinp_datatype_publications_id_publication_seq; Type: SEQUENCE SET; Schema: gn_meta; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_meta.sinp_datatype_publications_id_publication_seq', 1, false);


--
-- Name: t_acquisition_frameworks_id_acquisition_framework_seq; Type: SEQUENCE SET; Schema: gn_meta; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_meta.t_acquisition_frameworks_id_acquisition_framework_seq', 1, false);


--
-- Name: t_bibliographical_references_id_bibliographic_reference_seq; Type: SEQUENCE SET; Schema: gn_meta; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_meta.t_bibliographical_references_id_bibliographic_reference_seq', 1, false);


--
-- Name: t_datasets_id_dataset_seq; Type: SEQUENCE SET; Schema: gn_meta; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_meta.t_datasets_id_dataset_seq', 1, false);


--
-- Name: t_base_sites_id_base_site_seq; Type: SEQUENCE SET; Schema: gn_monitoring; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_monitoring.t_base_sites_id_base_site_seq', 1, false);


--
-- Name: t_base_visits_id_base_visit_seq; Type: SEQUENCE SET; Schema: gn_monitoring; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_monitoring.t_base_visits_id_base_visit_seq', 1, false);


--
-- Name: bib_filters_type_id_filter_type_seq; Type: SEQUENCE SET; Schema: gn_permissions; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_permissions.bib_filters_type_id_filter_type_seq', 4, true);


--
-- Name: cor_object_module_id_cor_object_module_seq; Type: SEQUENCE SET; Schema: gn_permissions; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_permissions.cor_object_module_id_cor_object_module_seq', 2, true);


--
-- Name: cor_role_action_filter_module_object_id_permission_seq; Type: SEQUENCE SET; Schema: gn_permissions; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_permissions.cor_role_action_filter_module_object_id_permission_seq', 49, true);


--
-- Name: t_actions_id_action_seq; Type: SEQUENCE SET; Schema: gn_permissions; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_permissions.t_actions_id_action_seq', 6, true);


--
-- Name: t_filters_id_filter_seq; Type: SEQUENCE SET; Schema: gn_permissions; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_permissions.t_filters_id_filter_seq', 8, true);


--
-- Name: t_objects_id_object_seq; Type: SEQUENCE SET; Schema: gn_permissions; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_permissions.t_objects_id_object_seq', 3, true);


--
-- Name: t_parameters_id_parameter_seq; Type: SEQUENCE SET; Schema: gn_profiles; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_profiles.t_parameters_id_parameter_seq', 3, true);


--
-- Name: t_sensitivity_rules_id_sensitivity_seq; Type: SEQUENCE SET; Schema: gn_sensitivity; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_sensitivity.t_sensitivity_rules_id_sensitivity_seq', 1, false);


--
-- Name: synthese_id_synthese_seq; Type: SEQUENCE SET; Schema: gn_synthese; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_synthese.synthese_id_synthese_seq', 1, false);


--
-- Name: t_sources_id_source_seq; Type: SEQUENCE SET; Schema: gn_synthese; Owner: geonatadmin
--

SELECT pg_catalog.setval('gn_synthese.t_sources_id_source_seq', 1, false);


--
-- Name: bib_organismes_id_organisme_seq; Type: SEQUENCE SET; Schema: utilisateurs; Owner: geonatadmin
--

SELECT pg_catalog.setval('utilisateurs.bib_organismes_id_organisme_seq', 2, true);


--
-- Name: t_applications_id_application_seq; Type: SEQUENCE SET; Schema: utilisateurs; Owner: geonatadmin
--

SELECT pg_catalog.setval('utilisateurs.t_applications_id_application_seq', 2, false);


--
-- Name: t_listes_id_liste_seq; Type: SEQUENCE SET; Schema: utilisateurs; Owner: geonatadmin
--

SELECT pg_catalog.setval('utilisateurs.t_listes_id_liste_seq', 1, false);


--
-- Name: t_profils_id_profil_seq; Type: SEQUENCE SET; Schema: utilisateurs; Owner: geonatadmin
--

SELECT pg_catalog.setval('utilisateurs.t_profils_id_profil_seq', 7, false);


--
-- Name: t_roles_id_role_seq; Type: SEQUENCE SET; Schema: utilisateurs; Owner: geonatadmin
--

SELECT pg_catalog.setval('utilisateurs.t_roles_id_role_seq', 7, true);


--
-- Name: temp_users_id_temp_user_seq; Type: SEQUENCE SET; Schema: utilisateurs; Owner: geonatadmin
--

SELECT pg_catalog.setval('utilisateurs.temp_users_id_temp_user_seq', 1, false);


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
-- Name: t_parameters pk_parameters; Type: CONSTRAINT; Schema: gn_profiles; Owner: geonatadmin
--

ALTER TABLE ONLY gn_profiles.t_parameters
    ADD CONSTRAINT pk_parameters PRIMARY KEY (id_parameter);


--
-- Name: cor_taxons_parameters pk_taxons_parameters; Type: CONSTRAINT; Schema: gn_profiles; Owner: geonatadmin
--

ALTER TABLE ONLY gn_profiles.cor_taxons_parameters
    ADD CONSTRAINT pk_taxons_parameters PRIMARY KEY (cd_nom);


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
-- Name: bib_organismes bib_organismes_un; Type: CONSTRAINT; Schema: utilisateurs; Owner: geonatadmin
--

ALTER TABLE ONLY utilisateurs.bib_organismes
    ADD CONSTRAINT bib_organismes_un UNIQUE (uuid_organisme);


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
-- Name: index_vm_cor_taxon_phenology_cd_ref; Type: INDEX; Schema: gn_profiles; Owner: geonatadmin
--

CREATE INDEX index_vm_cor_taxon_phenology_cd_ref ON gn_profiles.vm_cor_taxon_phenology USING btree (cd_ref);


--
-- Name: index_vm_valid_profiles_cd_ref; Type: INDEX; Schema: gn_profiles; Owner: geonatadmin
--

CREATE UNIQUE INDEX index_vm_valid_profiles_cd_ref ON gn_profiles.vm_valid_profiles USING btree (cd_ref);


--
-- Name: vm_cor_taxon_phenology_cd_ref_period_id_nomenclature_life_s_idx; Type: INDEX; Schema: gn_profiles; Owner: geonatadmin
--

CREATE UNIQUE INDEX vm_cor_taxon_phenology_cd_ref_period_id_nomenclature_life_s_idx ON gn_profiles.vm_cor_taxon_phenology USING btree (cd_ref, doy_min, doy_max, id_nomenclature_life_stage);


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
-- Name: i_unique_t_sources_name_source; Type: INDEX; Schema: gn_synthese; Owner: geonatadmin
--

CREATE UNIQUE INDEX i_unique_t_sources_name_source ON gn_synthese.t_sources USING btree (name_source);


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

CREATE TRIGGER tri_insert_calculate_sensitivity AFTER INSERT ON gn_synthese.synthese REFERENCING NEW TABLE AS new FOR EACH STATEMENT EXECUTE FUNCTION gn_synthese.fct_tri_calculate_sensitivity_on_each_statement();


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

CREATE TRIGGER tri_update_calculate_sensitivity BEFORE UPDATE OF date_min, date_max, cd_nom, the_geom_local, id_nomenclature_bio_status, id_nomenclature_behaviour ON gn_synthese.synthese FOR EACH ROW EXECUTE FUNCTION gn_synthese.fct_tri_update_sensitivity_on_each_row();


--
-- Name: synthese tri_update_cor_area_synthese; Type: TRIGGER; Schema: gn_synthese; Owner: geonatadmin
--

CREATE TRIGGER tri_update_cor_area_synthese AFTER UPDATE OF the_geom_local, the_geom_4326 ON gn_synthese.synthese FOR EACH ROW EXECUTE FUNCTION gn_synthese.fct_trig_update_in_cor_area_synthese();


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
    ADD CONSTRAINT fk_cor_dataset_protocol_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cor_dataset_protocol fk_cor_dataset_protocol_id_protocol; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_protocol
    ADD CONSTRAINT fk_cor_dataset_protocol_id_protocol FOREIGN KEY (id_protocol) REFERENCES gn_meta.sinp_datatype_protocols(id_protocol) ON UPDATE CASCADE;


--
-- Name: cor_dataset_territory fk_cor_dataset_territory_id_dataset; Type: FK CONSTRAINT; Schema: gn_meta; Owner: geonatadmin
--

ALTER TABLE ONLY gn_meta.cor_dataset_territory
    ADD CONSTRAINT fk_cor_dataset_territory_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: cor_taxons_parameters fk_cor_taxons_parameters_cd_nom; Type: FK CONSTRAINT; Schema: gn_profiles; Owner: geonatadmin
--

ALTER TABLE ONLY gn_profiles.cor_taxons_parameters
    ADD CONSTRAINT fk_cor_taxons_parameters_cd_nom FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE;


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
    ADD CONSTRAINT fk_cor_area_synthese_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: vm_cor_taxon_phenology; Type: MATERIALIZED VIEW DATA; Schema: gn_profiles; Owner: geonatadmin
--

REFRESH MATERIALIZED VIEW gn_profiles.vm_cor_taxon_phenology;


--
-- Name: vm_valid_profiles; Type: MATERIALIZED VIEW DATA; Schema: gn_profiles; Owner: geonatadmin
--

REFRESH MATERIALIZED VIEW gn_profiles.vm_valid_profiles;


--
-- Name: t_sensitivity_rules_cd_ref; Type: MATERIALIZED VIEW DATA; Schema: gn_sensitivity; Owner: geonatadmin
--

REFRESH MATERIALIZED VIEW gn_sensitivity.t_sensitivity_rules_cd_ref;


--
-- PostgreSQL database dump complete
--

