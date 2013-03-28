http = require "http"
querystring = require 'querystring'

defaults = 
	host:"api.xssnurse.com"
	port:80
	path:""
	method:"GET"

stored_key = "test_key"
stored_policy = "default"

module.exports = 

	setup: (key, policy="default") ->
		stored_policy = policy
		stored_key = key

	sanitize: (val, cbk) ->

		info = {}

		isString = typeof val is "string"

		info.options =
			key : stored_key

		if isString
			info =
				method: "GET"
				options:
					val : val
		else
			dataStringed = JSON.stringify val
			info = 
				data: dataStringed
				method: "POST"
				headers:
					'Content-Type':'application/json'
					'Content-Length': Buffer.byteLength(dataStringed, 'utf8')
					
		sendRequest info, (err, r) ->
			return cbk err, null if err?
			if isString
				cbk null, r
			else
				cbk null, JSON.parse r


sendRequest = (info, cbk) ->
	reqOptions =
		host: info.host or defaults.host
		port: info.port or defaults.port
		path: info.path or defaults.path
		method: info.method or defaults.method

	reqOptions.path += "?" + querystring.stringify info.options if info.options?

	request = http.request reqOptions

	request.on 'error', (err) ->
		cbk err, null if cbk?

	request.on 'response', (resp) ->
		body = ""

		resp.on 'data', (chunk) ->
			body += chunk;

		resp.on 'end', ->
			cbk null, body if cbk?

		resp.on 'error', (err) ->
			cbk err, null if cbk?

	request.setHeader key, value for key,value of info.headers?

	request.end info.data;