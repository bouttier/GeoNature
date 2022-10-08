Installation de GeoNature avec Docker
*************************************

Prérequis
---------

* Docker
* Docker Compose


Installation
------------

* Build de l’image du backend ::

    docker compose build api

* Installation / mise-à-jour de la base de données ::

    docker compose run --rm api update.sh

* Installation / mise-à-jour des modules en base de données ::

    docker compose run --rm api geonature upgrade-modules

* Génération des fichiers du frontend ::

    docker compose run --rm --no-TTY api geonature generate-frontend-config --input - < frontend/src/conf/app.config.ts.sample --output - > frontend/src/conf/app.config.ts
    docker compose run --rm --no-TTY api geonature update-module-configuration --output - OCCTAX > contrib/occtax/frontend/app/module.config.ts
    docker compose run --rm --no-TTY api geonature update-module-configuration --output - OCCHAB > contrib/gn_module_occhab/frontend/app/module.config.ts
    docker compose run --rm --no-TTY api geonature update-module-configuration --output - VALIDATION > contrib/gn_module_validation/frontend/app/module.config.ts

* Build de l’image du frontend ::

    docker compose build web

* Démarrage ::

    docker compose up -d


Installation en mode développement
----------------------------------

* Activer la configuration Docker Compose de développement ::

    ln -s docker-compose.dev.yml docker-compose.override.yml

WIP


Modification de la configuration
--------------------------------

Après modification de la configuration (``config/docker_config.toml`` par défaut), il faut :

* Re-générer la configuration du frontend ::

    docker compose run --rm --no-TTY api geonature generate-frontend-config --input - < frontend/src/conf/app.config.ts.sample --output - > frontend/src/conf/app.config.ts

* Re-builder l’image du frontend ::

    docker compose build web

* Redémarrer les conteneurs ::

    docker compose restart
