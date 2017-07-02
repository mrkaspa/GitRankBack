import sqlalchemy as sa
import datetime
import os
from aiopg.sa import create_engine

uri = os.environ.get('DATABASE_URL', 'postgresql://mrkaspa:@localhost/langs')
metadata = sa.MetaData()
langs = sa.Table(
    'langs', metadata,
    sa.Column('id', sa.Integer, primary_key=True),
    sa.Column('name', sa.String(150), nullable=False, unique=True),
    sa.Column('url', sa.String(250), nullable=False, unique=True))
stats = sa.Table(
    'stats', metadata,
    sa.Column('id', sa.Integer, primary_key=True),
    sa.Column(
        'lang_id', sa.Integer, sa.ForeignKey('langs.id'), nullable=False),
    sa.Column('stars', sa.Integer, nullable=False),
    sa.Column('year', sa.Integer, nullable=False),
    sa.Column('month', sa.Integer, nullable=False),
    sa.UniqueConstraint('lang_id', 'year', 'month', name='uix_date'))


async def init_db():
    return await create_engine(uri)


def setup_db():
    engine = sa.create_engine(uri)
    metadata.create_all(engine)


async def with_conn(do):
    engine = await init_db()
    async with engine:
        async with engine.acquire() as conn:
            return await do(conn)


async def get_langs_data():
    async def do_conn(conn):
        join = sa.join(langs, stats, langs.c.id == stats.c.lang_id)
        query = sa.select(
            [langs, stats], use_labels=True) \
            .select_from(join) \
            .order_by(
                stats.c.stars.desc(), sa.func.lower(langs.c.name),
                stats.c.year, stats.c.month)
        rs = await conn.execute(query)
        return [(dict(row.items())) for row in rs]
    return await with_conn(do_conn)


async def store_info(info):
    async def do_conn(conn):
        async with conn.begin():
            info_list = list(info)
            ids = await insert_langs(conn, info_list)
            await insert_stats(conn, info_list, ids)
    await with_conn(do_conn)


async def insert_langs(conn, info):
    ids = {}
    for (name, url, stars) in info:
        query = sa.select([langs.c.id]).where(langs.c.name == name)
        async for rows in conn.execute(query):
            ids[name] = rows[0]
            break
        else:
            ids[name] = await conn.scalar(
                langs.insert().values(name=name, url=url))
    return ids


async def insert_stats(conn, info, ids):
    now = datetime.datetime.now()
    year, month = now.year, now.month
    for (name, _, stars) in info:
        await conn.execute(
            stats.insert().values(
                lang_id=ids[name], stars=stars, year=year, month=month))
