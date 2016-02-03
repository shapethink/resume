d3 = require "d3"

d3.select "title"
	.text "Loaded!"

body = d3.select "body"

Resume = require "resume"

resume = require "data/json-resume-default"
resume.el = body.append("div").node()
resume = new Resume resume
resume.render()

io = require "socket.io-client"
sock = io()

sock.on "refresh", () ->
	d3.select("title").text "Reloading..."
	window.location.reload()
