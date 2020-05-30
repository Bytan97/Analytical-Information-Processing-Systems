DROP TABLE IF EXISTS remains;
DROP TABLE IF EXISTS irlink;
CREATE TABLE remains
(
    id      int,
    subid   int,
    goods   int REFERENCES goods (id),
    storage int REFERENCES storage (id),
    ddate   date,
    volume  int,
    PRIMARY KEY (id, subid)
);
CREATE TABLE irlink
(
    id      serial,
    i_id    int REFERENCES income (id),
    i_subid int,
    r_id    int REFERENCES recept (id),
    r_subid int,
    goods   int REFERENCES goods (id),
    volume  int,
    PRIMARY KEY (id)
);

CREATE OR REPLACE FUNCTION Deleted() RETURNS trigger AS
$$
DECLARE
    income_storage int;
    income_date    date;
    item           record;
    remain         record;
    dif_value      int;
    remain_value   int;
    irlink_sum     int;
BEGIN
    SELECT storage, ddate
    INTO income_storage, income_date
    FROM income
    WHERE id = old.id;
    DELETE FROM remains WHERE id = old.id AND subid = old.subid;
    CREATE TEMP TABLE irl
    (
        id      integer,
        i_id    integer,
        i_subid integer,
        r_id    integer,
        r_subid integer,
        r_date  date,
        goods   integer,
        volume  integer
    );
    INSERT INTO irl(id, i_id, i_subid, r_id, r_subid, r_date, goods, volume)
    SELECT irlink.id,
           i_id,
           i_subid,
           r_id,
           r_subid,
           r.ddate,
           goods,
           volume
    FROM irlink
             JOIN recept r ON irlink.r_id = r.id
    WHERE i_id = old.id
      AND i_subid = old.subid
      AND goods = old.goods;
    IF ((SELECT count(*) FROM irl) > 0) THEN
        SELECT sum(volume)
        INTO irlink_sum
        FROM irl;
        dif_value = irlink_sum;
        FOR item IN SELECT * FROM irl
            LOOP
                CREATE TEMP TABLE rms
                (
                    id      integer,
                    subid   integer,
                    goods   integer,
                    storage integer,
                    ddate   date,
                    volume  integer
                );

                INSERT INTO rms (id, subid, goods, storage, ddate, volume)
                SELECT id, subid, goods, storage, ddate, volume
                FROM remains
                WHERE storage = income_storage
                  AND goods = old.goods
                  AND (ddate < item.r_date OR ddate = item.r_date)
                ORDER BY ddate;

                IF (item.volume < dif_value) THEN
                    FOR remain IN SELECT * FROM rms
                        LOOP
                            IF (item.volume < remain.volume) THEN
                                UPDATE remains
                                SET volume = (remain.volume - item.volume)
                                WHERE id = remain.id
                                  AND subid = remain.subid;
                                --Привязываем в irlink новый расход
                                UPDATE irlink
                                SET i_id    = remain.id,
                                    i_subid = remain.subid
                                WHERE irlink.id = item.id;
                                item.volume = 0;
                            ELSE
                                INSERT INTO irlink(i_id, i_subid, r_id, r_subid, goods, volume)
                                VALUES (remain.id, remain.subid, item.r_id, item.r_subid, item.goods,
                                        remain.volume);

                                UPDATE irlink
                                SET volume = (irlink.volume - remain.volume)
                                WHERE id = item.id;
                                item.volume = item.volume - remain.volume;

                                DELETE FROM remains WHERE id = remain.id AND subid = remain.subid;
                            END IF;
                            EXIT WHEN item.volume = 0;
                        END LOOP;
                    dif_value = dif_value - item.volume;
                ELSE
                    FOR remain IN SELECT * FROM rms
                        LOOP
                            IF (dif_value < remain.volume) THEN
                                UPDATE remains
                                SET volume = (remain.volume - dif_value)
                                WHERE id = remain.id
                                  AND subid = remain.subid;
                                UPDATE irlink
                                SET volume = (irlink.volume - dif_value)
                                WHERE irlink.id = item.id;

                                INSERT INTO irlink(i_id, i_subid, r_id, r_subid, goods, volume)
                                VALUES (remain.id, remain.subid, item.r_id, item.r_subid, remain.goods, dif_value);
                                dif_value = 0;
                            ELSE
                                INSERT INTO irlink(i_id, i_subid, r_id, r_subid, goods, volume)
                                VALUES (remain.id, remain.subid, item.r_id, item.r_subid, item.goods,
                                        remain.volume);

                                UPDATE irlink
                                SET volume = (irlink.volume - remain.volume)
                                WHERE id = item.id;

                                dif_value = dif_value - remain.volume;
                                DELETE FROM remains WHERE id = remain.id AND subid = remain.subid;
                            END IF;
                            EXIT WHEN dif_value = 0;
                        END LOOP;
                END IF;
                DELETE FROM rms WHERE TRUE;
                EXIT WHEN dif_value = 0;
            END LOOP;
        DROP TABLE IF EXISTS rms;
    END IF;
    DROP TABLE irl;
    DELETE FROM irlink WHERE volume = 0;
    RETURN old;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Deleting() RETURNS trigger AS
$$
DECLARE
    income_storage integer;
    income_date    date;
    sum            integer;
BEGIN
    SELECT recept.storage,
           recept.ddate
    INTO income_storage, income_date
    FROM recept
    WHERE recept.id = new.id;

    sum = (
        SELECT sum(volume)
        FROM remains
        WHERE remains.goods = new.goods
          AND remains.ddate < income_date
          AND remains.storage = income_storage
    );

    RETURN old;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_deleted ON incgoods;
DROP TRIGGER IF EXISTS on_deleting ON incgoods;
CREATE TRIGGER on_deleted
    AFTER DELETE
    ON incgoods
    FOR EACH ROW
EXECUTE PROCEDURE Deleted();

CREATE TRIGGER on_deleting
    BEFORE DELETE
    ON incgoods
    FOR EACH ROW
EXECUTE PROCEDURE Deleting();

