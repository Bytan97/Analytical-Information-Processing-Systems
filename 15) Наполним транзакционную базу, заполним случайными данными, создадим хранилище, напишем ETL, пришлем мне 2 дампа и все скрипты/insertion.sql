INSERT INTO region(name)
SELECT ('Регион ' || t)::text
FROM generate_series(1, 5) t;

INSERT INTO city(name, region)
SELECT ('Город ' || t)::text,
       (SELECT id FROM region WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 100) t;


INSERT INTO client(name, address, city)
SELECT ('Клиент ' || t)::text,
       ('Address: Улица - ' || (SELECT * FROM generate_series(1, 227) WHERE t > 0 ORDER BY random() LIMIT 1))::text,
       (SELECT id FROM city WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 100) t;

INSERT INTO storage(name)
SELECT ('warehouse: ' || t)::text
FROM generate_series(1, 10) t;

INSERT INTO goods_groups(name, parent)
SELECT ('Group: ' || t)::text,
       (t)::int
FROM generate_series(1, 5) t;

INSERT INTO goods_groups(name, parent)
SELECT ('Subgroup: ' || t)::text,
       (SELECT id FROM goods_groups WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 5) t;

INSERT INTO goods(g_group, name, weight, length, height, width)
SELECT (SELECT id FROM goods_groups WHERE t > 0 ORDER BY random() LIMIT 1),
       ('Good: ' || t)::text,
       (SELECT * FROM generate_series(1, 10) WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT * FROM generate_series(1, 14) WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT * FROM generate_series(1, 5) WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT * FROM generate_series(1, 4) WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 15) t;

CREATE OR REPLACE FUNCTION generate_dates(dt1 date,
                                          dt2 date,
                                          n int) RETURNS setof date AS
$$
SELECT $1 + i
FROM generate_series(0, $2 - $1, $3) i;
$$ LANGUAGE SQL IMMUTABLE;

INSERT INTO recept(ddate, ndoc, client, storage)
SELECT (SELECT * FROM generate_dates('2020-01-01', '2020-12-31', 2) WHERE t > 0 ORDER BY random() LIMIT 1) d,
       t,
       (SELECT client.id FROM client WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT storage.id FROM storage WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 100000) t
ORDER BY d;

INSERT INTO recept(ddate, ndoc, client, storage)
SELECT (SELECT * FROM generate_dates('2020-01-01', '2020-12-31', 1) WHERE t > 0 ORDER BY random() LIMIT 1) d,
       t,
       (SELECT client.id FROM client WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT storage.id FROM storage WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 100000) t
ORDER BY d;

INSERT INTO income(ddate, ndoc, client, storage)
SELECT (SELECT * FROM generate_dates('2020-01-01', '2020-12-31', 1) WHERE t > 0 ORDER BY random() LIMIT 1) d,
       t,
       (SELECT client.id FROM client WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT storage.id FROM storage WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 100000) t
ORDER BY d;


INSERT INTO incgoods(id, subid, goods, volume, price)
SELECT t,
       t,
       (SELECT goods.id FROM goods WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT * FROM generate_series(1, 500) WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT * FROM generate_series(1, 1500) WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 100000) t;

INSERT INTO recgoods(id, subid, goods, volume, price)
SELECT t,
       t,
       (SELECT goods.id FROM goods WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT * FROM generate_series(1, 500) WHERE t > 0 ORDER BY random() LIMIT 1),
       (SELECT * FROM generate_series(1, 1500) WHERE t > 0 ORDER BY random() LIMIT 1)
FROM generate_series(1, 100000) t;


INSERT INTO bank_income(ddate, summ, client)
SELECT R.ddate, (R2.volume * R2.price) sum, R.client
FROM recept R
         JOIN recgoods R2 ON R.id = R2.id
LIMIT 50000;

INSERT INTO cassa_income(ddate, summ, client)
SELECT R.ddate, (R2.volume * R2.price) sum, R.client
FROM recept R
         JOIN recgoods R2 ON R.id = R2.id
LIMIT 50000 OFFSET 50000;

INSERT INTO bank_recept(ddate, summ, client)
SELECT I.ddate, (I2.volume * I2.price) sum, I.client
FROM income I
         JOIN incgoods I2 ON I.id = I2.id
LIMIT 50000;

INSERT INTO cassa_recept(ddate, summ, client)
SELECT I.ddate, (I2.volume * I2.price) sum, I.client
FROM income I
         JOIN incgoods I2 ON I.id = I2.id
LIMIT 50000 OFFSET 50000;