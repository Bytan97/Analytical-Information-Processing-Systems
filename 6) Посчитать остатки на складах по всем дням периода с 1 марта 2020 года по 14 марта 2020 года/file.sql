WITH temp_dates AS (
    SELECT date
    FROM generate_series('2020-03-01' :: date, '2020-03-14', '1 day') date
)
SELECT temp_income.date,
       temp_income.storage,
       temp_income.goods,
       CASE
           WHEN temp_recept.recept_volume IS NULL THEN temp_income.income_volume
           WHEN temp_income.income_volume IS NULL THEN -temp_recept.recept_volume
           ELSE (temp_income.income_volume - temp_recept.recept_volume)
           END AS remnants

FROM (SELECT temp_dates.date,
             income.storage,
             incgoods.goods,
             sum(incgoods.volume) income_volume
      FROM income
               JOIN incgoods
                    ON incgoods.id = income.id
               JOIN temp_dates ON income.ddate <= temp_dates.date
      GROUP BY temp_dates.date, income.storage, incgoods.goods
     ) temp_income
         FULL JOIN
     (SELECT temp_dates.date,
             recept.storage,
             recgoods.goods,
             sum(recgoods.volume) recept_volume
      FROM recept
               JOIN recgoods ON recgoods.id = recept.id
               JOIN temp_dates ON recept.ddate <= temp_dates.date
      GROUP BY temp_dates.date, recept.storage, recgoods.goods
     ) temp_recept
     ON temp_recept.storage = temp_income.storage AND temp_recept.goods = temp_income.goods
         AND temp_recept.date = temp_income.date

ORDER BY temp_income.date, temp_income.storage

