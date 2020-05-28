INSERT INTO partners(name)
SELECT ('partner ' || t)::text
FROM generate_series(1, 20) t;

INSERT INTO goods_group(name)
SELECT ('goods group ' || t)::text
FROM generate_series(1, 10) t;

INSERT INTO goods(name, id_group)
SELECT ('goods ' || t)::text,
       (SELECT id
        FROM goods_group
        WHERE t > 0
        ORDER BY random()
        LIMIT 1)
FROM generate_series(1, 50) t;

INSERT INTO price_lists(name)
SELECT ('price_list ' || t)::text
FROM generate_series(1, 20) t;

INSERT INTO price_list(id_prlist, id_goods, price, ddate)
SELECT (SELECT id
        FROM price_lists
        WHERE t > 0
        ORDER BY random()
        LIMIT 1),
       (SELECT id
        FROM goods
        WHERE t > 0
        ORDER BY random()
        LIMIT 1),
       t * 2.5,
       '2020-03-01'::date + t
FROM generate_series(1, 30) t;

INSERT INTO group_parts(name)
SELECT ('group parts ' || t)::text
FROM generate_series(1, 10) t;

INSERT INTO group_part(id_ggroup_part, id_goods_group)
SELECT (SELECT id
        FROM group_parts
        WHERE t > 0
        ORDER BY random()
        LIMIT 1),
       (SELECT id
        FROM goods_group
        WHERE t > 0
        ORDER BY random()
        LIMIT 1)
FROM generate_series(1, 30) t;

INSERT INTO group_price(id_prlist, id_ggroup_part, id_partner)
SELECT (SELECT id
        FROM price_lists
        WHERE t > 0
        ORDER BY random()
        LIMIT 1),
       (SELECT id
        FROM group_parts
        WHERE t > 0
        ORDER BY random()
        LIMIT 1),
       (SELECT id
        FROM partners
        WHERE t > 0
        ORDER BY random()
        LIMIT 1)
FROM generate_series(1, 30) t;
