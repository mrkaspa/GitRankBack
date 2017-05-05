from sanic import Sanic
from sanic.response import html, json
from sanic.exceptions import NotFound
from sanic_jinja2 import SanicJinja2
import os

app = Sanic()
jinja = SanicJinja2(app)

@app.route("/")
async def test(request):
    return json({"hello": "world"})

@app.exception(NotFound)
def ignore_404s(request, exception):
    return jinja.render('index.html', request, url=request.url)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, workers=os.cpu_count())
