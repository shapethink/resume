express = require "express"
app = express()

app.set "port", process.env.PORT ? 9966

app.set "views", "src"
app.set "view engine", "jade"

bundle = require "./bundle"

app.get "/", (req, res) -> res.render "index"

app.get "/bundle.js", (request, response) ->
	bundle.pipe response

app.use express.static __dirname

http = require("http").Server app
io = require("socket.io")(http)

http.listen app.get("port"), ->
	console.log "Listening on http://localhost:#{app.get("port")}"

io.on "connection", (socket) ->
	console.log "connection arrived."

chokidar = require "chokidar"
chokidar.watch(__dirname).on "change", (path) ->
	console.log "[watch] change:#{path}"
	bundle ->
		io.emit "refresh"
