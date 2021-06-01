TYPE-POOLS: slis.
TABLES: spfli.

TYPES: BEGIN OF gty_data,
         carrid    TYPE spfli-carrid,
         countryto TYPE spfli-countryto,
       END OF gty_data.

DATA: gtd_data          TYPE STANDARD TABLE OF gty_data,
      gtd_data_col      TYPE STANDARD TABLE OF gty_data,
      gtd_data_detail   TYPE STANDARD TABLE OF gty_data,
      gtd_fcat          TYPE lvc_t_fcat,
      gtd_dynamic_table TYPE REF TO data,
      gtd_fieldcat      TYPE slis_t_fieldcat_alv,
      gwa_fcat          TYPE lvc_s_fcat,
      gwa_dyn_line      TYPE REF TO data,
      gwa_data          TYPE gty_data,
      gwa_data_aux      TYPE gty_data.

DATA: gwa_layout TYPE slis_layout_alv.

FIELD-SYMBOLS:
  <i_dyn_table>   TYPE STANDARD TABLE,
  <i_final_table> TYPE STANDARD TABLE,
  <wa_dyn>        TYPE any,
  <wa_final>      TYPE any.