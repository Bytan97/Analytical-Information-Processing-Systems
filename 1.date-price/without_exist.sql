DROP TABLE IF EXISTS g;
CREATE TABLE IF NOT EXISTS g
(
    id    serial,
    pid int,
    price int,
    ddate date
);
INSERT INTO g(pid, price, ddate)
VALUES (1, 120, '2018-06-06'),
       (2, 130, '2018-07-06'),
       (3, 140, '2018-02-04'),
       (4, 150, '2019-06-06'),
       (2, 160, '2018-10-05'),
       (3, 170, '2018-12-06'),
       (1, 180, '2019-01-10'),
       (5, 190, '2018-12-06'),
       (1, 200, '2018-10-12'),
       (2, 210, '2019-02-06'),
       (3, 220, '2019-03-15');



WITH a_ AS (
    SELECT price, ddate date, row_number() OVER () AS rn
    FROM (
             SELECT price, ddate
             FROM g
             WHERE id = 2
               AND ddate <= '2018-10-04'
             ORDER BY ddate DESC
         ) AS t
)

SELECT price, date
FROM a_
WHERE rn = 1;