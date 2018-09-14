view: period_ranges {
  derived_table: {
    sql: (SELECT
        orders.created_at AS "entire_date_range"
        , TRUE as "is_this_period"
      FROM orders
      WHERE
        {% condition period_1 %} orders.created_at  {% endcondition %}
      GROUP BY 1
      ) UNION ALL (
      SELECT
        orders.created_at  AS "entire_date_range"
        , FALSE as "is_this_period"
      FROM orders
      WHERE
        {% condition period_2 %} orders.created_at  {% endcondition %}
      GROUP BY 1
      ) ;;
  }

  dimension: entire_date_range {
    primary_key: yes
    hidden: yes
  }

  filter: period_1 {
    type: date
  }

  filter: period_2 {
    type: date
  }

  dimension: is_this_period {
    type:  yesno
    hidden: yes
  }

  dimension: period_name {
    case: {
      when: {
        sql: ${is_this_period} = "yes" ;;
        label: "this"
    }
      else: "previous"
    }
  }
}
