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
-- Name: ref_habitats; Type: SCHEMA; Schema: -; Owner: geonatadmin
--

CREATE SCHEMA ref_habitats;


ALTER SCHEMA ref_habitats OWNER TO geonatadmin;

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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- PostgreSQL database dump complete
--

