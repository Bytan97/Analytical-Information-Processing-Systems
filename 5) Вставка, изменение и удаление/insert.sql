DROP TABLE temp;
CREATE TABLE temp
(
    date       date,
    warehouse  int,
    sum        int,
    volume     int,
    uniq_goods int
);

INSERT INTO temp(date, warehouse, sum, volume, uniq_goods)
SELECT income.ddate,
       income.storage,
       sum(incgoods.volume * incgoods.price)                            sum,
       sum(goods.height * goods.width * goods.length * incgoods.volume) volume,
       count(DISTINCT incgoods.goods)
FROM income
         JOIN incgoods ON income.id = incgoods.id
         JOIN goods ON goods.id = incgoods.goods
GROUP BY income.ddate, income.storage;
