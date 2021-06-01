TYPE-POOLS: slis.

TYPES:
  BEGIN OF gty_columns,
    col(15)  TYPE c,
    desc(20) TYPE c,
  END OF gty_columns,

  BEGIN OF gty_values,
    field1 TYPE char10,
    field2 TYPE char15,
    field3 TYPE char20,
    field4 TYPE char20,
    field5 TYPE char20,
    field6 TYPE char20,
  END OF gty_values,

  BEGIN OF gty_spfli,
    carrid    TYPE s_carr_id,
    connid    TYPE s_conn_id,
    countryfr TYPE spfli-countryfr,
    cityfrom  TYPE s_from_cit,
    countryto TYPE spfli-countryto,
    cityto    TYPE s_to_city,
  END OF gty_spfli.


DATA: gtd_columns TYPE STANDARD TABLE OF gty_columns,
      gtd_values  TYPE STANDARD TABLE OF gty_values,
      gtd_alvfc    TYPE slis_t_fieldcat_alv,
      gwa_alvfc    TYPE slis_fieldcat_alv,
      gtd_fldcat   TYPE lvc_t_fcat,
      gwa_fldcat   TYPE lvc_s_fcat.

DATA: new_table    TYPE REF TO data,
      new_line     TYPE REF TO data.

DATA: gtd_spfli TYPE STANDARD TABLE OF gty_spfli,
      gwa_spfli TYPE gty_spfli.

FIELD-SYMBOLS: <fs_columns> TYPE gty_columns,
               <fs_values>  TYPE gty_values,
               <dyn_table>  TYPE STANDARD TABLE,
               <dyn_wa>.