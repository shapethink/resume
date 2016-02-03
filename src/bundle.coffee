browserify = require "browserify"
jadeify = require "jadeify"
coffeeify = require "coffeeify"
module.exports = (callback) ->
	console.log "Bundling..."
	bundler = browserify "src/interface.coffee",
		extensions: [".jade", ".coffee"]
	bundler.transform jadeify, global:true
	bundler.transform coffeeify, global:true
	bundler.bundle (error, result) ->
		if error?
			console.log "Failed to build bundle:"
			console.log error
			module.exports.cached = """
				console.log("An error occurred.");
				setTimeout(function(){
					document.body.innerText = "An error occurred. Reload in 15 seconds.";
				}, 1);
				setTimeout(function(){
					window.location.reload();
				}, 15000);
			"""
		else
			module.exports.cached = result
		callback(error, result) if callback?

module.exports.cached = null
module.exports.pipe = (dest) ->
	if module.exports.cached?
		dest.send module.exports.cached
		dest.end()
	else
		module.exports (error, result) ->
			dest.send """console.log("freshly generated");""" + module.exports.cached
			dest.end()
