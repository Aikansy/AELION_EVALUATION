# SPECIFICATION FONCTIONNELLE ET TECHNIQUE DETAILLEE - ORDRE DE TRAVAIL

## CYCLE DE VALIDATION

_CARACTERISTIQUE DU DOCUMENT_

> | AUTEUR(S)         | DATE       | VERSION | DOMAINE   | REFERENCE |
> |-------------------|------------|---------|-----------|-----------|
> | Frédéric GIUSTINI | 29.05.2024 | 1.0     | Formation | None      |

_SUIVI DES EVOLUTIONS DU DOCUMENT_

> | VERSION | DATE       | AUTEUR            | DESCRIPTION DE LA MISE A JOUR |
> |---------|------------|-------------------|-------------------------------|
> | 1.0     | 29.05.2024 | Frédéric GIUSTINI | Création                      |

_LISTE DE DIFFUSION_

> | CLIENT | STMS (représentant) |
> |--------|---------------------|
> | AELION | Frédéric GIUSTINI   |

## TABLE DES MATIERES

1. BESOIN FONCTIONNEL

    1.1 Contexte

    1.2 Description du besoin

2. DEMANDE

    2.1 Règles de gestion spécifiques

    2.2 Récupération des données depuis la Base de données

    - 2.2.1 Ecran de sélection

    - 2.2.2 Table `AUFK` (Données de base ordre) & `AFPO` (Poste d'ordre)

    - 2.2.3 Traitement des données et alimentation de la table finale

3. AFFICHAGE DE L'ALV

## 1. BESOIN FONCTIONNEL

### 1.1 Contexte

> Le client souhaite disposer d’un `PROGRAMME SPECIFIQUE` lui permettant de sélectionner un à plusieurs `ORDRES DE TRAVAIL` en fonction de différents `CRITERES` accessibles via une `INTERFACE UTILISATEUR`, d'altérer `LOCALEMENT` les données afin de les présenter en toute fin dans un `REPORT ALV`.

### 1.2 Description du besoin

> Afin de répondre à son besoin, la solution décrite ci-dessous a été envisagée :
>
> - Un `ECRAN DE SELECTION` (Selection-screen) donnera le choix à l'utilisateur de renseigner des `FILTRES` de sélection.
>
> - Modification des données en fonction du souhait de présentation du client
>
> - Affichage des `ORDRES DE TRAVAIL` et leurs données via un `ALV`.

## 2. DEMANDE

> Le programme devra respecter les critères suivants :
>
> - Nom du programme : `ZTRI_MODULE_ABAP` (`TRI` sera remmplacé par votre trigramme)
>
> - Description du programme : `Programme d'évaluation - Module Prog.Abap`
>
> - Package : `ZAELION`
>
> - OT : ordre de transport personnel
>
> - Vérifier que vous avez bien des `CAS DE TESTS` dans les tables `AUFK`, `AFPO` et `MAKT` (cad. présence de données pour tester votre programme).

<details>
    <summary>RAPPEL(S)</summary>
 
    La transaction 'SE16N' permet de visualiser les données d'une table de la base de données. Si (dans votre environnement de développement) les tables ciblées par la demande sont vides, informer immédiatement le fonctionnel en charge de ce ticket.

</details>

### 2.1 Règles de gestion spécifiques

| REGLE DE GESTION | DESCRIPTION                                                |
|------------------|------------------------------------------------------------|
| RG 1             | Respecter les conventions de nommage pour les déclarations |
| RG 2             | Les nommages devront être également explicites             |
| RG 3             | Structurer le programme                                    |
| RG 4             | Le programme devra être à minima commenté                  |

### 2.2 Récupération des données depuis la Base de données

### 2.2.1 Ecran de sélection

> Un `ECRAN DE SELECTION` devra être créé pour faciliter le filtrage des données par l'utilisateur.
>
> L'utilisateur final aura la possibilité de sélectionner :
>
> - Une `PLAGE DE VALEUR` (range) pour le champ dont la description est `ORDRE` appartenant à la table `AUFK`.
> - Une `VALEUR UNIQUE` pour le champ dont la description est `DEVISE` de la table `AUFK`. Le champ devra être `OBLIGATOIRE`. Ce champ pourrait être renseigné avec des valeurs telles que `USD` ou `EUR` entre autres.
>
> Les champs de sélection devront afficher les `NOMS DE REFERENCE` issue du `DICTIONNAIRE DE DONNEES` dans l'interface de manière automatique.

<details>
    <summary>RAPPEL(S)</summary>
 
    La transaction 'SE11' permet de visualiser la structure d'une table de la base de données (Nom zone, Clés de table (couleur bleue), Nom technique). Le 'Nom zone' correspond à la description et le 'Nom technique' correspond au champ de la table.

    Il existe un paramètre pour forcer un utilisateur à renseigner 'obligatoirement' un champ de l'écran de sélection.

    Les 'éléments de texte' peuvent être paramétrés pour qu'ils affichent une description automatiquement. De plus, la description paramétrée ce cette façon changera en fonction de la lanque de connexion de l'utilisateur en référence au dictionnaire de données.

</details>

### 2.2.2 Récupération des données

> - Dans la table `AUFK` issue de la `BASE DE DONNEES`, récupérer les valeurs des éléments suivants dans une table locale :
>
>   - Ordre (clé de la table de la table `AUFK` et `AFPO`)
>   - Type d'ordre
>   - Catégorie ordre
>   - Société
>   - Devise
>
>   Conditions : Les données à récupérer dans cette table devront prendre en compte les `FILTRES DE SELECTION` définis dans l'`ECRAN DE SELECTION` créé en amont (cf. 2.2.1 Ecran de sélection).
>
>   Si la requête n'aboutit pas, un `MESSAGE D'ERREUR` devra informer l'utilisateur qu'`ERROR 404 - NOT FOUND - AUFK`. Ce message devra apparaître dans une fenêtre `POPUP` pour `INFORMER` l'utilisateur du statut de la requête.
>
> - Dans les tables `AFPO` et `MAKT` issues de la `BASE DE DONNEES`, récupérer les valeurs des éléments suivants dans une table locale :
>
>   Le client souhaite `SELECTIONNER` les données `COMMUNES` entre les deux tables.
>
>   - (Table `AFPO`) Ordre (clé de la table de la table `AUFK` et `AFPO`)
>   - (Table `AFPO`) Nº poste (clé commune de la table `AUFK` et `AFPO`) 
>   - (Table `AFPO`) Quantité totale
>   - (Table `AFPO`) UQ ordre
>   - (Table `AFPO`) Numéro article (clé commune de la table `AFPO` et `MAKT`) 
>   - (Table `AFPO`) Magasin
>   - (Table `MAKT`) Langue
>   - (Table `MAKT`) Description
>
>   Les données récupérées depuis les tables `AFPO` et `MATNR` devront être stockées dans une seule et unique table interne (locale).
>
>   Conditions : les données récupérées dans la requête en base de données devront avoir la condition `OU` la `LANGUE` est `EGALE` à `EN`.
>
>   Si la requête n'aboutit pas, un `MESSAGE D'ERREUR` devra informer l'utilisateur avec le message `ERROR 404 - NOT FOUND - AFPO MAKT`. Ce message devra `APPARAITRE` dans une fenêtre `POPUP` pour `INFORMER` l'utilisateur du statut de la requête.

<details>
    <summary>RAPPEL(S)</summary>
 
    La transaction 'SE11' permet de visualiser la structure d'une table de la base de données (Nom zone, Clés de table (couleur bleue), Nom technique). Le 'Nom zone' correspond à la description et le 'Nom technique' correspond au champ de la table.

    Une jointure entre des tables se font en précisant la ou les clés communes entre ces tables.

    Il existe une manière de traiter les échecs de requête de table grâce à une variable `SYSTEM`. Cette variable est régulèrement utilisée dans une condition.

</details>

### 2.2.3 Traitement des données et alimentation de la table finale

> Le client souhaite que la table finale (celle qui sera affichée avec l'ALV) se présente sous un format spécifique (ci-dessous) et qui sera alimentée avec les données des précédentes tables :
>
> | COLONNE          | CONSIGNE                                                                                                                                                                | TYPE       |
> |------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------|
> | Ordre            | Correspond à l'`Ordre` (Table `AUFK`)                                                                                                                                   | aufk-????? |
> | N° poste         | Correspond à `N° poste` (Table `AFPO`)                                                                                                                                  | afpo-????? |
> | Type_Cat         | Concaténation de `Type d'ordre` `-` `Catégorie d'ordre` (Table `AUFK`)                                                                                                  | char40     |
> | Société          | Correspond à `Société` (Table `AUFK`)                                                                                                                                   | aufk-????? |
> | Numéro d'article | Correspond à `Numéro article` (Table `AFPO`)                                                                                                                            | afpo-????? |
> | Description      | Correspond à `Description` (Table `MAKT`). `SI` `Description` est `vide`, alors la valeur devra être `Aucune description`                                               | char50     |
> | Quantité totale  | Correspond à `Quantité totale` (Table `AFPO`)                                                                                                                           | afpo-????? |
> | UQ ordre         | Correspond à `UQ ordre` (Table `AFPO`)                                                                                                                                  | afpo-????? |
> | Devise           | `SI` 'EUR' alors la valeur devra être 'EUROS'. `SI` 'USD' alors la valeur devra être 'DOLLARS'. `SI` autres, alors la valeur reste la même que `Devise` (Table `AUFK`). | char10     |
> | Magasin          | Correspond à `Magasin` (Table `AFPO`)                                                                                                                                   | afpo-????? |

<details>
    <summary>RAPPEL(S)</summary>
 
    Afin d'alimenter une table, il sera peut-être nécessaire de créer une `structure de table`, puis une `table` pour y stocker les données et enfin une `structure` afin d'ajouter les données.

    Il sera également nécessaire d'ajouter les données dans cette table en bouclant sur la 1ère table locale obtenue, ainsi que sur la seconde en spécifiant la clé commune entre ces deux tables.

</details>

## 3. AFFICHAGE DE L'ALV

> Utilser la méthode `FACTORY` (snippet ci-dessous) de la classe `CL_SALV_TABLE` pour afficher la table finale.
>
> Il sera apprécié que la déclaration (DATA) soit déplacé en haut du programme.

```abap
DATA: r_salv_table TYPE REF TO cl_salv_table.

TRY.
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = r_salv_table
    CHANGING
      t_table      = lt_xxxxx. "remplacer lt_xxxxx par le nom de votre table
  CATCH cx_salv_msg.
ENDTRY.

r_salv_table->display( ).
```

<details>
    <summary>RAPPEL(S)</summary>
 
    'lt_xxxxx' sera à remplacer par la table qui devra être affichée.

</details>