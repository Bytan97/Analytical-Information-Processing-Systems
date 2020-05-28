


WITH "TABLE" AS (SELECT temp_table.name, temp_table.id_goods, temp_table.ddate, temp_table.id_partner, count(*)
                 FROM (
                          SELECT DISTINCT goods.name,
                                          price_list.id_goods,
                                          price_list.ddate,
                                          group_price.id_partner,
                                          price_list.id_prlist
                          FROM price_list
                                   JOIN goods ON goods.id = price_list.id_goods
                                   JOIN group_part ON group_part.id_goods_group = goods.id_group
                                   JOIN group_price
                                        ON price_list.id_prlist = group_price.id_prlist AND
                                           group_price.id_ggroup_part = group_part.id_ggroup_part) temp_table
                 GROUP BY temp_table.name, temp_table.id_goods, temp_table.ddate, temp_table.id_partner
                 HAVING count(*) > 1)
SELECT goods.name,
       price_list.id_goods,
       price_list.ddate,
       group_price.id_partner,
       string_agg(price_list.id_prlist::text, ',')
FROM price_list
         JOIN goods ON goods.id = price_list.id_goods
         JOIN group_part ON group_part.id_goods_group = goods.id_group
         JOIN group_price
              ON price_list.id_prlist = group_price.id_prlist AND group_price.id_ggroup_part = group_part.id_ggroup_part
WHERE price_list.id_goods IN (SELECT id_goods FROM "TABLE")
  AND price_list.ddate IN (SELECT ddate FROM "TABLE")
  AND group_price.id_partner IN (SELECT id_partner FROM "TABLE")
GROUP BY goods.name, price_list.id_goods, price_list.ddate, group_price.id_partner;