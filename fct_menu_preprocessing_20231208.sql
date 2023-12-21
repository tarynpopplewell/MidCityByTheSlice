
/*
This is pre-processing of the raw, Excel based menu data.
*/

WITH fct_pizza AS (
  SELECT
  restaurant_id,
  pizza_name,
  pizza_size__in_,
  pizza_shape,
  pizza_price,
  --Remove 'x' placeholders where there is only a single character in the cell
  CASE WHEN topping_1 = 'x' THEN NULL ELSE topping_1 END AS topping_1,  
  CASE WHEN topping_2 = 'x' THEN NULL ELSE topping_2 END AS topping_2,
  case WHEN topping_3 = 'x' THEN NULL ELSE topping_3 END AS topping_3,
  CASE WHEN topping_4 = 'x' THEN NULL ELSE topping_4 END AS topping_4,
  CASE WHEN topping_5 = 'x' THEN NULL ELSE topping_5 END AS topping_5,	
  CASE WHEN topping_6 = 'x' THEN NULL ELSE topping_6 END AS topping_6,	
  case WHEN topping_7 = 'x' THEN NULL ELSE topping_7 END AS topping_7,
  CASE WHEN topping_8 = 'x' THEN NULL ELSE topping_8 END AS topping_8,
  CASE WHEN topping_9 = 'x' THEN NULL ELSE topping_9 END AS topping_9,
  CASE WHEN topping_10 = 'x' THEN NULL ELSE topping_10 END AS topping_10,  
  CASE WHEN topping_11 = 'x' THEN NULL ELSE topping_11 END AS topping_11,  
  date_collected,
  collection_wave,
  notes,
  --ACOS(-1) is the same as pi. GBQ doesn't have a built in PI() function.
  --This calculates the area of each pie.
  CASE WHEN pizza_shape IN (LOWER('circle'),LOWER('round')) 
    THEN ACOS(-1)*POWER((CAST(SPLIT(pizza_size__in_, 'x')[SAFE_ORDINAL(1)] AS decimal))/2,2) 
    WHEN LOWER(pizza_shape) = 'ellipse' 
    THEN ACOS(-1)*CAST(SPLIT(pizza_size__in_, 'x')[SAFE_ORDINAL(1)] AS decimal)*CAST(SPLIT(pizza_size__in_, 'x')[SAFE_ORDINAL(2)] AS decimal)
    ELSE 0 END AS pie_area,
    --Count the distinct number of toppings a pie has.
  (SELECT COUNT(DISTINCT topping) 
    FROM UNNEST([topping_1,topping_2,topping_3,topping_4,topping_5,topping_6,topping_7,topping_8,topping_9,topping_10,topping_11]) AS topping  
      WHERE topping != 'x'
  ) AS topping_count,
  CASE WHEN MAX(date_collected) OVER (PARTITION BY restaurant_id) = date_collected THEN 1 ELSE 0 END AS latest_collection
  FROM midcitybytheslice.midcitybytheslice.fct_menu 

)

, top_arr AS (

  SELECT 
  restaurant_id,
  pizza_name,
  pizza_size__in_,
  pizza_shape,
  pizza_price,
  date_collected,
  collection_wave,
  notes,
  pie_area,
  topping_count,
  latest_collection,
  ARRAY_AGG(DISTINCT topping_ids IGNORE NULLS) topping_list
  FROM fct_pizza,
    UNNEST([topping_1,topping_2,topping_3,topping_4,topping_5,topping_6,topping_7,topping_8,topping_9,topping_10,topping_11]) topping_ids
  GROUP BY 1,2,3,4,5,6,7,8,9,10,11
)

SELECT
restaurant_id,
pizza_name,
pizza_shape,
pizza_size__in_,
pie_area,
pizza_price,
date_collected,
collection_wave,
notes,
topping_count,
latest_collection,
ARRAY_AGG(topping_id) AS toppings, 
ARRAY_AGG(topping_cat_id) AS topping_cats
FROM top_arr ta
JOIN midcitybytheslice.dim_topping t 
ON t.topping_id IN UNNEST(topping_list)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11


