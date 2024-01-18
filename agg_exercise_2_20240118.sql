/*
Agg exercise 2
Get the max average pie price per year by zip code
*/

select * from (
  select 
  menu_year,
  zip_code,
  avg_price_zip,
  dense_rank() over (partition by menu_year order by avg_price_zip desc) as avg_price_rank
  from (
    select
    extract(year from menu_date) as menu_year,
    dr.zip_code,
    ROUND(avg(pizza_price)) as avg_price_zip
    from midcitybytheslice.midcitybytheslice.fct_pizza fp
    inner join `midcitybytheslice.midcitybytheslice.dim_restaurants` dr 
    on fp.restaurant_id = dr.restaurant_id
    group by 1,2
  )
) where avg_price_rank = 1
order by 1,2