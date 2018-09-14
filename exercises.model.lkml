connection: "thelook"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

explore: events {
  hidden: yes
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one

  }
}

explore: inventory_items {
  hidden: yes
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}


explore: customers {
  hidden: yes
  join: orders {
    sql_on: ${customers.customer_id} = ${orders.customer_id} ;;
  }
}


explore: order_items {
  hidden: yes
  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}

explore: orders {
  hidden: yes
  join: users {
    type: left_outer
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: products {
  hidden: yes
}

explore: schema_migrations {
  hidden: yes
}

explore: user_data {
  hidden: yes
  join: users {
    type: left_outer
    sql_on: ${user_data.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: orders_two {
  hidden: yes
  from:  orders
  conditionally_filter: {
    filters: {
      field: period_ranges.period_1
      value: "today"
    }
    unless: [period_ranges.period_2]
  }
  join: period_ranges {
    type: inner
    sql_on: ${orders_two.created_raw} = ${period_ranges.entire_date_range} ;;
  }
}

explore: users {
  hidden: yes
}

explore: users_nn {
  hidden: yes
}

explore: period_ranges {
  hidden: yes
}

explore: users_ab_test {
  hidden: yes
  join: user_order_facts {
    sql_on: ${user_order_facts.user_id} = ${users_ab_test.id} ;;
    relationship: one_to_one
  }
}
