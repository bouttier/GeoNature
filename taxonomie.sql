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
-- Name: taxonomie; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA taxonomie;


ALTER SCHEMA taxonomie OWNER TO geonatadmin;

--
-- Name: check_is_cd_ref(integer); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.check_is_cd_ref(mycdnom integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    --fonction permettant de vérifier si une valeur est bien un cd_ref existant
    --peut notamment servir pour les contraintes de certaines tables comme "gn_profiles.cor_taxons_profiles_parameters"
      BEGIN
        IF EXISTS( SELECT cd_ref FROM taxonomie.taxref WHERE cd_ref=mycdnom )
            THEN
          RETURN true;
        ELSE
            RAISE EXCEPTION 'Error : The code entered as argument is not a valid cd_ref' ;
        END IF;
        RETURN false;
      END;
    $$;


ALTER FUNCTION taxonomie.check_is_cd_ref(mycdnom integer) OWNER TO geonatadmin;

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
-- Name: find_all_taxons_parents(integer); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.find_all_taxons_parents(mycdnom integer) RETURNS TABLE(cd_nom integer, distance smallint)
    LANGUAGE plpgsql IMMUTABLE
    AS $$
     -- Param : cd_nom d'un taxon quelque soit son rang.
     -- Retourne une table avec le cd_nom de tout les taxons parents et leur distance au dessus du cd_nom
     -- donné en argument. Les cd_nom sont ordonnées du plus bas (celui passé en argument) vers le plus
     -- haut (Dumm). Usage SELECT * FROM taxonomie.find_all_taxons_parents(457346);
      DECLARE
        inf RECORD;
     BEGIN
        RETURN QUERY
            WITH RECURSIVE parents AS (
                SELECT tx1.cd_nom,tx1.cd_sup, tx1.id_rang, 0 AS nr
                FROM taxonomie.taxref tx1
                WHERE tx1.cd_nom = taxonomie.find_cdref(mycdnom)
                UNION ALL
                SELECT tx2.cd_nom,tx2.cd_sup, tx2.id_rang, nr + 1
                    FROM parents p
                    JOIN taxonomie.taxref tx2 ON tx2.cd_nom = p.cd_sup
            )
            SELECT parents.cd_nom, nr::smallint AS distance FROM parents
            ORDER BY parents.nr;
      END;
    $$;


ALTER FUNCTION taxonomie.find_all_taxons_parents(mycdnom integer) OWNER TO geonatadmin;

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
-- Name: match_binomial_taxref(character varying); Type: FUNCTION; Schema: taxonomie; Owner: geonatadmin
--

CREATE FUNCTION taxonomie.match_binomial_taxref(mytaxonname character varying) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    --fonction permettant de rattacher un nom latin à son cd_nom taxref sur le principe suivant :
    -- - Si un seul cd_nom existe pour ce nom latin, la fonction retourne le cd_nom en question
    -- - Si plusieurs cd_noms existent pour ce nom latin, mais qu'ils appartiennent tous à un unique cd_ref, la fonction renvoie le cd_ref (= cd_nom valide)
    -- - Si plusieurs cd_noms existent pour ce nom latin et qu'ils correspondent à plusieurs cd_ref, la fonction renvoie NULL : le rattachement devra être fait manuellement
    DECLARE
        matching_cd integer;
    BEGIN
        IF (SELECT count(DISTINCT cd_nom) FROM taxonomie.taxref WHERE lb_nom=mytaxonname OR nom_valide=mytaxonname)=1 THEN matching_cd:= cd_nom FROM taxonomie.taxref WHERE lb_nom=mytaxonname OR nom_valide=mytaxonname ;
        ELSIF (SELECT count(DISTINCT cd_ref) FROM taxonomie.taxref WHERE lb_nom=mytaxonname OR nom_valide=mytaxonname)=1 THEN matching_cd:= DISTINCT(cd_ref) FROM taxonomie.taxref WHERE lb_nom=mytaxonname OR nom_valide=mytaxonname ;
        ELSE matching_cd:= NULL;
        END IF;
        RETURN matching_cd;
    END ;
    $$;


ALTER FUNCTION taxonomie.match_binomial_taxref(mytaxonname character varying) OWNER TO geonatadmin;

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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: v_bdc_status; Type: VIEW; Schema: taxonomie; Owner: geonatadmin
--

CREATE VIEW taxonomie.v_bdc_status AS
 SELECT s.cd_nom,
    s.cd_ref,
    s.rq_statut,
    v.code_statut,
    v.label_statut,
    t.cd_type_statut,
    ty.thematique,
    ty.lb_type_statut,
    ty.regroupement_type,
    t.cd_st_text,
    t.cd_sig,
    t.cd_doc,
    t.niveau_admin,
    t.cd_iso3166_1,
    t.cd_iso3166_2,
    t.full_citation,
    t.doc_url,
    ty.type_value
   FROM ((((taxonomie.bdc_statut_taxons s
     JOIN taxonomie.bdc_statut_cor_text_values c ON ((s.id_value_text = c.id_value_text)))
     JOIN taxonomie.bdc_statut_text t ON ((t.id_text = c.id_text)))
     JOIN taxonomie.bdc_statut_values v ON ((v.id_value = c.id_value)))
     JOIN taxonomie.bdc_statut_type ty ON (((ty.cd_type_statut)::text = (t.cd_type_statut)::text)))
  WHERE (t.enable = true);


ALTER TABLE taxonomie.v_bdc_status OWNER TO geonatadmin;

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
-- Name: bib_listes id_liste; Type: DEFAULT; Schema: taxonomie; Owner: geonatadmin
--

ALTER TABLE ONLY taxonomie.bib_listes ALTER COLUMN id_liste SET DEFAULT nextval('taxonomie.bib_listes_id_liste_seq'::regclass);


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
-- PostgreSQL database dump complete
--

