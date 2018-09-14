view: user_order_facts {
  derived_table: {
    sql: SELECT
        orders.user_id as user_id
        , COUNT(*) as lifetime_items
        , COUNT(DISTINCT order_items.order_id) as lifetime_orders
        , MIN(NULLIF(orders.created_at,0)) as first_order
        , MAX(NULLIF(orders.created_at,0)) as latest_order
        , COUNT(DISTINCT NULLIF(month(orders.created_at),0))
            as number_of_distinct_months_with_orders
        , SUM(order_items.sale_price) as lifetime_revenue
      FROM order_items
      LEFT JOIN orders ON order_items.order_id=orders.id
      GROUP BY user_id
 ;;
  }

  measure: count {
    type: count
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: lifetime_items {
    type: number
    sql: COALESCE(${TABLE}.lifetime_items, 0) ;;
  }

  dimension: lifetime_orders {
    type: number
    sql: COALESCE(${TABLE}.lifetime_orders, 0) ;;
  }

  dimension: lifetime_orders_tiered {
    type: tier
    sql: ${lifetime_orders} ;;
    tiers: [0,1,2,3,5,10]
  }

  dimension: first_order {
    type: string
    sql: ${TABLE}.first_order ;;
    hidden: yes
  }

  dimension: latest_order {
    type: string
    sql: ${TABLE}.latest_order ;;
    hidden: yes
  }

  dimension: number_of_distinct_months_with_orders {
    type: number
    sql: ${TABLE}.number_of_distinct_months_with_orders ;;
    hidden: yes
  }

  dimension: lifetime_revenue {
    type: number
    sql: ${TABLE}.lifetime_revenue ;;
    hidden:  yes
  }
}
