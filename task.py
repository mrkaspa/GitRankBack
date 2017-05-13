import asyncio
import uvloop
import aiohttp
from db import store_info
from pyquery import PyQuery as pq

showcase = 'https://github.com/showcases/programming-languages'


async def crawl():
    page = await curl(showcase)
    select = pq(page)
    repos = select('.repo-list-item')
    stars = repos('.f6.text-gray.mt-2 a.muted-link.mr-3:first').text()
    stars = [int(s.strip().replace(',', '')) for s in stars.split(' ')]
    urls = [s.get('href') for s in repos('h3.mb-1 a')]
    names = [u.split('/')[2] for u in urls]
    await store_info(zip(names, urls, stars))


async def curl(url):
    async with aiohttp.ClientSession() as session:
        async with session.request('GET', url) as response:
            return await response.content.read()


if __name__ == "__main__":
    asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
    loop = asyncio.get_event_loop()
    loop.run_until_complete(crawl())
