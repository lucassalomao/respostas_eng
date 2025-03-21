*&---------------------------------------------------------------------*
*& Report ZTESTE_ENG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTESTE_ENG.

*---------------------------------------
*  TABLES
*--------------------------------------
TABLES j_1bnfdoc.

* ----------------------------------------------------------------------------------------
* Definição da Classe de relatório
* ----------------------------------------------------------------------------------------
CLASS lcl_report DEFINITION.

*---------------------------------------
  PUBLIC SECTION.
*--------------------------------------

    TYPES: BEGIN OF ty_out,
             docnum TYPE j_1bnfdoc-docnum,
             bukrs  TYPE j_1bnfdoc-bukrs,
             branch TYPE j_1bnfdoc-branch,
             nfenum TYPE j_1bnfdoc-nfenum,
             series TYPE j_1bnfdoc-series,
             parid  TYPE j_1bnfdoc-parid,
             vliq   TYPE j_1bnfdoc-vliq,
           END OF ty_out.

    DATA: it_outab TYPE STANDARD TABLE OF ty_out.
    DATA: t_alv_table TYPE REF TO cl_salv_table.

*Métodos
    METHODS:
      select_data,
      show_alv.

ENDCLASS.

* ----------------------------------------------------------------------------------------
* Globais
* ----------------------------------------------------------------------------------------
DATA: lo_report TYPE REF TO lcl_report.

* ----------------------------------------------------------------------------------------
* Parâmetros de Seleção
* ----------------------------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:  s_docdat FOR j_1bnfdoc-docdat,
                 s_bukrs  FOR j_1bnfdoc-bukrs,
                 s_branch FOR j_1bnfdoc-branch,
                 s_parid  FOR j_1bnfdoc-parid.
SELECTION-SCREEN END OF BLOCK frame1.

* -----------------------------------------------------------------------------------------
* Implementação da Classe de relatório
* -----------------------------------------------------------------------------------------
CLASS lcl_report IMPLEMENTATION.

  METHOD select_data.

    SELECT   a~docnum
             a~bukrs
             a~branch
             a~nfenum
             a~series
             a~parid
             a~vliq
      FROM j_1bnfdoc AS a
      INNER JOIN j_1bnfe_active AS b ON a~docnum = b~docnum
      INTO TABLE lo_report->it_outab
      WHERE a~cancel EQ abap_false
        AND a~model  EQ '55'
        AND a~docdat IN s_docdat
        AND a~bukrs  IN s_bukrs
        AND a~branch IN s_branch
        AND a~parid  IN s_parid
        AND b~docsta EQ '1'.

    IF sy-subrc NE 0.
      MESSAGE s208(00) WITH 'Não há registros para essa seleção!' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ENDMETHOD.

  METHOD show_alv.

    TRY.

        cl_salv_table=>factory(
          IMPORTING
            r_salv_table   = lo_report->t_alv_table
          CHANGING
            t_table        = lo_report->it_outab
        ).


        CALL METHOD lo_report->t_alv_table->display.

      CATCH cx_salv_msg.
        MESSAGE s208(00) WITH 'Erro ao exibir o ALV!' DISPLAY LIKE 'E'.
    ENDTRY.


  ENDMETHOD.


ENDCLASS.

* --------------------------------------------
* Início do programa
* --------------------------------------------
INITIALIZATION.
  CREATE OBJECT lo_report.

START-OF-SELECTION.
  lo_report->select_data( ).
  lo_report->show_alv( ).
