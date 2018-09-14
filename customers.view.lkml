view: customers {
  sql_table_name: my_db.customers ;;

  dimension: customer_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.customer_id ;;
  }
}
