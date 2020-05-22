DROP TABLE IF EXISTS g;
DROP TABLE IF EXISTS test;
DROP TABLE IF EXISTS goods_groups CASCADE;
DROP TABLE IF EXISTS storage CASCADE;
DROP TABLE IF EXISTS recept CASCADE;
DROP TABLE IF EXISTS recgoods CASCADE;
DROP TABLE IF EXISTS region CASCADE;
DROP TABLE IF EXISTS income CASCADE;
DROP TABLE IF EXISTS incgoods CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS client_groups CASCADE;
DROP TABLE IF EXISTS cassa_income CASCADE;
DROP TABLE IF EXISTS city CASCADE;
DROP TABLE IF EXISTS goods CASCADE;
DROP TABLE IF EXISTS cassa_recept CASCADE;
DROP TABLE IF EXISTS bank_recept CASCADE;
DROP TABLE IF EXISTS bank_income CASCADE;
DROP TABLE IF EXISTS temp CASCADE ;

CREATE TABLE region
(
    id   serial,
    name text,
    PRIMARY KEY (id)
);

CREATE TABLE city
(
    id     serial,
    name   text,
    region int REFERENCES region (id),
    PRIMARY KEY (id)
);

CREATE TABLE storage
(
    id   serial,
    name text,
    PRIMARY KEY (id)
);

CREATE TABLE client
(
    id      serial,
    name    text,
    address text,
    city    int REFERENCES city (id),
    PRIMARY KEY (id)
);

CREATE TABLE recept
(
    id      serial,
    ddate   date,
    ndoc    int,
    client  int REFERENCES client (id),
    storage int REFERENCES storage (id),
    PRIMARY KEY (id)
);

CREATE TABLE income
(
    id      serial,
    ddate   date,
    ndoc    int,
    client  int REFERENCES client (id),
    storage int REFERENCES storage (id),
    PRIMARY KEY (id)
);

CREATE TABLE goods_groups
(
    id     serial,
    name   text,
    parent int REFERENCES goods_groups (id),
    PRIMARY KEY (id)
);


CREATE TABLE goods
(
    id      serial,
    g_group int REFERENCES goods_groups (id),
    name    text,
    weight  decimal(18, 4),
    length  decimal(18, 4),
    height  decimal(18, 4),
    width   decimal(18, 4),
    PRIMARY KEY (id)
);

CREATE TABLE recgoods
(
    id     int REFERENCES recept (id),
    subid  int,
    goods  int REFERENCES goods (id),
    volume int,
    price  decimal(18, 4),
    PRIMARY KEY (id, subid)
);

CREATE TABLE incgoods
(
    id     int REFERENCES income (id),
    subid  int,
    goods  int REFERENCES goods (id),
    volume int,
    price  decimal(18, 4),
    PRIMARY KEY (id, subid)
);

CREATE TABLE cassa_income
(
    id     serial PRIMARY KEY,
    ddate  date,
    summ   int,
    client int REFERENCES client (id)
);

CREATE TABLE bank_income
(
    id     serial PRIMARY KEY,
    ddate  date,
    summ   int,
    client int REFERENCES client (id)
);

CREATE TABLE cassa_recept
(
    id     serial PRIMARY KEY,
    ddate  date,
    summ   int,
    client int REFERENCES client (id)
);

CREATE TABLE bank_recept
(
    id     serial PRIMARY KEY,
    ddate  date,
    summ   int,
    client int REFERENCES client (id)
);
