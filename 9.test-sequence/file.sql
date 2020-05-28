drop function if exists my_f(int);

create or replace function my_f(n int)
    returns table
            (
                num int
            )
as
$$
declare
    i int;
begin
    create temp table t(
        num      int
    );
    i = 0;
   IF (n < 1) THEN
      RETURN query select * from t;
      drop table t;
   END IF;

   LOOP
      EXIT WHEN i = n ;
      i = i + 1 ;
      insert into t values (i);
   END LOOP ;

    return query select * from t;
    drop table t;
end;
$$ language plpgsql;

select *
from my_f(10);