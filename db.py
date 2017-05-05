from aiopg.sa import create_engine
# import sqlalchemy as sa

async def init_db():
    return await create_engine(user='mrkaspa', database='core_dev',
        host='localhost', password='')

async def store_info(info):
    engine = await init_db()
    # query = '''SELECT * FROM services'''
    # async with engine:
    #     async with engine.acquire() as conn:
    #         async for row in conn.execute(query):
    #             print(row.id)
