DROP FUNCTION IF EXISTS moving_average(d1 date, d2 date);

CREATE OR REPLACE FUNCTION moving_average(d1 date, d2 date)
    RETURNS table
            (
                client     int,
                goods      int,
                date       date,
                sum        int,
                prediction double precision
            )
AS
$$
DECLARE
    cursor CURSOR FOR SELECT recept.client, recgoods.goods, recept.ddate, sum(recgoods.volume * recgoods.price)
                      FROM recept
                               JOIN recgoods ON (recept.id = recgoods.subid)
                      WHERE recept.ddate >= d1
                        AND recept.ddate <= d2
--                       AND recept.client = cl
--                       AND recgoods.goods = g
                      GROUP BY recept.client, recgoods.goods, recept.ddate
                      ORDER BY recept.client
    ;
    cnt         int := 0;
    temp_cnt    int := 0;
    pred        double precision;
    prev_client int;
    prev_goods  int;
--
    client      int;
    goods       int;
    date        date;
    sum         int;
BEGIN
    CREATE TEMP TABLE tmp
    (
        goods_id int,
        date     date,
        sum      int
    );
    CREATE TEMP TABLE to_return
    (
        client     int,
        goods      int,
        date       date,
        sum        int,
        prediction double precision
    );
    OPEN cursor;
    LOOP
        FETCH cursor INTO client, goods, date, sum;
        EXIT WHEN NOT found;

        IF client != prev_client OR goods != prev_goods THEN
            temp_cnt := 1;
            TRUNCATE tmp;
            INSERT INTO tmp VALUES (goods, date, sum);
            INSERT INTO to_return (client, goods, date, sum, prediction)
            VALUES (client, goods, date, sum, sum);
        ELSE
            IF temp_cnt < 2 THEN
                temp_cnt = temp_cnt + 1;
                INSERT INTO to_return (client, goods, date, sum, prediction)
                VALUES (client, goods, date, sum, sum);
                INSERT INTO tmp VALUES (goods, date, sum);
            ELSE
                temp_cnt = temp_cnt + 1;
                INSERT INTO to_return (client, goods, date, sum, prediction)
                VALUES (client, goods, date, sum, (SELECT avg(tmp.sum) FROM tmp));
                DELETE FROM tmp WHERE tmp.date IN (SELECT tmp.date FROM tmp ORDER BY tmp.date ASC LIMIT 1);
                INSERT INTO tmp VALUES (goods, date, sum);
            END IF;
        END IF;
        prev_goods = goods;
        prev_client = client;
        cnt := cnt + 1;
    END LOOP;

    CLOSE cursor;
    RETURN QUERY SELECT * FROM to_return;
    DROP TABLE to_return;
    DROP TABLE tmp;
END
$$ LANGUAGE plpgsql;

SELECT *
FROM moving_average('2020-02-01', '2020-12-31');