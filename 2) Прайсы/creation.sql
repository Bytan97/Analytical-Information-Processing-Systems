DROP TABLE IF EXISTS partners CASCADE;
DROP TABLE IF EXISTS goods_group CASCADE;
DROP TABLE IF EXISTS goods CASCADE;
DROP TABLE IF EXISTS price_lists CASCADE;
DROP TABLE IF EXISTS price_list CASCADE;
DROP TABLE IF EXISTS group_parts CASCADE;
DROP TABLE IF EXISTS group_part CASCADE;
DROP TABLE IF EXISTS group_price CASCADE;

CREATE TABLE partners
(
    id   serial,
    name text,
    PRIMARY KEY (id)
);
CREATE TABLE goods_group
(
    id   serial,
    name text,
    PRIMARY KEY (id)
);
CREATE TABLE goods
(
    id       serial,
    name     text,
    id_group int REFERENCES goods_group (id),
    PRIMARY KEY (id)
);
CREATE TABLE price_lists
(
    id   serial,
    name text,
    PRIMARY KEY (id)
);
CREATE TABLE price_list
(
    id        serial,
    id_prlist int REFERENCES price_lists (id),
    id_goods  int REFERENCES goods (id),
    price     decimal(18, 4),
    ddate     date,
    PRIMARY KEY (id)
);
CREATE TABLE group_parts
(
    id   serial,
    name text,
    PRIMARY KEY (id)
);
CREATE TABLE group_part
(
    id             serial,
    id_ggroup_part int REFERENCES group_parts (id),
    id_goods_group int REFERENCES goods_group (id),
    PRIMARY KEY (id)
);
CREATE TABLE group_price
(
    id             serial,
    id_prlist      int REFERENCES price_lists (id),
    id_ggroup_part int REFERENCES group_parts (id),
    id_partner     int REFERENCES partners (id),
    PRIMARY KEY (id)
);