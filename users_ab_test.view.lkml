view: users_ab_test {
  sql_table_name: users ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    sql: ${age} ;;
    tiers: [0,10,20,30,40,50,60,70,80]
  }

  dimension: gender {
    sql: ${TABLE}.gender ;;
  }

  measure: count {
    type: count
  }

  #   #BEGIN AB TEST INFORMATION-----------------------------

  #We can have any number of user traits on which to split the groups into A and B
  filter: a_b_gender {
    suggest_explore: users
    suggest_dimension: users.gender
    }

  filter: a_b_age {
    type: number
    suggest_explore: users
    suggest_dimension: users.age
    }
  #-----------------------------------

  #WE CREATE A YESNO DIMENSION THAT TAKES THESE FILTERS
  dimension: a_b {
    sql:{%condition a_b_gender %} ${gender} {% endcondition %} AND {%condition a_b_age %} ${age} {% endcondition %} ;;
    type: yesno
    }
  #-----------------------------------

  # WE CREATE A SET OF FITLERED MEASURES THAT WE"LL NEED FOR THE STATISICAL CALCULATIONS, ONE FOR EACH GROUP.

  measure: count_a {
    type: count
    filters: {
      field: a_b
      value: "yes"
    }
  }

  measure: count_b {
    type: count
    filters: {
      field: a_b
      value: "no"
    }
  }


  # IN THIS CASE WE ARE TESTING LIFETIME ORDERS

  measure: average_lifetime_orders_a {
    type: average
    sql: 1.0 * ${user_order_facts.lifetime_orders} ;;
    value_format: "#.00"
    filters: {
      field: a_b
      value: "yes"
    }
  }

  measure: average_lifetime_orders_b {
    type: average
    sql: 1.0 * ${user_order_facts.lifetime_orders} ;;
    value_format: "#.00"
    filters: {
      field: a_b
      value: "no"
    }
  }

  measure: stdev_lifetime_orders_a {
    type: number
    sql: 1.0 * STD(CASE WHEN ${a_b} = "yes" THEN ${user_order_facts.lifetime_orders} ELSE NULL END) ;;
    value_format: "#.00"
  }

  measure: stdev_lifetime_orders_b {
    type: number
    sql: 1.0 * STD(CASE WHEN ${a_b} = "no" THEN ${user_order_facts.lifetime_orders} ELSE NULL END) ;;
    value_format: "#.00"
  }

  measure: t_score {
    type: number
    sql: 1.0 * (${average_lifetime_orders_a} - ${average_lifetime_orders_b}) /
          SQRT(
            (POWER(${stdev_lifetime_orders_a},2) / ${count_a}) + (POWER(${stdev_lifetime_orders_b},2) / ${count_b})
          ) ;;
      value_format: "#.00"
  }

  measure: significance {
    sql:  CASE
        WHEN (ABS(${t_score}) > 3.291) THEN '(7) .0005 sig. level'
        WHEN (ABS(${t_score}) > 3.091) THEN '(6) .001  sig. level'
        WHEN (ABS(${t_score}) > 2.576) THEN '(5) .005 sig. level'
        WHEN (ABS(${t_score}) > 2.326) THEN '(4) .01 sig. level'
        WHEN (ABS(${t_score}) > 1.960) THEN '(3) .025 sig. level'
        WHEN (ABS(${t_score}) > 1.645) THEN '(2) .05 sig. level'
        WHEN (ABS(${t_score}) > 1.282) THEN '(1) .1 sig. level'
        ELSE '(0) Insignificant'
        END ;;
  }


}
