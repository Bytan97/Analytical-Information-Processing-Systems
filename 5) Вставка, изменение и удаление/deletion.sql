DELETE
FROM goods
WHERE id NOT IN (SELECT goods FROM recgoods)
  AND id NOT IN (SELECT goods FROM incgoods)
RETURNING id;