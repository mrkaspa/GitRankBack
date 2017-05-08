from aiopg.sa import create_engine
import sqlalchemy as sa

metadata = sa.MetaData()
user = sa.Table('user', metadata,
    sa.Column('user_id', sa.Integer, primary_key=True),
    sa.Column('user_name', sa.String(16), nullable=False),
    sa.Column('email_address', sa.String(60), key='email'),
    sa.Column('password', sa.String(20), nullable=False)
)
user_prefs = sa.Table('user_prefs', metadata,
    sa.Column('pref_id', sa.Integer, primary_key=True),
    sa.Column('user_id', sa.Integer, sa.ForeignKey('user.user_id'), nullable=False),
    sa.Column('pref_name', sa.String(40), nullable=False),
    sa.Column('pref_value', sa.String(100))
)

async def init_db():
    return await create_engine('postgresql://mrkaspa:@localhost/core_dev')

def setup_db():
    engine = sa.create_engine('postgresql://mrkaspa:@localhost/langs')
    metadata.create_all(engine)

async def store_info(info):
    engine = await init_db()
    query = '''SELECT * FROM services'''
    async with engine:
        async with engine.acquire() as conn:
            async for row in conn.execute(query):
                print(row.id)
