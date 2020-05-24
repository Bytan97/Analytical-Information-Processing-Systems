import matplotlib.pyplot as plt
import pandas as pd
from sqlalchemy import create_engine


base = 'localhost:5432/base'
name_pass = 'postgres:50541'
pref = 'postgresql'
engine = create_engine(f"{pref}://{name_pass}@{base}")


def moving_average(d1: str, d2: str, window_size: int) -> pd.DataFrame:
    SQL = '''
        SELECT
            recept.client cl, recgoods.goods g, recept.ddate d, sum(recgoods.volume * recgoods.price) s
        FROM
            recept JOIN recgoods ON (recept.id = recgoods.id)
        WHERE
            recept.ddate >= %(mindate)s AND recept.ddate <= %(maxdate)s
        GROUP BY
        recept.client, recgoods.goods, recept.ddate
        ;
    '''
    df = pd.read_sql(SQL,
                     engine,
                     params={'mindate': d1, 'maxdate': d2},
                     parse_dates={'recept.ddate': dict(format='%Y%m%d'), }
                     )
    N = df.shape[0]
    if (N < window_size):
        raise ValueError(f"Invalid windows size > {N}")

    dfs = df.set_index(['cl', 'g'])
    dfs.drop('d', axis=1, inplace=True)
    dfs.s = dfs.s.shift(1)
    dfs = dfs.groupby(level=['cl', 'g']).rolling(window=window_size).mean()
    dfs.reset_index(level=[2, 1], inplace=True)
    dfs.reset_index(drop=True, inplace=True)
    dft = df.sort_values(['cl', 'g'],)
    dft.reset_index(drop=True, inplace=True)
    names = ['client', 'goods', 'date', 'sum']
    dft.columns = names
    dft['prediction'] = dfs['s']

    return dft


result = moving_average('20200201', '20201231', 2)
print(result.head(30))


result["sum"][:200].plot(figsize=(16, 4), legend=True)
result["prediction"][:200].plot(figsize=(16, 4), legend=True)
plt.legend(['Data', 'Prediction'])
plt.title('Rolling mean prediciont')
plt.show()
