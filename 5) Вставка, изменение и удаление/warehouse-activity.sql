ALTER TABLE storage
    ADD COLUMN active int;

WITH warehourse_sales AS (
    SELECT recept.storage, sum(recgoods.volume * recgoods.price) AS sum
    FROM recept
             JOIN recgoods ON recept.id = recgoods.id
    WHERE recept.ddate > date_trunc('month', current_date - INTERVAL '1' MONTH)
    GROUP BY recept.storage
    HAVING sum(recgoods.volume * recgoods.price) > 10000)


UPDATE storage
SET active = 1
WHERE id IN (SELECT storage FROM warehourse_sales);

SELECT *
FROM storage;