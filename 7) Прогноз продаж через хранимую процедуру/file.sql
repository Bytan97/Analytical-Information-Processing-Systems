DROP FUNCTION IF EXISTS my_f(date, date, int);

CREATE OR REPLACE FUNCTION my_f(d1 date, d2 date, window_size int)
    RETURNS table
            (
                client      int,
                goods       int,
                ddate       date,
                ssum        int,
                predication double precision
            )
AS
$$
DECLARE
    curs CURSOR FOR SELECT recept.client cl, recgoods.goods g, recept.ddate d, sum(recgoods.volume * recgoods.price) s
                    FROM recept
                             JOIN recgoods ON (recept.id = recgoods.subid)
                    WHERE recept.ddate >= d1
                      AND recept.ddate <= d2
                    GROUP BY recept.client, recgoods.goods, recept.ddate
                    ORDER BY recept.ddate
    ;
    pred double precision;
    cnt  int;
--     cursor
    cl   int;
    dg   int;
    dd   date;
    ss   int;


BEGIN
    CREATE TEMP TABLE t
    (
        client      int,
        goods       int,
        ddate       date,
        ssum        int,
        predicition double precision
    );

    OPEN curs;
    cnt = 0;
    LOOP
        FETCH curs INTO cl, dg, dd, ss;
        EXIT WHEN NOT FOUND;
        IF cnt < window_size THEN
            INSERT INTO t VALUES (cl, dg, dd, ss, NULL);
        ELSE
            pred = (SELECT sum(d.ssum)
                    FROM (SELECT t.ssum, row_number() OVER () AS row_n FROM t) AS d
                    WHERE d.row_n >= cnt - window_size
                      AND d.row_n <= cnt)
                / window_size;
            INSERT INTO t VALUES (cl, dg, dd, ss, pred);
        END IF;
        cnt = cnt + 1;

    END LOOP;


    CLOSE curs;
    RETURN QUERY SELECT * FROM t;
    DROP TABLE t;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM my_f('2020-02-01', '2020-12-31', 2);
