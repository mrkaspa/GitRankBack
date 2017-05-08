import sqlalchemy as sa
import datetime
from aiopg.sa import create_engine

uri = 'postgresql://mrkaspa:@localhost/langs'
metadata = sa.MetaData()
langs = sa.Table('langs', metadata,
    sa.Column('id', sa.Integer, primary_key=True),
    sa.Column('name', sa.String(150), nullable=False, unique=True),
    sa.Column('url', sa.String(250), nullable=False, unique=True))
stats = sa.Table('stats', metadata,
    sa.Column('id', sa.Integer, primary_key=True),
    sa.Column('lang_id', sa.Integer, sa.ForeignKey('langs.id'), nullable=False),
    sa.Column('stars', sa.Integer, nullable=False),
    sa.Column('year', sa.Integer, nullable=False),
    sa.Column('month', sa.Integer, nullable=False),
    sa.UniqueConstraint('lang_id', 'year', 'month', name='uix_date'))

async def init_db():
    return await create_engine(uri)

def setup_db():
    engine = sa.create_engine(uri)
    metadata.create_all(engine)

async def get_langs_data():
    pass

async def store_info(info):
    engine = await init_db()
    async with engine:
        async with engine.acquire() as conn:
            async with conn.begin():
                info = list(info)
                ids = await insert_langs(conn, info)
                await insert_stats(conn, info, ids)

async def insert_langs(conn, info):
    ids = {}
    for (name, url, stars) in info:
        query = sa.select([langs.c.id]).where(langs.c.name == name)
        async for rows in conn.execute(query):
            ids[name] = rows[0]
            break
        else:
            ids[name] = await conn.scalar(langs.insert().values(name=name, url=url))
    return ids

async def insert_stats(conn, info, ids):
    now = datetime.datetime.now()
    year, month = now.year, now.month
    for (name, _, stars) in info:
        await conn.execute(stats.insert().values(lang_id=ids[name], stars=stars, year=year, month=month))
