window.d3 = d3 = require "d3"

d3.select "title"
	.text "Loaded!"

Debug = require "debug"

debug =
	info: new Debug("info")

localStorage.debug = "info"
debug.info "test:", __filename

body = d3.select "body"

resume = require "data/json-resume-default"
resume._id = "active resume"
Subject = require "resume"
data = resume

subject = new Subject data
view = new subject.view model:subject, el: body.append("div").node()
view.render()

io = require "socket.io-client"
sock = io()

sock.on "refresh", () ->
	d3.select("title").text "Reloading..."
	window.location.reload()

PouchDB = require "pouchdb"

local_db = new PouchDB "/db"
remote_db = new PouchDB "http://localhost:9966/db/db_name"

local_db.get "active resume"
	.then (resume) -> subject.set resume
	.catch (e) ->
		if e.status is 404
			local_db.put {_id:"active resume"}
				.then ->
					console.log "initial blank active resume created"
				.catch ->
					console.log "could not create blank active resume", arguments

subject.on "change", ->
	local_db.get "active resume"
		.then (data) ->
			new_data = subject.serialize()
			data = Object.assign data ? {_id:"active resume"}, new_data
			return local_db.put data
		.then -> console.log "updated subject"
		.catch console.log.bind console

sync = local_db.sync remote_db,
	live: true
	retry: true

sync.on "change", (result) ->
	subject.set result.change.docs[0]

sync.on "error", ->
	console.log "sync error", arguments

window.touch = (key) ->
	local_db.get key
		.then (doc) ->
			doc.lastUpdated = Date.now()
			return local_db.put doc
		.then -> console.log "updated local_db"
		.catch console.log.bind console
