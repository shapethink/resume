express = require "express"
app = express()

# bodyParser = require "body-parser"

app.set "port", process.env.PORT ? 9966

app.set "views", "src"
app.set "view engine", "jade"

bundle = require "./bundle"

app.get "/", (req, res) -> res.render "index"

app.get "/bundle.js", (request, response) ->
	bundle.pipe response

PouchDB = require "pouchdb"
PouchDB.debug.enable "pouchdb:*"
express_pouch = require "express-pouchdb"

debug = require "debug"
reqlog = debug "request"

# app.get /./, (req, res, next) ->
# 	reqlog req.originalUrl
# 	next()

app.use "/db", express_pouch(PouchDB)

db1 = new PouchDB "db_name"
db2 = new PouchDB "another_db"

for db in [db1, db2]
	db.info().then (info) -> console.log info

db1.sync db2, {live:true}
	.on "change", (stat) ->
		console.log stat

db2.get "active resume"
	.catch ->
		db2.put {_id:"active resume"}
			.then ->
				console.log "initial blank active resume created"
			.catch ->
				console.log "could not create blank active resume", arguments
	.then (doc) ->
		db2.put {_id:"active resume", _rev:doc._rev}
			.then ->
				console.log "active resume found and blanked"
			.catch ->
				console.log "could not blank existing active resume", arguments

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

console.log require("hello")()
