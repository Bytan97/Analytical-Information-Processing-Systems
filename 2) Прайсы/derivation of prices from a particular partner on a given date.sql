WITH product AS (SELECT price_list.id_goods,
                        goods.name,
                        goods.id_group,
                        group_part.id_ggroup_part,
                        price_list.price,
                        price_list.ddate,
                        price_list.id_prlist
                 FROM price_list
                          JOIN goods ON goods.id = price_list.id_goods
                          JOIN group_part ON group_part.id_goods_group = goods.id_group)

SELECT DISTINCT product.name, product.price
FROM group_price
         JOIN product
              ON product.id_prlist = group_price.id_prlist AND group_price.id_ggroup_part = product.id_ggroup_part
WHERE group_price.id_partner = 4
  AND product.ddate = '2020-03-04';
