*&---------------------------------------------------------------------*
*& DECLARATIONS
*&---------------------------------------------------------------------*

TABLES: aufk.

CONSTANTS: lc_error_aufk TYPE string VALUE 'ERROR 404 - NOT FOUND - AUFK',
           lc_error_afpo TYPE string VALUE 'ERROR 404 - NOT FOUND - AUFK MAKT',

           lc_euros      TYPE string VALUE 'EUROS',
           lc_eur        TYPE string VALUE 'EUR',
           lc_dollars    TYPE string VALUE 'DOLLARS',
           lc_usd        TYPE string VALUE 'USD',
           lc_dash       TYPE string VALUE '-',
           lc_none_desc  TYPE string VALUE 'Aucune description'.

TYPES: BEGIN OF ty_final,
         aufnr    TYPE aufk-aufnr,
         posnr    TYPE afpo-posnr,
         type_cat TYPE char40,
         bukrs    TYPE aufk-bukrs,
         matnr    TYPE afpo-matnr,
         maktx    TYPE makt-maktx,
         psmng    TYPE afpo-psmng,
         amein    TYPE afpo-amein,
         devise   TYPE char10,
         lgort    TYPE afpo-lgort,
       END OF ty_final.

DATA: lt_final TYPE STANDARD TABLE OF ty_final,
      ls_final LIKE LINE OF lt_final.

DATA: r_salv_table TYPE REF TO cl_salv_table.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN
*&---------------------------------------------------------------------*

*2.2.1 Ecran de sélection

SELECTION-SCREEN: BEGIN OF BLOCK b000 WITH FRAME TITLE TEXT-000.

  SELECT-OPTIONS: s_aufnr FOR aufk-aufnr.
  PARAMETERS: p_waers TYPE aufk-waers OBLIGATORY DEFAULT 'USD'.

SELECTION-SCREEN: END OF BLOCK b000.

*&---------------------------------------------------------------------*
*& PROCESSING
*&---------------------------------------------------------------------*

START-OF-SELECTION.

*2.2.2 Récupération des données

  "Sélection des valeurs des champs suivants depuis la table AUFK
  SELECT aufnr,       "Ordre
         auart,       "Type d'ordre
         autyp,       "Catégorie ordre
         bukrs,       "Société
         waers        "Devise
    FROM aufk
    INTO TABLE @DATA(lt_aufk)
    WHERE aufnr IN @s_aufnr
    AND waers = @p_waers.

  "Prévient le DUMP et affiche un message d'erreur en cas d'échec
  IF sy-subrc <> 0.
    MESSAGE lc_error_aufk TYPE 'E' DISPLAY LIKE 'I'.
  ENDIF.

  "Sélection des valeurs des champs suivants depuis les tables AFPO/MAKT
  SELECT afpo~aufnr,  "Ordre
         afpo~posnr,  "N° poste
         afpo~psmng,  "Quantité totale
         afpo~amein,  "UQ ordre
         afpo~matnr,  "Numéro article
         afpo~lgort,  "Magasin
         makt~spras,  "langue
         makt~maktx   "Description
    FROM afpo
    INNER JOIN makt
      ON afpo~matnr = makt~matnr
    INTO TABLE @DATA(lt_afpo_makt)
    WHERE makt~spras = 'E'.

  "Prévient le DUMP et affiche un message d'erreur en cas d'échec
  IF sy-subrc <> 0.
    MESSAGE lc_error_afpo TYPE 'E' DISPLAY LIKE 'I'.
  ENDIF.

*2.2.3 Traitement des données et alimentation de la table finale

  "Boucle sur la table d'entête
  LOOP AT lt_aufk ASSIGNING FIELD-SYMBOL(<lfs_aufk>).

    "Boucle sur la table des postes
    LOOP AT lt_afpo_makt ASSIGNING FIELD-SYMBOL(<lfs_afpo_makt>)
                         WHERE aufnr = <lfs_aufk>-aufnr.

      "Traitement des données d'entête issues de la table AUFK
      ls_final-aufnr = <lfs_aufk>-aufnr.
      ls_final-bukrs = <lfs_aufk>-bukrs.

      CONCATENATE <lfs_aufk>-auart lc_dash <lfs_aufk>-autyp INTO ls_final-type_cat.

      CASE <lfs_aufk>-waers.
        WHEN lc_eur.
          ls_final-devise = lc_euros.
        WHEN lc_usd.
          ls_final-devise = lc_dollars.
        WHEN OTHERS.
          ls_final-devise = <lfs_aufk>-waers.
      ENDCASE.

      "Traitement des données des postes issues de la table AFPO/MAKT
      ls_final-posnr = <lfs_afpo_makt>-posnr.
      ls_final-matnr = <lfs_afpo_makt>-matnr.
      ls_final-psmng = <lfs_afpo_makt>-psmng.
      ls_final-amein = <lfs_afpo_makt>-amein.
      ls_final-lgort = <lfs_afpo_makt>-lgort.

      CASE <lfs_afpo_makt>-maktx.
        WHEN ' '.
          ls_final-maktx = lc_none_desc.
        WHEN OTHERS.
          ls_final-maktx = <lfs_afpo_makt>-maktx.
      ENDCASE.

      "Ajout des données d'entête et de poste à chaque itération
      APPEND ls_final TO lt_final.
      CLEAR: ls_final.

    ENDLOOP.

  ENDLOOP.

  "Vérification: si la table est remplie, alors...
  IF lt_final IS NOT INITIAL.

    "... Affichage de l'ALV
    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = r_salv_table
          CHANGING
            t_table      = lt_final.
      CATCH cx_salv_msg.
    ENDTRY.

    r_salv_table->display( ).

  ENDIF.