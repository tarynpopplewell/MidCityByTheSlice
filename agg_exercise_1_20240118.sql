
/*
Agg_exercise_1_20240118
average area of pie by zip code

case when
average price of pie by restaurant less than or equal to 12 = LOW
average price of pie by restaurant greater than 12 and less than or equal to 19 = MED
average price of pie by restaurant greater than 19 = HIGH
*/

with pizza_data as (
select
cast(menu_date as DATE) as menu_date,
fp.restaurant_id,
zip_code,
pizza_name,
pie_area,
pizza_price
from midcitybytheslice.midcitybytheslice.fct_pizza fp
inner join `midcitybytheslice.midcitybytheslice.dim_restaurants` dr 
on fp.restaurant_id = dr.restaurant_id
)

select
extract(year from menu_date) as menu_year,
restaurant_id,
zip_code,
ROUND(avg(pie_area) over (partition by extract(year from menu_date),zip_code),4) as avg_pie_area_zip,
ROUND(avg(pizza_price) over (partition by extract(year from menu_date),restaurant_id),2) as avg_pie_price_rest,
case when avg(pizza_price) over (partition by extract(year from menu_date),restaurant_id) <= 12 then 'LOW'
      when avg(pizza_price) over (partition by extract(year from menu_date),restaurant_id) > 12 AND avg(pizza_price) over (partition by extract(year from menu_date),restaurant_id) <= 21 then 'MED'
      when avg(pizza_price) over (partition by extract(year from menu_date),restaurant_id) > 21 then 'HIGH' end as price_group
from pizza_data
