FORM get_data.

  SELECT carrid connid countryfr cityfrom countryto cityto UP TO 20 ROWS
    INTO TABLE gtd_spfli
    FROM spfli.

  LOOP AT gtd_spfli INTO gwa_spfli.

    APPEND INITIAL LINE TO gtd_values ASSIGNING <fs_values>.

    IF p_carrid IS NOT INITIAL.
      <fs_values>-field1 = gwa_spfli-carrid.
    ENDIF.

    IF p_connid IS NOT INITIAL.
      <fs_values>-field2 = gwa_spfli-connid.
    ENDIF.

    IF p_coufr IS NOT INITIAL.
      <fs_values>-field3 = gwa_spfli-countryfr.
    ENDIF.

    IF p_cityfr IS NOT INITIAL.
      <fs_values>-field4 = gwa_spfli-cityfrom.
    ENDIF.

    IF p_couto IS NOT INITIAL.
      <fs_values>-field5 = gwa_spfli-countryto.
    ENDIF.

    IF p_cityto IS NOT INITIAL.
      <fs_values>-field6 = gwa_spfli-cityto.
    ENDIF.

  ENDLOOP.

** get data
*  APPEND INITIAL LINE TO gtd_values ASSIGNING <fs_values>.
*  <fs_values>-field1 = '1'.
*  <fs_values>-field2 = 'Elvis'.
*  <fs_values>-field3 = 'Segura'.
*  <fs_values>-field4 = 'Aguirre'.
*
*  APPEND INITIAL LINE TO gtd_values ASSIGNING <fs_values>.
*  <fs_values>-field1 = '2'.
*  <fs_values>-field2 = 'Pepe'.
*  <fs_values>-field3 = 'Gonzales'.
*  <fs_values>-field4 = 'Lara'.

ENDFORM.



FORM set_columns.

"* Set column names

  IF p_carrid IS NOT INITIAL.
    APPEND INITIAL LINE TO gtd_columns ASSIGNING <fs_columns>.
    <fs_columns>-col  = 'CARRID'.
    <fs_columns>-desc = 'ID Compañia'.
  ENDIF.

  IF p_connid IS NOT INITIAL.
    APPEND INITIAL LINE TO gtd_columns ASSIGNING <fs_columns>.
    <fs_columns>-col  = 'CONNID'.
    <fs_columns>-desc = 'ID Conexión'.
  ENDIF.

  IF p_coufr IS NOT INITIAL.
    APPEND INITIAL LINE TO gtd_columns ASSIGNING <fs_columns>.
    <fs_columns>-col  = 'COUNTRYFR'.
    <fs_columns>-desc = 'Clave de país (FR)'.
  ENDIF.

  IF p_cityfr IS NOT INITIAL.
    APPEND INITIAL LINE TO gtd_columns ASSIGNING <fs_columns>.
    <fs_columns>-col  = 'CITYFROM'.
    <fs_columns>-desc = 'Ciudad de salida'.
  ENDIF.

  IF p_couto IS NOT INITIAL.
    APPEND INITIAL LINE TO gtd_columns ASSIGNING <fs_columns>.
    <fs_columns>-col  = 'COUNTRYTO'.
    <fs_columns>-desc = 'Clave de país (FR)'.
  ENDIF.

  IF p_cityto IS NOT INITIAL.
    APPEND INITIAL LINE TO gtd_columns ASSIGNING <fs_columns>.
    <fs_columns>-col  = 'CITYTO'.
    <fs_columns>-desc = 'Ciudad de llegada'.
  ENDIF.


"* Create fieldcat.
  LOOP AT gtd_columns ASSIGNING <fs_columns>.
    CLEAR gwa_fldcat.
    gwa_fldcat-fieldname = <fs_columns>-col.
    gwa_fldcat-seltext   = <fs_columns>-desc.
    gwa_fldcat-datatype  = 'CHAR'.
    gwa_fldcat-intlen    = 20.
    APPEND gwa_fldcat TO gtd_fldcat .
  ENDLOOP.

ENDFORM.




FORM process.

* Create dynamic internal table and assign to FS
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = gtd_fldcat
    IMPORTING
      ep_table        = new_table.

  ASSIGN new_table->* TO <dyn_table>.

* Create dynamic work area and assign to FS
  CREATE DATA new_line LIKE LINE OF <dyn_table>.
  ASSIGN new_line->* TO <dyn_wa>.

*write records
  LOOP AT gtd_values ASSIGNING <fs_values>.

* Fill some values into the dynamic internal table
    DATA: fieldname(20) TYPE c.
    DATA: fieldvalue(20) TYPE c.
    FIELD-SYMBOLS: <fs1>.

    LOOP AT gtd_columns ASSIGNING <fs_columns>.

      ASSIGN COMPONENT  <fs_columns>-col  OF STRUCTURE <dyn_wa> TO <fs1>.

      CASE <fs_columns>-col.
        WHEN 'CARRID'.
          <fs1> = <fs_values>-field1.
        WHEN 'CONNID'.
          <fs1> = <fs_values>-field2.
        WHEN 'COUNTRYFR'.
          <fs1> = <fs_values>-field3.
        WHEN 'CITYFROM'.
          <fs1> = <fs_values>-field4.
        WHEN 'COUNTRYTO'.
          <fs1> = <fs_values>-field5.
        WHEN 'CITYTO'.
          <fs1> = <fs_values>-field6.
      ENDCASE.

    ENDLOOP.

* Append to the dynamic internal table
    APPEND <dyn_wa> TO <dyn_table>.

  ENDLOOP.

ENDFORM.


FORM alv_display.

  LOOP AT  gtd_fldcat INTO gwa_fldcat.
    gwa_alvfc-fieldname = gwa_fldcat-fieldname.
    gwa_alvfc-seltext_s = gwa_fldcat-seltext.
    gwa_alvfc-outputlen = gwa_fldcat-intlen.
    APPEND gwa_alvfc TO gtd_alvfc.
  ENDLOOP.

* Call ABAP List Viewer (ALV)
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat = gtd_alvfc
    TABLES
      t_outtab    = <dyn_table>.

ENDFORM.