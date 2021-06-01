*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
FORM get_data .

  SELECT carrid countryto
    INTO TABLE gtd_data
    FROM spfli
    WHERE carrid IN s_carrid.
  IF sy-subrc EQ 0.
    SORT gtd_data BY carrid.
    gtd_data_col[]  = gtd_data[].
    gtd_data_detail[] = gtd_data[].
    SORT gtd_data_col BY countryto.
    DELETE ADJACENT DUPLICATES FROM gtd_data COMPARING carrid.
    DELETE ADJACENT DUPLICATES FROM gtd_data_col COMPARING countryto.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  POPULATE_CATLOG
*&---------------------------------------------------------------------*
FORM populate_catlog .

  DATA: ls_field_name TYPE fieldname.

  ls_field_name = 'CARRID'.

  PERFORM sub_pop_field_catlog USING ls_field_name.

  ls_field_name = 'COUNTRYTO'.

  LOOP AT gtd_data_col INTO gwa_data.
    PERFORM sub_pop_field_catlog USING ls_field_name.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SUB_POP_FIELD_CATLOG
*&---------------------------------------------------------------------*
FORM sub_pop_field_catlog  USING    p_l_field_name TYPE fieldname.

  DATA: ltd_dfies TYPE STANDARD TABLE OF dfies,
        lwa_dfies TYPE dfies.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = 'SPFLI'
      fieldname      = p_l_field_name
    TABLES
      dfies_tab      = ltd_dfies
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc EQ 0.

    CLEAR: lwa_dfies, gwa_fcat.
    READ TABLE ltd_dfies INTO lwa_dfies INDEX 1.

    IF p_l_field_name = 'COUNTRYTO'.
      lwa_dfies-fieldname = gwa_data-countryto.
    ENDIF.

    MOVE-CORRESPONDING lwa_dfies TO gwa_fcat.
    APPEND gwa_fcat TO gtd_fcat.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUILD_INT_TABLE
*&---------------------------------------------------------------------*
FORM build_int_table .


  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gtd_fcat
    IMPORTING
      ep_table                  = gtd_dynamic_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
* Assign the structure of dynamic table to field symbol
  ASSIGN gtd_dynamic_table->* TO <i_dyn_table>.
* Create the dynamic work area
  CREATE DATA gwa_dyn_line LIKE LINE OF <i_dyn_table>.
  ASSIGN gwa_dyn_line->* TO <wa_dyn>.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_FIELD_CAT
*&---------------------------------------------------------------------*
FORM alv_field_cat .

  DATA: ls_fieldname TYPE fieldname,
        ls_seltext   TYPE scrtext_l.


  PERFORM sub_fill_alv_field_cat USING 'CARRID' '<I_DYN_TABLE>' 'L' 'Company' 36.

  LOOP AT gtd_data_col INTO gwa_data.

    ls_fieldname = gwa_data-countryto.
    ls_seltext   = gwa_data-countryto.
    PERFORM sub_fill_alv_field_cat USING ls_fieldname '<I_DYN_TABLE>' 'L' ls_seltext 8.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SUB_FILL_ALV_FIELD_CAT
*&---------------------------------------------------------------------*
FORM sub_fill_alv_field_cat  USING p_fldnam  TYPE fieldname
                                   p_tabnam  TYPE tabname
                                   p_justif  TYPE char1
                                   p_seltext TYPE dd03p-scrtext_l
                                   p_outlen  TYPE i.

  DATA l_lfl_fcat TYPE slis_fieldcat_alv.

  l_lfl_fcat-fieldname  = p_fldnam.
  l_lfl_fcat-tabname    = p_tabnam.
  l_lfl_fcat-just       = p_justif.
  l_lfl_fcat-seltext_l  = p_seltext.
  l_lfl_fcat-outputlen  = p_outlen.

  APPEND l_lfl_fcat TO gtd_fieldcat.

  CLEAR l_lfl_fcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM display_data .

  DATA: l_count     TYPE i,
        l_factor    TYPE i,
        ls_field    TYPE string.

  FIELD-SYMBOLS: <fs1>.

  LOOP AT gtd_data INTO gwa_data.

    CLEAR: l_factor, l_count.

    APPEND INITIAL LINE TO <i_dyn_table> ASSIGNING <wa_dyn>.

    ASSIGN COMPONENT 'CARRID' OF STRUCTURE <wa_dyn> TO <fs1>.
    <fs1> = gwa_data-carrid.

    LOOP AT gtd_data_detail INTO gwa_data_aux WHERE carrid = gwa_data-carrid.

      ls_field = gwa_data_aux-countryto.
      TRANSLATE ls_field TO UPPER CASE.

      ASSIGN COMPONENT ls_field OF STRUCTURE <wa_dyn> TO <fs1>.
      CONCATENATE <fs1> 'X' INTO <fs1>.

    ENDLOOP.

  ENDLOOP.

  CLEAR: gwa_layout.
  gwa_layout-zebra = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = gwa_layout
      it_fieldcat        = gtd_fieldcat
    TABLES
      t_outtab           = <i_dyn_table>
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.