#!/usr/bin/env lua
-- Client for the Splay Distributed DB
-- Created by José Valerio
-- Neuchâtel 2011

-- BEGIN LIBRARIES
--for the communication over HTTP
local socket = require"socket"
local http   = require"socket.http"
local ltn12  = require"ltn12"
--for hashing
require"sha1"
--for picking a random port
misc = require"splay.misc"

-- END LIBRARIES

-- FUNCTIONS

function send_put_bucket(access_key_id, bucket, port, technique)
	
	local response_body = {}
	local response_to_discard = nil
	local response_status = nil
	local response_headers = nil
	local response_status_line = nil

	if technique == 1 then
		response_to_discard, response_status, response_headers, response_status_line = http.request({
			url = "http://127.0.0.1:"..port.."/"..bucket,
			method = "PUT",
			headers = {
				["Host"] = "splay-project.org",
				["Authorization"] = access_key_id
				},
			source = ltn12.source.empty(),
			sink = ltn12.sink.table(response_body)
		})
	else
		response_to_discard, response_status, response_headers, response_status_line = http.request({
			url = "http://127.0.0.1:"..port.."/",
			method = "PUT",
			headers = {
				["Host"] = bucket..".splay-project.org",
				["Authorization"] = access_key_id
				},
			source = ltn12.source.empty(),
			sink = ltn12.sink.table(response_body)
		})
	end

	if response_status == 200 then
		print("PUT done.")
	else
		print("Error "..response_status..":\n"..response_body[1])
	end
end

dofile("ports.lua")
math.randomseed(os.time())
if arg[3] then
	port = arg[3]
else
	port = misc.random_pick(ports)
end
send_put_bucket(arg[1], arg[2], port, tonumber(arg[4]))