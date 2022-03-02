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
-- Name: ref_nomenclatures; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA ref_nomenclatures;


ALTER SCHEMA ref_nomenclatures OWNER TO geonatadmin;

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

CREATE FUNCTION ref_nomenclatures.get_default_nomenclature_value(mytype character varying, myidorganism integer DEFAULT NULL::integer) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    --Function that return the default nomenclature id with wanted nomenclature type (mnemonique), organism id
    --Return -1 if nothing matches with given parameters
      DECLARE
        thenomenclatureid integer;
      BEGIN
        SELECT
            INTO thenomenclatureid id_nomenclature,
            CASE 
                WHEN id_organisme = myidorganism THEN 1
                ELSE 0
            END priority
        FROM ref_nomenclatures.defaults_nomenclatures_value dnv
        JOIN utilisateurs.bib_organismes o
        ON o.id_organisme = dnv.id_organism 
        WHERE mnemonique_type = mytype
        AND (id_organisme = myidorganism OR id_organisme = NULL OR nom_organisme = 'ALL')
        ORDER BY priority DESC
        LIMIT 1;
        RETURN thenomenclatureid;
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
    AS $$
        --Function which return the label from the id_nomenclature and the language
        DECLARE
            labelfield character varying;
            thelabel character varying;
        BEGIN
        IF myidnomenclature IS NULL THEN
            RETURN NULL;
        END IF;

        labelfield = 'label_'||mylanguage;
        EXECUTE format('
            SELECT  %s
            FROM ref_nomenclatures.t_nomenclatures n
            WHERE id_nomenclature = %s
        ',labelfield, myidnomenclature
        )
        INTO thelabel;
        return thelabel;
        END;
        $$;


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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: bib_nomenclatures_types id_type; Type: DEFAULT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.bib_nomenclatures_types ALTER COLUMN id_type SET DEFAULT nextval('ref_nomenclatures.bib_nomenclatures_types_id_type_seq'::regclass);


--
-- Name: t_nomenclatures id_nomenclature; Type: DEFAULT; Schema: ref_nomenclatures; Owner: geonatadmin
--

ALTER TABLE ONLY ref_nomenclatures.t_nomenclatures ALTER COLUMN id_nomenclature SET DEFAULT nextval('ref_nomenclatures.t_nomenclatures_id_nomenclature_seq'::regclass);


--
-- Data for Name: bib_nomenclatures_types; Type: TABLE DATA; Schema: ref_nomenclatures; Owner: geonatadmin
--

COPY ref_nomenclatures.bib_nomenclatures_types (id_type, mnemonique, label_default, definition_default, label_fr, definition_fr, label_en, definition_en, label_es, definition_es, label_de, definition_de, label_it, definition_it, source, statut, meta_create_date, meta_update_date) FROM stdin;
2	DS_PUBLIQUE	Code d'origine de la donnée	Nomenclature des codes d'origine de la donnée : publique, privée, mixte...	Code d'origine de la donnée	Nomenclature des codes d'origine de la donnée : publique, privée, mixte...	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
3	NAT_OBJ_GEO	Nature d'objet géographique	Nomenclature des natures d'objets géographiques	Nature d'objet géographique	Nomenclature des natures d'objets géographiques	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
4	DEE_FLOU	Existence d'un floutage sur la donnée	Nomenclature indiquant l'existence d'un floutage sur la donnée lors de sa création en tant que DEE.	Existence d'un floutage sur la donnée	Nomenclature indiquant l'existence d'un floutage sur la donnée lors de sa création en tant que DEE.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
5	NIV_PRECIS	Niveaux de précision de diffusion souhaités	Nomenclature des niveaux de précision de diffusion souhaités par le producteur.	Niveaux de précision de diffusion souhaités	Nomenclature des niveaux de précision de diffusion souhaités par le producteur.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
6	OBJ_DENBR	Objet du dénombrement	Nomenclature des objets qui peuvent être dénombrés	Objet du dénombrement	Nomenclature des objets qui peuvent être dénombrés	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
7	ETA_BIO	Etat biologique de l'observation	Nomenclature des états biologiques de l'observation.	Etat biologique de l'observation	Nomenclature des états biologiques de l'observation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
8	NATURALITE	Niveau de naturalité	Nomenclature des niveaux de naturalité	Niveau de naturalité	Nomenclature des niveaux de naturalité	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
9	SEXE	Sexe	Nomenclature des sexes	Sexe	Nomenclature des sexes	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
10	STADE_VIE	Stade de vie : stade de développement du sujet	Nomenclature des stades de vie : stades de développement du sujet de l'observation.	Stade de vie : stade de développement du sujet	Nomenclature des stades de vie : stades de développement du sujet de l'observation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
11	STAT_BIOGEO	Statut biogéographique	Nomenclature des statuts biogéographiques.	Statut biogéographique	Nomenclature des statuts biogéographiques.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
12	REF_HAB	Référentiels d'habitats et typologies	Nomenclature des référentiels d'habitats et typologies utilisés pour rapporter un habitat au sein du standard. La référence à paraître prochainement est HABREF. http://inpn.mnhn.fr/telechargement/referentiels/habitats Les typologies sont disponibles à la même adresse, mais seront prochainement à l'adresse suivante : http://inpn.mnhn.fr/telechargement/referentiels/habitats/typologies	Référentiels d'habitats et typologies	Nomenclature des référentiels d'habitats et typologies utilisés pour rapporter un habitat au sein du standard. La référence à paraître prochainement est HABREF. http://inpn.mnhn.fr/telechargement/referentiels/habitats Les typologies sont disponibles à la même adresse, mais seront prochainement à l'adresse suivante : http://inpn.mnhn.fr/telechargement/referentiels/habitats/typologies	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
13	STATUT_BIO	Statut biologique	Nomenclature des statuts biologiques.	Statut biologique	Nomenclature des statuts biologiques.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
14	METH_OBS	Méthodes d'observation	Nomenclature des méthodes d'observation, indiquant de quelle manière ou avec quel indice on a pu observer le sujet.	Méthodes d'observation	Nomenclature des méthodes d'observation, indiquant de quelle manière ou avec quel indice on a pu observer le sujet.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
15	PREUVE_EXIST	Preuve existante	Nomenclature de l'existence des preuves.	Preuve existante	Nomenclature de l'existence des preuves.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
16	SENSIBILITE	Niveaux de sensibilité	Nomenclature des niveaux de sensibilité possibles	Niveaux de sensibilité	Nomenclature des niveaux de sensibilité possibles	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
17	SENSIBLE	Valeurs de sensibilité qualitative	Nomenclature des valeurs de sensibilité qualitative (oui/non)	Valeurs de sensibilité qualitative	Nomenclature des valeurs de sensibilité qualitative (oui/non)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
18	STATUT_OBS	Statut d'observation	Nomenclature des statuts d'observation.	Statut d'observation	Nomenclature des statuts d'observation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
19	STATUT_SOURCE	Statut de la source	Nomenclature des statuts possibles de la source.	Statut de la source	Nomenclature des statuts possibles de la source.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
20	TYP_ATTR	Type de l'attribut	Nomenclature des types d'attributs additionnels.	Type de l'attribut	Nomenclature des types d'attributs additionnels.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
21	TYP_DENBR	Type de dénombrement	Nomenclature des types de dénombrement possibles (comptage, estimation...)	Type de dénombrement	Nomenclature des types de dénombrement possibles (comptage, estimation...)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
22	TYP_EN	Type d'espace naturel	Nomenclature des types d'espaces naturels.	Type d'espace naturel	Nomenclature des types d'espaces naturels.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
23	TYP_INF_GEO	Type d'information géographique	Nomenclature des types d'information géographique dans le cas de l'utilisation d'un rattachement à un objet géographique (commune, département, espace naturel, masse d'eau...).	Type d'information géographique	Nomenclature des types d'information géographique dans le cas de l'utilisation d'un rattachement à un objet géographique (commune, département, espace naturel, masse d'eau...).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
24	TYP_GRP	Type de regroupement	Nomenclature listant les valeurs possibles pour le type de regroupement.	Type de regroupement	Nomenclature listant les valeurs possibles pour le type de regroupement.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
25	VERS_ME	Version des masses d'eau	Nomenclature des versions du référentiel SANDRE utilisé pour les masses d'eau.	Version des masses d'eau	Nomenclature des versions du référentiel SANDRE utilisé pour les masses d'eau.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
26	ACC2	Raison de niveau d'accessibilité	Nomenclature des raisons d'un niveau d'accessibilité	Raison de niveau d'accessibilité	Nomenclature des raisons d'un niveau d'accessibilité	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
27	ACC	Niveau d'accessibilité	Nomenclature des niveaux d'accessibilité à un site géologique	Niveau d'accessibilité	Nomenclature des niveaux d'accessibilité à un site géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
28	AUTPREAL	Autorisation préalable pour accès	Nomenclature des valeurs concernant l'éventuelle délivrance d'une autorisation préalable pour accéder à un site	Autorisation préalable pour accès	Nomenclature des valeurs concernant l'éventuelle délivrance d'une autorisation préalable pour accéder à un site	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
29	GILGES	Code Gilges	Nomenclature des codes Gilges	Code Gilges	Nomenclature des codes Gilges	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
30	REGION	Code région	Nomenclature des codes région	Code région	Nomenclature des codes région	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
31	CONFID	Valeur de confidentialité	Nomenclatures des valeurs de confidentialité	Valeur de confidentialité	Nomenclatures des valeurs de confidentialité	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
32	COUPGEOL	Présence/absence de coupe géologique	Nomenclature de présence/absence de coupe géologique	Présence/absence de coupe géologique	Nomenclature de présence/absence de coupe géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
33	ETAT1	Niveau d'état d'un site géologique	Nomenclature des niveaux d'état potentiels d'un site	Niveau d'état d'un site géologique	Nomenclature des niveaux d'état potentiels d'un site	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
34	ETAT2	Raison du niveau d'état d'un site géologique	Nomenclature indiquant les raisons du niveau d'état du site	Raison du niveau d'état d'un site géologique	Nomenclature indiquant les raisons du niveau d'état du site	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
35	EXISTPROT	Existence d'une protection pour un site géologique	Nomenclature indiquant si une protection existe ou non	Existence d'une protection pour un site géologique	Nomenclature indiquant si une protection existe ou non	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
36	INTGEOL	Intérêt géologique du site géologique	Nomenclature des intérêts géologiques que peut avoir un site	Intérêt géologique du site géologique	Nomenclature des intérêts géologiques que peut avoir un site	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
37	INTSECTYP	Type d'intérêt secondaire du site géologique	Nomenclature des types d'intérêt secondaire potentiels d'un site géologique	Type d'intérêt secondaire du site géologique	Nomenclature des types d'intérêt secondaire potentiels d'un site géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
38	INTSEC	Intérêt secondaire du site géologique	Nomenclature des intérêts secondaires potentiels, fonction des types d'intérêts secondaires.	Intérêt secondaire du site géologique	Nomenclature des intérêts secondaires potentiels, fonction des types d'intérêts secondaires.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
39	MODIF	Statut de modification de fiche de site géologique	Nomenclature des statuts de modification de fiche de site	Statut de modification de fiche de site géologique	Nomenclature des statuts de modification de fiche de site	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
40	PAY	Paiement spécifique à l'accès du site géologique	Nomenclature qui indique si un site nécessite un paiement spécifique pour y accéder	Paiement spécifique à l'accès du site géologique	Nomenclature qui indique si un site nécessite un paiement spécifique pour y accéder	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
41	PEROUV	Périodes d'ouverture du site géologique	Nomenclature des périodes d'ouverture d'un site	Périodes d'ouverture du site géologique	Nomenclature des périodes d'ouverture d'un site	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
42	PHENGEOL	Phénomène géologique	Nomenclature des phénomènes géologiques	Phénomène géologique	Nomenclature des phénomènes géologiques	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
43	RARETE	Niveau de rareté du site géologique	Nomenclature des niveaux de rareté pour les sites géologiques	Niveau de rareté du site géologique	Nomenclature des niveaux de rareté pour les sites géologiques	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
44	JUR1	Statut de protection, éléments primaires, pour un site géologique	Nomenclature des statuts de protection, éléments primaires	Statut de protection, éléments primaires, pour un site géologique	Nomenclature des statuts de protection, éléments primaires	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
45	JUR2	Statut de protection, éléments secondaires, pour un site géologique	Nomenclature des statuts de protection, éléments secondaires	Statut de protection, éléments secondaires, pour un site géologique	Nomenclature des statuts de protection, éléments secondaires	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
46	PROT1	Type générique de statut de protection pour un site géologique	Nomenclature des types génériques (ou primaires) de statuts de protection et/ou de gestion	Type générique de statut de protection pour un site géologique	Nomenclature des types génériques (ou primaires) de statuts de protection et/ou de gestion	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
70	ORDIN	Echelle ordinale	Nomenclature des valeurs de l'échelle ordinale d'abondance-dominance, suivant Barkman (1964)	Echelle ordinale	Nomenclature des valeurs de l'échelle ordinale d'abondance-dominance, suivant Barkman (1964)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
47	PROT2	Type spécifique de statut de protection pour un site  géologique	Nomenclature des types spécifiques (ou secondaires) de statuts de protection et/ou gestion d'un site géologique	Type spécifique de statut de protection pour un site  géologique	Nomenclature des types spécifiques (ou secondaires) de statuts de protection et/ou gestion d'un site géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
48	VALNAT	Statut de validation nationale pour un site géologique	Nomenclature des statuts de validation nationaux pour un site géologique	Statut de validation nationale pour un site géologique	Nomenclature des statuts de validation nationaux pour un site géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
49	VALREG	Statut de validation régionale pour un site géologique	Nomenclature des statuts de validation régionaux pour le site considéré.	Statut de validation régionale pour un site géologique	Nomenclature des statuts de validation régionaux pour le site considéré.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
50	DOC	Type de document	Nomenclature des types de documents	Type de document	Nomenclature des types de documents	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
51	INVGEOL	Type d'inventaire géologique	Nomenclature des types d'inventaires géologiques pouvant être réalisés sur un site	Type d'inventaire géologique	Nomenclature des types d'inventaires géologiques pouvant être réalisés sur un site	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
52	TYPPERS	Intervenant fiche (type de personne)	Nomenclature des types de personnes ayant pu intervenir sur une fiche de site géologique, de quelque manière que ce soit, ou types de personnes.	Intervenant fiche (type de personne)	Nomenclature des types de personnes ayant pu intervenir sur une fiche de site géologique, de quelque manière que ce soit, ou types de personnes.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
53	TYPO1	Typologie primaire d'un site géologique	Nomenclature des éléments de typologie primaire d'un site géologique	Typologie primaire d'un site géologique	Nomenclature des éléments de typologie primaire d'un site géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
54	TYPO2	Typologie secondaire d'un site géologique	Nomenclature des éléments secondaires de typologie du site géologique. Certains éléments de cette liste sont restreints à certains éléments primaires uniquement (cf. nomenclature 53).	Typologie secondaire d'un site géologique	Nomenclature des éléments secondaires de typologie du site géologique. Certains éléments de cette liste sont restreints à certains éléments primaires uniquement (cf. nomenclature 53).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
55	TYPO3	Typologie tertiaire d'un site géologique	Nomenclature des éléments tertiaires de typologie du site géologique	Typologie tertiaire d'un site géologique	Nomenclature des éléments tertiaires de typologie du site géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
110	TERRITOIRE	Territoire	Nomenclature des territoires.	Territoire	Nomenclature des territoires.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
56	UNITSURF	Unité de superficie pour un site géologique	Nomenclature des unités de superficie pouvant être utilisées pour indiquer la surface d'un site géologique	Unité de superficie pour un site géologique	Nomenclature des unités de superficie pouvant être utilisées pour indiquer la surface d'un site géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
57	USEACTU	Usage d'un site géologique	Nomenclature des usages qui peuvent être faits d'un site géologique	Usage d'un site géologique	Nomenclature des usages qui peuvent être faits d'un site géologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
58	AIRECONNUE	Aire connue	Nomenclature des valeurs indiquant si la surface d'un relevé est connue ou non	Aire connue	Nomenclature des valeurs indiquant si la surface d'un relevé est connue ou non	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
59	BRANCHEMETH	Méthodes phytosociologiques, branches	Nomenclature des branches de méthodes phytosociologiques	Méthodes phytosociologiques, branches	Nomenclature des branches de méthodes phytosociologiques	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
60	BRAUNBLANQABDOM	Braun Blanquet Pavillard, abondance-dominance	Nomenclature des valeurs pour l'échelle d'abondance-dominance de Braun-Blanquet Pavillard (1928)	Braun Blanquet Pavillard, abondance-dominance	Nomenclature des valeurs pour l'échelle d'abondance-dominance de Braun-Blanquet Pavillard (1928)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
61	BRAUNBARK	Braun Blanquet Barkman, abondance-dominance	Nomenclature des valeurs de l'échelle de Braun-Blanquet Barkman complétée telle que dans le dictionnaire de sociologie et synécologie végétales (Géhu, 2006)	Braun Blanquet Barkman, abondance-dominance	Nomenclature des valeurs de l'échelle de Braun-Blanquet Barkman complétée telle que dans le dictionnaire de sociologie et synécologie végétales (Géhu, 2006)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
62	BRAUNPAV	Braun Blanquet Pavillard, abondance	Nomenclature des valeurs de l'échelle d'abondance de Braun-Blanquet Pavillard (1928)	Braun Blanquet Pavillard, abondance	Nomenclature des valeurs de l'échelle d'abondance de Braun-Blanquet Pavillard (1928)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
63	COMPLETREL	Complétude des relevés	Nomenclature des valeurs de complétude des relevés phytosociologiques détaillés	Complétude des relevés	Nomenclature des valeurs de complétude des relevés phytosociologiques détaillés	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
64	RATTACH	Rattachement au syntaxon, confère	Nomenclature des indicateurs de doute dans le rattachement au syntaxon (confère).	Rattachement au syntaxon, confère	Nomenclature des indicateurs de doute dans le rattachement au syntaxon (confère).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
65	DOMIN	Echelle de Domin	Nomenclature des valeurs de l'échelle de Domin (Source : Evans & Dahl, 1955)	Echelle de Domin	Nomenclature des valeurs de l'échelle de Domin (Source : Evans & Dahl, 1955)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
66	EXPOSITION	Exposition d'un terrain	Nomenclature des points cardinaux et intercardinaux permettant d'indiquer l'exposition d'un terrain.	Exposition d'un terrain	Nomenclature des points cardinaux et intercardinaux permettant d'indiquer l'exposition d'un terrain.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
67	FORMES	Formes du relevé	Nomenclature des formes possibles pour un relevé phytosociologique	Formes du relevé	Nomenclature des formes possibles pour un relevé phytosociologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
68	LONDO	Echelle de Londo	Nomenclature des valeurs de l'échelle d'abondance-dominnance de Londo suivant Londo, 1976 (The decimal scale for releves of permanent quadrats)	Echelle de Londo	Nomenclature des valeurs de l'échelle d'abondance-dominnance de Londo suivant Londo, 1976 (The decimal scale for releves of permanent quadrats)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
69	NIVORGA	Niveaux d'organisation des relevés	Nomenclature des niveaux d'organisation auxquels peuvent se trouver des relevés phytosociologiques détaillés	Niveaux d'organisation des relevés	Nomenclature des niveaux d'organisation auxquels peuvent se trouver des relevés phytosociologiques détaillés	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
71	PRES	Présence	Nomenclature des cas de présence d'un taxon	Présence	Nomenclature des cas de présence d'un taxon	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
72	SOCIAB	Sociabilité	Nomenclature des valeurs de sociabilité des taxons végétaux suivant Braun Blanquet (1964)	Sociabilité	Nomenclature des valeurs de sociabilité des taxons végétaux suivant Braun Blanquet (1964)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
73	TYPEAIRE	Types de surface	Nomenclature des types de surfaces utilisées pour les relevés phytosociologiques	Types de surface	Nomenclature des types de surfaces utilisées pour les relevés phytosociologiques	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
74	TYPCORR	Type de correspondance avec le syntaxon	Nomenclature des types de correspondance entre relevés synusiaux et syntaxons sigmatistes	Type de correspondance avec le syntaxon	Nomenclature des types de correspondance entre relevés synusiaux et syntaxons sigmatistes	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
75	TYPECH	Type d'échelle	Nomenclature des types d'échelles utilisées pour l'évaluation d'un paramètre de taxon en phytosociologie	Type d'échelle	Nomenclature des types d'échelles utilisées pour l'évaluation d'un paramètre de taxon en phytosociologie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
76	TYPEPARM	Paramètres suivis pour un taxon, phytosociologie	Nomenclature des types de paramètres potentiellement suivis pour un taxon en phytosociologie	Paramètres suivis pour un taxon, phytosociologie	Nomenclature des types de paramètres potentiellement suivis pour un taxon en phytosociologie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
77	UNITOP	Unités opérationnelles	Liste des modifications morphologiques végétales particulières, génétiquement non fixées (unités morphologiques opérationnelles, unités biologiques opérationnelles, et/ou accommodats), imposées par le milieu	Unités opérationnelles	Liste des modifications morphologiques végétales particulières, génétiquement non fixées (unités morphologiques opérationnelles, unités biologiques opérationnelles, et/ou accommodats), imposées par le milieu	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
0	ROOT	Racine des nomenclatures	Racine. Parent de toutes les nomenclatures	Racine des nomenclatures	Racine. Parent de toutes les nomenclatures	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
100	TECHNIQUE_OBS	Techniques d'observation	Une technique désigne l'ensemble des savoirs-faire, procédés et outils spécifiques, mobilisés de manière logique (règles, étapes et principes) pour collecter des données associées à un paramètre à observer ou à un facteur écologique à prendre en compte. Ce sont les moyens mis en oeuvre sur le terrain pour l'observation d'espèces ou d'habitats. Une technique est définie par rapport à une cible. Dans le cadre d'un protocole, elle doit être reproductible dans le temps et dans l'espace.	Techniques d'observation	Une technique désigne l'ensemble des savoirs-faire, procédés et outils spécifiques, mobilisés de manière logique (règles, étapes et principes) pour collecter des données associées à un paramètre à observer ou à un facteur écologique à prendre en compte. Ce sont les moyens mis en oeuvre sur le terrain pour l'observation d'espèces ou d'habitats. Une technique est définie par rapport à une cible. Dans le cadre d'un protocole, elle doit être reproductible dans le temps et dans l'espace.	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
101	STATUT_VALID	Statut de validation	Nomenclature des statuts de validations de la données	Statut de validation	Nomenclature des statuts de validations de la données	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
102	RESOURCE_TYP	Type de ressources	Nomenclature des types de ressources relatifs aux jeux de données	Type de ressources	Nomenclature des types de ressources relatifs aux jeux de données	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
103	DATA_TYP	Type de données	Nomenclature des types de données SINP relatifs aux jeux de données	Type de données	Nomenclature des types de données SINP relatifs aux jeux de données	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
104	SAMPLING_PLAN_TYP	Type de plan d'échantillonnage	Processus de sélection des unités d'échantillonnage sur lesquelles sont effectuées les mesures des paramètres prévus dans le protocole	Type de plan d'échantillonnage	Processus de sélection des unités d'échantillonnage sur lesquelles sont effectuées les mesures des paramètres prévus dans le protocole	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
105	SAMPLING_UNITS_TYP	Type d'unités d'échantillonnage	L'unité d'échantillonnage désigne l'unité sur laquelle sont mesurés les paramètres étudiés	Type d'unités d'échantillonnage	L'unité d'échantillonnage désigne l'unité sur laquelle sont mesurés les paramètres étudiés	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
106	METH_DETERMIN	Méthode de détermination	Nomenclature des méthodes de détermination, indiquant quelle méthode a été utilisée pour déterminer le sujet.	Méthode de détermination	Nomenclature des méthodes de détermination, indiquant quelle méthode a été utilisée pour déterminer le sujet.	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
107	NIVEAU_TERRITORIAL	Niveau Territorial	Nomenclature des valeurs pour le niveau territorial.	Niveau Territorial	Nomenclature des valeurs pour le niveau territorial.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
108	CA_OBJECTIFS	Objectif du cadre d'acquisition	Nomenclature des valeurs permises pour les objectifs du cadre d'acquisition.	Objectif du cadre d'acquisition	Nomenclature des valeurs permises pour les objectifs du cadre d'acquisition.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
109	ROLE_ACTEUR	Role de l'Acteur	Liste des types de rôles pour les acteurs. Chaque valeur correspond exactement à une valeur de la norme ISO 19115. Cela est précisé pour chacune d'entre elles.	Role de l'Acteur	Liste des types de rôles pour les acteurs. Chaque valeur correspond exactement à une valeur de la norme ISO 19115. Cela est précisé pour chacune d'entre elles.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
111	TYPE_FINANCEMENT	Type de financement	Nomenclature des types de financement.	Type de financement	Nomenclature des types de financement.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
112	TYPE_PROTOCOLE	Type de protocole	Nomenclature des types de protocles.	Type de protocole	Nomenclature des types de protocles.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
113	VOLET_SINP	Volet SINP	Nomenclature des volets que peut viser le SINP.	Volet SINP	Nomenclature des volets que peut viser le SINP.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
114	JDD_OBJECTIFS	Objectif du jeu de données	Nomenclature des valeurs permises pour les objectifs du jeu de données.	Objectif du jeu de données	Nomenclature des valeurs permises pour les objectifs du jeu de données.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
115	METHO_RECUEIL	Méthode de recueil des données	Nomenclature de l'ensemble de techniques, savoir-faire et outils mobilisés pour collecter des données.	Méthode de recueil des données	Nomenclature de l'ensemble de techniques, savoir-faire et outils mobilisés pour collecter des données.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
116	TYPE_SITE	Type de sites	Nomenclature des types de sites suivi dans gn_monitoring.	Type de sites	Nomenclature des types de sites suivi dans gn_monitoring.	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
117	TYPE_MEDIA	Type de médias	Nomenclature des types de médias.	Type de médias	Nomenclature des types de médias.	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
118	DETERMINATION_TYP_HAB	Type de détermination de l'habitat	Nomenclature des types de détermination de l'habitat	Type de détermination de l'habitat	Nomenclature des types de détermination de l'habitat	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
119	TECHNIQUE_COLLECT_HAB	Technique de collecte de l'information habitats	Nomenclature des techniques de collectes ayant présidé à l'obtention de l'information sur l'habitat	Technique de collecte de l'information habitats	Nomenclature des techniques de collectes ayant présidé à l'obtention de l'information sur l'habitat	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
120	ABONDANCE_HAB	Abondance des habitats	Nomenclature des coefficients de Braun-Blanquet et Pavillard adaptés pour décrire l'abondance relative des habitats au sein d'une station	Abondance des habitats	Nomenclature des coefficients de Braun-Blanquet et Pavillard adaptés pour décrire l'abondance relative des habitats au sein d'une station	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
121	HAB_INTERET_COM	Habitat d'intérêt communautaire	Nomenclature des valeurs permettant d'indiquer si un habitat est d'intérêt communautaire	Habitat d'intérêt communautaire	Nomenclature des valeurs permettant d'indiquer si un habitat est d'intérêt communautaire	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
122	METHOD_CALCUL_SURFACE	Méthode de calcul de surface	Nomenclature des types de détermination d'une surface	Méthode de calcul de surface	Nomenclature des types de détermination d'une surface	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
124	OCC_COMPORTEMENT	Comportement des occurrences observées	Nomenclature des domportement des occurrences observées	Comportement des occurrences observées	Nomenclature des domportement des occurrences observées	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235
\.


--
-- Data for Name: cor_application_nomenclature; Type: TABLE DATA; Schema: ref_nomenclatures; Owner: geonatadmin
--

COPY ref_nomenclatures.cor_application_nomenclature (id_nomenclature, id_application) FROM stdin;
\.


--
-- Data for Name: cor_nomenclatures_relations; Type: TABLE DATA; Schema: ref_nomenclatures; Owner: geonatadmin
--

COPY ref_nomenclatures.cor_nomenclatures_relations (id_nomenclature_l, id_nomenclature_r, relation_type) FROM stdin;
\.


--
-- Data for Name: cor_taxref_nomenclature; Type: TABLE DATA; Schema: ref_nomenclatures; Owner: geonatadmin
--

COPY ref_nomenclatures.cor_taxref_nomenclature (id_nomenclature, regne, group2_inpn, meta_create_date, meta_update_date) FROM stdin;
182	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
183	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
192	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
194	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
199	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
201	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
205	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
207	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
209	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
226	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
232	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
238	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
239	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
240	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
244	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
245	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
247	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
248	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
249	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
250	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
258	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
260	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
261	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
262	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
263	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
264	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
265	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
266	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
182	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
183	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
185	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
186	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
187	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
189	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
191	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
193	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
194	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
195	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
196	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
197	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
198	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
199	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
200	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
202	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
203	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
204	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
205	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
207	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
209	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
213	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
214	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
215	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
216	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
217	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
219	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
220	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
221	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
222	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
226	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
228	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
229	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
230	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
231	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
232	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
233	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
234	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
235	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
236	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
237	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
238	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
240	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
241	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
243	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
250	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
253	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
257	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
267	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
268	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
270	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
271	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
272	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
273	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
274	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
275	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
276	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
277	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
278	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
279	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
280	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
281	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
282	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
283	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
284	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
285	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
286	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
287	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
288	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
289	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
290	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
291	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
296	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
297	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
298	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
299	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
300	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
301	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
302	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
303	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
312	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
313	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
314	all	all	2022-03-02 08:42:09.321235	\N
258	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
266	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
182	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
194	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
196	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
197	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
203	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
205	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
206	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
207	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
208	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
209	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
224	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
226	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
227	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
229	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
232	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
238	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
239	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
240	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
241	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
244	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
245	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
246	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
247	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
248	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
249	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
250	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
253	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
254	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
256	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
269	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
292	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
293	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
294	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
295	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
304	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
312	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
258	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
266	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
182	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
194	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
196	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
197	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
203	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
205	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
206	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
207	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
208	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
209	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
224	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
226	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
227	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
229	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
232	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
238	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
239	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
240	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
241	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
244	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
245	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
246	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
247	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
248	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
249	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
250	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
253	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
254	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
256	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
269	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
292	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
293	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
294	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
295	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
304	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
312	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
182	Plantae	all	2022-03-02 08:42:09.321235	\N
184	Plantae	all	2022-03-02 08:42:09.321235	\N
210	Plantae	all	2022-03-02 08:42:09.321235	\N
212	Plantae	all	2022-03-02 08:42:09.321235	\N
213	Plantae	all	2022-03-02 08:42:09.321235	\N
214	Plantae	all	2022-03-02 08:42:09.321235	\N
215	Plantae	all	2022-03-02 08:42:09.321235	\N
216	Plantae	all	2022-03-02 08:42:09.321235	\N
218	Plantae	all	2022-03-02 08:42:09.321235	\N
219	Plantae	all	2022-03-02 08:42:09.321235	\N
222	Plantae	all	2022-03-02 08:42:09.321235	\N
223	Plantae	all	2022-03-02 08:42:09.321235	\N
226	Plantae	all	2022-03-02 08:42:09.321235	\N
239	Plantae	all	2022-03-02 08:42:09.321235	\N
240	Plantae	all	2022-03-02 08:42:09.321235	\N
244	Plantae	all	2022-03-02 08:42:09.321235	\N
245	Plantae	all	2022-03-02 08:42:09.321235	\N
246	Plantae	all	2022-03-02 08:42:09.321235	\N
247	Plantae	all	2022-03-02 08:42:09.321235	\N
249	Plantae	all	2022-03-02 08:42:09.321235	\N
250	Plantae	all	2022-03-02 08:42:09.321235	\N
310	Plantae	all	2022-03-02 08:42:09.321235	\N
311	Plantae	all	2022-03-02 08:42:09.321235	\N
182	Fungi	all	2022-03-02 08:42:09.321235	\N
189	Fungi	all	2022-03-02 08:42:09.321235	\N
204	Fungi	all	2022-03-02 08:42:09.321235	\N
217	Fungi	all	2022-03-02 08:42:09.321235	\N
240	Fungi	all	2022-03-02 08:42:09.321235	\N
250	Fungi	all	2022-03-02 08:42:09.321235	\N
312	Fungi	all	2022-03-02 08:42:09.321235	\N
182	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
183	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
188	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
190	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
192	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
194	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
202	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
205	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
207	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
209	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
226	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
238	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
239	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
240	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
241	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
242	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
244	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
245	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
246	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
247	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
248	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
249	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
250	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
254	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
269	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
305	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
306	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
308	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
309	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
312	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
258	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
259	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
182	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
194	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
203	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
211	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
218	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
219	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
226	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
229	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
232	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
239	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
244	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
245	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
246	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
247	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
248	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
249	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
250	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
252	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
253	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
254	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
255	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
256	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
257	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
292	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
293	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
1	all	all	2022-03-02 08:42:09.321235	\N
2	all	all	2022-03-02 08:42:09.321235	\N
19	Plantae	all	2022-03-02 08:42:09.321235	\N
20	Plantae	all	2022-03-02 08:42:09.321235	\N
21	Plantae	all	2022-03-02 08:42:09.321235	\N
23	Plantae	all	2022-03-02 08:42:09.321235	\N
24	Plantae	all	2022-03-02 08:42:09.321235	\N
25	Plantae	all	2022-03-02 08:42:09.321235	\N
28	Plantae	all	2022-03-02 08:42:09.321235	\N
10	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
7	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
4	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
3	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
10	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
7	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
8	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
11	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
12	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
13	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
14	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
15	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
16	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
17	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
10	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
27	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
4	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
5	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
11	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
3	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
10	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
7	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
27	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
4	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
6	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
3	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
10	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
26	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
4	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
5	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
6	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
3	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
11	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
10	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
26	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
18	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
5	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
6	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
3	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
10	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
4	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
11	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
3	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
10	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
4	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
3	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
10	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
26	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
7	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
9	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
27	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
3	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
3	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
5	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
6	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
10	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
4	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
5	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
6	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
3	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
11	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
162	all	all	2022-03-02 08:42:09.321235	\N
163	all	all	2022-03-02 08:42:09.321235	\N
168	all	all	2022-03-02 08:42:09.321235	\N
167	Plantae	all	2022-03-02 08:42:09.321235	\N
167	Animalia	all	2022-03-02 08:42:09.321235	\N
164	Plantae	all	2022-03-02 08:42:09.321235	\N
165	Plantae	all	2022-03-02 08:42:09.321235	\N
166	Plantae	all	2022-03-02 08:42:09.321235	\N
164	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
165	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
166	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
164	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
165	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
164	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
165	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
164	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
165	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
164	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
165	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
164	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
165	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
164	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
165	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
164	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
165	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
164	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
165	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
166	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
164	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
165	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
164	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
165	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
166	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
164	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
165	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
164	Animalia	Myriapodes	2022-03-02 08:42:09.321235	\N
165	Animalia	Myriapodes	2022-03-02 08:42:09.321235	\N
164	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
165	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
166	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
37	all	all	2022-03-02 08:42:09.321235	\N
56	all	all	2022-03-02 08:42:09.321235	\N
57	all	all	2022-03-02 08:42:09.321235	\N
58	all	all	2022-03-02 08:42:09.321235	\N
63	all	all	2022-03-02 08:42:09.321235	\N
52	Plantae	all	2022-03-02 08:42:09.321235	\N
53	Plantae	all	2022-03-02 08:42:09.321235	\N
55	Plantae	all	2022-03-02 08:42:09.321235	\N
51	Plantae	Angiospermes	2022-03-02 08:42:09.321235	\N
54	Plantae	Angiospermes	2022-03-02 08:42:09.321235	\N
51	Plantae	Gymnospermes	2022-03-02 08:42:09.321235	\N
54	Plantae	Gymnospermes	2022-03-02 08:42:09.321235	\N
50	Plantae	Ptéridophytes	2022-03-02 08:42:09.321235	\N
50	Plantae	Mousses	2022-03-02 08:42:09.321235	\N
50	Plantae	Hépatiques et Anthocérotes	2022-03-02 08:42:09.321235	\N
50	Fungi	all	2022-03-02 08:42:09.321235	\N
64	Animalia	all	2022-03-02 08:42:09.321235	\N
38	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
40	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
42	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
43	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
44	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
45	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
47	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
48	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
59	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
60	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
61	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
62	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
39	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
41	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
44	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
47	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
44	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
47	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
38	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
39	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
41	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
43	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
44	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
45	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
46	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
47	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
48	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
49	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
62	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
47	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
44	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
48	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
47	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
61	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
38	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
41	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
43	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
47	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
62	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
38	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
40	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
41	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
43	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
44	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
45	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
47	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
48	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
49	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
60	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
62	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
29	all	all	2022-03-02 08:42:09.321235	\N
30	all	all	2022-03-02 08:42:09.321235	\N
31	all	all	2022-03-02 08:42:09.321235	\N
32	Plantae	all	2022-03-02 08:42:09.321235	\N
35	Plantae	all	2022-03-02 08:42:09.321235	\N
36	Plantae	all	2022-03-02 08:42:09.321235	\N
32	Fungi	all	2022-03-02 08:42:09.321235	\N
35	Fungi	all	2022-03-02 08:42:09.321235	\N
32	Animalia	all	2022-03-02 08:42:09.321235	\N
35	Animalia	all	2022-03-02 08:42:09.321235	\N
33	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
34	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
33	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
34	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
33	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
33	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
34	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
88	all	all	2022-03-02 08:42:09.321235	\N
89	all	all	2022-03-02 08:42:09.321235	\N
90	all	all	2022-03-02 08:42:09.321235	\N
91	all	all	2022-03-02 08:42:09.321235	\N
142	all	all	2022-03-02 08:42:09.321235	\N
143	Plantae	all	2022-03-02 08:42:09.321235	\N
148	Plantae	all	2022-03-02 08:42:09.321235	\N
149	Plantae	all	2022-03-02 08:42:09.321235	\N
150	Plantae	all	2022-03-02 08:42:09.321235	\N
151	Plantae	all	2022-03-02 08:42:09.321235	\N
143	Fungi	all	2022-03-02 08:42:09.321235	\N
151	Fungi	all	2022-03-02 08:42:09.321235	\N
143	Animalia	all	2022-03-02 08:42:09.321235	\N
145	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
144	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
145	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
146	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
147	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
144	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
144	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
147	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
145	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
147	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
144	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
145	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
146	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
147	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
145	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
147	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
145	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
147	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
145	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
147	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
144	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
145	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
147	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
144	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
145	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
156	all	all	2022-03-02 08:42:09.321235	\N
157	all	all	2022-03-02 08:42:09.321235	\N
158	Plantae	all	2022-03-02 08:42:09.321235	\N
159	Plantae	all	2022-03-02 08:42:09.321235	\N
161	Plantae	all	2022-03-02 08:42:09.321235	\N
158	Fungi	all	2022-03-02 08:42:09.321235	\N
159	Fungi	all	2022-03-02 08:42:09.321235	\N
161	Fungi	all	2022-03-02 08:42:09.321235	\N
158	Animalia	all	2022-03-02 08:42:09.321235	\N
160	Animalia	all	2022-03-02 08:42:09.321235	\N
161	Animalia	all	2022-03-02 08:42:09.321235	\N
152	all	all	2022-03-02 08:42:09.321235	\N
153	all	all	2022-03-02 08:42:09.321235	\N
154	all	all	2022-03-02 08:42:09.321235	\N
155	all	all	2022-03-02 08:42:09.321235	\N
77	all	all	2022-03-02 08:42:09.321235	\N
78	all	all	2022-03-02 08:42:09.321235	\N
79	all	all	2022-03-02 08:42:09.321235	\N
80	all	all	2022-03-02 08:42:09.321235	\N
83	all	all	2022-03-02 08:42:09.321235	\N
84	all	all	2022-03-02 08:42:09.321235	\N
315	all	all	2022-03-02 08:42:09.321235	\N
316	all	all	2022-03-02 08:42:09.321235	\N
317	all	all	2022-03-02 08:42:09.321235	\N
318	all	all	2022-03-02 08:42:09.321235	\N
319	all	all	2022-03-02 08:42:09.321235	\N
320	all	all	2022-03-02 08:42:09.321235	\N
458	all	all	2022-03-02 08:42:09.321235	\N
136	all	all	2022-03-02 08:42:09.321235	\N
137	all	all	2022-03-02 08:42:09.321235	\N
138	all	all	2022-03-02 08:42:09.321235	\N
139	all	all	2022-03-02 08:42:09.321235	\N
140	all	all	2022-03-02 08:42:09.321235	\N
141	all	all	2022-03-02 08:42:09.321235	\N
438	all	all	2022-03-02 08:42:09.321235	\N
351	all	all	2022-03-02 08:42:09.321235	\N
342	all	all	2022-03-02 08:42:09.321235	\N
343	all	all	2022-03-02 08:42:09.321235	\N
344	Bacteria	all	2022-03-02 08:42:09.321235	\N
350	Plantae	all	2022-03-02 08:42:09.321235	\N
453	Plantae	all	2022-03-02 08:42:09.321235	\N
454	Plantae	all	2022-03-02 08:42:09.321235	\N
455	Plantae	all	2022-03-02 08:42:09.321235	\N
456	Plantae	all	2022-03-02 08:42:09.321235	\N
457	Plantae	all	2022-03-02 08:42:09.321235	\N
346	Plantae	Angiospermes	2022-03-02 08:42:09.321235	\N
346	Plantae	Gymnospermes	2022-03-02 08:42:09.321235	\N
346	Plantae	Ptéridophytes	2022-03-02 08:42:09.321235	\N
346	Plantae	Autres	2022-03-02 08:42:09.321235	\N
344	Fungi	all	2022-03-02 08:42:09.321235	\N
346	Fungi	all	2022-03-02 08:42:09.321235	\N
350	Fungi	all	2022-03-02 08:42:09.321235	\N
453	Fungi	all	2022-03-02 08:42:09.321235	\N
454	Fungi	all	2022-03-02 08:42:09.321235	\N
455	Fungi	all	2022-03-02 08:42:09.321235	\N
456	Fungi	all	2022-03-02 08:42:09.321235	\N
457	Fungi	all	2022-03-02 08:42:09.321235	\N
350	Animalia	all	2022-03-02 08:42:09.321235	\N
448	Animalia	all	2022-03-02 08:42:09.321235	\N
454	Animalia	all	2022-03-02 08:42:09.321235	\N
455	Animalia	all	2022-03-02 08:42:09.321235	\N
347	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
447	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
449	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
450	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
453	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
456	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
457	Animalia	Bivalves	2022-03-02 08:42:09.321235	\N
447	Animalia	Acanthocéphales	2022-03-02 08:42:09.321235	\N
449	Animalia	Acanthocéphales	2022-03-02 08:42:09.321235	\N
450	Animalia	Acanthocéphales	2022-03-02 08:42:09.321235	\N
453	Animalia	Acanthocéphales	2022-03-02 08:42:09.321235	\N
456	Animalia	Acanthocéphales	2022-03-02 08:42:09.321235	\N
457	Animalia	Acanthocéphales	2022-03-02 08:42:09.321235	\N
346	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
347	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
348	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
349	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
447	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
449	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
450	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
451	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
452	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
453	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
456	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
457	Animalia	Insectes	2022-03-02 08:42:09.321235	\N
347	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
447	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
449	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
450	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
453	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
456	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
457	Animalia	Céphalopodes	2022-03-02 08:42:09.321235	\N
447	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
449	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
450	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
451	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
452	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
453	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
456	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
457	Animalia	Reptiles	2022-03-02 08:42:09.321235	\N
349	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
447	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
449	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
450	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
451	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
452	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
453	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
456	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
457	Animalia	Crustacés	2022-03-02 08:42:09.321235	\N
447	Animalia	Scléractiniaires	2022-03-02 08:42:09.321235	\N
449	Animalia	Scléractiniaires	2022-03-02 08:42:09.321235	\N
450	Animalia	Scléractiniaires	2022-03-02 08:42:09.321235	\N
453	Animalia	Scléractiniaires	2022-03-02 08:42:09.321235	\N
456	Animalia	Scléractiniaires	2022-03-02 08:42:09.321235	\N
457	Animalia	Scléractiniaires	2022-03-02 08:42:09.321235	\N
447	Animalia	Hydrozoaires	2022-03-02 08:42:09.321235	\N
449	Animalia	Hydrozoaires	2022-03-02 08:42:09.321235	\N
450	Animalia	Hydrozoaires	2022-03-02 08:42:09.321235	\N
451	Animalia	Hydrozoaires	2022-03-02 08:42:09.321235	\N
452	Animalia	Hydrozoaires	2022-03-02 08:42:09.321235	\N
453	Animalia	Hydrozoaires	2022-03-02 08:42:09.321235	\N
456	Animalia	Hydrozoaires	2022-03-02 08:42:09.321235	\N
457	Animalia	Hydrozoaires	2022-03-02 08:42:09.321235	\N
345	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
346	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
348	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
447	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
449	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
450	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
451	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
452	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
453	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
456	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
457	Animalia	Oiseaux	2022-03-02 08:42:09.321235	\N
345	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
447	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
449	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
450	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
453	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
456	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
457	Animalia	Poissons	2022-03-02 08:42:09.321235	\N
447	Animalia	Némertes	2022-03-02 08:42:09.321235	\N
449	Animalia	Némertes	2022-03-02 08:42:09.321235	\N
450	Animalia	Némertes	2022-03-02 08:42:09.321235	\N
453	Animalia	Némertes	2022-03-02 08:42:09.321235	\N
456	Animalia	Némertes	2022-03-02 08:42:09.321235	\N
457	Animalia	Némertes	2022-03-02 08:42:09.321235	\N
447	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
449	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
450	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
451	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
452	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
453	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
456	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
457	Animalia	Arachnides	2022-03-02 08:42:09.321235	\N
347	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
447	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
449	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
450	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
453	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
456	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
457	Animalia	Gastéropodes	2022-03-02 08:42:09.321235	\N
346	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
348	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
447	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
449	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
450	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
451	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
452	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
453	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
456	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
457	Animalia	Amphibiens	2022-03-02 08:42:09.321235	\N
447	Animalia	Octocoralliaires	2022-03-02 08:42:09.321235	\N
449	Animalia	Octocoralliaires	2022-03-02 08:42:09.321235	\N
450	Animalia	Octocoralliaires	2022-03-02 08:42:09.321235	\N
453	Animalia	Octocoralliaires	2022-03-02 08:42:09.321235	\N
456	Animalia	Octocoralliaires	2022-03-02 08:42:09.321235	\N
457	Animalia	Octocoralliaires	2022-03-02 08:42:09.321235	\N
447	Animalia	Pycnogonides	2022-03-02 08:42:09.321235	\N
449	Animalia	Pycnogonides	2022-03-02 08:42:09.321235	\N
450	Animalia	Pycnogonides	2022-03-02 08:42:09.321235	\N
453	Animalia	Pycnogonides	2022-03-02 08:42:09.321235	\N
456	Animalia	Pycnogonides	2022-03-02 08:42:09.321235	\N
457	Animalia	Pycnogonides	2022-03-02 08:42:09.321235	\N
347	Animalia	Autres	2022-03-02 08:42:09.321235	\N
447	Animalia	Autres	2022-03-02 08:42:09.321235	\N
449	Animalia	Autres	2022-03-02 08:42:09.321235	\N
450	Animalia	Autres	2022-03-02 08:42:09.321235	\N
451	Animalia	Autres	2022-03-02 08:42:09.321235	\N
452	Animalia	Autres	2022-03-02 08:42:09.321235	\N
453	Animalia	Autres	2022-03-02 08:42:09.321235	\N
456	Animalia	Autres	2022-03-02 08:42:09.321235	\N
457	Animalia	Autres	2022-03-02 08:42:09.321235	\N
447	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
453	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
456	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
457	Animalia	Annélides	2022-03-02 08:42:09.321235	\N
449	Animalia	Nématodes	2022-03-02 08:42:09.321235	\N
450	Animalia	Nématodes	2022-03-02 08:42:09.321235	\N
456	Animalia	Nématodes	2022-03-02 08:42:09.321235	\N
457	Animalia	Nématodes	2022-03-02 08:42:09.321235	\N
345	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
346	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
347	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
348	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
349	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
447	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
449	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
450	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
451	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
452	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
453	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
456	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
457	Animalia	Mammifères	2022-03-02 08:42:09.321235	\N
447	Animalia	Ascidies	2022-03-02 08:42:09.321235	\N
449	Animalia	Ascidies	2022-03-02 08:42:09.321235	\N
450	Animalia	Ascidies	2022-03-02 08:42:09.321235	\N
453	Animalia	Ascidies	2022-03-02 08:42:09.321235	\N
456	Animalia	Ascidies	2022-03-02 08:42:09.321235	\N
457	Animalia	Ascidies	2022-03-02 08:42:09.321235	\N
447	Animalia	Myriapodes	2022-03-02 08:42:09.321235	\N
449	Animalia	Myriapodes	2022-03-02 08:42:09.321235	\N
450	Animalia	Myriapodes	2022-03-02 08:42:09.321235	\N
453	Animalia	Myriapodes	2022-03-02 08:42:09.321235	\N
456	Animalia	Myriapodes	2022-03-02 08:42:09.321235	\N
457	Animalia	Myriapodes	2022-03-02 08:42:09.321235	\N
447	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
449	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
450	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
453	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
456	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
457	Animalia	Plathelminthes	2022-03-02 08:42:09.321235	\N
344	Chromista	Autres	2022-03-02 08:42:09.321235	\N
350	Chromista	Autres	2022-03-02 08:42:09.321235	\N
447	Chromista	Autres	2022-03-02 08:42:09.321235	\N
448	Chromista	Autres	2022-03-02 08:42:09.321235	\N
449	Chromista	Autres	2022-03-02 08:42:09.321235	\N
450	Chromista	Autres	2022-03-02 08:42:09.321235	\N
453	Chromista	Autres	2022-03-02 08:42:09.321235	\N
454	Chromista	Autres	2022-03-02 08:42:09.321235	\N
455	Chromista	Autres	2022-03-02 08:42:09.321235	\N
456	Chromista	Autres	2022-03-02 08:42:09.321235	\N
457	Chromista	Autres	2022-03-02 08:42:09.321235	\N
344	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
350	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
447	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
448	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
449	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
450	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
453	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
454	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
455	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
456	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
457	Chromista	Ochrophytes	2022-03-02 08:42:09.321235	\N
344	Chromista	Diatomées	2022-03-02 08:42:09.321235	\N
350	Chromista	Diatomées	2022-03-02 08:42:09.321235	\N
448	Chromista	Diatomées	2022-03-02 08:42:09.321235	\N
450	Chromista	Diatomées	2022-03-02 08:42:09.321235	\N
453	Chromista	Diatomées	2022-03-02 08:42:09.321235	\N
454	Chromista	Diatomées	2022-03-02 08:42:09.321235	\N
455	Chromista	Diatomées	2022-03-02 08:42:09.321235	\N
457	Chromista	Diatomées	2022-03-02 08:42:09.321235	\N
350	Protozoa	Autres	2022-03-02 08:42:09.321235	\N
448	Protozoa	Autres	2022-03-02 08:42:09.321235	\N
450	Protozoa	Autres	2022-03-02 08:42:09.321235	\N
455	Protozoa	Autres	2022-03-02 08:42:09.321235	\N
457	Protozoa	Autres	2022-03-02 08:42:09.321235	\N
354	Plantae	all	2022-03-02 08:42:09.321235	\N
355	Plantae	all	2022-03-02 08:42:09.321235	\N
356	Plantae	all	2022-03-02 08:42:09.321235	\N
357	Plantae	all	2022-03-02 08:42:09.321235	\N
354	Fungi	all	2022-03-02 08:42:09.321235	\N
355	Fungi	all	2022-03-02 08:42:09.321235	\N
356	Fungi	all	2022-03-02 08:42:09.321235	\N
357	Fungi	all	2022-03-02 08:42:09.321235	\N
544	all	all	2022-03-02 08:42:09.321235	\N
545	all	all	2022-03-02 08:42:09.321235	\N
546	Animalia	all	2022-03-02 08:42:09.321235	\N
547	Animalia	all	2022-03-02 08:42:09.321235	\N
548	Animalia	all	2022-03-02 08:42:09.321235	\N
549	Animalia	all	2022-03-02 08:42:09.321235	\N
550	Animalia	all	2022-03-02 08:42:09.321235	\N
551	Animalia	all	2022-03-02 08:42:09.321235	\N
552	Animalia	all	2022-03-02 08:42:09.321235	\N
553	Animalia	all	2022-03-02 08:42:09.321235	\N
554	Animalia	all	2022-03-02 08:42:09.321235	\N
555	Animalia	all	2022-03-02 08:42:09.321235	\N
556	Animalia	all	2022-03-02 08:42:09.321235	\N
557	Animalia	all	2022-03-02 08:42:09.321235	\N
558	Animalia	all	2022-03-02 08:42:09.321235	\N
559	Animalia	all	2022-03-02 08:42:09.321235	\N
560	Animalia	all	2022-03-02 08:42:09.321235	\N
561	Animalia	all	2022-03-02 08:42:09.321235	\N
562	Animalia	all	2022-03-02 08:42:09.321235	\N
563	Animalia	all	2022-03-02 08:42:09.321235	\N
564	Animalia	all	2022-03-02 08:42:09.321235	\N
565	Animalia	all	2022-03-02 08:42:09.321235	\N
566	Animalia	all	2022-03-02 08:42:09.321235	\N
567	Animalia	all	2022-03-02 08:42:09.321235	\N
\.


--
-- Data for Name: defaults_nomenclatures_value; Type: TABLE DATA; Schema: ref_nomenclatures; Owner: geonatadmin
--

COPY ref_nomenclatures.defaults_nomenclatures_value (mnemonique_type, id_organism, id_nomenclature) FROM stdin;
DATA_TYP	1	323
DS_PUBLIQUE	1	76
JDD_OBJECTIFS	1	408
METH_DETERMIN	1	438
METHO_RECUEIL	1	396
NIVEAU_TERRITORIAL	1	354
RESOURCE_TYP	1	321
STATUT_SOURCE	1	73
STATUT_VALID	1	458
TYPE_FINANCEMENT	1	383
\.


--
-- Data for Name: t_nomenclatures; Type: TABLE DATA; Schema: ref_nomenclatures; Owner: geonatadmin
--

COPY ref_nomenclatures.t_nomenclatures (id_nomenclature, id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, label_en, definition_en, label_es, definition_es, label_de, definition_de, label_it, definition_it, source, statut, id_broader, hierarchy, meta_create_date, meta_update_date, active) FROM stdin;
497	119	4	4	Modélisation	Modélisation	Modélisation	Modélisation	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
336	105	1	Individus	Individus	Individus	Individus	Individus	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	105.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
0	0	0	Root	Racine des nomenclatures	Racine = Parent de toutes les nomenclatures	Racine des nomenclatures	Racine = Parent de toutes les nomenclatures	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
1	10	0	Inconnu	Inconnu	Le stade de vie de l'individu n'est pas connu.	Inconnu	Le stade de vie de l'individu n'est pas connu.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
2	10	1	Indéterminé	Indéterminé	Le stade de vie de l'individu n'a pu être déterminé (observation insuffisante pour la détermination).	Indéterminé	Le stade de vie de l'individu n'a pu être déterminé (observation insuffisante pour la détermination).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
3	10	2	Adulte	Adulte	L'individu est au stade adulte.	Adulte	L'individu est au stade adulte.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
4	10	3	Juvénile	Juvénile	L'individu n'a pas encore atteint le stade adulte. C'est un individu jeune.	Juvénile	L'individu n'a pas encore atteint le stade adulte. C'est un individu jeune.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
5	10	4	Immature	Immature	Individu n'ayant pas atteint sa maturité sexuelle.	Immature	Individu n'ayant pas atteint sa maturité sexuelle.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
6	10	5	Sub-adulte	Sub-adulte	Individu ayant presque atteint la taille adulte mais qui n'est pas considéré en tant que tel par ses congénères.	Sub-adulte	Individu ayant presque atteint la taille adulte mais qui n'est pas considéré en tant que tel par ses congénères.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
7	10	6	Larve	Larve	Individu dans l'état où il est en sortant de l'œuf, état dans lequel il passe un temps plus ou moins long avant métamorphose.	Larve	Individu dans l'état où il est en sortant de l'œuf, état dans lequel il passe un temps plus ou moins long avant métamorphose.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
8	10	7	Chenille	Chenille	Larve éruciforme des lépidoptères ou papillons.	Chenille	Larve éruciforme des lépidoptères ou papillons.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
9	10	8	Têtard	Têtard	Larve de batracien.	Têtard	Larve de batracien.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
10	10	9	Œuf	Œuf	L'individu se trouve dans un œuf, ou au sein d'un regroupement d'œufs (ponte)	Œuf	L'individu se trouve dans un œuf, ou au sein d'un regroupement d'œufs (ponte)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
11	10	10	Mue	Mue	L'individu est en cours de mue (pour les reptiles : renouvellement de la peau, pour les oiseaux/mammifères : renouvellement du plumage/pelage, pour les cervidés : chute des bois).	Mue	L'individu est en cours de mue (pour les reptiles : renouvellement de la peau, pour les oiseaux/mammifères : renouvellement du plumage/pelage, pour les cervidés : chute des bois).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
12	10	11	Exuvie	Exuvie	L'individu est en cours d'exuviation : l'exuvie est une enveloppe (cuticule chitineuse ou peau) que le corps de l'animal a quittée lors de la mue ou de la métamorphose.	Exuvie	L'individu est en cours d'exuviation : l'exuvie est une enveloppe (cuticule chitineuse ou peau) que le corps de l'animal a quittée lors de la mue ou de la métamorphose.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
13	10	12	Chrysalide	Chrysalide	Nymphe des lépidoptères ou papillons.	Chrysalide	Nymphe des lépidoptères ou papillons.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
14	10	13	Nymphe	Nymphe	Stade de développement intermédiaire, entre larve et imago, pendant lequel l'individu ne se nourrit pas.	Nymphe	Stade de développement intermédiaire, entre larve et imago, pendant lequel l'individu ne se nourrit pas.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
15	10	14	Pupe	Pupe	Nymphe des diptères.	Pupe	Nymphe des diptères.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
16	10	15	Imago	Imago	Stade final d'un individu dont le développement se déroule en plusieurs phases (en général, œuf, larve, imago).	Imago	Stade final d'un individu dont le développement se déroule en plusieurs phases (en général, œuf, larve, imago).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
17	10	16	Sub-imago	Sub-imago	Stade de développement chez certains insectess : insecte mobile, incomplet et sexuellement immature, bien qu'évoquant assez fortement la forme définitive de l'adulte, l'imago.	Sub-imago	Stade de développement chez certains insectess : insecte mobile, incomplet et sexuellement immature, bien qu'évoquant assez fortement la forme définitive de l'adulte, l'imago.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
18	10	17	Alevin	Alevin	L'individu, un poisson, est à un stade juvénile.	Alevin	L'individu, un poisson, est à un stade juvénile.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
19	10	18	Germination	Germination	L'individu est en cours de germination.	Germination	L'individu est en cours de germination.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.018	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
20	10	19	Fané	Fané	L'individu est altéré dans ses couleurs et sa fraîcheur, par rapport à un individu normal.	Fané	L'individu est altéré dans ses couleurs et sa fraîcheur, par rapport à un individu normal.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.019	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
21	10	20	Graine	Graine	La graine est la structure qui contient et protège l'embryon végétal.	Graine	La graine est la structure qui contient et protège l'embryon végétal.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.020	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
22	10	21	Thalle, protothalle	Thalle, protothalle	Un thalle est un appareil végétatif ne possédant ni feuilles, ni tiges, ni racines, produit par certains organismes non mobiles.	Thalle, protothalle	Un thalle est un appareil végétatif ne possédant ni feuilles, ni tiges, ni racines, produit par certains organismes non mobiles.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.021	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
65	16	0	0	Non sensible - Diffusion précise	Donnée non sensible - Diffusion précise	Non sensible - Diffusion précise	Donnée non sensible - Diffusion précise	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	016.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
488	119	2.4	2.4	Imagerie satellitaire	Imagerie satellitaire	Imagerie satellitaire	Imagerie satellitaire	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
23	10	22	Tubercule	Tubercule	Un tubercule est un organe de réserve, généralement souterrain, assurant la survie des plantes pendant la saison d'hiver ou en période de sécheresse, et souvent leur multiplication par voie végétative.	Tubercule	Un tubercule est un organe de réserve, généralement souterrain, assurant la survie des plantes pendant la saison d'hiver ou en période de sécheresse, et souvent leur multiplication par voie végétative.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.022	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
24	10	23	Bulbe	Bulbe	Un bulbe est une pousse souterraine verticale disposant de feuilles modifiées utilisées comme organe de stockage de nourriture par une plante à dormance.	Bulbe	Un bulbe est une pousse souterraine verticale disposant de feuilles modifiées utilisées comme organe de stockage de nourriture par une plante à dormance.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.023	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
25	10	24	Rhizome	Rhizome	Le rhizome est une tige souterraine et parfois subaquatique remplie de réserves alimentaires chez certaines plantes vivaces.	Rhizome	Le rhizome est une tige souterraine et parfois subaquatique remplie de réserves alimentaires chez certaines plantes vivaces.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.024	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
26	10	25	Emergent	Emergent	L'individu est au stade émergent : sortie de l'œuf.	Emergent	L'individu est au stade émergent : sortie de l'œuf.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.025	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
27	10	26	Post-Larve	Post-Larve	Stade qui suit immédiatement celui de la larve et présente certains caractères du juvénile.	Post-Larve	Stade qui suit immédiatement celui de la larve et présente certains caractères du juvénile.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.026	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
28	10	27	Fruit	Fruit	Fruit : L'individu est sous forme de fruit.	Fruit	Fruit : L'individu est sous forme de fruit.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	010.027	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
29	13	0	Inconnu	Inconnu	Inconnu : Le statut biologique de l'individu n'est pas connu.	Inconnu	Inconnu : Le statut biologique de l'individu n'est pas connu.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	013.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
30	13	1	Non renseigné	Non renseigné	Non renseigné : Le statut biologique de l'individu n'a pas été renseigné.	Non renseigné	Non renseigné : Le statut biologique de l'individu n'a pas été renseigné.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	013.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
31	13	2	Non Déterminé	Non Déterminé	Non déterminé : Le statut biologique de l'individu n'a pas pu être déterminé.	Non Déterminé	Non déterminé : Le statut biologique de l'individu n'a pas pu être déterminé.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	013.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
32	13	3	Reproduction	Reproduction	Reproduction : Le sujet d'observation en est au stade de reproduction (nicheur, gravide, carpophore, floraison, fructification…)	Reproduction	Reproduction : Le sujet d'observation en est au stade de reproduction (nicheur, gravide, carpophore, floraison, fructification…)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	013.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
33	13	4	Hibernation	Hibernation	Hibernation : L'hibernation est un état d'hypothermie régulée, durant plusieurs jours ou semaines qui permet aux animaux de conserver leur énergie pendant l'hiver. 	Hibernation	Hibernation : L'hibernation est un état d'hypothermie régulée, durant plusieurs jours ou semaines qui permet aux animaux de conserver leur énergie pendant l'hiver. 	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	013.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
34	13	5	Estivation	Estivation	Estivation : L'estivation est un phénomène analogue à celui de l'hibernation, au cours duquel les animaux tombent en léthargie. L'estivation se produit durant les périodes les plus chaudes et les plus sèches de l'été.	Estivation	Estivation : L'estivation est un phénomène analogue à celui de l'hibernation, au cours duquel les animaux tombent en léthargie. L'estivation se produit durant les périodes les plus chaudes et les plus sèches de l'été.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	013.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
35	13	9	Pas de reproduction	Pas de reproduction	Pas de reproduction : Indique que l'individu n'a pas un comportement reproducteur. Chez les végétaux : absence de fleurs, de fruits…	Pas de reproduction	Pas de reproduction : Indique que l'individu n'a pas un comportement reproducteur. Chez les végétaux : absence de fleurs, de fruits…	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	013.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
36	13	13	Végétatif	Végétatif	L'individu est au stade végétatif.	Végétatif	L'individu est au stade végétatif.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	013.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
407	115	12	Autre	Autre	Autre	Autre	Autre	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
37	14	0	Vu	Vu	Observation directe d'un individu vivant.	Vu	Observation directe d'un individu vivant.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
38	14	1	Entendu	Entendu	Observation acoustique d'un individu vivant.	Entendu	Observation acoustique d'un individu vivant.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
39	14	2	Coquilles d'œuf	Coquilles d'œuf	Observation indirecte via coquilles d'œuf.	Coquilles d'œuf	Observation indirecte via coquilles d'œuf.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
40	14	3	Ultrasons	Ultrasons	Observation acoustique indirecte d'un individu vivant avec matériel spécifique permettant de transduire des ultrasons en sons perceptibles par un humain.	Ultrasons	Observation acoustique indirecte d'un individu vivant avec matériel spécifique permettant de transduire des ultrasons en sons perceptibles par un humain.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
41	14	4	Empreintes	Empreintes	Observation indirecte via empreintes.	Empreintes	Observation indirecte via empreintes.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
42	14	5	Exuvie	Exuvie	Observation indirecte : une exuvie.	Exuvie	Observation indirecte : une exuvie.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
43	14	6	Fèces/Guano/Epreintes	Fèces/Guano/Epreintes	Observation indirecte par les excréments	Fèces/Guano/Epreintes	Observation indirecte par les excréments	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
44	14	7	Mues	Mues	Observation indirecte par des plumes, poils, phanères, peau, bois... issus d'une mue.	Mues	Observation indirecte par des plumes, poils, phanères, peau, bois... issus d'une mue.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
45	14	8	Nid/Gîte	Nid/Gîte	Observation indirecte par présence d'un nid ou d'un gîte non occupé au moment de l'observation.	Nid/Gîte	Observation indirecte par présence d'un nid ou d'un gîte non occupé au moment de l'observation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
46	14	9	Pelote de réjection	Pelote de réjection	Identifie l'espèce ayant produit la pelote de réjection.	Pelote de réjection	Identifie l'espèce ayant produit la pelote de réjection.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
88	21	Ca	Ca	Calculé	Calculé : Dénombrement par opération mathématique	Calculé	Calculé : Dénombrement par opération mathématique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	021.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
47	14	10	Restes dans pelote de réjection	Restes dans pelote de réjection	Identifie l'espèce à laquelle appartiennent les restes retrouvés dans la pelote de réjection (os ou exosquelettes, par exemple).	Restes dans pelote de réjection	Identifie l'espèce à laquelle appartiennent les restes retrouvés dans la pelote de réjection (os ou exosquelettes, par exemple).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
48	14	11	Poils/plumes/phanères	Poils/plumes/phanères	Observation indirecte de l'espèce par ses poils, plumes ou phanères, non nécessairement issus d'une mue.	Poils/plumes/phanères	Observation indirecte de l'espèce par ses poils, plumes ou phanères, non nécessairement issus d'une mue.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
369	110	GLP	Guadeloupe	Guadeloupe	Guadeloupe	Guadeloupe	Guadeloupe	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
49	14	12	Restes de repas	Restes de repas	Observation indirecte par le biais de restes de l'alimentation de l'individu.	Restes de repas	Observation indirecte par le biais de restes de l'alimentation de l'individu.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
50	14	13	Spore	Spore	Identification d'un individu ou groupe d'individus d'un taxon par l'observation de spores, corpuscules unicellulaires ou pluricellulaires pouvant donner naissance sans fécondation à un nouvel individu. Chez les végétaux, corpuscules reproducteurs donnant des prothalles rudimentaires mâles et femelles (correspondant respectivement aux grains de pollen et au sac embryonnaire), dont les produits sont les gamètes.	Spore	Identification d'un individu ou groupe d'individus d'un taxon par l'observation de spores, corpuscules unicellulaires ou pluricellulaires pouvant donner naissance sans fécondation à un nouvel individu. Chez les végétaux, corpuscules reproducteurs donnant des prothalles rudimentaires mâles et femelles (correspondant respectivement aux grains de pollen et au sac embryonnaire), dont les produits sont les gamètes.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
51	14	14	Pollen	Pollen	Observation indirecte d'un individu ou groupe d'individus d'un taxon par l'observation de pollen, poussière très fine produite dans les loges des anthères et dont chaque grain microscopique est un utricule ou petit sac membraneux contenant le fluide fécondant (d'apr. Bouillet 1859).	Pollen	Observation indirecte d'un individu ou groupe d'individus d'un taxon par l'observation de pollen, poussière très fine produite dans les loges des anthères et dont chaque grain microscopique est un utricule ou petit sac membraneux contenant le fluide fécondant (d'apr. Bouillet 1859).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
52	14	15	Oosphère	Oosphère	Observation indirecte. Cellule sexuelle femelle chez les végétaux qui, après sa fécondation, devient l'oeuf.	Oosphère	Observation indirecte. Cellule sexuelle femelle chez les végétaux qui, après sa fécondation, devient l'oeuf.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
53	14	16	Ovule	Ovule	Observation indirecte. Organe contenant le gamète femelle. Macrosporange des spermaphytes.	Ovule	Observation indirecte. Organe contenant le gamète femelle. Macrosporange des spermaphytes.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
54	14	17	Fleur	Fleur	Identification d'un individu ou groupe d'individus d'un taxon par l'observation  de fleurs. La fleur correspond à un ensemble de feuilles modifiées, en enveloppe florale et en organe sexuel, disposées sur un réceptacle. Un pédoncule la relie à la tige. (ex : chaton).	Fleur	Identification d'un individu ou groupe d'individus d'un taxon par l'observation  de fleurs. La fleur correspond à un ensemble de feuilles modifiées, en enveloppe florale et en organe sexuel, disposées sur un réceptacle. Un pédoncule la relie à la tige. (ex : chaton).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
55	14	18	Feuille	Feuille	Identification d'un individu ou groupe d'individus d'un taxon par l'observation  de feuilles. Organe aérien très important dans la nutrition de la plante, lieu de la photosynthèse qui aboutit à des composés organiques (sucres, protéines) formant la sève.	Feuille	Identification d'un individu ou groupe d'individus d'un taxon par l'observation  de feuilles. Organe aérien très important dans la nutrition de la plante, lieu de la photosynthèse qui aboutit à des composés organiques (sucres, protéines) formant la sève.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.018	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
56	14	19	ADN environnemental	ADN environnemental	Séquence ADN trouvée dans un prélèvement environnemental (eau ou sol).	ADN environnemental	Séquence ADN trouvée dans un prélèvement environnemental (eau ou sol).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.019	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
57	14	20	Autre	Autre	Pour tout cas qui ne rentrerait pas dans la présente liste. Le nombre d'apparitions permettra de faire évoluer la nomenclature.	Autre	Pour tout cas qui ne rentrerait pas dans la présente liste. Le nombre d'apparitions permettra de faire évoluer la nomenclature.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.020	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
58	14	21	Inconnu	Inconnu	Inconnu : La méthode n'est pas mentionnée dans les documents de l'observateur (bibliographie par exemple).	Inconnu	Inconnu : La méthode n'est pas mentionnée dans les documents de l'observateur (bibliographie par exemple).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.021	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
59	14	22	Mine	Mine	Galerie forée dans l'épaisseur d'une feuille, entre l'épiderme supérieur et l'épiderme inférieur par des larves	Mine	Galerie forée dans l'épaisseur d'une feuille, entre l'épiderme supérieur et l'épiderme inférieur par des larves	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.022	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
60	14	23	Galerie/terrier	Galerie/terrier	Observation indirecte : Galerie forée dans le bois, les racines ou les tiges, par des larves (Lépidoptères, Coléoptères, Diptères) ou creusée dans la terre (micro-mammifères, mammifères... ).	Galerie/terrier	Observation indirecte : Galerie forée dans le bois, les racines ou les tiges, par des larves (Lépidoptères, Coléoptères, Diptères) ou creusée dans la terre (micro-mammifères, mammifères... ).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.023	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
61	14	24	Oothèque	Oothèque	Membrane-coque qui protège la ponte de certains insectes et certains mollusques.	Oothèque	Membrane-coque qui protège la ponte de certains insectes et certains mollusques.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.024	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
62	14	25	Vu et entendu	Vu et entendu	Vu et entendu : l'occurrence a à la fois été vue et entendue.	Vu et entendu	Vu et entendu : l'occurrence a à la fois été vue et entendue.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.025	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
63	14	26	Olfactif	Olfactif	Contact olfactif : l'occurrence a été sentie sur le lieu d'observation	Olfactif	Contact olfactif : l'occurrence a été sentie sur le lieu d'observation	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.026	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
64	14	27	Empreintes et fèces	Empreintes et fèces	Empreintes et fèces	Empreintes et fèces	Empreintes et fèces	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	014.027	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
489	119	3	3	Techniques acoustiques	Techniques acoustiques	Techniques acoustiques	Techniques acoustiques	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
66	16	1	1	Sensible - Diffusion à la Commune ou Znieff	Sensible - Commune ou Znieff (visible uniquement à partir du niveau)	Sensible - Diffusion à la Commune ou Znieff	Sensible - Commune ou Znieff (visible uniquement à partir du niveau)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	016.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
67	16	2	2	Sensible - Diffusion à la maille 10km	Sensibile - Mailles 10 (visible uniquement à partir du niveau)	Sensible - Diffusion à la maille 10km	Sensibile - Mailles 10 (visible uniquement à partir du niveau)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	016.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
68	16	3	3	Sensible - Diffusion au département	Sensible - Départements (visible uniquement à partir du niveau)	Sensible - Diffusion au département	Sensible - Départements (visible uniquement à partir du niveau)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	016.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
69	16	4	4	Sensible - Aucune diffusion	Sensible - Aucune diffusion	Sensible - Aucune diffusion	Sensible - Aucune diffusion	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	016.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
70	19	Co	Co	Collection	Collection : l'observation concerne une base de données de collection.	Collection	Collection : l'observation concerne une base de données de collection.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	019.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
71	19	Li	Li	Littérature	Littérature : l'observation a été extraite d'un article ou un ouvrage scientifique.	Littérature	Littérature : l'observation a été extraite d'un article ou un ouvrage scientifique.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	019.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
72	19	NSP	NSP	Ne Sait Pas	Ne Sait Pas : la source est inconnue.	Ne Sait Pas	Ne Sait Pas : la source est inconnue.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	019.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
73	19	Te	Te	Terrain	Terrain : l'observation provient directement d'une base de données ou d'un document issu de la prospection sur le terrain.	Terrain	Terrain : l'observation provient directement d'une base de données ou d'un document issu de la prospection sur le terrain.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	019.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
74	2	NSP	Ne sait pas	Ne sait pas	Ne sait pas : L'information indiquant si la Donnée Source est publique ou privée n'est pas connue.	Ne sait pas	Ne sait pas : L'information indiquant si la Donnée Source est publique ou privée n'est pas connue.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	002.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
75	2	Pr	Privée	Privée	Privée : La Donnée Source a été produite par un organisme privé ou un individu à titre personnel. Aucun organisme ayant autorité publique n'a acquis les droits patrimoniaux,  la Donnée Source reste la propriété de l'organisme ou de l'individu privé. Seul ce cas autorise un floutage géographique de la DEE.	Privée	Privée : La Donnée Source a été produite par un organisme privé ou un individu à titre personnel. Aucun organisme ayant autorité publique n'a acquis les droits patrimoniaux,  la Donnée Source reste la propriété de l'organisme ou de l'individu privé. Seul ce cas autorise un floutage géographique de la DEE.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	002.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
76	2	Pu	Publique	Publique	Publique : La Donnée Source est publique qu'elle soit produite en « régie » ou « acquise ».	Publique	Publique : La Donnée Source est publique qu'elle soit produite en « régie » ou « acquise ».	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	002.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
77	15	0	NSP	Inconnu	Indique que la personne ayant fourni la donnée ignore s'il existe une preuve, ou qu'il est indiqué dans la donnée qu'il y a eu une preuve qui a pu servir pour la détermination, sans moyen de le vérifier.	Inconnu	Indique que la personne ayant fourni la donnée ignore s'il existe une preuve, ou qu'il est indiqué dans la donnée qu'il y a eu une preuve qui a pu servir pour la détermination, sans moyen de le vérifier.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	015.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
78	15	1	Oui	Oui	Indique qu'une preuve existe ou a existé pour la détermination, et est toujours accessible.	Oui	Indique qu'une preuve existe ou a existé pour la détermination, et est toujours accessible.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	015.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
79	15	2	Non	Non	Indique l'absence de preuve.	Non	Indique l'absence de preuve.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	015.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
80	15	3	NonAcquise	Non acquise	NonAcquise : La donnée de départ mentionne une preuve, ou non, mais n'est pas suffisamment standardisée pour qu'il soit possible de récupérer des informations. L'information n'est donc pas acquise lors du transfert.	Non acquise	NonAcquise : La donnée de départ mentionne une preuve, ou non, mais n'est pas suffisamment standardisée pour qu'il soit possible de récupérer des informations. L'information n'est donc pas acquise lors du transfert.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	015.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
81	17	NON	Non	Non	"Indique que la donnée n'est pas sensible (par défaut, équivalent au niveau ""0"" des niveaux de sensibilité)."	Non	"Indique que la donnée n'est pas sensible (par défaut, équivalent au niveau ""0"" des niveaux de sensibilité)."	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	017.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
82	17	OUI	Oui	Oui	Indique que la donnée est sensible.	Oui	Indique que la donnée est sensible.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	017.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
83	18	No	No	Non observé	Non Observé : L'observateur n'a pas détecté un taxon particulier, recherché suivant le protocole adéquat à la localisation et à la date de l'observation. Le taxon peut être présent et non vu, temporairement absent, ou réellement absent.	Non observé	Non Observé : L'observateur n'a pas détecté un taxon particulier, recherché suivant le protocole adéquat à la localisation et à la date de l'observation. Le taxon peut être présent et non vu, temporairement absent, ou réellement absent.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	018.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
84	18	Pr	Pr	Présent	Présent : Un ou plusieurs individus du taxon ont été effectivement observés et/ou des indices témoignant de la présence du taxon	Présent	Présent : Un ou plusieurs individus du taxon ont été effectivement observés et/ou des indices témoignant de la présence du taxon	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	018.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
85	18	NSP	NSP	Ne Sait Pas	Ne Sait Pas : l'information n'est pas connue	Ne Sait Pas	Ne Sait Pas : l'information n'est pas connue	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	018.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
86	20	QTA	QTA	Quantitatif	Le paramètre est de type quantitatif : il peut être mesuré par une valeur numérique. Exemples : âge précis, taille, nombre de cercles ligneux...	Quantitatif	Le paramètre est de type quantitatif : il peut être mesuré par une valeur numérique. Exemples : âge précis, taille, nombre de cercles ligneux...	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	020.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
87	20	QUAL	QUAL	Qualitatif	Le paramètre est de type qualitatif : Il décrit une qualité qui ne peut être définie par une quantité numérique. Exemples : individu âgé / individu jeune, eau trouble, milieu clairsemé…	Qualitatif	Le paramètre est de type qualitatif : Il décrit une qualité qui ne peut être définie par une quantité numérique. Exemples : individu âgé / individu jeune, eau trouble, milieu clairsemé…	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	020.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
89	21	Co	Co	Compté	Compté : Dénombrement par énumération des individus	Compté	Compté : Dénombrement par énumération des individus	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	021.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
90	21	Es	Es	Estimé	Estimé : Dénombrement qualifié d'estimé lorsque le produit concerné n'a fait l'objet d'aucune action de détermination de cette valeur du paramètre par le biais d'une technique de mesure.	Estimé	Estimé : Dénombrement qualifié d'estimé lorsque le produit concerné n'a fait l'objet d'aucune action de détermination de cette valeur du paramètre par le biais d'une technique de mesure.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	021.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
91	21	NSP	NSP	Ne sait pas	Ne sait Pas : La méthode de dénombrement n'est pas connue	Ne sait pas	Ne sait Pas : La méthode de dénombrement n'est pas connue	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	021.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
92	22	AAPN	AAPN	AAPN	Aire d'adhésion de parc national	AAPN	Aire d'adhésion de parc national	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
93	22	ANTAR	ANTAR	ANTAR	Zone protégée du Traité de l'Antarctique	ANTAR	Zone protégée du Traité de l'Antarctique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
94	22	APB	APB	APB	Arrêté de protection de biotope	APB	Arrêté de protection de biotope	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
95	22	APIA	APIA	APIA	Zone protégée de la convention d'Apia	APIA	Zone protégée de la convention d'Apia	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
96	22	ASPIM	ASPIM	ASPIM	Aire spécialement protégée d'importance méditerranéenne	ASPIM	Aire spécialement protégée d'importance méditerranéenne	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
97	22	BPM	BPM	BPM	Bien inscrit sur la liste du patrimoine mondial de l'UNESCO	BPM	Bien inscrit sur la liste du patrimoine mondial de l'UNESCO	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
98	22	CARTH	CARTH	CARTH	Zone protégée de la convention de Carthagène	CARTH	Zone protégée de la convention de Carthagène	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
99	22	CNP	CNP	CNP	"Coeur de parc national. Valeur gelée le 15/06/2016 et remplacée par ""CPN"""	CNP	"Coeur de parc national. Valeur gelée le 15/06/2016 et remplacée par ""CPN"""	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Gelé	0	022.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
100	22	ENS	ENS	ENS	Espace naturel sensible	ENS	Espace naturel sensible	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
101	22	MAB	MAB	MAB	Réserve de biosphère (Man and Biosphère)	MAB	Réserve de biosphère (Man and Biosphère)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
102	22	N2000	N2000	N2000	Natura 2000	N2000	Natura 2000	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
103	22	NAIRO	NAIRO	NAIRO	Zone spécialement protégée de la convention de Nairobi	NAIRO	Zone spécialement protégée de la convention de Nairobi	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
104	22	OSPAR	OSPAR	OSPAR	Zone marine protégée de la convention OSPAR	OSPAR	Zone marine protégée de la convention OSPAR	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
105	22	PNM	PNM	PNM	Parc naturel marin	PNM	Parc naturel marin	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
106	22	PNR	PNR	PNR	Parc naturel régional	PNR	Parc naturel régional	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
107	22	PRN	PRN	PRN	Périmètre de protection de réserve naturelle	PRN	Périmètre de protection de réserve naturelle	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
108	22	RAMSAR	RAMSAR	RAMSAR	Site Ramsar : Zone humide d'importance internationale	RAMSAR	Site Ramsar : Zone humide d'importance internationale	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
109	22	RBD	RBD	RBD	Réserve biologique	RBD	Réserve biologique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.018	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
110	22	RBI	RBI	RBI	Réserve biologique intégrale	RBI	Réserve biologique intégrale	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.019	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
111	22	RCFS	RCFS	RCFS	Réserve de chasse et de faune sauvage	RCFS	Réserve de chasse et de faune sauvage	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.020	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
112	22	RIPN	RIPN	RIPN	Réserve intégrale de parc national	RIPN	Réserve intégrale de parc national	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.021	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
113	22	RNC	RNC	RNC	Réserve naturelle de Corse	RNC	Réserve naturelle de Corse	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.022	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
114	22	RNCFS	RNCFS	RNCFS	Réserve nationale de chasse et faune sauvage	RNCFS	Réserve nationale de chasse et faune sauvage	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.023	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
115	22	RNN	RNN	RNN	Réserve naturelle nationale	RNN	Réserve naturelle nationale	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.024	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
116	22	RNR	RNR	RNR	Réserve naturelle régionale	RNR	Réserve naturelle régionale	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.025	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
117	22	SCEN	SCEN	SCEN	Site de Conservatoire d'espaces naturels	SCEN	Site de Conservatoire d'espaces naturels	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.026	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
118	22	SCL	SCL	SCL	Site du Conservatoire du littoral	SCL	Site du Conservatoire du littoral	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.027	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
119	22	ZHAE	ZHAE	ZHAE	Zone humide acquise par une Agence de l'eau	ZHAE	Zone humide acquise par une Agence de l'eau	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.028	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
120	22	ZNIEFF	ZNIEFF	ZNIEFF	Zone Naturelle d'Intérêt Ecologique Faunistique et Floristique (type non précisé)	ZNIEFF	Zone Naturelle d'Intérêt Ecologique Faunistique et Floristique (type non précisé)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	022.029	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
121	22	ZNIEFF1	ZNIEFF1	ZNIEFF1	Zone Naturelle d'Intérêt Ecologique Faunistique et Floristique de type I	ZNIEFF1	Zone Naturelle d'Intérêt Ecologique Faunistique et Floristique de type I	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	\N	022.029.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
122	22	ZNIEFF2	ZNIEFF2	ZNIEFF2	Zone Naturelle d'Intérêt Ecologique Faunistique et Floristique de type II	ZNIEFF2	Zone Naturelle d'Intérêt Ecologique Faunistique et Floristique de type II	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	\N	022.029.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
370	110	MAF	Saint-Martin	Saint-Martin	Saint-Martin	Saint-Martin	Saint-Martin	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
123	23	1	1	Géoréférencement	Géoréférencement de l'objet géographique. L'objet géographique est celui sur lequel on a effectué l'observation.	Géoréférencement	Géoréférencement de l'objet géographique. L'objet géographique est celui sur lequel on a effectué l'observation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	023.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
192	100	11	Capture au filet japonais	Capture au filet japonais	Capture au filet japonais	Capture au filet japonais	Capture au filet japonais	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
124	23	2	2	Rattachement	Rattachement à l'objet géographique : l'objet géographique n'est pas la géoréférence d'origine, ou a été déduit d'informations autres.	Rattachement	Rattachement à l'objet géographique : l'objet géographique n'est pas la géoréférence d'origine, ou a été déduit d'informations autres.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	023.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
125	24	AUTR	AUTR	AUTR	La valeur n'est pas contenue dans la présente liste. Elle doit être complétée par d'autres informations.	AUTR	La valeur n'est pas contenue dans la présente liste. Elle doit être complétée par d'autres informations.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
126	24	CAMP	CAMP	CAMP	Campagne de prélèvement	CAMP	Campagne de prélèvement	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
127	24	INVSTA	INVSTA	INVSTA	Inventaire stationnel	INVSTA	Inventaire stationnel	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
128	24	LIEN	LIEN	LIEN	Lien : Indique un lien fort entre 2 observations. (Une occurrence portée par l'autre, une symbiose, un parasitisme…)	LIEN	Lien : Indique un lien fort entre 2 observations. (Une occurrence portée par l'autre, une symbiose, un parasitisme…)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
129	24	NSP	NSP	NSP	Ne sait pas : l'information n'est pas connue.	NSP	Ne sait pas : l'information n'est pas connue.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
130	24	OBS	OBS	OBS	Observations	OBS	Observations	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
131	24	OP	OP	OP	Opération de prélèvement	OP	Opération de prélèvement	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
132	24	PASS	PASS	PASS	Passage	PASS	Passage	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
133	24	POINT	POINT	POINT	Point de prélèvement ou point d'observation.	POINT	Point de prélèvement ou point d'observation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
134	24	REL	REL	REL	Relevé (qu'il soit phytosociologique, d'observation, ou autre...)	REL	Relevé (qu'il soit phytosociologique, d'observation, ou autre...)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
135	24	STRAT	STRAT	STRAT	Strate	STRAT	Strate	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	024.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
136	5	0	Standard	Standard	Diffusion standard : à la maille, à la ZNIEFF, à la commune, à l'espace protégé (statut par défaut).	Standard	Diffusion standard : à la maille, à la ZNIEFF, à la commune, à l'espace protégé (statut par défaut).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	005.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
137	5	1	Commune	Commune	Diffusion floutée de la DEE par rattachement à la commune.	Commune	Diffusion floutée de la DEE par rattachement à la commune.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	005.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
138	5	2	Maille	Maille	Diffusion floutée par rattachement à la maille 10 x 10 km	Maille	Diffusion floutée par rattachement à la maille 10 x 10 km	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	005.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
139	5	3	Département	Département	Diffusion floutée par rattachement au département.	Département	Diffusion floutée par rattachement au département.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	005.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
140	5	4	Aucune	Aucune	Aucune diffusion (cas exceptionnel), correspond à une donnée de sensibilité 4.	Aucune	Aucune diffusion (cas exceptionnel), correspond à une donnée de sensibilité 4.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	005.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
141	5	5	Précise	Précise	Diffusion telle quelle : si une donnée précise existe, elle doit être diffusée telle quelle.	Précise	Diffusion telle quelle : si une donnée précise existe, elle doit être diffusée telle quelle.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	005.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
142	6	NSP	Ne Sait Pas	Ne Sait Pas	La méthode de dénombrement n'est pas connue.	Ne Sait Pas	La méthode de dénombrement n'est pas connue.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
143	6	IND	Individu	Individu	Nombre d'individus observés.	Individu	Nombre d'individus observés.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
144	6	CPL	Couple	Couple	Nombre de couples observé.	Couple	Nombre de couples observé.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
145	6	COL	Colonie	Colonie	Nombre de colonies observées.	Colonie	Nombre de colonies observées.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
146	6	NID	Nid	Nid	Nombre de nids observés.	Nid	Nombre de nids observés.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
147	6	PON	Ponte	Ponte	Nombre de pontes observées.	Ponte	Nombre de pontes observées.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
148	6	HAM	Hampe florale	Hampe florale	Nombre de hampes florales observées.	Hampe florale	Nombre de hampes florales observées.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
149	6	TIGE	Tige	Tige	Nombre de tiges observées.	Tige	Nombre de tiges observées.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
150	6	TOUF	Touffe	Touffe	Nombre de touffes observées.	Touffe	Nombre de touffes observées.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
151	6	SURF	Surface	Surface	Zone aréale occupée par le taxon, en mètres carrés.	Surface	Zone aréale occupée par le taxon, en mètres carrés.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	006.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
152	7	0	NSP	NSP	Inconnu (peut être utilisé pour les virus ou les végétaux fanés par exemple).	NSP	Inconnu (peut être utilisé pour les virus ou les végétaux fanés par exemple).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	007.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
153	7	1	Non renseigné	Non renseigné	L'information n'a pas été renseignée.	Non renseigné	L'information n'a pas été renseignée.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	007.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
154	7	2	Observé vivant	Observé vivant	L'individu a été observé vivant.	Observé vivant	L'individu a été observé vivant.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	007.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
155	7	3	Trouvé mort	Trouvé mort	L'individu a été trouvé mort : Cadavre entier ou crâne par exemple. La mort est antérieure au processus d'observation.	Trouvé mort	L'individu a été trouvé mort : Cadavre entier ou crâne par exemple. La mort est antérieure au processus d'observation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	007.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
156	8	0	Inconnu	Inconnu	Inconnu : la naturalité du sujet est inconnue	Inconnu	Inconnu : la naturalité du sujet est inconnue	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	008.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
187	100	6	Battage (battage de la végétation, parapluie japonais)	Battage (battage de la végétation, parapluie japonais)	Battage (battage de la végétation, parapluie japonais)	Battage (battage de la végétation, parapluie japonais)	Battage (battage de la végétation, parapluie japonais)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
157	8	1	Sauvage	Sauvage	Sauvage : Qualifie un animal ou végétal à l'état sauvage, individu autochtone, se retrouvant dans son aire de répartition naturelle et dont les individus sont le résultat d'une reproduction naturelle, sans intervention humaine.	Sauvage	Sauvage : Qualifie un animal ou végétal à l'état sauvage, individu autochtone, se retrouvant dans son aire de répartition naturelle et dont les individus sont le résultat d'une reproduction naturelle, sans intervention humaine.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	008.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
158	8	2	Cultivé/élevé	Cultivé/élevé	Cultivé/élevé : Qualifie un individu d'une population allochtone introduite volontairement dans des espaces non naturels dédiés à la culture, ou à l'élevage.	Cultivé/élevé	Cultivé/élevé : Qualifie un individu d'une population allochtone introduite volontairement dans des espaces non naturels dédiés à la culture, ou à l'élevage.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	008.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
500	119	7	7	Extrapolation	Extrapolation	Extrapolation	Extrapolation	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.019	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
159	8	3	Planté	Planté	Planté : Qualifie un végétal d'une population allochtone introduite ponctuellement et  volontairement dans un espace naturel/semi naturel.	Planté	Planté : Qualifie un végétal d'une population allochtone introduite ponctuellement et  volontairement dans un espace naturel/semi naturel.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	008.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
160	8	4	Féral	Féral	Féral : Qualifie un animal élevé retourné à l'état sauvage, individu d'une population allochtone.	Féral	Féral : Qualifie un animal élevé retourné à l'état sauvage, individu d'une population allochtone.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	008.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
161	8	5	Subspontané	Subspontané	"Subspontané : Qualifie un végétal d'une population allochtone, introduite volontairement, qui persiste plus ou moins longtemps dans sa station d'origine et qui a une dynamique propre peu étendue et limitée aux alentours de son implantation initiale. ""Echappée des jardins""."	Subspontané	"Subspontané : Qualifie un végétal d'une population allochtone, introduite volontairement, qui persiste plus ou moins longtemps dans sa station d'origine et qui a une dynamique propre peu étendue et limitée aux alentours de son implantation initiale. ""Echappée des jardins""."	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	008.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
162	9	0	Inconnu	Inconnu	Inconnu : Il n'y a pas d'information disponible pour cet individu.	Inconnu	Inconnu : Il n'y a pas d'information disponible pour cet individu.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	009.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
486	119	2.2	2.2	Radar	Radar	Radar	Radar	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
163	9	1	Indéterminé	Indéterminé	Indéterminé : Le sexe de l'individu n'a pu être déterminé	Indéterminé	Indéterminé : Le sexe de l'individu n'a pu être déterminé	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	009.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
164	9	2	Femelle	Femelle	Féminin : L'individu est de sexe féminin.	Femelle	Féminin : L'individu est de sexe féminin.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	009.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
165	9	3	Mâle	Mâle	Masculin : L'individu est de sexe masculin.	Mâle	Masculin : L'individu est de sexe masculin.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	009.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
166	9	4	Hermaphrodite	Hermaphrodite	Hermaphrodite : L'individu est hermaphrodite.	Hermaphrodite	Hermaphrodite : L'individu est hermaphrodite.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	009.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
167	9	5	Mixte	Mixte	Mixte : Sert lorsque l'on décrit plusieurs individus.	Mixte	Mixte : Sert lorsque l'on décrit plusieurs individus.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	009.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
168	9	6	Non renseigné	Non renseigné	Non renseigné : l'information n'a pas été renseignée dans le document à l'origine de la donnée.	Non renseigné	Non renseigné : l'information n'a pas été renseignée dans le document à l'origine de la donnée.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	009.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
169	3	In	Inventoriel	Inventoriel	Inventoriel : Le taxon observé est présent quelque part dans l'objet géographique	Inventoriel	Inventoriel : Le taxon observé est présent quelque part dans l'objet géographique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	003.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
170	3	NSP	Ne sait pas	Ne sait pas	Ne Sait Pas : L'information est inconnue	Ne sait pas	Ne Sait Pas : L'information est inconnue	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	003.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
171	3	St	Stationnel	Stationnel	Stationnel : Le taxon observé est présent sur l'ensemble de l'objet géographique	Stationnel	Stationnel : Le taxon observé est présent sur l'ensemble de l'objet géographique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	003.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
172	4	NON	Non	Non	Non : indique qu'aucun floutage n'a eu lieu. Donnée non floutée, fournie précise par le producteur.	Non	Non : indique qu'aucun floutage n'a eu lieu. Donnée non floutée, fournie précise par le producteur.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	004.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
173	4	OUI	Oui	Oui	Oui : indique qu'un floutage a eu lieu. Floutage effectué par le producteur avant envoi vers le SINP (une plateforme du SINP).	Oui	Oui : indique qu'un floutage a eu lieu. Floutage effectué par le producteur avant envoi vers le SINP (une plateforme du SINP).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	004.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
174	4	NSP	NSP	NSP	NSP : Indique qu'on ignore si un floutage a eu lieu.	NSP	NSP : Indique qu'on ignore si un floutage a eu lieu.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	004.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
175	11	0	Inconnu/cryptogène	Inconnu/cryptogène	Individu dont le taxon a une aire d'origine inconnue qui fait qu'on ne peut donc pas dire s'il est indigène ou introduit.	Inconnu/cryptogène	Individu dont le taxon a une aire d'origine inconnue qui fait qu'on ne peut donc pas dire s'il est indigène ou introduit.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	011.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
176	11	1	Non renseigné	Non renseigné	Individu pour lequel l'information n'a pas été renseignée.	Non renseigné	Individu pour lequel l'information n'a pas été renseignée.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	011.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
188	100	7	Battue avec rabatteurs	Battue avec rabatteurs	Battue avec rabatteurs	Battue avec rabatteurs	Battue avec rabatteurs	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
189	100	8	Brossage (terrestre : écorces…)	Brossage (terrestre : écorces…)	Brossage (terrestre : écorces…)	Brossage (terrestre : écorces…)	Brossage (terrestre : écorces…)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
190	100	9	Capture au collet	Capture au collet	Capture au collet	Capture au collet	Capture au collet	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
191	100	10	Capture au filet Cryldé	Capture au filet Cryldé	Capture au filet Cryldé	Capture au filet Cryldé	Capture au filet Cryldé	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
494	119	3.5	3.5	Imagerie sismique	Imagerie sismique	Imagerie sismique	Imagerie sismique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
177	11	2	Présent (indigène ou indéterminé)	Présent (indigène ou indéterminé)	Individu d'un taxon présent au sens large dans la zone géographique considérée, c'est-à-dire taxon indigène ou taxon dont on ne sait pas s'il appartient à l'une des autres catégories. Le défaut de connaissance profite donc à l'indigénat.  Par indigène on entend : taxon qui est issu de la zone géographique considérée et qui s'y est naturellement développé sans contribution humaine, ou taxon qui est arrivé là sans intervention humaine (intentionnelle ou non) à partir d'une zone dans laquelle il est indigène6.  (NB : exclut les hybrides dont l'un des parents au moins est introduit dans la zone considérée)  Sont regroupés sous ce statut tous les taxons catégorisés « natif » ou « autochtone ».  Les taxons hivernant quelques mois de l'année entrent dans cette catégorie.	Présent (indigène ou indéterminé)	Individu d'un taxon présent au sens large dans la zone géographique considérée, c'est-à-dire taxon indigène ou taxon dont on ne sait pas s'il appartient à l'une des autres catégories. Le défaut de connaissance profite donc à l'indigénat.  Par indigène on entend : taxon qui est issu de la zone géographique considérée et qui s'y est naturellement développé sans contribution humaine, ou taxon qui est arrivé là sans intervention humaine (intentionnelle ou non) à partir d'une zone dans laquelle il est indigène6.  (NB : exclut les hybrides dont l'un des parents au moins est introduit dans la zone considérée)  Sont regroupés sous ce statut tous les taxons catégorisés « natif » ou « autochtone ».  Les taxons hivernant quelques mois de l'année entrent dans cette catégorie.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	011.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
178	11	3	Introduit	Introduit	Taxon introduit (établi ou possiblement établi) au niveau local.  Par introduit on entend : taxon dont la présence locale est due à une intervention humaine, intentionnelle ou non, ou taxon qui est arrivé dans la zone sans intervention humaine mais à partir d'une zone dans laquelle il est introduit.  Par établi (terme pour la faune, naturalisé pour la flore) on entend : taxon introduit qui forme des populations viables (se reproduisant) et durables qui se maintiennent dans le milieu naturel sans besoin d'intervention humaine.  Sont regroupés sous ce statut tous les taxons catégorisés « non-indigène », « exotique », « exogène », « allogène », « allochtone », « non-natif », « naturalisé » dans une publication scientifique.	Introduit	Taxon introduit (établi ou possiblement établi) au niveau local.  Par introduit on entend : taxon dont la présence locale est due à une intervention humaine, intentionnelle ou non, ou taxon qui est arrivé dans la zone sans intervention humaine mais à partir d'une zone dans laquelle il est introduit.  Par établi (terme pour la faune, naturalisé pour la flore) on entend : taxon introduit qui forme des populations viables (se reproduisant) et durables qui se maintiennent dans le milieu naturel sans besoin d'intervention humaine.  Sont regroupés sous ce statut tous les taxons catégorisés « non-indigène », « exotique », « exogène », « allogène », « allochtone », « non-natif », « naturalisé » dans une publication scientifique.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	011.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
179	11	4	Introduit envahissant	Introduit envahissant	"Individu d'un taxon introduit  localement, qui produit des descendants fertiles souvent en grand nombre, et qui a le potentiel pour s'étendre de façon exponentielle sur une grande aire, augmentant ainsi rapidement son aire de répartition. Cela induit souvent des conséquences écologiques, économiques ou sanitaires négatives. Sont regroupés sous ce statut tous les individus de taxons catégorisés ""introduits envahissants"", ""exotiques envahissants"", ou ""invasif""."	Introduit envahissant	"Individu d'un taxon introduit  localement, qui produit des descendants fertiles souvent en grand nombre, et qui a le potentiel pour s'étendre de façon exponentielle sur une grande aire, augmentant ainsi rapidement son aire de répartition. Cela induit souvent des conséquences écologiques, économiques ou sanitaires négatives. Sont regroupés sous ce statut tous les individus de taxons catégorisés ""introduits envahissants"", ""exotiques envahissants"", ou ""invasif""."	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	011.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
180	11	5	Introduit non établi (dont domestique)	Introduit non établi (dont domestique)	Individu dont le taxon est introduit, qui se reproduit occasionnellement hors de son aire de culture ou captivité, mais qui ne peut se maintenir à l'état sauvage.	Introduit non établi (dont domestique)	Individu dont le taxon est introduit, qui se reproduit occasionnellement hors de son aire de culture ou captivité, mais qui ne peut se maintenir à l'état sauvage.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	011.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
181	11	6	Occasionnel	Occasionnel	Individu dont le taxon est occasionnel, non nicheur, accidentel ou exceptionnel dans la zone géographique considérée (par exemple migrateur de passage), qui est locale.	Occasionnel	Individu dont le taxon est occasionnel, non nicheur, accidentel ou exceptionnel dans la zone géographique considérée (par exemple migrateur de passage), qui est locale.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	011.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
182	100	1	Analyse ADN environnemental (ADNe)	Analyse ADN environnemental (ADNe)	Analyse ADN environnemental (ADNe)	Analyse ADN environnemental (ADNe)	Analyse ADN environnemental (ADNe)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
183	100	2	Analyse de restes de prédateurs - pelotes de réjection, restes de repas de carnivores, analyses stomacales	Analyse de restes de prédateurs - pelotes de réjection, restes de repas de carnivores, analyses stomacales	Analyse de restes de prédateurs - pelotes de réjection, restes de repas de carnivores, analyses stomacales	Analyse de restes de prédateurs - pelotes de réjection, restes de repas de carnivores, analyses stomacales	Analyse de restes de prédateurs - pelotes de réjection, restes de repas de carnivores, analyses stomacales	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
184	100	3	Aspirateur à air comprimé (marin)	Aspirateur à air comprimé (marin)	Aspirateur à air comprimé (marin)	Aspirateur à air comprimé (marin)	Aspirateur à air comprimé (marin)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
185	100	4	Aspiration moteur type D-VAC (aspirateur à moteur)	Aspiration moteur type D-VAC (aspirateur à moteur)	Aspiration moteur type D-VAC (aspirateur à moteur)	Aspiration moteur type D-VAC (aspirateur à moteur)	Aspiration moteur type D-VAC (aspirateur à moteur)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
186	100	5	Attraction pour observation (miellée, phéromones…)	Attraction pour observation (miellée, phéromones…)	Attraction pour observation (miellée, phéromones…)	Attraction pour observation (miellée, phéromones…)	Attraction pour observation (miellée, phéromones…)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
331	104	4	Adaptative sampling	Adaptative sampling	Tirage aléatoire d'un premier lot d'unités, puis de nouvelles unités sont ajoutées selon les résultats obtenus sur les premières	Adaptative sampling	Tirage aléatoire d'un premier lot d'unités, puis de nouvelles unités sont ajoutées selon les résultats obtenus sur les premières	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	104.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
193	100	12	Capture au filet stationnaire	Capture au filet stationnaire	Capture au filet stationnaire	Capture au filet stationnaire	Capture au filet stationnaire	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
194	100	13	Capture directe (capture à vue, capture relâche)	Capture directe (capture à vue, capture relâche)	Capture directe (capture à vue, capture relâche)	Capture directe (capture à vue, capture relâche)	Capture directe (capture à vue, capture relâche)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
195	100	14	Chalutage terrestre (capture au filet de toit - voiture)	Chalutage terrestre (capture au filet de toit - voiture)	Chalutage terrestre (capture au filet de toit - voiture)	Chalutage terrestre (capture au filet de toit - voiture)	Chalutage terrestre (capture au filet de toit - voiture)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
196	100	15	Création d'habitat refuge : autres techniques	Création d'habitat refuge : autres techniques	Création d'habitat refuge : autres techniques	Création d'habitat refuge : autres techniques	Création d'habitat refuge : autres techniques	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
197	100	16	Création d'habitat refuge : couverture du sol (plaques, bâches)	Création d'habitat refuge : couverture du sol (plaques, bâches)	Création d'habitat refuge : couverture du sol (plaques, bâches)	Création d'habitat refuge : couverture du sol (plaques, bâches)	Création d'habitat refuge : couverture du sol (plaques, bâches)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
198	100	17	Création d'habitat refuge : dévitalisation de plantes, mutilation	Création d'habitat refuge : dévitalisation de plantes, mutilation	Création d'habitat refuge : dévitalisation de plantes, mutilation	Création d'habitat refuge : dévitalisation de plantes, mutilation	Création d'habitat refuge : dévitalisation de plantes, mutilation	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
199	100	18	Création d'habitat refuge : hôtels à insectes, nichoirs	Création d'habitat refuge : hôtels à insectes, nichoirs	Création d'habitat refuge : hôtels à insectes, nichoirs	Création d'habitat refuge : hôtels à insectes, nichoirs	Création d'habitat refuge : hôtels à insectes, nichoirs	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.018	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
200	100	19	Création d'habitat refuge : substrat artificiel aquatique	Création d'habitat refuge : substrat artificiel aquatique	Création d'habitat refuge : substrat artificiel aquatique	Création d'habitat refuge : substrat artificiel aquatique	Création d'habitat refuge : substrat artificiel aquatique	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.019	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
201	100	20	Détection au chien d'arrêt	Détection au chien d'arrêt	Détection au chien d'arrêt	Détection au chien d'arrêt	Détection au chien d'arrêt	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.020	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
202	100	21	Détection des ultrasons (écoute indirecte, analyse sonore, détection ultrasonore)	Détection des ultrasons (écoute indirecte, analyse sonore, détection ultrasonore)	Détection des ultrasons (écoute indirecte, analyse sonore, détection ultrasonore)	Détection des ultrasons (écoute indirecte, analyse sonore, détection ultrasonore)	Détection des ultrasons (écoute indirecte, analyse sonore, détection ultrasonore)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.021	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
203	100	22	Détection nocturne à la lampe frontale (chasse de nuit à la lampe frontale)	Détection nocturne à la lampe frontale (chasse de nuit à la lampe frontale)	Détection nocturne à la lampe frontale (chasse de nuit à la lampe frontale)	Détection nocturne à la lampe frontale (chasse de nuit à la lampe frontale)	Détection nocturne à la lampe frontale (chasse de nuit à la lampe frontale)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.022	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
204	100	23	Ecorcage	Ecorcage	Ecorcage	Ecorcage	Ecorcage	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.023	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
205	100	24	Ecoute directe (reconnaissance sonore directe, détection auditive)	Ecoute directe (reconnaissance sonore directe, détection auditive)	Ecoute directe (reconnaissance sonore directe, détection auditive)	Ecoute directe (reconnaissance sonore directe, détection auditive)	Ecoute directe (reconnaissance sonore directe, détection auditive)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.024	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
206	100	25	Ecoute directe avec hydrophone	Ecoute directe avec hydrophone	Ecoute directe avec hydrophone	Ecoute directe avec hydrophone	Ecoute directe avec hydrophone	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.025	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
207	100	26	Ecoute directe avec repasse	Ecoute directe avec repasse	Ecoute directe avec repasse	Ecoute directe avec repasse	Ecoute directe avec repasse	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.026	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
208	100	27	Enregistrement sonore avec hydrophone	Enregistrement sonore avec hydrophone	Enregistrement sonore avec hydrophone	Enregistrement sonore avec hydrophone	Enregistrement sonore avec hydrophone	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.027	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
209	100	28	Enregistrement sonore simple	Enregistrement sonore simple	Enregistrement sonore simple	Enregistrement sonore simple	Enregistrement sonore simple	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.028	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
210	100	29	Etude de la banque de graines du sol	Etude de la banque de graines du sol	Etude de la banque de graines du sol	Etude de la banque de graines du sol	Etude de la banque de graines du sol	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.029	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
211	100	30	Examen des hôtes - écrevisses et poissons (sangsues piscicolidae et branchiobdellidae)	Examen des hôtes - écrevisses et poissons (sangsues piscicolidae et branchiobdellidae)	Examen des hôtes - écrevisses et poissons (sangsues piscicolidae et branchiobdellidae)	Examen des hôtes - écrevisses et poissons (sangsues piscicolidae et branchiobdellidae)	Examen des hôtes - écrevisses et poissons (sangsues piscicolidae et branchiobdellidae)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.030	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
212	100	31	Extraction de substrat : délitage de susbtrats durs (marin)	Extraction de substrat : délitage de susbtrats durs (marin)	Extraction de substrat : délitage de susbtrats durs (marin)	Extraction de substrat : délitage de susbtrats durs (marin)	Extraction de substrat : délitage de susbtrats durs (marin)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.031	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
363	109	5	Fournisseur du jeu de données	Fournisseur du jeu de données	Fournisseur du jeu de données	Fournisseur du jeu de données	Fournisseur du jeu de données	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	109.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
213	100	32	Extraction de substrat par benne (Van Veen, Smith McIntyre, Hamon…)	Extraction de substrat par benne (Van Veen, Smith McIntyre, Hamon…)	Extraction de substrat par benne (Van Veen, Smith McIntyre, Hamon…)	Extraction de substrat par benne (Van Veen, Smith McIntyre, Hamon…)	Extraction de substrat par benne (Van Veen, Smith McIntyre, Hamon…)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.032	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
214	100	33	Extraction de substrat par carottier à main (en plongée)	Extraction de substrat par carottier à main (en plongée)	Extraction de substrat par carottier à main (en plongée)	Extraction de substrat par carottier à main (en plongée)	Extraction de substrat par carottier à main (en plongée)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.033	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
215	100	34	Extraction de substrat par carottier à main (sans plongée - continental ou supra/médiolittoral)	Extraction de substrat par carottier à main (sans plongée - continental ou supra/médiolittoral)	Extraction de substrat par carottier à main (sans plongée - continental ou supra/médiolittoral)	Extraction de substrat par carottier à main (sans plongée - continental ou supra/médiolittoral)	Extraction de substrat par carottier à main (sans plongée - continental ou supra/médiolittoral)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.034	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
501	119	8	8	Techniques de prélèvements in situ	Techniques de prélèvements in situ	Techniques de prélèvements in situ	Techniques de prélèvements in situ	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.020	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
216	100	35	Extraction de substrat par filet dragueur ou haveneau (drague Rallier du Baty, Charcot Picard…)	Extraction de substrat par filet dragueur ou haveneau (drague Rallier du Baty, Charcot Picard…)	Extraction de substrat par filet dragueur ou haveneau (drague Rallier du Baty, Charcot Picard…)	Extraction de substrat par filet dragueur ou haveneau (drague Rallier du Baty, Charcot Picard…)	Extraction de substrat par filet dragueur ou haveneau (drague Rallier du Baty, Charcot Picard…)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.035	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
217	100	36	Extraction de substrat terrestre : bloc de sol, récolte de litière…	Extraction de substrat terrestre : bloc de sol, récolte de litière…	Extraction de substrat terrestre : bloc de sol, récolte de litière…	Extraction de substrat terrestre : bloc de sol, récolte de litière…	Extraction de substrat terrestre : bloc de sol, récolte de litière…	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.036	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
218	100	37	Fauchage marin au filet fauchoir (en plongée)	Fauchage marin au filet fauchoir (en plongée)	Fauchage marin au filet fauchoir (en plongée)	Fauchage marin au filet fauchoir (en plongée)	Fauchage marin au filet fauchoir (en plongée)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.037	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
219	100	38	Fauchage marin au filet fauchoir (sans plongée - supra/médiolittoral)	Fauchage marin au filet fauchoir (sans plongée - supra/médiolittoral)	Fauchage marin au filet fauchoir (sans plongée - supra/médiolittoral)	Fauchage marin au filet fauchoir (sans plongée - supra/médiolittoral)	Fauchage marin au filet fauchoir (sans plongée - supra/médiolittoral)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.038	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
220	100	39	Fauchage terrestre au filet fauchoir (fauchage de la végétation)	Fauchage terrestre au filet fauchoir (fauchage de la végétation)	Fauchage terrestre au filet fauchoir (fauchage de la végétation)	Fauchage terrestre au filet fauchoir (fauchage de la végétation)	Fauchage terrestre au filet fauchoir (fauchage de la végétation)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.039	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
221	100	40	Fumigation (fogging, thermonébulisation insecticide)	Fumigation (fogging, thermonébulisation insecticide)	Fumigation (fogging, thermonébulisation insecticide)	Fumigation (fogging, thermonébulisation insecticide)	Fumigation (fogging, thermonébulisation insecticide)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.040	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
222	100	41	Grattage, brossage du susbtrat (marin)	Grattage, brossage du susbtrat (marin)	Grattage, brossage du susbtrat (marin)	Grattage, brossage du susbtrat (marin)	Grattage, brossage du susbtrat (marin)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.041	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
223	100	42	Méthode de De Vries (méthode des prélèvements, méthode des poignées)	Méthode de De Vries (méthode des prélèvements, méthode des poignées)	Méthode de De Vries (méthode des prélèvements, méthode des poignées)	Méthode de De Vries (méthode des prélèvements, méthode des poignées)	Méthode de De Vries (méthode des prélèvements, méthode des poignées)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.042	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
224	100	43	Méthode de l'élastique (lézards arboricoles)	Méthode de l'élastique (lézards arboricoles)	Méthode de l'élastique (lézards arboricoles)	Méthode de l'élastique (lézards arboricoles)	Méthode de l'élastique (lézards arboricoles)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.043	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
225	100	44	Observation à la moutarde - vers de terre	Observation à la moutarde - vers de terre	Observation à la moutarde - vers de terre	Observation à la moutarde - vers de terre	Observation à la moutarde - vers de terre	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.044	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
226	100	45	Observation aux jumelles (observation à la longue-vue)	Observation aux jumelles (observation à la longue-vue)	Observation aux jumelles (observation à la longue-vue)	Observation aux jumelles (observation à la longue-vue)	Observation aux jumelles (observation à la longue-vue)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.045	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
227	100	46	Observation aux lunettes polarisantes	Observation aux lunettes polarisantes	Observation aux lunettes polarisantes	Observation aux lunettes polarisantes	Observation aux lunettes polarisantes	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.046	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
228	100	47	Observation de détritus d'inondation, débris et laisses de crues	Observation de détritus d'inondation, débris et laisses de crues	Observation de détritus d'inondation, débris et laisses de crues	Observation de détritus d'inondation, débris et laisses de crues	Observation de détritus d'inondation, débris et laisses de crues	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.047	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
229	100	48	Observation de larves (recherche de larves)	Observation de larves (recherche de larves)	Observation de larves (recherche de larves)	Observation de larves (recherche de larves)	Observation de larves (recherche de larves)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.048	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
230	100	49	Observation de macro-restes (cadavres, élytres…)	Observation de macro-restes (cadavres, élytres…)	Observation de macro-restes (cadavres, élytres…)	Observation de macro-restes (cadavres, élytres…)	Observation de macro-restes (cadavres, élytres…)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.049	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
231	100	50	Observation de micro-habitats (recherche de gîtes, chandelles, polypores, dendrotelmes…) 	Observation de micro-habitats (recherche de gîtes, chandelles, polypores, dendrotelmes…) 	Observation de micro-habitats (recherche de gîtes, chandelles, polypores, dendrotelmes…) 	Observation de micro-habitats (recherche de gîtes, chandelles, polypores, dendrotelmes…) 	Observation de micro-habitats (recherche de gîtes, chandelles, polypores, dendrotelmes…) 	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.050	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
495	119	3.6	3.6	Sondeur de sédiments	Sondeur de sédiments	Sondeur de sédiments	Sondeur de sédiments	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
232	100	51	Observation de pontes (observation des œufs, recherche des pontes)	Observation de pontes (observation des œufs, recherche des pontes)	Observation de pontes (observation des œufs, recherche des pontes)	Observation de pontes (observation des œufs, recherche des pontes)	Observation de pontes (observation des œufs, recherche des pontes)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.051	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
233	100	52	Observation de substrat et tamisage	Observation de substrat et tamisage	Observation de substrat et tamisage	Observation de substrat et tamisage	Observation de substrat et tamisage	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.052	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
364	109	6	Producteur du jeu de données	Producteur du jeu de données	Producteur du jeu de données	Producteur du jeu de données	Producteur du jeu de données	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	109.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
234	100	53	Observation de substrat par extraction : appareil de Berlèse-Tullgren, Winckler-Moczarski…	Observation de substrat par extraction : appareil de Berlèse-Tullgren, Winckler-Moczarski…	Observation de substrat par extraction : appareil de Berlèse-Tullgren, Winckler-Moczarski…	Observation de substrat par extraction : appareil de Berlèse-Tullgren, Winckler-Moczarski…	Observation de substrat par extraction : appareil de Berlèse-Tullgren, Winckler-Moczarski…	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.053	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
235	100	54	Observation de substrat par extraction : par flottaison (par densité)	Observation de substrat par extraction : par flottaison (par densité)	Observation de substrat par extraction : par flottaison (par densité)	Observation de substrat par extraction : par flottaison (par densité)	Observation de substrat par extraction : par flottaison (par densité)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.054	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
236	100	55	Observation de trous de sortie, trous d'émergence	Observation de trous de sortie, trous d'émergence	Observation de trous de sortie, trous d'émergence	Observation de trous de sortie, trous d'émergence	Observation de trous de sortie, trous d'émergence	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.055	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
237	100	56	Observation d'exuvies	Observation d'exuvies	Observation d'exuvies	Observation d'exuvies	Observation d'exuvies	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.056	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
238	100	57	Observation d'indices de présence	Observation d'indices de présence	Observation d'indices de présence	Observation d'indices de présence	Observation d'indices de présence	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.057	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
239	100	58	Observation directe marine (observation en plongée)	Observation directe marine (observation en plongée)	Observation directe marine (observation en plongée)	Observation directe marine (observation en plongée)	Observation directe marine (observation en plongée)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.058	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
240	100	59	Observation directe terrestre diurne (chasse à vue de jour)	Observation directe terrestre diurne (chasse à vue de jour)	Observation directe terrestre diurne (chasse à vue de jour)	Observation directe terrestre diurne (chasse à vue de jour)	Observation directe terrestre diurne (chasse à vue de jour)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.059	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
241	100	60	Observation directe terrestre nocturne (chasse à vue de nuit)	Observation directe terrestre nocturne (chasse à vue de nuit)	Observation directe terrestre nocturne (chasse à vue de nuit)	Observation directe terrestre nocturne (chasse à vue de nuit)	Observation directe terrestre nocturne (chasse à vue de nuit)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.060	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
242	100	61	Observation directe terrestre nocturne au phare	Observation directe terrestre nocturne au phare	Observation directe terrestre nocturne au phare	Observation directe terrestre nocturne au phare	Observation directe terrestre nocturne au phare	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.061	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
243	100	62	Observation manuelle de substrat (litière, sol…)	Observation manuelle de substrat (litière, sol…)	Observation manuelle de substrat (litière, sol…)	Observation manuelle de substrat (litière, sol…)	Observation manuelle de substrat (litière, sol…)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.062	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
244	100	63	Observation marine par caméra suspendue	Observation marine par caméra suspendue	Observation marine par caméra suspendue	Observation marine par caméra suspendue	Observation marine par caméra suspendue	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.063	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
245	100	64	Observation marine par traineau vidéo	Observation marine par traineau vidéo	Observation marine par traineau vidéo	Observation marine par traineau vidéo	Observation marine par traineau vidéo	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.064	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
246	100	65	Observation marine par véhicule téléguidé (ROV)	Observation marine par véhicule téléguidé (ROV)	Observation marine par véhicule téléguidé (ROV)	Observation marine par véhicule téléguidé (ROV)	Observation marine par véhicule téléguidé (ROV)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.065	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
247	100	66	Observation marine photographique (observation photographique en plongée)	Observation marine photographique (observation photographique en plongée)	Observation marine photographique (observation photographique en plongée)	Observation marine photographique (observation photographique en plongée)	Observation marine photographique (observation photographique en plongée)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.066	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
248	100	67	Observation par piège photographique	Observation par piège photographique	Observation par piège photographique	Observation par piège photographique	Observation par piège photographique	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.067	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
249	100	68	Observation photographique aérienne, prise de vue aérienne	Observation photographique aérienne, prise de vue aérienne	Observation photographique aérienne, prise de vue aérienne	Observation photographique aérienne, prise de vue aérienne	Observation photographique aérienne, prise de vue aérienne	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.068	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
250	100	69	Observation photographique terrestre (affût photographique)	Observation photographique terrestre (affût photographique)	Observation photographique terrestre (affût photographique)	Observation photographique terrestre (affût photographique)	Observation photographique terrestre (affût photographique)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.069	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
251	100	70	Paniers à vers de terre	Paniers à vers de terre	Paniers à vers de terre	Paniers à vers de terre	Paniers à vers de terre	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.070	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
252	100	71	Pêche à la palangre	Pêche à la palangre	Pêche à la palangre	Pêche à la palangre	Pêche à la palangre	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.071	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
253	100	72	Pêche à l'épuisette (capture par épuisette, chasse à l'épuisette)	Pêche à l'épuisette (capture par épuisette, chasse à l'épuisette)	Pêche à l'épuisette (capture par épuisette, chasse à l'épuisette)	Pêche à l'épuisette (capture par épuisette, chasse à l'épuisette)	Pêche à l'épuisette (capture par épuisette, chasse à l'épuisette)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.072	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
254	100	73	Pêche au chalut, chalutage (chalut à perche...)	Pêche au chalut, chalutage (chalut à perche...)	Pêche au chalut, chalutage (chalut à perche...)	Pêche au chalut, chalutage (chalut à perche...)	Pêche au chalut, chalutage (chalut à perche...)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.073	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
255	100	74	Pêche au filet - à détailler	Pêche au filet - à détailler	Pêche au filet - à détailler	Pêche au filet - à détailler	Pêche au filet - à détailler	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.074	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
256	100	75	Pêche au filet lesté (pêche à la senne)	Pêche au filet lesté (pêche à la senne)	Pêche au filet lesté (pêche à la senne)	Pêche au filet lesté (pêche à la senne)	Pêche au filet lesté (pêche à la senne)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.075	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
257	100	76	Pêche au filet Surber	Pêche au filet Surber	Pêche au filet Surber	Pêche au filet Surber	Pêche au filet Surber	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.076	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
258	100	77	Pêche au filet troubleau (chasse au filet troubleau)	Pêche au filet troubleau (chasse au filet troubleau)	Pêche au filet troubleau (chasse au filet troubleau)	Pêche au filet troubleau (chasse au filet troubleau)	Pêche au filet troubleau (chasse au filet troubleau)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.077	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
259	100	78	Pêche électrique, électropêche	Pêche électrique, électropêche	Pêche électrique, électropêche	Pêche électrique, électropêche	Pêche électrique, électropêche	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.078	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
260	100	79	Piégeage à appât type Plantrou (piège à Charaxes)	Piégeage à appât type Plantrou (piège à Charaxes)	Piégeage à appât type Plantrou (piège à Charaxes)	Piégeage à appât type Plantrou (piège à Charaxes)	Piégeage à appât type Plantrou (piège à Charaxes)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.079	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
261	100	80	Piégeage à cornet (capture par piège cornet unidirectionnel)	Piégeage à cornet (capture par piège cornet unidirectionnel)	Piégeage à cornet (capture par piège cornet unidirectionnel)	Piégeage à cornet (capture par piège cornet unidirectionnel)	Piégeage à cornet (capture par piège cornet unidirectionnel)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.080	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
262	100	81	Piégeage à fosse à coprophages	Piégeage à fosse à coprophages	Piégeage à fosse à coprophages	Piégeage à fosse à coprophages	Piégeage à fosse à coprophages	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.081	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
263	100	82	Piégeage à fosse à nécrophages	Piégeage à fosse à nécrophages	Piégeage à fosse à nécrophages	Piégeage à fosse à nécrophages	Piégeage à fosse à nécrophages	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.082	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
264	100	83	Piégeage à fosse appâté (capture par piège à fosse avec liquide conservateur, piège Barber, pot-piège)	Piégeage à fosse appâté (capture par piège à fosse avec liquide conservateur, piège Barber, pot-piège)	Piégeage à fosse appâté (capture par piège à fosse avec liquide conservateur, piège Barber, pot-piège)	Piégeage à fosse appâté (capture par piège à fosse avec liquide conservateur, piège Barber, pot-piège)	Piégeage à fosse appâté (capture par piège à fosse avec liquide conservateur, piège Barber, pot-piège)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.083	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
265	100	84	Piégeage à fosse non appâté (piège à fosse sans liquide conservateur)	Piégeage à fosse non appâté (piège à fosse sans liquide conservateur)	Piégeage à fosse non appâté (piège à fosse sans liquide conservateur)	Piégeage à fosse non appâté (piège à fosse sans liquide conservateur)	Piégeage à fosse non appâté (piège à fosse sans liquide conservateur)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.084	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
266	100	85	Piégeage adhésif (piège collant, piège gluant, bande collante)	Piégeage adhésif (piège collant, piège gluant, bande collante)	Piégeage adhésif (piège collant, piège gluant, bande collante)	Piégeage adhésif (piège collant, piège gluant, bande collante)	Piégeage adhésif (piège collant, piège gluant, bande collante)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.085	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
267	100	86	Piégeage aérien à succion (aspirateur échantillonneur, piège à moustiques)	Piégeage aérien à succion (aspirateur échantillonneur, piège à moustiques)	Piégeage aérien à succion (aspirateur échantillonneur, piège à moustiques)	Piégeage aérien à succion (aspirateur échantillonneur, piège à moustiques)	Piégeage aérien à succion (aspirateur échantillonneur, piège à moustiques)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.086	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
268	100	87	Piégeage aérien rotatif	Piégeage aérien rotatif	Piégeage aérien rotatif	Piégeage aérien rotatif	Piégeage aérien rotatif	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.087	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
269	100	88	Piégeage au sol - à détailler	Piégeage au sol - à détailler	Piégeage au sol - à détailler	Piégeage au sol - à détailler	Piégeage au sol - à détailler	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.088	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
270	100	89	Piégeage bouteille (piège à vin, piège à appât fermenté, piège à cétoines)	Piégeage bouteille (piège à vin, piège à appât fermenté, piège à cétoines)	Piégeage bouteille (piège à vin, piège à appât fermenté, piège à cétoines)	Piégeage bouteille (piège à vin, piège à appât fermenté, piège à cétoines)	Piégeage bouteille (piège à vin, piège à appât fermenté, piège à cétoines)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.089	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
271	100	90	Piégeage entomologique composite (PEC)	Piégeage entomologique composite (PEC)	Piégeage entomologique composite (PEC)	Piégeage entomologique composite (PEC)	Piégeage entomologique composite (PEC)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.090	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
272	100	91	Piégeage lumineux aquatique à fluorescence	Piégeage lumineux aquatique à fluorescence	Piégeage lumineux aquatique à fluorescence	Piégeage lumineux aquatique à fluorescence	Piégeage lumineux aquatique à fluorescence	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.091	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
273	100	92	Piégeage lumineux aquatique à incandescence	Piégeage lumineux aquatique à incandescence	Piégeage lumineux aquatique à incandescence	Piégeage lumineux aquatique à incandescence	Piégeage lumineux aquatique à incandescence	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.092	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
274	100	93	Piégeage lumineux aquatique à LED	Piégeage lumineux aquatique à LED	Piégeage lumineux aquatique à LED	Piégeage lumineux aquatique à LED	Piégeage lumineux aquatique à LED	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.093	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
275	100	94	Piégeage lumineux automatique à fluorescence	Piégeage lumineux automatique à fluorescence	Piégeage lumineux automatique à fluorescence	Piégeage lumineux automatique à fluorescence	Piégeage lumineux automatique à fluorescence	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.094	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
276	100	95	Piégeage lumineux automatique à incandescence	Piégeage lumineux automatique à incandescence	Piégeage lumineux automatique à incandescence	Piégeage lumineux automatique à incandescence	Piégeage lumineux automatique à incandescence	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.095	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
277	100	96	Piégeage lumineux automatique à LED	Piégeage lumineux automatique à LED	Piégeage lumineux automatique à LED	Piégeage lumineux automatique à LED	Piégeage lumineux automatique à LED	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.096	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
278	100	97	Piégeage lumineux manuel à fluorescence	Piégeage lumineux manuel à fluorescence	Piégeage lumineux manuel à fluorescence	Piégeage lumineux manuel à fluorescence	Piégeage lumineux manuel à fluorescence	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.097	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
279	100	98	Piégeage lumineux manuel à incandescence	Piégeage lumineux manuel à incandescence	Piégeage lumineux manuel à incandescence	Piégeage lumineux manuel à incandescence	Piégeage lumineux manuel à incandescence	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.098	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
280	100	99	Piégeage lumineux manuel à LED	Piégeage lumineux manuel à LED	Piégeage lumineux manuel à LED	Piégeage lumineux manuel à LED	Piégeage lumineux manuel à LED	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.099	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
281	100	100	Piégeage Malaise (capture par tente Malaise)	Piégeage Malaise (capture par tente Malaise)	Piégeage Malaise (capture par tente Malaise)	Piégeage Malaise (capture par tente Malaise)	Piégeage Malaise (capture par tente Malaise)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.100	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
282	100	101	Piégeage Marris House Net (capture par piège Malaise type Marris House Net)	Piégeage Marris House Net (capture par piège Malaise type Marris House Net)	Piégeage Marris House Net (capture par piège Malaise type Marris House Net)	Piégeage Marris House Net (capture par piège Malaise type Marris House Net)	Piégeage Marris House Net (capture par piège Malaise type Marris House Net)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.101	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
283	100	102	Piégeage microtube à fourmis	Piégeage microtube à fourmis	Piégeage microtube à fourmis	Piégeage microtube à fourmis	Piégeage microtube à fourmis	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.102	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
365	109	7	Point de contact base de données de production	Point de contact base de données de production	Point de contact base de données de productions	Point de contact base de données de production	Point de contact base de données de productions	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	109.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
284	100	103	Piégeage par assiettes colorées (piège coloré, plaque colorée adhésive)	Piégeage par assiettes colorées (piège coloré, plaque colorée adhésive)	Piégeage par assiettes colorées (piège coloré, plaque colorée adhésive)	Piégeage par assiettes colorées (piège coloré, plaque colorée adhésive)	Piégeage par assiettes colorées (piège coloré, plaque colorée adhésive)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.103	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
285	100	104	Piégeage par attraction sexuelle avec femelles	Piégeage par attraction sexuelle avec femelles	Piégeage par attraction sexuelle avec femelles	Piégeage par attraction sexuelle avec femelles	Piégeage par attraction sexuelle avec femelles	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.104	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
286	100	105	Piégeage par attraction sexuelle avec phéromones	Piégeage par attraction sexuelle avec phéromones	Piégeage par attraction sexuelle avec phéromones	Piégeage par attraction sexuelle avec phéromones	Piégeage par attraction sexuelle avec phéromones	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.105	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
287	100	106	Piégeage par enceinte à émergence aquatique (nasse à émergence aquatique)	Piégeage par enceinte à émergence aquatique (nasse à émergence aquatique)	Piégeage par enceinte à émergence aquatique (nasse à émergence aquatique)	Piégeage par enceinte à émergence aquatique (nasse à émergence aquatique)	Piégeage par enceinte à émergence aquatique (nasse à émergence aquatique)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.106	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
288	100	107	Piégeage par enceinte à émergence terrestre ex situ (nasse à émergence terrestre, éclosoir)	Piégeage par enceinte à émergence terrestre ex situ (nasse à émergence terrestre, éclosoir)	Piégeage par enceinte à émergence terrestre ex situ (nasse à émergence terrestre, éclosoir)	Piégeage par enceinte à émergence terrestre ex situ (nasse à émergence terrestre, éclosoir)	Piégeage par enceinte à émergence terrestre ex situ (nasse à émergence terrestre, éclosoir)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.107	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
289	100	108	Piégeage par enceinte à émergence terrestre in situ (nasse à émergence terrestre, éclosoir)	Piégeage par enceinte à émergence terrestre in situ (nasse à émergence terrestre, éclosoir)	Piégeage par enceinte à émergence terrestre in situ (nasse à émergence terrestre, éclosoir)	Piégeage par enceinte à émergence terrestre in situ (nasse à émergence terrestre, éclosoir)	Piégeage par enceinte à émergence terrestre in situ (nasse à émergence terrestre, éclosoir)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.108	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
290	100	109	Piégeage par enceinte type biocénomètre	Piégeage par enceinte type biocénomètre	Piégeage par enceinte type biocénomètre	Piégeage par enceinte type biocénomètre	Piégeage par enceinte type biocénomètre	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.109	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
291	100	110	Piégeage par nasse à Coléoptères Hydrocanthares (piège appâté aquatique)	Piégeage par nasse à Coléoptères Hydrocanthares (piège appâté aquatique)	Piégeage par nasse à Coléoptères Hydrocanthares (piège appâté aquatique)	Piégeage par nasse à Coléoptères Hydrocanthares (piège appâté aquatique)	Piégeage par nasse à Coléoptères Hydrocanthares (piège appâté aquatique)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.110	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
292	100	111	Piégeage par nasses aquatiques ou filets verveux (appâtés)	Piégeage par nasses aquatiques ou filets verveux (appâtés)	Piégeage par nasses aquatiques ou filets verveux (appâtés)	Piégeage par nasses aquatiques ou filets verveux (appâtés)	Piégeage par nasses aquatiques ou filets verveux (appâtés)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.111	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
496	119	3.7	3.7	Sondeur monofaisceau	Sondeur monofaisceau	Sondeur monofaisceau	Sondeur monofaisceau	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
293	100	112	Piégeage par nasses aquatiques ou filets verveux (non appâtés)	Piégeage par nasses aquatiques ou filets verveux (non appâtés)	Piégeage par nasses aquatiques ou filets verveux (non appâtés)	Piégeage par nasses aquatiques ou filets verveux (non appâtés)	Piégeage par nasses aquatiques ou filets verveux (non appâtés)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.112	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
294	100	113	Piégeage par piège à entonnoir terrestre (funnel trap) (appâté)	Piégeage par piège à entonnoir terrestre (funnel trap) (appâté)	Piégeage par piège à entonnoir terrestre (funnel trap) (appâté)	Piégeage par piège à entonnoir terrestre (funnel trap) (appâté)	Piégeage par piège à entonnoir terrestre (funnel trap) (appâté)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.113	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
295	100	114	Piégeage par piège à entonnoir terrestre (funnel trap) (non appâté)	Piégeage par piège à entonnoir terrestre (funnel trap) (non appâté)	Piégeage par piège à entonnoir terrestre (funnel trap) (non appâté)	Piégeage par piège à entonnoir terrestre (funnel trap) (non appâté)	Piégeage par piège à entonnoir terrestre (funnel trap) (non appâté)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.114	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
296	100	115	Piégeage par piège-vitre bidirectionnel \\"mimant une cavité\\" (bande noire)	Piégeage par piège-vitre bidirectionnel \\"mimant une cavité\\" (bande noire)	Piégeage par piège-vitre bidirectionnel \\"mimant une cavité\\" (bande noire)	Piégeage par piège-vitre bidirectionnel \\"mimant une cavité\\" (bande noire)	Piégeage par piège-vitre bidirectionnel \\"mimant une cavité\\" (bande noire)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.115	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
297	100	116	Piégeage par piège-vitre bidirectionnel (piège fenêtre, piège-vitre plan)	Piégeage par piège-vitre bidirectionnel (piège fenêtre, piège-vitre plan)	Piégeage par piège-vitre bidirectionnel (piège fenêtre, piège-vitre plan)	Piégeage par piège-vitre bidirectionnel (piège fenêtre, piège-vitre plan)	Piégeage par piège-vitre bidirectionnel (piège fenêtre, piège-vitre plan)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.116	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
298	100	117	Piégeage par piège-vitre multidirectionnel avec alcool (piège Polytrap, PIMUL)	Piégeage par piège-vitre multidirectionnel avec alcool (piège Polytrap, PIMUL)	Piégeage par piège-vitre multidirectionnel avec alcool (piège Polytrap, PIMUL)	Piégeage par piège-vitre multidirectionnel avec alcool (piège Polytrap, PIMUL)	Piégeage par piège-vitre multidirectionnel avec alcool (piège Polytrap, PIMUL)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.117	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
299	100	118	Piégeage par piège-vitre multidirectionnel sans alcool (piège Polytrap, PIMUL)	Piégeage par piège-vitre multidirectionnel sans alcool (piège Polytrap, PIMUL)	Piégeage par piège-vitre multidirectionnel sans alcool (piège Polytrap, PIMUL)	Piégeage par piège-vitre multidirectionnel sans alcool (piège Polytrap, PIMUL)	Piégeage par piège-vitre multidirectionnel sans alcool (piège Polytrap, PIMUL)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.118	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
300	100	119	Piégeage par sac collecteur de feuillage et rameaux ligneux	Piégeage par sac collecteur de feuillage et rameaux ligneux	Piégeage par sac collecteur de feuillage et rameaux ligneux	Piégeage par sac collecteur de feuillage et rameaux ligneux	Piégeage par sac collecteur de feuillage et rameaux ligneux	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.119	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
301	100	120	Piégeage par sélecteur de Chauvin	Piégeage par sélecteur de Chauvin	Piégeage par sélecteur de Chauvin	Piégeage par sélecteur de Chauvin	Piégeage par sélecteur de Chauvin	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.120	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
302	100	121	Piégeage par tissu imbibé d'insecticide	Piégeage par tissu imbibé d'insecticide	Piégeage par tissu imbibé d'insecticide	Piégeage par tissu imbibé d'insecticide	Piégeage par tissu imbibé d'insecticide	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.121	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
303	100	122	Piégeage SLAM (capture par piège Sand Land and Air Malaise)	Piégeage SLAM (capture par piège Sand Land and Air Malaise)	Piégeage SLAM (capture par piège Sand Land and Air Malaise)	Piégeage SLAM (capture par piège Sand Land and Air Malaise)	Piégeage SLAM (capture par piège Sand Land and Air Malaise)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.122	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
366	110	METROP	Métropole	Métropole	Métropole	Métropole	Métropole	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
367	110	GUF	Guyane française	Guyane française	Guyane française	Guyane française	Guyane française	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
304	100	123	Piégeages par pièges barrières (pots-pièges associés à une barrière d'interception)	Piégeages par pièges barrières (pots-pièges associés à une barrière d'interception)	Piégeages par pièges barrières (pots-pièges associés à une barrière d'interception)	Piégeages par pièges barrières (pots-pièges associés à une barrière d'interception)	Piégeages par pièges barrières (pots-pièges associés à une barrière d'interception)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.123	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
305	100	124	Pièges à poils	Pièges à poils	Pièges à poils	Pièges à poils	Pièges à poils	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.124	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
306	100	125	Pièges à traces (pièges à empreintes)	Pièges à traces (pièges à empreintes)	Pièges à traces (pièges à empreintes)	Pièges à traces (pièges à empreintes)	Pièges à traces (pièges à empreintes)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.125	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
307	100	126	Pièges aquatiques à sangsues (bouteilles percées, appâtées…)	Pièges aquatiques à sangsues (bouteilles percées, appâtées…)	Pièges aquatiques à sangsues (bouteilles percées, appâtées…)	Pièges aquatiques à sangsues (bouteilles percées, appâtées…)	Pièges aquatiques à sangsues (bouteilles percées, appâtées…)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.126	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
308	100	127	Pièges cache-tubes	Pièges cache-tubes	Pièges cache-tubes	Pièges cache-tubes	Pièges cache-tubes	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.127	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
309	100	128	Pièges cache-tubes adhésifs (tubes capteurs de poils)	Pièges cache-tubes adhésifs (tubes capteurs de poils)	Pièges cache-tubes adhésifs (tubes capteurs de poils)	Pièges cache-tubes adhésifs (tubes capteurs de poils)	Pièges cache-tubes adhésifs (tubes capteurs de poils)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.128	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
310	100	129	Prélèvement par râteau ou grappin (macrophytes)	Prélèvement par râteau ou grappin (macrophytes)	Prélèvement par râteau ou grappin (macrophytes)	Prélèvement par râteau ou grappin (macrophytes)	Prélèvement par râteau ou grappin (macrophytes)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.129	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
490	119	3.1	3.1	Sonar à balayage latéral	Sonar à balayage latéral	Sonar à balayage latéral	Sonar à balayage latéral	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
311	100	130	Prospection à pied de cours d'eau (macrophytes)	Prospection à pied de cours d'eau (macrophytes)	Prospection à pied de cours d'eau (macrophytes)	Prospection à pied de cours d'eau (macrophytes)	Prospection à pied de cours d'eau (macrophytes)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.130	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
312	100	131	Prospection active dans l'habitat naturel (talus, souches, pierres…)	Prospection active dans l'habitat naturel (talus, souches, pierres…)	Prospection active dans l'habitat naturel (talus, souches, pierres…)	Prospection active dans l'habitat naturel (talus, souches, pierres…)	Prospection active dans l'habitat naturel (talus, souches, pierres…)	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.131	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
313	100	132	Recherche dans filtres de piscines, skimmer	Recherche dans filtres de piscines, skimmer	Recherche dans filtres de piscines, skimmer	Recherche dans filtres de piscines, skimmer	Recherche dans filtres de piscines, skimmer	\N	\N	\N	\N	\N	\N	\N	\N	CAMPANULE	Validation en cours	0	100.132	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
314	100	133	Non renseigné	Non renseigné	La  technique d'observation n'est pas renseignée	Non renseigné	La  technique d'observation n'est pas renseignée	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	100.133	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
315	101	1	Certain - très probable	Certain - très probable	La donnée est exacte. Il n’y a pas de doute notable et significatif quant à l’exactitude de l’observation ou de la détermination du taxon. La validation a été réalisée notamment à partir d’une preuve de l’observation qui confirme la détermination du producteur ou après vérification auprès de l’observateur et/ou du déterminateur.	Certain - très probable	La donnée est exacte. Il n’y a pas de doute notable et significatif quant à l’exactitude de l’observation ou de la détermination du taxon. La validation a été réalisée notamment à partir d’une preuve de l’observation qui confirme la détermination du producteur ou après vérification auprès de l’observateur et/ou du déterminateur.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	validé	0	101.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
316	101	2	Probable	Probable	 La donnée présente un bon niveau de fiabilité. Elle est vraisemblable et crédible. Il n’y a, a priori, aucune raison de douter de l’exactitude de la donnée mais il n’y a pas d’éléments complémentaires suffisants disponibles ou évalués (notamment la présence d’une preuve ou la possibilité de revenir à la donnée source) permettant d’attribuer un plus haut niveau de certitude.	Probable	 La donnée présente un bon niveau de fiabilité. Elle est vraisemblable et crédible. Il n’y a, a priori, aucune raison de douter de l’exactitude de la donnée mais il n’y a pas d’éléments complémentaires suffisants disponibles ou évalués (notamment la présence d’une preuve ou la possibilité de revenir à la donnée source) permettant d’attribuer un plus haut niveau de certitude.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	validé	0	101.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
317	101	3	Douteux	Douteux	La donnée est peu vraisemblable ou surprenante mais on ne dispose pas d’éléments suffisants pour attester d’une erreur manifeste. La donnée est considérée comme douteuse.	Douteux	La donnée est peu vraisemblable ou surprenante mais on ne dispose pas d’éléments suffisants pour attester d’une erreur manifeste. La donnée est considérée comme douteuse.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	validé	0	101.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
318	101	4	Invalide	Invalide	La donnée a été infirmée (erreur manifeste/avérée) ou présente un trop bas niveau de fiabilité. Elle est considérée comme trop improbable (aberrante notamment au regard de l’aire de répartition connue, des paramètres biotiques et abiotiques de la niche écologique du taxon, la preuve révèle une erreur de détermination). Elle est considérée comme invalide.	Invalide	La donnée a été infirmée (erreur manifeste/avérée) ou présente un trop bas niveau de fiabilité. Elle est considérée comme trop improbable (aberrante notamment au regard de l’aire de répartition connue, des paramètres biotiques et abiotiques de la niche écologique du taxon, la preuve révèle une erreur de détermination). Elle est considérée comme invalide.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	validé	0	101.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
319	101	5	Non réalisable	Non réalisable	La donnée a été soumise à l’ensemble du processus de validation mais l’opérateur (humain ou machine) n’a pas pu statuer sur le niveau de fiabilité, notamment à cause des points suivants : état des connaissances du taxon insuffisantes, ou informations insuffisantes sur l’observation.	Non réalisable	La donnée a été soumise à l’ensemble du processus de validation mais l’opérateur (humain ou machine) n’a pas pu statuer sur le niveau de fiabilité, notamment à cause des points suivants : état des connaissances du taxon insuffisantes, ou informations insuffisantes sur l’observation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	validé	0	101.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
320	101	6	Inconnu	Inconnu	Le statut de validation n'est pas connu.	Inconnu	Le statut de validation n'est pas connu.	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	101.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
321	102	1	Dataset	Dataset	Jeu de données	Dataset	Jeu de données	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	102.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
322	102	2	Series	Series	ensemble de séries de données	Series	ensemble de séries de données	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	102.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
323	103	1	Occtax	Occurrences de Taxons	Occurrences de Taxons	Occurrences de Taxons	Occurrences de Taxons	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	103.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
324	103	2	Occhab	Occurrences d'habitats	Occurrences d'habitats	Occurrences d'habitats	Occurrences d'habitats	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	103.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
325	103	3	Syntax	Syntax	Synthèse de taxons	Syntax	Synthèse de taxons	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	103.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
326	103	4	Synhab	Synhab	Synthese d'habitats	Synhab	Synthese d'habitats	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	103.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
327	103	5	NR	Non renseigné	Non renseigné	Non renseigné	Non renseigné	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	103.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
328	104	1	Aléatoire simple	Aléatoire simple	Les tirages des unités sont équiprobables et indépendants)	Aléatoire simple	Les tirages des unités sont équiprobables et indépendants)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	104.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
329	104	2	Systématique	Systématique	Les unités sont ordonnées (par ex. selon leurs coordonnées). Une première unité est tirée au hasard et les suivantes s'en déduisent en respectant l'agencement	Systématique	Les unités sont ordonnées (par ex. selon leurs coordonnées). Une première unité est tirée au hasard et les suivantes s'en déduisent en respectant l'agencement	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	104.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
452	106	17	Examen direct des traces ou indices de présence	Examen direct des traces ou indices de présence	La détermination repose sur l'examen direct des traces ou indices de présences par le déterminateur	Examen direct des traces ou indices de présence	La détermination repose sur l'examen direct des traces ou indices de présences par le déterminateur	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
330	104	3	Stratifié	Stratifié	La zone d'étude est découpée en strates plus homogènes (selon les grands types de milieux par ex.), et les unités d'échantillonnage sont sélectionnées au sein de chaque strate selon un plan d'échantillonnage secondaire	Stratifié	La zone d'étude est découpée en strates plus homogènes (selon les grands types de milieux par ex.), et les unités d'échantillonnage sont sélectionnées au sein de chaque strate selon un plan d'échantillonnage secondaire	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	104.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
502	119	8.1	8.1	Plongées	Plongées	Plongées	Plongées	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.021	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
368	110	MTQ	Martinique	Martinique	Martinique	Martinique	Martinique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
332	104	5	Probabilités inégales	Probabilités inégales (distance sampling, relascope)	Le tirage des unités est aléatoire avec probabilités inégales (chaque unité d'échantillonnage n'a pas la même probabilité d'être sélectionnée). C'est souvent le cas pour des unités de taille variable	Probabilités inégales (distance sampling, relascope)	Le tirage des unités est aléatoire avec probabilités inégales (chaque unité d'échantillonnage n'a pas la même probabilité d'être sélectionnée). C'est souvent le cas pour des unités de taille variable	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	104.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
333	104	6	Par degrés, par grappes	Par degrés, par grappes	La sélection des unités s'effectue dans un système hiérarchisé d'unités primaires, composées d'unités secondaires, etc. Par exemple, des arbres sont sélectionnés au sein de placettes, elles-mêmes sélectionnées au sein de peuplements forestiers, etc	Par degrés, par grappes	La sélection des unités s'effectue dans un système hiérarchisé d'unités primaires, composées d'unités secondaires, etc. Par exemple, des arbres sont sélectionnés au sein de placettes, elles-mêmes sélectionnées au sein de peuplements forestiers, etc	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	104.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
334	104	7	Subjectif	Subjectif	Le choix des unités d'échantillonnage est effectué selon des critères propres à l'observateur (pas toujours précisés)	Subjectif	Le choix des unités d'échantillonnage est effectué selon des critères propres à l'observateur (pas toujours précisés)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	104.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
335	104	8	Autre	Autre	Autre type de plan d'échantillonnage	Autre	Autre type de plan d'échantillonnage	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	104.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
337	105	2	Points	Points	Points	Points	Points	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	105.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
338	105	3	Quadrats	Quadrats	Surface impérativement carrée.	Quadrats	Surface impérativement carrée.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	105.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
339	105	4	Placettes	Placettes	Surface de format variable (souvent circulaire, peut également être rectangulaire, etc.)	Placettes	Surface de format variable (souvent circulaire, peut également être rectangulaire, etc.)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	105.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
340	105	5	Transects	Transects	Mesure en continu le long d'un tracé entre deux points (Désigne parfois une série de placettes effectuées le long d'un parcours entre deux points, mais c'est un abus de langage : dans ce cas, l'unité d'échantillonnage est la placette)	Transects	Mesure en continu le long d'un tracé entre deux points (Désigne parfois une série de placettes effectuées le long d'un parcours entre deux points, mais c'est un abus de langage : dans ce cas, l'unité d'échantillonnage est la placette)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	105.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
341	105	6	Autre	Autre	Autre type d'unités d'échantillonnage	Autre	Autre type d'unités d'échantillonnage	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	105.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
342	106	3	Analyse d’ADN environnemental	Analyse d’ADN environnemental	La détermination a été effectuée sur la base des résultats d'une analyse d'ADN environnemental	Analyse d’ADN environnemental	La détermination a été effectuée sur la base des résultats d'une analyse d'ADN environnemental	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
343	106	4	Analyse ADN de l'individu ou de ses restes	Analyse ADN de l'individu ou de ses restes	La détermination a été effectuée sur la base des résultats d'une analyse d'ADN réalisée à partir d'un échantillon prélevé sur un ou des individus, des traces ou restes (fragments ou résidus) d'individus	Analyse ADN de l'individu ou de ses restes	La détermination a été effectuée sur la base des résultats d'une analyse d'ADN réalisée à partir d'un échantillon prélevé sur un ou des individus, des traces ou restes (fragments ou résidus) d'individus	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
344	106	5	Analyse biophysique ou biochimique	Analyse biophysique ou biochimique	La détermination repose sur des méthodes biophysiques ou biochimiques	Analyse biophysique ou biochimique	La détermination repose sur des méthodes biophysiques ou biochimiques	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
345	106	6	Déduction de l'espèce par n° d'identification	Déduction de l'espèce par n° d'identification	L'espèce est déduite sur la base d'un numéro d'identification attribué précédemment à un individu : n° de bague, n° de balise gps etc	Déduction de l'espèce par n° d'identification	L'espèce est déduite sur la base d'un numéro d'identification attribué précédemment à un individu : n° de bague, n° de balise gps etc	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
346	106	7	Détermination informatique par un outil de reconnaissance automatique	Détermination informatique par un outil de reconnaissance automatique	La détermination a été effectuée à l'aide d'une ou des applications de reconnaissance automatique visuelle ou auditive des espèces, sur informatique ou appareils mobiles	Détermination informatique par un outil de reconnaissance automatique	La détermination a été effectuée à l'aide d'une ou des applications de reconnaissance automatique visuelle ou auditive des espèces, sur informatique ou appareils mobiles	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
347	106	8	Examen biométrique	Examen biométrique	La détermination repose sur des examens biométriques	Examen biométrique	La détermination repose sur des examens biométriques	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
348	106	9	Examen auditif direct	Examen auditif direct	La détermination repose sur une écoute directe des sons produits par l'espèce, à l'oreille et sans transformation	Examen auditif direct	La détermination repose sur une écoute directe des sons produits par l'espèce, à l'oreille et sans transformation	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
453	106	18	Examen visuel à distance	Examen visuel à distance	La détermination a été effectuée à distance sur le terrain, à l'œil nu ou à l'aide de longue vue, jumelles etc	Examen visuel à distance	La détermination a été effectuée à distance sur le terrain, à l'œil nu ou à l'aide de longue vue, jumelles etc	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.018	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
349	106	10	Examen auditif avec transformation électronique	Examen auditif avec transformation électronique	La détermination repose sur une écoute des sons produits par l'espèce après transformation électronique : transformation d'ultrasons, signaux hétérodynes, expansions de temps…	Examen auditif avec transformation électronique	La détermination repose sur une écoute des sons produits par l'espèce après transformation électronique : transformation d'ultrasons, signaux hétérodynes, expansions de temps…	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
350	106	11	Examen des organes reproducteurs ou critères spécifiques en laboratoire	Examen des organes reproducteurs ou critères spécifiques en laboratoire	La détermination repose sur l'examen précis des organes reproducteurs ou autres critères spécifiques en laboratoire	Examen des organes reproducteurs ou critères spécifiques en laboratoire	La détermination repose sur l'examen précis des organes reproducteurs ou autres critères spécifiques en laboratoire	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
351	106	2	Autre méthode de détermination	Autre méthode de détermination	La méthode de détermination n'est pas présente dans cette liste	Autre méthode de détermination	La méthode de détermination n'est pas présente dans cette liste	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
352	107	1	International	International	Niveau international	International	Niveau international	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	107.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
353	107	2	Européen	Européen	Niveau européen	Européen	Niveau européen	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	107.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
354	107	3	National	National	Niveau national	National	Niveau national	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	107.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
355	107	4	Inter-régional terrestre, ou région marine	Inter-régional terrestre, ou région marine	Niveau inter-régional terrestre, ou région marine	Inter-régional terrestre, ou région marine	Niveau inter-régional terrestre, ou région marine	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	107.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
356	107	5	Régional terrestre, ou sous-région marine	Régional terrestre, ou sous-région marine	Niveau régional terrestre, ou sous-région marine	Régional terrestre, ou sous-région marine	Niveau régional terrestre, ou sous-région marine	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	107.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
357	107	6	Départemental, ou secteur marin	Départemental, ou secteur marin	Niveau départemental, ou secteur marin	Départemental, ou secteur marin	Niveau départemental, ou secteur marin	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	107.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
358	107	7	Communal ou local	Communal ou local	Niveau communal ou local	Communal ou local	Niveau communal ou local	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	107.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
359	109	1	Contact principal	Contact principal	Contact principal	Contact principal	Contact principal	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	109.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
360	109	2	Financeur	Financeur	Financeur	Financeur	Financeur	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	109.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
361	109	3	Maître d'ouvrage	Maître d'ouvrage	Maître d'ouvrage	Maître d'ouvrage	Maître d'ouvrage	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	109.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
362	109	4	Maître d'oeuvre	Maître d'oeuvre	Maître d'oeuvre	Maître d'oeuvre	Maître d'oeuvre	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	109.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
561	124	17	17	Repos	Repos	Repos	Repos	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
371	110	BLM	Saint-Barthélemy	Saint-Barthélemy	Saint-Barthélemy	Saint-Barthélemy	Saint-Barthélemy	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
372	110	SPM	Saint-Pierre et Miquelon	Saint-Pierre et Miquelon	Saint-Pierre et Miquelon	Saint-Pierre et Miquelon	Saint-Pierre et Miquelon	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
373	110	MYT	Mayotte	Mayotte	Mayotte	Mayotte	Mayotte	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
374	110	REU	Réunion	Réunion	Réunion	Réunion	Réunion	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
375	110	NCL	Nouvelle-Calédonie	Nouvelle-Calédonie	Nouvelle-Calédonie	Nouvelle-Calédonie	Nouvelle-Calédonie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
376	110	WLF	Wallis-et-Futuna	Wallis-et-Futuna	Wallis-et-Futuna	Wallis-et-Futuna	Wallis-et-Futuna	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
377	110	PYF	Polynésie française	Polynésie française	Polynésie française	Polynésie française	Polynésie française	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
378	110	CLI	Clipperton	Clipperton	Clipperton	Clipperton	Clipperton	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
379	110	EPA	TAAF : Iles Eparses	TAAF : Iles Eparses	TAAF : Iles Eparses	TAAF : Iles Eparses	TAAF : Iles Eparses	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
380	110	SUBANT	TAAF : Iles sub-Antarctiques	TAAF : Iles sub-Antarctiques	TAAF : Iles sub-Antarctiques	TAAF : Iles sub-Antarctiques	TAAF : Iles sub-Antarctiques	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
381	110	TADL	TAAF : Terre-Adélie	TAAF : Terre-Adélie	TAAF : Terre-Adélie	TAAF : Terre-Adélie	TAAF : Terre-Adélie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
382	110	HORSFR	Hors territoire	Hors territoire	Hors territoire	Hors territoire	Hors territoire	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	110.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
383	111	1	Publique	Publique	Type de financement public	Publique	Type de financement public	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	111.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
384	111	2	Privée	Privée	Type de financement privé	Privée	Type de financement privé	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	111.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
385	111	3	Mixte	Mixte	Mélange de financement public et privé	Mixte	Mélange de financement public et privé	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	111.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
386	111	4	Non financé	Non financé	Absence de financement	Non financé	Absence de financement	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	111.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
387	112	0	Inconnu	Inconnu	Inconnu	Inconnu	Inconnu	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	112.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
388	112	1	Protocole de collecte	Protocole de collecte	Protocole de collecte	Protocole de collecte	Protocole de collecte	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	1121.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
389	112	2	Protocole de synthèse	Protocole de synthèse	Protocole de synthèse	Protocole de synthèse	Protocole de synthèse	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	112.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
390	112	3	Protocole de conformité et de cohérence	Protocole de conformité et de cohérence	Protocole de conformité et de cohérence	Protocole de conformité et de cohérence	Protocole de conformité et de cohérence	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	111.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
391	112	4	Protocole de validation	Protocole de validation	Protocole de validation	Protocole de validation	Protocole de validation	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	112.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
392	113	1	Terre	Terre	Toutes les données relatives à la nature/biodiversité française du domaine terrestre (outre-mer compris) : habitats, flore, faune, champignons..., les données relatives aux espaces naturels (protégés / gérés ou non), aux sites géologiques, aux écosystèmes et leur fonctionnement.	Terre	Toutes les données relatives à la nature/biodiversité française du domaine terrestre (outre-mer compris) : habitats, flore, faune, champignons..., les données relatives aux espaces naturels (protégés / gérés ou non), aux sites géologiques, aux écosystèmes et leur fonctionnement.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	113.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
393	113	2	Mer	Mer	Toutes les données relatives à la nature / biodiversité française du domaine marin (outre-mer compris) : habitats, flore, faune, champignons..., les données relatives aux espaces naturels (protégés/gérés ou non), aux sites géologiques, aux écosystèmes et leur fonctionnement.	Mer	Toutes les données relatives à la nature / biodiversité française du domaine marin (outre-mer compris) : habitats, flore, faune, champignons..., les données relatives aux espaces naturels (protégés/gérés ou non), aux sites géologiques, aux écosystèmes et leur fonctionnement.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	113.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
394	113	3	Paysage	Paysage	Toutes les données relatives aux paysages, c'est-à-dire des données relatives aux formes du territoire, aux perceptions sociales et aux dynamiques du territoire. Elles intègrent également des inventaires particuliers. Elles concernent les espaces naturels, ruraux, urbains et périurbains. Elles incluent les espaces terrestres, les eaux intérieures et maritimes. Elles concernent tant les paysages pouvant être considérés comme remarquables que les paysages du quotidien et les paysages dégradés.	Paysage	Toutes les données relatives aux paysages, c'est-à-dire des données relatives aux formes du territoire, aux perceptions sociales et aux dynamiques du territoire. Elles intègrent également des inventaires particuliers. Elles concernent les espaces naturels, ruraux, urbains et périurbains. Elles incluent les espaces terrestres, les eaux intérieures et maritimes. Elles concernent tant les paysages pouvant être considérés comme remarquables que les paysages du quotidien et les paysages dégradés.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	113.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
395	109	8	Point de contact pour les métadonnées	Point de contact pour les métadonnées	Point de contact pour les métadonnées	Point de contact pour les métadonnées	Point de contact pour les métadonnées	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	109.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
396	115	1	Observation directe : Vue, écoute, olfactive, tactile	Observation directe : Vue, écoute, olfactive, tactile	Observation directe : Vue, écoute, olfactive, tactile	Observation directe : Vue, écoute, olfactive, tactile	Observation directe : Vue, écoute, olfactive, tactile	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
397	115	2	Pièges photo	Pièges photo	Pièges photo	Pièges photo	Pièges photo	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
398	115	3	Détection d'ultrasons	Détection d'ultrasons	Détection d'ultrasons	Détection d'ultrasons	Détection d'ultrasons	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
399	115	4	Recherche d'indices de présence	Recherche d'indices de présence	Recherche d'indices de présence	Recherche d'indices de présence	Recherche d'indices de présence	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
400	115	5	Photographies aériennes	Photographies aériennes	Photographies aériennes	Photographies aériennes	Photographies aériennes	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
401	115	6	Télédétection	Télédétection	Télédétection	Télédétection	Télédétection	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
402	115	7	Télémétrie	Télémétrie	Télémétrie	Télémétrie	Télémétrie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
403	115	8	Capture d'individus (sans capture d'échantillon) : capture-relâcher	Capture d'individus (sans capture d'échantillon) : capture-relâcher	Capture d'individus (sans capture d'échantillon) : capture-relâcher	Capture d'individus (sans capture d'échantillon) : capture-relâcher	Capture d'individus (sans capture d'échantillon) : capture-relâcher	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
404	115	9	Prélèvement (capture avec collecte d'échantillon) : capture-conservation	Prélèvement (capture avec collecte d'échantillon) : capture-conservation	Prélèvement (capture avec collecte d'échantillon) : capture-conservation	Prélèvement (capture avec collecte d'échantillon) : capture-conservation	Prélèvement (capture avec collecte d'échantillon) : capture-conservation	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
405	115	10	Capture marquage recapture	Capture marquage recapture	Capture marquage recapture	Capture marquage recapture	Capture marquage recapture	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
406	115	11	Capture-suivi (radiotracking)	Capture-suivi (radiotracking)	Capture-suivi (radiotracking)	Capture-suivi (radiotracking)	Capture-suivi (radiotracking)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	115.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
562	124	18	18	Chant	Chant	Chant	Chant	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.018	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
408	114	1.1	Observations naturalistes opportunistes	Observations naturalistes opportunistes	Les programmes d’observation participative (tous publics ou experts bénévoles, «recording scheme »), recueillant les données d’observation, sans plan d’échantillonnage particulier ni objectif prédéfini. La saisie de carnet de terrain entre dans cette rubrique. De même des observations annexes (groupe non cible) faites lors d’un programme spécifique entrent dans cette catégorie. Si ces informations sont recueillies dans un programme d’atlas en ligne, elles entrent dans la catégorie 1.2	Observations naturalistes opportunistes	Les programmes d’observation participative (tous publics ou experts bénévoles, «recording scheme »), recueillant les données d’observation, sans plan d’échantillonnage particulier ni objectif prédéfini. La saisie de carnet de terrain entre dans cette rubrique. De même des observations annexes (groupe non cible) faites lors d’un programme spécifique entrent dans cette catégorie. Si ces informations sont recueillies dans un programme d’atlas en ligne, elles entrent dans la catégorie 1.2	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
454	106	19	Examen visuel en collection 	Examen visuel en collection 	La détermination repose sur l'examen visuel d'un individu en collection : boite entomologique, herbier, collections en alcool ou formol…	Examen visuel en collection 	La détermination repose sur l'examen visuel d'un individu en collection : boite entomologique, herbier, collections en alcool ou formol…	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.019	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
455	106	20	Examen visuel sous loupe ou microscope	Examen visuel sous loupe ou microscope	La détermination repose sur l'examen précis de l'individu sous loupe ou microscope	Examen visuel sous loupe ou microscope	La détermination repose sur l'examen précis de l'individu sous loupe ou microscope	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.020	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
409	114	1.2	Inventaire de répartition	Inventaire de répartition	Logique de projet avec un échantillonnage visant à couvrir le plus de territoire possible pour une espèce ou un groupe taxonomique donné, afin d’établir sa distribution dans une logique d’atlas, quelques soit son échelle (généralement départemental, régional ou national). Quand l’inventaire de répartition est la logique dominante, et qu’elle s’accompagne d’observations occasionnelles (non cible : exemple observation d’une couleuvre à collier lors d’un carré d’atlas oiseaux nicheur), ces observations occasionnelles peuvent être inclues dans cette catégorie mais devraient le plus possible faire l’objet d’un jdd distinct dans le même CA avec la catégorie « observation naturalistes opportunistes »	Inventaire de répartition	Logique de projet avec un échantillonnage visant à couvrir le plus de territoire possible pour une espèce ou un groupe taxonomique donné, afin d’établir sa distribution dans une logique d’atlas, quelques soit son échelle (généralement départemental, régional ou national). Quand l’inventaire de répartition est la logique dominante, et qu’elle s’accompagne d’observations occasionnelles (non cible : exemple observation d’une couleuvre à collier lors d’un carré d’atlas oiseaux nicheur), ces observations occasionnelles peuvent être inclues dans cette catégorie mais devraient le plus possible faire l’objet d’un jdd distinct dans le même CA avec la catégorie « observation naturalistes opportunistes »	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
410	114	1.3	Inventaire pour étude d’espèces ou de communautés	Inventaire pour étude d’espèces ou de communautés	Logique d’acquisition de données associées à un protocole dans le but d’avoir des informations sur les facteurs qui structurent la présence et/ou l’observation d’une espèce, d’une population ou d’une communauté à l’échelle d’une station ou d’un éco-complexe. Les objectifs peuvent être multiples (conservation, éthologie, dynamique des populations, interactions biologiques, structuration des communautés ...). La mise en place de protocoles pour établir des indices de détectabilité pour les espèces et/ou leur degré de spécialisation vis-à-vis d’un habitat rentre dans ce cas.	Inventaire pour étude d’espèces ou de communautés	Logique d’acquisition de données associées à un protocole dans le but d’avoir des informations sur les facteurs qui structurent la présence et/ou l’observation d’une espèce, d’une population ou d’une communauté à l’échelle d’une station ou d’un éco-complexe. Les objectifs peuvent être multiples (conservation, éthologie, dynamique des populations, interactions biologiques, structuration des communautés ...). La mise en place de protocoles pour établir des indices de détectabilité pour les espèces et/ou leur degré de spécialisation vis-à-vis d’un habitat rentre dans ce cas.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
411	114	1.4	Numérisation de collections	Numérisation de collections	Jeux de données généré par la mobilisation (saisie) de données d’une ou plusieurs collections de spécimens (herbier, collection entomologiques etc.) et visant à les rendre disponibles pour tout usage. Ce cas n’est à utiliser que si aucun autre motif plus précis à l’origine de la constitution de la collection ne peut être affecté : par exemple dans le cas où une campagne d’exploration génère des collections, le rattachement doit se faire à l’objectif « ATBI et exploration » (cf. libellé 2.5)	Numérisation de collections	Jeux de données généré par la mobilisation (saisie) de données d’une ou plusieurs collections de spécimens (herbier, collection entomologiques etc.) et visant à les rendre disponibles pour tout usage. Ce cas n’est à utiliser que si aucun autre motif plus précis à l’origine de la constitution de la collection ne peut être affecté : par exemple dans le cas où une campagne d’exploration génère des collections, le rattachement doit se faire à l’objectif « ATBI et exploration » (cf. libellé 2.5)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
412	114	1.5	Numérisation de bibliographie	Numérisation de bibliographie	Cas particulier d’un jeu de données contenant uniquement des données issues de l’analyse de la bibliographie (qu’elle soit publié ou en littérature grise) et visant à les rendre disponibles pour tout usage. Ce cas n’est à utiliser que si aucun autre motif plus précis à l’origine de la constitution de la bibliographie ne peut être affecté : par exemple dans le cas où une campagne d’exploration d’un site génère des publications, le rattachement doit se faire à l’objectif « ATBI et exploration ». Les carnets d’observation de terrain relèvent plutôt du 1.1, Observation opportunistes	Numérisation de bibliographie	Cas particulier d’un jeu de données contenant uniquement des données issues de l’analyse de la bibliographie (qu’elle soit publié ou en littérature grise) et visant à les rendre disponibles pour tout usage. Ce cas n’est à utiliser que si aucun autre motif plus précis à l’origine de la constitution de la bibliographie ne peut être affecté : par exemple dans le cas où une campagne d’exploration d’un site génère des publications, le rattachement doit se faire à l’objectif « ATBI et exploration ». Les carnets d’observation de terrain relèvent plutôt du 1.1, Observation opportunistes	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
413	114	2.1	Cartographie habitats	Cartographie habitats	Données correspondant à une cartographie des végétations-habitats-écosystèmes établie à une échelle large (département, région, PNR, petite région naturelle) et non selon une logique de site ou réseau de site. Les approches terrain, traitement d’image ou la combinaison des deux sont inclues. Relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisés dans le cadre d’une cartographie des végétations-habitats-écosystèmes. Si seuls des relevés sont effectués (sans détermination du type de végétation ou habitat), il faut affecter à une autre rubrique.	Cartographie habitats	Données correspondant à une cartographie des végétations-habitats-écosystèmes établie à une échelle large (département, région, PNR, petite région naturelle) et non selon une logique de site ou réseau de site. Les approches terrain, traitement d’image ou la combinaison des deux sont inclues. Relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisés dans le cadre d’une cartographie des végétations-habitats-écosystèmes. Si seuls des relevés sont effectués (sans détermination du type de végétation ou habitat), il faut affecter à une autre rubrique.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
456	106	21	Examen visuel de l’individu en main	Examen visuel de l’individu en main	La détermination repose sur l'examen direct de l'individu en main à l'œil nu	Examen visuel de l’individu en main	La détermination repose sur l'examen direct de l'individu en main à l'œil nu	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.021	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
491	119	3.2	3.2	Sondeur multifaisceaux	Sondeur multifaisceaux	Sondeur multifaisceaux	Sondeur multifaisceaux	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
492	119	3.3	3.3	Sonar à interféromètre	Sonar à interféromètre	Sonar à interféromètre	Sonar à interféromètre	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
414	114	2.2	Inventaire d’habitat	Inventaire d’habitat	Plan d’échantillonnage de l’espace avec détermination du type de végétation-habitat-écosystème. Relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisé dans le cadre d’un inventaire des végétations-habitats-écosystèmes. Si seuls des relevés sont effectués (sans détermination du type de végétation ou habitat), il faut affecter à une autre rubrique	Inventaire d’habitat	Plan d’échantillonnage de l’espace avec détermination du type de végétation-habitat-écosystème. Relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisé dans le cadre d’un inventaire des végétations-habitats-écosystèmes. Si seuls des relevés sont effectués (sans détermination du type de végétation ou habitat), il faut affecter à une autre rubrique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
415	114	2.3	Données opportuniste d’habitat	Données opportuniste d’habitat	Relevé de présence d’un type de végétation-habitat-écosystème n’entrant pas dans un plan d’échantillonnage prédéfini	Données opportuniste d’habitat	Relevé de présence d’un type de végétation-habitat-écosystème n’entrant pas dans un plan d’échantillonnage prédéfini	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
416	114	2.4	Inventaire pour étude d’habitat	Inventaire pour étude d’habitat	Relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisé pour des études ou de la recherche sur les végétations-habitats-écosystèmes. Logique d’acquisition de données associées à un protocole dans le but d’améliorer la connaissance ou la définition d’un habitat, de construire une typologie, ou de préciser son fonctionnement, évaluer son état de conservation... Si seuls des relevés sont effectués (sans lien avec le type de végétation ou habitat), il faut affecter à une autre rubrique (1.3)	Inventaire pour étude d’habitat	Relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisé pour des études ou de la recherche sur les végétations-habitats-écosystèmes. Logique d’acquisition de données associées à un protocole dans le but d’améliorer la connaissance ou la définition d’un habitat, de construire une typologie, ou de préciser son fonctionnement, évaluer son état de conservation... Si seuls des relevés sont effectués (sans lien avec le type de végétation ou habitat), il faut affecter à une autre rubrique (1.3)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
417	114	2.5	Numérisation de bibliographie habitat	Numérisation de bibliographie habitat	Cas particulier d’un jeu de données contenant uniquement des données issues de l’analyse de la bibliographie (qu’elle soit publié ou en littérature grise) et visant à les rendre disponibles pour tout usage concernant les habitats et les relevés standardisés associés (phytosociologiques, benthos)	Numérisation de bibliographie habitat	Cas particulier d’un jeu de données contenant uniquement des données issues de l’analyse de la bibliographie (qu’elle soit publié ou en littérature grise) et visant à les rendre disponibles pour tout usage concernant les habitats et les relevés standardisés associés (phytosociologiques, benthos)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
418	114	3.1	Inventaire type ABC	Inventaire type ABC	Inventaires menés dans le cadre de la réalisation d’un atlas de la biodiversité communale, que ce soit la démarche « Ministère » ou une démarche similaire (démarche des PNR, IBC par exemple). Les données pré-existantes numérisées à l’occasion et pour l’ABC entrent dans cette catégorie. Les éventuels suivis temporels initiés dans un ABC n’entrent pas dans cette rubrique	Inventaire type ABC	Inventaires menés dans le cadre de la réalisation d’un atlas de la biodiversité communale, que ce soit la démarche « Ministère » ou une démarche similaire (démarche des PNR, IBC par exemple). Les données pré-existantes numérisées à l’occasion et pour l’ABC entrent dans cette catégorie. Les éventuels suivis temporels initiés dans un ABC n’entrent pas dans cette rubrique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
449	106	14	Examen visuel des restes de l’individu	Examen visuel des restes de l’individu	La détermination repose sur un examen visuel des restes (fragments ou résidus) de l'individu à l'œil nu	Examen visuel des restes de l’individu	La détermination repose sur un examen visuel des restes (fragments ou résidus) de l'individu à l'œil nu	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
419	114	3.2	Inventaire de Zonages d’intérêt	Inventaire de Zonages d’intérêt	Acquisition de données de terrain (pas de synthèse) pour établir/confirmer ou actualiser les zonages d’inventaires ZNIEFF (et éventuelles approches type ZICO ou IBA). Les inventaires pour accompagner la gestion d’espaces (déjà désignés) entrent dans la rubrique suivante (3.3)	Inventaire de Zonages d’intérêt	Acquisition de données de terrain (pas de synthèse) pour établir/confirmer ou actualiser les zonages d’inventaires ZNIEFF (et éventuelles approches type ZICO ou IBA). Les inventaires pour accompagner la gestion d’espaces (déjà désignés) entrent dans la rubrique suivante (3.3)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
503	119	8.2	8.2	Mesures géotechniques	Mesures géotechniques	Mesures géotechniques	Mesures géotechniques	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.022	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
420	114	3.3	Inventaire/évaluation pour plans de gestion	Inventaire/évaluation pour plans de gestion	Acquisition structurée de données naturalistes pour préparer, réviser ou actualiser un plan de gestion (au sens large) d’un espace naturel à statut de protection ou de gestion particulier (Natura 2000, Réserves, Parcs, forêt publique...) ou d’un site privé pour sa gestion écologique (exemple golfs, emprise LGV...). Y compris les évaluations permettant d’évaluer l’intérêt patrimonial du site (type IQE), l’état de conservation de ses habitats, de définir des enjeux par secteurs... Les données « opportunistes » collectées par ces gestionnaires peuvent aussi entrer dans cette catégorie mais devraient mieux faire l’objet de jeux de données distincts des données protocolées (cat. 2.4)	Inventaire/évaluation pour plans de gestion	Acquisition structurée de données naturalistes pour préparer, réviser ou actualiser un plan de gestion (au sens large) d’un espace naturel à statut de protection ou de gestion particulier (Natura 2000, Réserves, Parcs, forêt publique...) ou d’un site privé pour sa gestion écologique (exemple golfs, emprise LGV...). Y compris les évaluations permettant d’évaluer l’intérêt patrimonial du site (type IQE), l’état de conservation de ses habitats, de définir des enjeux par secteurs... Les données « opportunistes » collectées par ces gestionnaires peuvent aussi entrer dans cette catégorie mais devraient mieux faire l’objet de jeux de données distincts des données protocolées (cat. 2.4)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
493	119	3.4	3.4	Sonar à interféromètre	Sonar à interféromètre	Sonar à interféromètre	Sonar à interféromètre	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
421	114	3.4	Observations opportunistes sur un site	Observations opportunistes sur un site	Données opportunistes collectées dans le cadre d’une logique site-centrée : lors d’opérations de gestion, données connexes d’observation faites lors d’un inventaire ou d'un suivi de site. La notion de site recouvre un espace (ou un réseau d’espace) prédéfini, avec un enjeu de gestion (réserves, site de conservatoire, sites d’une entreprise, espace vert...)	Observations opportunistes sur un site	Données opportunistes collectées dans le cadre d’une logique site-centrée : lors d’opérations de gestion, données connexes d’observation faites lors d’un inventaire ou d'un suivi de site. La notion de site recouvre un espace (ou un réseau d’espace) prédéfini, avec un enjeu de gestion (réserves, site de conservatoire, sites d’une entreprise, espace vert...)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
422	114	3.5	Inventaires généralisés & exploration	Inventaires généralisés & exploration	Programme ciblé sur un ou quelques sites, visant à dresser un vaste inventaire des taxons présents, multi-groupes et généralement pour découvrir de nouvelles espèces (pour la Science ou pour le territoire). Exemples : ATBI, IBG... Ces programmes comportent généralement de la mise en collection, du barcode, des travaux de taxonomie etc. Un travail d’inventaire sur un site portant sur un ordre d’invertébrés très vaste (Hyménoptères, ou Diptères, Coléoptères ou Lépidoptères, Arachnides etc.) rentre dans cette catégorie	Inventaires généralisés & exploration	Programme ciblé sur un ou quelques sites, visant à dresser un vaste inventaire des taxons présents, multi-groupes et généralement pour découvrir de nouvelles espèces (pour la Science ou pour le territoire). Exemples : ATBI, IBG... Ces programmes comportent généralement de la mise en collection, du barcode, des travaux de taxonomie etc. Un travail d’inventaire sur un site portant sur un ordre d’invertébrés très vaste (Hyménoptères, ou Diptères, Coléoptères ou Lépidoptères, Arachnides etc.) rentre dans cette catégorie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
423	114	3.6	Inventaire pour étude d'impact	Inventaire pour étude d'impact	Inventaires dans le cadre des procédures réglementaires d’études d’impact ou d’études d’incidence, avant la réalisation des impacts. Les suivis réglementaires post-implantatoires (ex mortalité chiroptères) ou de compensation ne sont pas concernés par cette catégorie (relève catégorie 5.4)	Inventaire pour étude d'impact	Inventaires dans le cadre des procédures réglementaires d’études d’impact ou d’études d’incidence, avant la réalisation des impacts. Les suivis réglementaires post-implantatoires (ex mortalité chiroptères) ou de compensation ne sont pas concernés par cette catégorie (relève catégorie 5.4)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
424	114	3.7	Cartographie d’habitat d’un site	Cartographie d’habitat d’un site	Données correspondant à une cartographie des végétations-habitats-écosystèmes pour un site, dans une logique d’appui à la gestion (détermination des enjeux, adaptation de la gestion etc.) Les approches terrain, les traitements d’image ou la combinaison des deux sont incluses. Les relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisés dans le cadre d’un inventaire ou d’une cartographie des végétations-habitats-écosystèmes d’un site. Si seuls des relevés sont effectués (sans détermination du type de végétation ou habitat), il faut affecter à une autre rubrique.	Cartographie d’habitat d’un site	Données correspondant à une cartographie des végétations-habitats-écosystèmes pour un site, dans une logique d’appui à la gestion (détermination des enjeux, adaptation de la gestion etc.) Les approches terrain, les traitements d’image ou la combinaison des deux sont incluses. Les relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisés dans le cadre d’un inventaire ou d’une cartographie des végétations-habitats-écosystèmes d’un site. Si seuls des relevés sont effectués (sans détermination du type de végétation ou habitat), il faut affecter à une autre rubrique.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
425	114	4.1	Évaluation de la ressource / prélèvements	Évaluation de la ressource / prélèvements	Inventaires et suivis piscicoles, de pêcheries, halieutiques, cynégétiques, pharmaceutiques ou dendrologiques afin de quantifier la ressource disponible, les stocks ou les prélèvements effectués (tableau de chasse...)	Évaluation de la ressource / prélèvements	Inventaires et suivis piscicoles, de pêcheries, halieutiques, cynégétiques, pharmaceutiques ou dendrologiques afin de quantifier la ressource disponible, les stocks ou les prélèvements effectués (tableau de chasse...)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.018	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
426	114	4.2	Évaluation des collisions/échouages	Évaluation des collisions/échouages	Recensement et suivi des points de collisions faune / infrastructure linéaire de transport. On met également dans cette rubrique les suivis d’échouages d’animaux marins (tortues, cétacés...)	Évaluation des collisions/échouages	Recensement et suivi des points de collisions faune / infrastructure linéaire de transport. On met également dans cette rubrique les suivis d’échouages d’animaux marins (tortues, cétacés...)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.019	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
427	114	5.1	Suivi individus centré	Suivi individus centré	Travaux, généralement dans le domaine de la recherche, visant à étudier le comportement à l’échelle d’un individu : dispersion, trajectoire de déplacement, trajectoire migratoire, occupation de l’espace à différentes périodes... etc.	Suivi individus centré	Travaux, généralement dans le domaine de la recherche, visant à étudier le comportement à l’échelle d’un individu : dispersion, trajectoire de déplacement, trajectoire migratoire, occupation de l’espace à différentes périodes... etc.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.020	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
432	114	6.1	Surveillance site	Surveillance site	Il s’agit des dispositifs de surveillance/ veille dans le temps pour détecter sans a priori des changements des variables mesurées (abondance d’une population d’espèce à enjeux, traits des individus, indice d’abondance, taux d’occupation, traits et autres métriques de communauté d’espèces, surface d’occupation de végétations-habitats-écosystèmes...). Elle concerne une échelle locale (site ou réseau de sites pré-déterminés – réseaux de réserves etc.). Ne vise pas directement à tester une hypothèse avec manipulation (si c’est le cas, catégorie 6.2). Design expérimental : série temporelle	Surveillance site	Il s’agit des dispositifs de surveillance/ veille dans le temps pour détecter sans a priori des changements des variables mesurées (abondance d’une population d’espèce à enjeux, traits des individus, indice d’abondance, taux d’occupation, traits et autres métriques de communauté d’espèces, surface d’occupation de végétations-habitats-écosystèmes...). Elle concerne une échelle locale (site ou réseau de sites pré-déterminés – réseaux de réserves etc.). Ne vise pas directement à tester une hypothèse avec manipulation (si c’est le cas, catégorie 6.2). Design expérimental : série temporelle	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.025	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
428	114	5.2	Surveillance temporelle d'espèces	Surveillance temporelle d'espèces	Cette catégorie comprend uniquement des données obtenues selon un protocole répété dans le temps qui vise à fournir une image fiable de l’évolution des variables mesurées à l’échelle d’une population, d’une espèce ou de plusieurs espèces mais qui ne constituent pas une communauté en interaction. Elle concerne une échelle généralement assez vaste (réseaux de sites, département à national), un échantillonnage généralement représentatif, exhaustif ou régulier et ne vise pas directement à tester une hypothèse avec manipulation (si c’est le cas, catégorie 5.). Les cas de répétition d’atlas permettant in fine de mesurer des changements de distribution entrent dans la catégorie 1.2	Surveillance temporelle d'espèces	Cette catégorie comprend uniquement des données obtenues selon un protocole répété dans le temps qui vise à fournir une image fiable de l’évolution des variables mesurées à l’échelle d’une population, d’une espèce ou de plusieurs espèces mais qui ne constituent pas une communauté en interaction. Elle concerne une échelle généralement assez vaste (réseaux de sites, département à national), un échantillonnage généralement représentatif, exhaustif ou régulier et ne vise pas directement à tester une hypothèse avec manipulation (si c’est le cas, catégorie 5.). Les cas de répétition d’atlas permettant in fine de mesurer des changements de distribution entrent dans la catégorie 1.2	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.021	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
429	114	5.3	Surveillance communauté d’espèces	Surveillance communauté d’espèces	Cette catégorie comprend uniquement des données obtenues selon un protocole de relevés d’espèces en interaction répétés dans le temps, qui vise à fournir une image fiable de l’évolution dans le temps des variables mesurées concernant une communauté d’espèces, éventuellement rattachée à un type d’habitat. Elle concerne une échelle assez vaste (réseaux de sites, département à national), un échantillonnage généralement représentatif, exhaustif ou régulier et ne vise pas directement à tester une hypothèse avec manipulation (si c’est le cas, catégorie 6.2 ou 6.3)	Surveillance communauté d’espèces	Cette catégorie comprend uniquement des données obtenues selon un protocole de relevés d’espèces en interaction répétés dans le temps, qui vise à fournir une image fiable de l’évolution dans le temps des variables mesurées concernant une communauté d’espèces, éventuellement rattachée à un type d’habitat. Elle concerne une échelle assez vaste (réseaux de sites, département à national), un échantillonnage généralement représentatif, exhaustif ou régulier et ne vise pas directement à tester une hypothèse avec manipulation (si c’est le cas, catégorie 6.2 ou 6.3)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.022	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
450	106	15	Examen des restes de l'individu sur photo ou vidéo	Examen des restes de l'individu sur photo ou vidéo	La détermination repose sur un examen visuel des restes (fragments ou résidus) de l'individu sur photographie ou vidéo	Examen des restes de l'individu sur photo ou vidéo	La détermination repose sur un examen visuel des restes (fragments ou résidus) de l'individu sur photographie ou vidéo	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
484	119	2	2	Télédétection (satellite, LIDAR...)	Télédétection (satellite, LIDAR...)	Télédétection (satellite, LIDAR...)	Télédétection (satellite, LIDAR...)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
430	114	5.4	Surveillance des habitats	Surveillance des habitats	Cette catégorie comprend uniquement des données obtenues selon un protocole répété dans le temps qui vise à fournir une image fiable de l’évolution dans le temps de la présence et/ou surface d’un habitat au sens large (végétation, écosystème...). Elle concerne une échelle généralement assez vaste (réseaux de sites, département à national), un échantillonnage généralement représentatif, exhaustif ou régulier et ne vise pas directement à tester une hypothèse avec manipulation (si c’est le cas, catégorie 6.2). Les relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisé pour la surveillance entrent dans ce cadre. Si seuls des relevés sont effectués (sans détermination du type de végétation ou habitat), il faut affecter à la rubrique précédente	Surveillance des habitats	Cette catégorie comprend uniquement des données obtenues selon un protocole répété dans le temps qui vise à fournir une image fiable de l’évolution dans le temps de la présence et/ou surface d’un habitat au sens large (végétation, écosystème...). Elle concerne une échelle généralement assez vaste (réseaux de sites, département à national), un échantillonnage généralement représentatif, exhaustif ou régulier et ne vise pas directement à tester une hypothèse avec manipulation (si c’est le cas, catégorie 6.2). Les relevés de communauté d’espèces (généralement végétation/relevés phytosociologiques ou benthos pour les habitats marins) réalisé pour la surveillance entrent dans ce cadre. Si seuls des relevés sont effectués (sans détermination du type de végétation ou habitat), il faut affecter à la rubrique précédente	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.023	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
431	114	5.5	Surveillance de pathogènes et EEE	Surveillance de pathogènes et EEE	Dispositifs dédiés à détecter la présence (ou l’abondance...) et suivre l’évolution d’espèces ayant un impact négatif sur l’agriculture, la sylviculture, la santé ou la biodiversité... Participatifs ou professionnels, enquêtes... Les observations connexes de ces protocoles entrent aussi dans cette catégorie mais devraient idéalement faire l’objet d’un autre jeu de données. Les suivis des espèces dites « nuisibles » entrent dans cette catégorie	Surveillance de pathogènes et EEE	Dispositifs dédiés à détecter la présence (ou l’abondance...) et suivre l’évolution d’espèces ayant un impact négatif sur l’agriculture, la sylviculture, la santé ou la biodiversité... Participatifs ou professionnels, enquêtes... Les observations connexes de ces protocoles entrent aussi dans cette catégorie mais devraient idéalement faire l’objet d’un autre jeu de données. Les suivis des espèces dites « nuisibles » entrent dans cette catégorie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.024	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
448	106	13	Examen des restes de l’individu sous loupe ou microscope	Examen des restes de l’individu sous loupe ou microscope	La détermination repose sur un examen visuel précis des restes (fragments ou résidus) de l'individu sous loupe ou microscope 	Examen des restes de l’individu sous loupe ou microscope	La détermination repose sur un examen visuel précis des restes (fragments ou résidus) de l'individu sous loupe ou microscope 	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
451	106	16	Examen des traces ou indices de présence sur photo ou vidéo	Examen des traces ou indices de présence sur photo ou vidéo	La détermination repose sur l'examen de photographies ou de vidéos représentant des traces ou indices de présences	Examen des traces ou indices de présence sur photo ou vidéo	La détermination repose sur l'examen de photographies ou de vidéos représentant des traces ou indices de présences	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
433	114	6.2	Suivis de gestion ou expérimental	Suivis de gestion ou expérimental	Suivi dans le temps (avant/ après, avec éventuellement des contrôles) couplant des espèces ou communautés, des végétations-habitats-écosystèmes, et une action de gestion (y compris la non intervention) ou d’une pression afin d’en déterminer l’effet. Généralement dans un cadre d’espace naturel ou de la restauration ou encore pour la compensation (vérification d’un gain dans le temps) voir des travaux de recherche. Concerne généralement un site ou un réseau de sites. Design expérimental : B/A (before/after) et BACI (before/after control/impact) Un éventuel dispositif adaptatif à large échelle entrerait dans cette catégorie	Suivis de gestion ou expérimental	Suivi dans le temps (avant/ après, avec éventuellement des contrôles) couplant des espèces ou communautés, des végétations-habitats-écosystèmes, et une action de gestion (y compris la non intervention) ou d’une pression afin d’en déterminer l’effet. Généralement dans un cadre d’espace naturel ou de la restauration ou encore pour la compensation (vérification d’un gain dans le temps) voir des travaux de recherche. Concerne généralement un site ou un réseau de sites. Design expérimental : B/A (before/after) et BACI (before/after control/impact) Un éventuel dispositif adaptatif à large échelle entrerait dans cette catégorie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.026	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
434	114	6.3	Étude effet gestion	Étude effet gestion	Étude des effets de la gestion (ou de pression, ou non gestion etc.) sur des espèces ou communautés, des végétations-habitats-écosystèmes, avec une substitution espace/temps. C’est-à-dire que l’effet est mesuré uniquement à un temps t, en comparant différents historiques de gestions mais sans mesure avant/après (si avant/après : 6.2). Design expérimental : C/I (control/ impact)	Étude effet gestion	Étude des effets de la gestion (ou de pression, ou non gestion etc.) sur des espèces ou communautés, des végétations-habitats-écosystèmes, avec une substitution espace/temps. C’est-à-dire que l’effet est mesuré uniquement à un temps t, en comparant différents historiques de gestions mais sans mesure avant/après (si avant/après : 6.2). Design expérimental : C/I (control/ impact)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.027	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
435	114	6.4	Suivis réglementaires	Suivis réglementaires	Il s’agit des suivis temporels visant à suivre les impacts après implantation d’un ouvrage, imposés par la loi ou lors de l’autorisation de réalisation des travaux. Par exemples les suivis de mortalité des oiseaux et chiroptères après mise en place d’un parc éolien. Les suivis réglementaires dans le cadre de compensations entrent aussi dans cette catégorie	Suivis réglementaires	Il s’agit des suivis temporels visant à suivre les impacts après implantation d’un ouvrage, imposés par la loi ou lors de l’autorisation de réalisation des travaux. Par exemples les suivis de mortalité des oiseaux et chiroptères après mise en place d’un parc éolien. Les suivis réglementaires dans le cadre de compensations entrent aussi dans cette catégorie	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.028	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
436	114	7.1	Regroupement de données	Regroupement de données	Catégorie à utiliser quand le jeu de données mélange divers types de données, sans métadonnées permettant pour l’instant de les séparer en jeux de données plus précis et plus cohérents. On peut inclure ici les CA et JDD constitué par des regroupements de Données Elémentaires d'Echange (DEE) pour réaliser un atlas, uniquement quand l’objectif original de collecte des données n’est pas déterminable. Lorsqu’on ne dispose pas d’information sur les raisons de l’acquisition des données, cette rubrique doit être utilisée	Regroupement de données	Catégorie à utiliser quand le jeu de données mélange divers types de données, sans métadonnées permettant pour l’instant de les séparer en jeux de données plus précis et plus cohérents. On peut inclure ici les CA et JDD constitué par des regroupements de Données Elémentaires d'Echange (DEE) pour réaliser un atlas, uniquement quand l’objectif original de collecte des données n’est pas déterminable. Lorsqu’on ne dispose pas d’information sur les raisons de l’acquisition des données, cette rubrique doit être utilisée	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.029	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
437	114	7.2	Autres études et programmes	Autres études et programmes	Cas n’entrant pas clairement dans les autres rubriques. Dans ce cas les métadonnées (champ libres « description » et « protocole » des fiches de métadonnées) devront bien expliquer en quoi consiste le but de l’acquisition des données	Autres études et programmes	Cas n’entrant pas clairement dans les autres rubriques. Dans ce cas les métadonnées (champ libres « description » et « protocole » des fiches de métadonnées) devront bien expliquer en quoi consiste le but de l’acquisition des données	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	114.030	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
438	106	1	Non renseigné	Non renseigné	La méthode de détermination n'a pas été renseignée	Non renseigné	La méthode de détermination n'a pas été renseignée	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
439	116	CHI	Site chiroptère	Site chiroptère	Site pour le suivi des chiroptères	Site chiroptère	Site pour le suivi des chiroptères	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	116.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
440	116	1	Grotte	Grotte	Site chiroptères de type grotte	Grotte	Site chiroptères de type grotte	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	\N	116.001.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
441	116	2	Mine	Mine	Site chiroptères de type mine	Mine	Site chiroptères de type mine	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	\N	116.001.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
442	116	3	Bâti	Bâti	Site chiroptères de type bâti	Bâti	Site chiroptères de type bâti	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	\N	116.001.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
443	116	4	Arbre	Arbre	Site chiroptères de type arbre	Arbre	Site chiroptères de type arbre	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	\N	116.001.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
444	116	5	Rocher	Rocher	Site chiroptères de type rocher	Rocher	Site chiroptères de type rocher	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	\N	116.001.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
445	116	6	Hors gîte	Hors gîte	Site chiroptères de type hors gîte	Hors gîte	Site chiroptères de type hors gîte	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	\N	116.001.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
446	116	7	Indéterminé	Indéterminé	Site chiroptères de type indéterminé	Indéterminé	Site chiroptères de type indéterminé	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	\N	116.001.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
447	106	12	Examen des organes reproducteurs ou critères spécifiques sur le terrain	Examen des organes reproducteurs ou critères spécifiques sur le terrain	La détermination repose sur l'examen des organes reproducteurs ou autres critères spécifiques directement sur le terrain	Examen des organes reproducteurs ou critères spécifiques sur le terrain	La détermination repose sur l'examen des organes reproducteurs ou autres critères spécifiques directement sur le terrain	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
487	119	2.3	2.3	Imagerie numérique aéroportée	Imagerie numérique aéroportée	Imagerie numérique aéroportée	Imagerie numérique aéroportée	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
457	106	22	Examen visuel sur photo ou vidéo	Examen visuel sur photo ou vidéo	La détermination repose sur l'examen de photographies ou de vidéos sur lesquelles apparait l'espèce	Examen visuel sur photo ou vidéo	La détermination repose sur l'examen de photographies ou de vidéos sur lesquelles apparait l'espèce	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	106.022	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
458	101	0	En attente de validation	En attente de validation	Le travail de validation n'a pas encore été réalisé. Le statut de validation est en attente	En attente de validation	Le travail de validation n'a pas encore été réalisé. Le statut de validation est en attente	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	non validé	0	101.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
459	117	2	Photo	Photo	Média de type image	Photo	Média de type image	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	117.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
460	117	3	Page web	Page web	Média de type page web	Page web	Média de type page web	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	117.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
461	117	4	PDF	PDF	Média de type document PDF	PDF	Média de type document PDF	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	117.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
462	117	5	Audio	Audio	Média de type fichier audio mp3	Audio	Média de type fichier audio mp3	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	117.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
463	117	6	Vidéo (fichier)	Vidéo (fichier)	Média de type fichier vidéo hébergé	Vidéo (fichier)	Média de type fichier vidéo hébergé	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	117.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
464	117	7	Vidéo Youtube	Vidéo Youtube	ID d'une video hébergée sur Youtube	Vidéo Youtube	ID d'une video hébergée sur Youtube	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	117.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
465	117	8	Vidéo Dailymotion	Vidéo Dailymotion	ID d'une video hébergée sur Dailymotion	Vidéo Dailymotion	ID d'une video hébergée sur Dailymotion	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	117.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
466	117	9	Vidéo Vimeo	Vidéo Vimeo	ID d'une video hébergée sur Vimeo	Vidéo Vimeo	ID d'une video hébergée sur Vimeo	\N	\N	\N	\N	\N	\N	\N	\N	GEONATURE	Non validé	0	117.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
467	31	1	Public	Public	Public : la fiche du site n'est pas confidentielle.	Public	Public : la fiche du site n'est pas confidentielle.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	031.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
468	31	2	Confidentiel	Confidentiel	Confidentiel : la fiche a un niveau de confidentialité élevé.	Confidentiel	Confidentiel : la fiche a un niveau de confidentialité élevé.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	031.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
469	72	1	1	1	1 : Individu qui pousse seul	1	1 : Individu qui pousse seul	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	072.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
470	72	2	2	2	2 : Individu cespiteux, qui pousse en touffe	2	2 : Individu cespiteux, qui pousse en touffe	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	072.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
471	72	3	3	3	3 : Individu qui pousse en groupe formant de petits patchs ou des coussins	3	3 : Individu qui pousse en groupe formant de petits patchs ou des coussins	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	072.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
472	72	4	4	4	4 : Individu qui pousse en colonie formant de grands patchs ou des tapis	4	4 : Individu qui pousse en colonie formant de grands patchs ou des tapis	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	072.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
473	72	5	5	5	5 : Individu qui pousse en grand nombre, population pure, monospécifique	5	5 : Individu qui pousse en grand nombre, population pure, monospécifique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	072.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
474	122	es	es	Estimée : la surface est estimée par l'opérateur	Estimée : la surface est estimée par l'opérateur	Estimée : la surface est estimée par l'opérateur	Estimée : la surface est estimée par l'opérateur	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
475	122	sig	sig	La surface est calculée directement par usage d'un logiciel SIG	La surface est calculée directement par usage d'un logiciel SIG	La surface est calculée directement par usage d'un logiciel SIG	La surface est calculée directement par usage d'un logiciel SIG	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
476	122	nsp	nsp	Ne sait pas : la méthode de calcul est inconnue	Ne sait pas : la méthode de calcul est inconnue	Ne sait pas : la méthode de calcul est inconnue	Ne sait pas : la méthode de calcul est inconnue	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
477	122	lin	lin	Calculée à partir de la largeur du linéaire	Calculée à partir de la largeur du linéaire	Calculée à partir de la largeur du linéaire	Calculée à partir de la largeur du linéaire	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
478	118	0	0	Inconnu	Inconnu : le type de détermination n'est pas connu	Inconnu	Inconnu : le type de détermination n'est pas connu	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	118.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
479	118	1	1	Attribué terrain	Attribué terrain : la détermination a été attribuée sur le terrain, ou en laboratoire après examens d'éléments en provenance du terrain	Attribué terrain	Attribué terrain : la détermination a été attribuée sur le terrain, ou en laboratoire après examens d'éléments en provenance du terrain	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	118.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
480	118	2	2	Expertise a posteriori	Expertise a posteriori : La détermination a été attribuée a posteriori sur la base du relevé d'espèces et/ou d'une expertise extérieure et/ou consultation de documents complémentaires.	Expertise a posteriori	Expertise a posteriori : La détermination a été attribuée a posteriori sur la base du relevé d'espèces et/ou d'une expertise extérieure et/ou consultation de documents complémentaires.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	118.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
481	118	3	3	Correspondance typologique : code attribué par l'application d'une correspondance entre typologies existantes de façon automatique.	Correspondance typologique : code attribué par l'application d'une correspondance entre typologies existantes de façon automatique	Correspondance typologique : code attribué par l'application d'une correspondance entre typologies existantes de façon automatique.	Correspondance typologique : code attribué par l'application d'une correspondance entre typologies existantes de façon automatique	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	118.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
482	119	0	0	Ne sait pas	Ne sait pas : la technique de collecte utilisée n'est pas connue	Ne sait pas	Ne sait pas : la technique de collecte utilisée n'est pas connue	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
483	119	1	1	In situ	In situ : observation directe, sur le terrain (parcouru ou longé). Correspond à Observation directe terrestre diurne dans la base de données CAMPANULE	In situ	In situ : observation directe, sur le terrain (parcouru ou longé). Correspond à Observation directe terrestre diurne dans la base de données CAMPANULE	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
485	119	2.1	2.1	Lidar	Lidar	Lidar	Lidar	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
498	119	5	5	Observation à distance (jumelles par exemple).	Observation à distance (jumelles par exemple).	Observation à distance (jumelles par exemple).	Observation à distance (jumelles par exemple).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.017	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
499	119	6	6	Observation directe marine (observation en plongée)	Observation directe marine (observation en plongée)	Observation directe marine (observation en plongée)	Observation directe marine (observation en plongée)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.018	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
504	119	8.3	8.3	Prélèvement à la benne	Prélèvement à la benne	Prélèvement à la benne	Prélèvement à la benne	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.023	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
505	119	8.4	8.4	Prélèvement au chalut ou à la drague	Prélèvement au chalut ou à la drague	Prélèvement au chalut ou à la drague	Prélèvement au chalut ou à la drague	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.024	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
506	119	8.4.1	8.4.1	Prélèvement au chalut	Prélèvement au chalut	Prélèvement au chalut	Prélèvement au chalut	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.025	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
507	119	8.4.2	8.4.2	Prélèvement à la drague	Prélèvement à la drague	Prélèvement à la drague	Prélèvement à la drague	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.026	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
508	119	8.5	8.5	Carottage	Carottage	Carottage	Carottage	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.027	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
509	119	9	9	Vidéo et photographies	Vidéo et photographies	Vidéo et photographies	Vidéo et photographies	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.028	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
510	119	9.1	9.1	Imagerie des profils sédimentaires	Imagerie des profils sédimentaires	Imagerie des profils sédimentaires	Imagerie des profils sédimentaires	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.029	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
511	119	9.2	9.2	Caméra tractée ou téléguidée	Caméra tractée ou téléguidée	Caméra tractée ou téléguidée	Caméra tractée ou téléguidée	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	2018-05-09 00:00:00	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
512	119	9.3	9.3	Observation marine photographique (observation photographique en plongée)	Observation marine photographique (observation photographique en plongée)	Observation marine photographique (observation photographique en plongée)	Observation marine photographique (observation photographique en plongée)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.031	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
513	119	9.4	9.4	Observation photographique aérienne, prise de vue aérienne, suivie d'une photointerprétation	Observation photographique aérienne, prise de vue aérienne, suivie d'une photointerprétation	Observation photographique aérienne, prise de vue aérienne, suivie d'une photointerprétation	Observation photographique aérienne, prise de vue aérienne, suivie d'une photointerprétation	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.032	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
514	119	9.5	9.5	Observation photographique terrestre suivie d'une photointerprétation.	Observation photographique terrestre suivie d'une photointerprétation.	Observation photographique terrestre suivie d'une photointerprétation.	Observation photographique terrestre suivie d'une photointerprétation.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.033	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
515	119	10	10	Autre, préciser	Autre, préciser	Autre, préciser	Autre, préciser	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	119.034	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
516	108	8	InvCart	Inventaires et cartographie	L'acquisition des données d'occurrence est réalisée avec la démarche d'avoir des informations sur la présence/absence ou effectif/abondance (dénombrement…) d'un ou de plusieurs objets de biodiversité. Le dispositif de collecte est établi pour avoir une représentation spatiale de la répartition d'un ou de plusieurs objets de biodiversité à des dates ou des périodes prédéfinies.	Inventaires et cartographie	L'acquisition des données d'occurrence est réalisée avec la démarche d'avoir des informations sur la présence/absence ou effectif/abondance (dénombrement…) d'un ou de plusieurs objets de biodiversité. Le dispositif de collecte est établi pour avoir une représentation spatiale de la répartition d'un ou de plusieurs objets de biodiversité à des dates ou des périodes prédéfinies.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	108.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
517	108	9	SuivSurv	Suivi/surveillance dans le temps	L'acquisition des données d'occurrence est réalisée avec un dispositif de collecte comprenant une répétition de l'acquisition au cours du temps. La démarche permet une comparaison d'un état entre différentes périodes pour un ou plusieurs objets de biodiversité. Elle est mise en place en lien avec une thématique prédéterminée (biologie de la conservation, changements globaux, …).	Suivi/surveillance dans le temps	L'acquisition des données d'occurrence est réalisée avec un dispositif de collecte comprenant une répétition de l'acquisition au cours du temps. La démarche permet une comparaison d'un état entre différentes périodes pour un ou plusieurs objets de biodiversité. Elle est mise en place en lien avec une thématique prédéterminée (biologie de la conservation, changements globaux, …).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	108.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
518	108	10	Exp/Rech	Expérimentation/recherche	L'acquisition des données est réalisée avec une démarche d'amélioration de la connaissance scientifique ciblée sur une ou plusieurs questions précises (de la description des patrons de biodiversité à l'expérimentation pour expliquer les processus ou démontrer des relations causales de type 'avant/après' (effet de la gestion, mécanismes etc.)). L'expérimentation et la recherche de type purement 'observationnelle' ou 'corrélative' doivent figurer dans les catégories 'inventaires' ou 'suivis/surveillance'.	Expérimentation/recherche	L'acquisition des données est réalisée avec une démarche d'amélioration de la connaissance scientifique ciblée sur une ou plusieurs questions précises (de la description des patrons de biodiversité à l'expérimentation pour expliquer les processus ou démontrer des relations causales de type 'avant/après' (effet de la gestion, mécanismes etc.)). L'expérimentation et la recherche de type purement 'observationnelle' ou 'corrélative' doivent figurer dans les catégories 'inventaires' ou 'suivis/surveillance'.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	108.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
519	108	11	MultAutr	Multiples ou autres	L'acquisition des données est réalisée avec une démarche propre faisant intervenir plusieurs démarches préalablement décrites.	Multiples ou autres	L'acquisition des données est réalisée avec une démarche propre faisant intervenir plusieurs démarches préalablement décrites.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	108.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
520	120	1	1	Recouvrement très faible	Recouvrement très faible	Recouvrement très faible	Recouvrement très faible	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
521	120	2	2	Habitat recouvrant environ 1/20 à 1/4 de la surface (5 à 25 %)	Habitat recouvrant environ 1/20 à 1/4 de la surface (5 à 25 %)	Habitat recouvrant environ 1/20 à 1/4 de la surface (5 à 25 %)	Habitat recouvrant environ 1/20 à 1/4 de la surface (5 à 25 %)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
522	120	3	3	Habitat recouvrant environ 1/4 à 1/2 de la surface (25 à 50 %)	Habitat recouvrant environ 1/4 à 1/2 de la surface (25 à 50 %)	Habitat recouvrant environ 1/4 à 1/2 de la surface (25 à 50 %)	Habitat recouvrant environ 1/4 à 1/2 de la surface (25 à 50 %)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
523	120	4	4	Habitat recouvrant environ 1/2 à 3/4 de la surface (50 à 75 %)	Habitat recouvrant environ 1/2 à 3/4 de la surface (50 à 75 %)	Habitat recouvrant environ 1/2 à 3/4 de la surface (50 à 75 %)	Habitat recouvrant environ 1/2 à 3/4 de la surface (50 à 75 %)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
524	120	5	5	Habitat recouvrant plus des 3/4 de la surface (>75 %)	Habitat recouvrant plus des 3/4 de la surface (>75 %)	Habitat recouvrant plus des 3/4 de la surface (>75 %)	Habitat recouvrant plus des 3/4 de la surface (>75 %)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	120.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
525	121	1	Oui	Oui : l'habitat est bien d'intérêt communautaire.	Oui : l'habitat est bien d'intérêt communautaire.	Oui : l'habitat est bien d'intérêt communautaire.	Oui : l'habitat est bien d'intérêt communautaire.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
526	121	2	Non	Non : l'habitat n'est pas d'intérêt communautaire	Non : l'habitat n'est pas d'intérêt communautaire	Non : l'habitat n'est pas d'intérêt communautaire	Non : l'habitat n'est pas d'intérêt communautaire	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
527	121	3	OuiPrio	Oui, prioritaire : Oui, l'habitat est d'intérêt communautaire prioritaire. Exemple : Pelouses calcicoles riches en orchidées.	Oui, prioritaire : Oui, l'habitat est d'intérêt communautaire prioritaire. Exemple : Pelouses calcicoles riches en orchidées.	Oui, prioritaire : Oui, l'habitat est d'intérêt communautaire prioritaire. Exemple : Pelouses calcicoles riches en orchidées.	Oui, prioritaire : Oui, l'habitat est d'intérêt communautaire prioritaire. Exemple : Pelouses calcicoles riches en orchidées.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
528	66	E	E	Est	Est : 78.75° - 101.25°	Est	Est : 78.75° - 101.25°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
529	66	ENE	ENE	Est-Nord-Est	Est-Nord-Est : 56.25° - 78.75°	Est-Nord-Est	Est-Nord-Est : 56.25° - 78.75°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
530	66	ESE	ESE	Est-Sud-Est	Est-Sud-Est : 101.25° - 123.75°	Est-Sud-Est	Est-Sud-Est : 101.25° - 123.75°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
531	66	N	N	Nord	Nord : 348.75° - 11.25°	Nord	Nord : 348.75° - 11.25°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
532	66	NE	NE	Nord-Est	Nord-Est : 33.75° - 56.25°	Nord-Est	Nord-Est : 33.75° - 56.25°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
533	66	NNE	NNE	Nord-Nord-Est	Nord-Nord-Est : 11.25° - 33.75°	Nord-Nord-Est	Nord-Nord-Est : 11.25° - 33.75°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
534	66	NNO	NNO	Nord-Nord-Ouest	Nord-Nord-Ouest : 326.25° - 348.75°	Nord-Nord-Ouest	Nord-Nord-Ouest : 326.25° - 348.75°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
535	66	NO	NO	Nord-Ouest	Nord-Ouest : 303.75° - 326.25 °	Nord-Ouest	Nord-Ouest : 303.75° - 326.25 °	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
536	66	O	O	Ouest	Ouest : 258.75° - 281.25°	Ouest	Ouest : 258.75° - 281.25°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
537	66	ONO	ONO	Ouest-Nord-Ouest	Ouest-Nord-Ouest : 281.25° - 303.75 °	Ouest-Nord-Ouest	Ouest-Nord-Ouest : 281.25° - 303.75 °	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
538	66	OSO	OSO	Ouest-Sud-Ouest	Ouest-Sud-Ouest : 236.25° - 258.75°	Ouest-Sud-Ouest	Ouest-Sud-Ouest : 236.25° - 258.75°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
539	66	S	S	Sud	Sud : 168.75° - 191.25°	Sud	Sud : 168.75° - 191.25°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
540	66	SE	SE	Sud-Est	Sud-Est : 123.75°- 146.25°	Sud-Est	Sud-Est : 123.75°- 146.25°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
541	66	SO	SO	Sud-Ouest	Sud-Ouest : 213.75° - 236.25°	Sud-Ouest	Sud-Ouest : 213.75° - 236.25°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
542	66	SSE	SSE	Sud-Sud-Est	Sud-Sud-Est : 146.25° - 168.75°	Sud-Sud-Est	Sud-Sud-Est : 146.25° - 168.75°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
543	66	SSO	SSO	Sud-Sud-Ouest	Sud-Sud-Ouest : 191.25° - 213.75°	Sud-Sud-Ouest	Sud-Sud-Ouest : 191.25° - 213.75°	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	121.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
544	124	0	NSP	Inconnu	Inconnu : Le statut biologique de l'individu n'est pas connu.	Inconnu	Inconnu : Le statut biologique de l'individu n'est pas connu.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.000	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
545	124	1	1	Non renseigné	Non renseigné : Le statut biologique de l'individu n'a pas été renseigné.	Non renseigné	Non renseigné : Le statut biologique de l'individu n'a pas été renseigné.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.001	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
546	124	2	2	Echouage	Echouage : l'individu tente de s'échouer ou vient de s'échouer sur le rivage	Echouage	Echouage : l'individu tente de s'échouer ou vient de s'échouer sur le rivage	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.002	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
547	124	3	3	Dortoir	Dortoir : individus se regroupant dans une zone définie pour y passer la nuit ou la journée.	Dortoir	Dortoir : individus se regroupant dans une zone définie pour y passer la nuit ou la journée.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.003	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
548	124	4	4	Migration	Migration : L'individu (ou groupe d'individus) est en migration active	Migration	Migration : L'individu (ou groupe d'individus) est en migration active	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.004	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
549	124	5	5	Construction de toile	Construction de toile : l'individu construit sa toile	Construction de toile	Construction de toile : l'individu construit sa toile	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.005	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
550	124	6	6	Halte migratoire	Halte migratoire : Indique que l'individu procède à une halte au cours de sa migration, et a été découvert sur sa zone de halte.	Halte migratoire	Halte migratoire : Indique que l'individu procède à une halte au cours de sa migration, et a été découvert sur sa zone de halte.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.006	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
551	124	7	7	Swarming	Swarming : Indique que l'individu a un comportement de swarming : il se regroupe avec d'autres individus de taille similaire, sur une zone spécifique, ou en mouvement.	Swarming	Swarming : Indique que l'individu a un comportement de swarming : il se regroupe avec d'autres individus de taille similaire, sur une zone spécifique, ou en mouvement.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.007	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
552	124	8	ChassAlim	Chasse/alimentation	Chasse / alimentation : Indique que l'individu est sur une zone qui lui permet de chasser ou de s'alimenter.	Chasse/alimentation	Chasse / alimentation : Indique que l'individu est sur une zone qui lui permet de chasser ou de s'alimenter.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.008	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
553	124	9	Hivernage	Hivernage	Hivernage : l'individu hiverne (modification de son comportement liée à l'hiver pouvant par exemple comporter un changement de lieu, d'alimentation, de production de sève ou de graisse...)	Hivernage	Hivernage : l'individu hiverne (modification de son comportement liée à l'hiver pouvant par exemple comporter un changement de lieu, d'alimentation, de production de sève ou de graisse...)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.009	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
554	124	10	10	Passage en vol	Passage en vol : Indique que l'individu est de passage et en vol.	Passage en vol	Passage en vol : Indique que l'individu est de passage et en vol.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.010	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
555	124	11	11	Erratique	Erratique : Individu d'une ou de populations d'un taxon qui ne se trouve, actuellement, que de manière occasionnelle dans les limites d’une région. Il a été retenu comme seuil, une absence de 80% d'un laps de temps donné (année, saisons...).	Erratique	Erratique : Individu d'une ou de populations d'un taxon qui ne se trouve, actuellement, que de manière occasionnelle dans les limites d’une région. Il a été retenu comme seuil, une absence de 80% d'un laps de temps donné (année, saisons...).	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.011	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
556	124	12	12	Sédentaire	Sédentaire : Individu demeurant à un seul emplacement, ou restant toute l'année dans sa région d'origine, même s'il effectue des déplacements locaux.	Sédentaire	Sédentaire : Individu demeurant à un seul emplacement, ou restant toute l'année dans sa région d'origine, même s'il effectue des déplacements locaux.	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.012	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
557	124	13	13	Estivage	Estivage : l'individu estive (modification de son comportement liée à l'été pouvant par exemple comporter un changement de lieu, d'alimentation, de production de sève ou de graisse...)	Estivage	Estivage : l'individu estive (modification de son comportement liée à l'été pouvant par exemple comporter un changement de lieu, d'alimentation, de production de sève ou de graisse...)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.013	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
558	124	14	14	Nourrissage des jeunes	Nourrissage des jeunes	Nourrissage des jeunes	Nourrissage des jeunes	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.014	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
559	124	15	15	Posé	Posé : Individu(s) posé(s)	Posé	Posé : Individu(s) posé(s)	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.015	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
560	124	16	16	Déplacement	Déplacement : Individu(s) en déplacement	Déplacement	Déplacement : Individu(s) en déplacement	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.016	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
563	124	19	19	Accouplement	Accouplement	Accouplement	Accouplement	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.019	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
564	124	20	20	Cœur copulatoire	Cœur copulatoire	Cœur copulatoire	Cœur copulatoire	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.020	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
565	124	21	21	Tandem	Tandem	Tandem	Tandem	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.021	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
566	124	22	22	Territorial	Territorial	Territorial	Territorial	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.022	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
567	124	23	23	Pond	Pond	Pond	Pond	\N	\N	\N	\N	\N	\N	\N	\N	SINP	Validé	0	122.023	2022-03-02 08:42:09.321235	2022-03-02 08:42:09.321235	t
\.


--
-- Name: bib_nomenclatures_types_id_type_seq; Type: SEQUENCE SET; Schema: ref_nomenclatures; Owner: geonatadmin
--

SELECT pg_catalog.setval('ref_nomenclatures.bib_nomenclatures_types_id_type_seq', 124, true);


--
-- Name: t_nomenclatures_id_nomenclature_seq; Type: SEQUENCE SET; Schema: ref_nomenclatures; Owner: geonatadmin
--

SELECT pg_catalog.setval('ref_nomenclatures.t_nomenclatures_id_nomenclature_seq', 567, true);


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
-- Name: index_t_nomenclatures_bib_nomenclatures_types_fkey; Type: INDEX; Schema: ref_nomenclatures; Owner: geonatadmin
--

CREATE INDEX index_t_nomenclatures_bib_nomenclatures_types_fkey ON ref_nomenclatures.t_nomenclatures USING btree (id_type);


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
-- PostgreSQL database dump complete
--

