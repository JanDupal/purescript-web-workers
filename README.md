# PureScript & HTML5 Web Workers

# Building

```bash
$ pulp browserify -O --to dist/Main.js
$ pulp browserify -O -m Worker --to dist/Worker.js
```

# Running

Open ``dist/index.html`` in browser. E.g. via Python serving at [http://localhost:8080/](http://localhost:8080/):

```bash
$ cd dist
$ python -m SimpleHTTPServer 8080
```
