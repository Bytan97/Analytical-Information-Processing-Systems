SELECT DISTINCT key1,
                key2,
                (
                    SELECT sum(data1)
                    FROM dd x
                    WHERE x.key1 = y.key1
                      AND x.key2 = y.key2
                )
                       ssum,
                (
                    SELECT min(data2)
                    FROM dd x
                    WHERE x.key1 = y.key1
                      AND x.key2 = y.key2
                )
                    AS mmin
FROM dd y;