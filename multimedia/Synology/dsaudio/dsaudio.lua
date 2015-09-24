-- Copyright Erwan Velu 2015
-- This code is under GPL
--
--
-- Dependencies: Toolkit Framework (built-in)

-- Items to be adjusted
local user = "admin"
local password = "dsm42support"
local player_name = "Yamaha-TV (Airplay)"
local ip = "192.168.1.2"
local port = "5000"
local default_volume = 27
-- Don't touch that unless requested
local base_url = "http://" .. ip .. ":" .. port .. "/"
local player_id = nil
local sid = nil
local commandTimeOut = 3500
local debug = false
local version = "1.0"
local release = "beta4"
local session_url = "&session=AudioStation"
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Toolkit Framework, lua library extention for HC2, hope that it will be useful.
-- This Framework is an addon for HC2 Toolkit application in a goal to aid the integration.
-- Tested on Lua 5.1 with Fibaro HC2 3.572 beta
--
-- Version 1.0.4 [01-13-2014]
--
-- Use: Toolkit or Tk shortcut to access Toolkit namespace members.
--
-- Example:
-- Toolkit:trace("value is %d", 35); or Tk:trace("value is %d", 35);
-- Toolkit.assertArg("argument", arg, "string"); or Tk.assertArg("argument", arg, "string");
--
-- current release: http://krikroff77.github.io/Fibaro-HC2-Toolkit-Framework/
-- latest release: https://github.com/Krikroff77/Fibaro-HC2-Toolkit-Framework/releases/latest
--
-- Memory is preserved: The code is loaded only the first time in a virtual device 
-- main loop and reloaded only if application pool restarded.
--
-- Copyright (C) 2013-2014 Jean-Christophe Vermandé
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- at your option) any later version.
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
if not Toolkit then Toolkit = { 
	__header = "Toolkit",
	__version = "1.0.4",
	__luaBase = "5.1.0", 
	__copyright = "Jean-Christophe Vermandé",
	__licence = [[
	Copyright (C) 2013-2014 Jean-Christophe Vermandé

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses></http:>.
	]],
	__frameworkHeader = (function(self)
		self:traceEx("green", "-------------------------------------------------------------------------");
		self:traceEx("green", "-- HC2 Toolkit Framework version %s", self.__version);
		self:traceEx("green", "-- Current interpreter version is %s", self.getInterpreterVersion());
		self:traceEx("green", "-- Total memory in use by Lua: %.2f Kbytes", self.getCurrentMemoryUsed());
		self:traceEx("green", "-------------------------------------------------------------------------");
	end),
	-- chars
	chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
	-- hex
	hex = "0123456789abcdef",
	-- now(), now("*t", 906000490)
	-- system date shortcut
	now = os.date,
	-- toUnixTimestamp(t)
	-- t (table)		- {year=2013, month=12, day=20, hour=12, min=00, sec=00}
	-- return Unix timestamp
	toUnixTimestamp = (function(t) return os.time(t) end),
	-- fromUnixTimestamp(ts)
	-- ts (string/integer)	- the timestamp
	-- Example : fromUnixTimestamp(1297694343) -> 02/14/11 15:39:03
	fromUnixTimestamp = (function(s) return os.date("%c", ts) end),
	-- currentTime()
	-- return current time
	currentTime = (function() return tonumber(os.date("%H%M%S")) end),
	-- comparableTime(hour, min, sec)
	-- hour (string/integer)
	-- min (string/integer)
	-- sec (string/integer)
	comparableTime = (function(hour, min, sec) return tonumber(string.format("%02d%02d%02d", hour, min, sec)) end),
	-- isTraceEnabled
	-- (boolean)	get or set to enable or disable trace
	isTraceEnabled = true,
	-- isAutostartTrigger()
	isAutostartTrigger = (function() local t = fibaro:getSourceTrigger();return (t["type"]=="autostart") end),
	-- isOtherTrigger()
	isOtherTrigger = (function() local t = fibaro:getSourceTrigger();return (t["type"]=="other") end),
	-- raiseError(message, level)
	-- message (string)	- message
	-- level (integer)	- level
	raiseError = (function(message, level) error(message, level); end),
	-- colorSetToRgbwTable(colorSet)
	-- colorSet (string) - colorSet string
	-- Example: local r, g, b, w = colorSetToRgbwTable(fibaro:getValue(354, "lastColorSet"));
	colorSetToRgbw = (function(self, colorSet)
		self.assertArg("colorSet", colorSet, "string");
		local t, i = {}, 1;
		for v in string.gmatch(colorSet,"(%d+)") do t[i] = v; i = i + 1; end
		return t[1], t[2], t[3], t[4];
	end),
	-- isValidJson(data, raise)
	-- data (string)	- data
	-- raise (boolean)- true if must raise error
	-- check if json data is valid
	isValidJson = (function(self, data, raise)
		self.assertArg("data", data, "string");
		self.assertArg("raise", raise, "boolean");
		if (string.len(data)>0) then
			if (pcall(function () return json.decode(data) end)) then
			return true;
		else
			if (raise) then self.raiseError("invalid json", 2) end;
		end
	end
	return false;
end),
-- assert_arg(name, value, typeOf)
-- (string)	name: name of argument
-- (various)	value: value to check
-- (type)		typeOf: type used to check argument
assertArg = (function(name, value, typeOf)
	if type(value) ~= typeOf then
		Tk.raiseError("argument "..name.." must be "..typeOf, 2);
	end
end),
-- trace(value, args...)
-- (string)	value: value to trace (can be a string template if args)
-- (various)	args: data used with template (in value parameter)
trace = (function(self, value, ...)
	if (self.isTraceEnabled) then
		if (value~=nil) then        
			return fibaro:debug(string.format(value, ...));
		end
	end
end),
-- traceEx(value, args...)
-- (string)	color: color use to display the message (red, green, yellow)
-- (string)	value: value to trace (can be a string template if args)
-- (various)	args: data used with template (in value parameter)
traceEx = (function(self, color, value, ...)
	self:trace(string.format('<%s style="color:%s;">%s</%s>', "span", color, string.format(value, ...), "span"));
end),
-- getInterpreterVersion()
-- return current lua interpreter version
getInterpreterVersion = (function()
	return _VERSION;
end),
-- getCurrentMemoryUsed()
-- return total current memory in use by lua interpreter
getCurrentMemoryUsed = (function()
	return collectgarbage("count");
end),
-- trim(value)
-- (string)	value: the string to trim
trim = (function(s)
	Tk.assertArg("value", s, "string");
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
end),
-- isNaN(value)
-- return true is NaN or false if not NaN
isNaN = (function (x) return x ~= x end),
-- filterByPredicate(table, predicate)
-- table (table)		- table to filter
-- predicate (function)	- function for predicate
-- Description: filter a table using a predicate
-- Usage:
-- local t = {1,2,3,4,5};
-- local out, n = filterByPredicate(t,function(v) return v.item == true end);
-- return out -> {2,4}, n -> 2;
filterByPredicate = (function(table, predicate)
	Tk.assertArg("table", table, "table");
	Tk.assertArg("predicate", predicate, "function");
	local n, out = 1, {};
	for i = 1,#table do
		local v = table[i];
		if (v~=nil) then
			if predicate(v) then
				out[n] = v;
				n = n + 1;    
			end
		end
	end
	return out, #out;
end)
};Toolkit:__frameworkHeader();Tk=Toolkit;
end;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Toolkit.Net library extention
-- Toolkit.Net.HttpRequest provide http request with advanced functions
-- Tested on Lua 5.1 with HC2 3.572 beta
--
-- Copyright 2013 Jean-christophe Vermandé
-- Thanks to rafal.m for the decodeChunks function used when reponse body is "chunked"
-- http://en.wikipedia.org/wiki/Chunked_transfer_encoding
--
-- Version 1.0.3 [12-13-2013]
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
if not Toolkit then error("You must add Toolkit", 2) end
if not Toolkit.Net then Toolkit.Net = {
	-- private properties
	__header = "Toolkit.Net",
	__version = "1.0.3",
	__cr = string.char(13),
	__lf = string.char(10),
	__crLf = string.char(13, 10),
	__host = nil,
	__port = nil,
	-- private methods
	__trace = (function(v, ...)
		if (Toolkit.Net.isTraceEnabled) then Toolkit:trace(v, ...) end
	end),
	__writeHeader = (function(socket, data)
		assert(tostring(data) or data==nil or data=="", "Invalid header found: "..data);
		local head = tostring(data);
		socket:write(head..Toolkit.Net.__crLf);
		Toolkit.Net.__trace("%s.%s::request > Add header [%s]", 
		Toolkit.Net.__header, Toolkit.Net.__Http.__header, head);
	end),
	__decodeChunks = (function(a)
		resp = "";
		line = "0";
		lenline = 0;
		len = string.len(a);
		i = 1;
		while i<=len do
			c = string.sub(a, i, i);
			if (lenline==0) then
				if (c==Toolkit.Net.__lf) then
					lenline = tonumber(line, 16);
					if (lenline==null) then
						lenline = 0;
					end
					line = 0;
				elseif (c==Toolkit.Net.__cr) then
					lenline = 0;
				else
					line = line .. c;
				end
			else
				resp = resp .. c;
				lenline = lenline - 1;
			end
			i = i + 1;
		end
		return resp;
	end),
	__readHeader = (function(data)
		if data == nil then
			error("Couldn't find header");
		end
		local buffer = "";
		local headers = {};
		local i, len = 1, string.len(data);
		while i<=len do
			local a = data:sub(i,i) or "";
			local b = data:sub(i+1,i+1) or "";
			if (a..b == Toolkit.Net.__crLf) then
				i = i + 1;
				table.insert(headers, buffer);
				buffer = "";
			else
				buffer = buffer..a;     
			end
			i = i + 1;
		end
		return headers;
	end),
	__readSocket = (function(socket)
		local err, len = 0, 1;
		local buffer, data = "", "";
		while (err==0 and len>0) do
			data, err = socket:read();
			len = string.len(data);
			buffer = buffer..data;
		end
		return buffer, err;
	end),
	__Http = {
		__header = "HttpRequest",
		__version = "1.0.3",    
		__tcpSocket = nil,
		__timeout = 250,
		__waitBeforeReadMs = 25,
		__isConnected = false,
		__isChunked = false,
		__url = nil,
		__method = "GET",  
		__headers = {},
		__body = nil,
		__authorization = nil,
		-- Toolkit.Net.HttpRequest:setBasicAuthentication(username, password)
		-- Sets basic credentials for all requests.
		-- username (string) – credentials username
		-- password (string) – credentials password
		setBasicAuthentication = (function(self, username, password)
			Toolkit.assertArg("username", username, "string");
			Toolkit.assertArg("password", password, "string");
			--see: http://en.wikipedia.org/wiki/Basic_access_authentication
			self.__authorization = Toolkit.Crypto.Base64:encode(tostring(username..":"..password));
		end),
		-- Toolkit.Net.HttpRequest:setBasicAuthenticationEncoded(base64String)
		-- Sets basic credentials already encoded. Avoid direct exposure for information.
		-- base64String (string)	- username and password encoded with base64
		setBasicAuthenticationEncoded = (function(self, base64String)
			Toolkit.assertArg("base64String", base64String, "string");
			self.__authorization = base64String;
		end),
		-- Toolkit.Net.HttpRequest:setWaitBeforeReadMs(ms)
		-- Sets ms
		-- ms (integer) – timeout value in milliseconds
		setWaitBeforeReadMs = (function(self, ms)
			Toolkit.assertArg("ms", ms, "integer");
			self.__waitBeforeReadMs = ms;
			Toolkit.Net.__trace("%s.%s::setWaitBeforeReadMs > set to %d ms", 
			Toolkit.Net.__header, Toolkit.Net.__Http.__header, ms);
		end),
		-- Toolkit.Net.HttpRequest.getWaitBeforeReadMs()
		-- Returns the value in milliseconds
		getWaitBeforeReadMs = (function(self)
			return self.__waitBeforeReadMs;
		end),
		-- Toolkit.Net.HttpRequest.setReadTimeout(ms)
		-- Sets timeout
		-- ms (integer) – timeout value in milliseconds
		setReadTimeout = (function(self, ms)
			Toolkit.assertArg("ms", ms, "number");
			self.__timeout = ms;
			Toolkit.Net.__trace("%s.%s::setReadTimeout > Timeout set to %d ms", 
			Toolkit.Net.__header, Toolkit.Net.__Http.__header, ms);
		end),
		-- Toolkit.Net.HttpRequest.getReadTimeout()
		-- Returns the timeout value in milliseconds
		getReadTimeout = (function(self)
			return self.__timeout;
		end),
		-- Toolkit.Net.HttpRequest:disconnect()
		-- Disconnect the socket used by httpRequest
		disconnect = (function(self)
			self.__tcpSocket:disconnect();
			self.__isConnected = false;
			Toolkit.Net.__trace("%s.%s::disconnect > Connected: %s", 
			Toolkit.Net.__header, Toolkit.Net.__Http.__header, tostring(self.__isConnected));
		end),
		-- Toolkit.Net.HttpRequest:request(method, uri, headers, body)
		-- method (string)	- method used for the request
		-- uri (string)		- uri used for the request
		-- headers (table)	- headers used for the request (option)
		-- body (string)	- data sent with the request (option)
		request = (function(self, method, uri, headers, body)
			-- validation
			Toolkit.assertArg("method", method, "string");
			assert(method=="GET" or method=="POST" or method=="PUT" or method=="DELETE");
			assert(uri~=nil or uri=="");
			self.__isChunked = false;
			self.__tcpSocket:setReadTimeout(self.__timeout);
			self.__url = uri;
			self.__method = method;
			self.__headers = headers or {};
			self.__body = body or nil;

			--local r = self.__method.." http://"..Toolkit.Net.__host..self.__url.." HTTP/1.1";
			--patch 18/12/2013
			local r = self.__method.." "..self.__url.." HTTP/1.1";
			Toolkit.Net.__trace("%s.%s::request > %s with method %s", 
			Toolkit.Net.__header, Toolkit.Net.__Http.__header, self.__url, self.__method);
			local p = "";
			if (Toolkit.Net.__port~=nil) then
				p = ":"..tostring(Toolkit.Net.__port);
			end
			local h = "Host: "..Toolkit.Net.__host .. p;
			-- write to socket headers method a host!
			Toolkit.Net.__writeHeader(self.__tcpSocket, r);
			Toolkit.Net.__writeHeader(self.__tcpSocket, h);
			-- add headers if needed

			for i = 1, #self.__headers do
				Toolkit.Net.__writeHeader(self.__tcpSocket, self.__headers[i]);
			end
			if (self.__authorization~=nil) then
				Toolkit.Net.__writeHeader(self.__tcpSocket, "Authorization: Basic "..self.__authorization);
			end
			-- add data in body if needed
			if (self.__body~=nil) then
				Toolkit.Net.__writeHeader(self.__tcpSocket, "Content-Length: "..string.len(self.__body));
				Toolkit.Net.__trace("%s.%s::request > Body length is %d", 
				Toolkit.Net.__header, Toolkit.Net.__Http.__header, string.len(self.__body));
			end
			self.__tcpSocket:write(Toolkit.Net.__crLf..Toolkit.Net.__crLf);
			-- write body
			if (self.__body~=nil) then
				self.__tcpSocket:write(self.__body);
			end
			-- sleep to help process
			fibaro:sleep(self.__waitBeforeReadMs);
			-- wait socket reponse
			local result, err = Toolkit.Net.__readSocket(self.__tcpSocket);
			Toolkit.Net.__trace("%s.%s::receive > Length of result: %d", 
			Toolkit.Net.__header, Toolkit.Net.__Http.__header, string.len(result));
			-- parse data
			local response, status;
			local cookie = "hello";
			if (string.len(result)>0) then
				local _flag = string.find(result, Toolkit.Net.__crLf..Toolkit.Net.__crLf);
				local _rawHeader = string.sub(result, 1, _flag + 2);
				if (string.len(_rawHeader)) then
					status = string.sub(_rawHeader, 10, 13);
					Toolkit.Net.__trace("%s.%s::receive > Status %s", Toolkit.Net.__header, 
					Toolkit.Net.__Http.__header, status);
					Toolkit.Net.__trace("%s.%s::receive > Length of headers reponse %d", Toolkit.Net.__header, 
					Toolkit.Net.__Http.__header, string.len(_rawHeader));
					__headers = Toolkit.Net.__readHeader(_rawHeader);
					for k, v in pairs(__headers) do
						--Toolkit.Net.__trace("raw #"..k..":"..v)
						if (string.find(string.lower( v or ""), "chunked")) then
							self.__isChunked = true;
							Toolkit.Net.__trace("%s.%s::receive > Transfer-Encoding: chunked", 
							Toolkit.Net.__header, Toolkit.Net.__Http.__header, string.len(result));
							-- Modification pour récupérer le cookie.
							-- Ofwood Jan 2015
						elseif (string.find(string.lower( v or ""), "cookie")) then				
							cookie = string.sub(v, 12)
							Toolkit.Net.__trace("%s.%s::receive > Cookie: %s", 
							Toolkit.Net.__header, Toolkit.Net.__Http.__header, cookie);                
						end
					end
				end
				local _rBody = string.sub(result, _flag + 4);
				--Toolkit.Net.__trace("Length of body reponse: " .. string.len(_rBody));
				if (self.__isChunked) then
					response = Toolkit.Net.__decodeChunks(_rBody);
					err = 0;
				else
					response = _rBody;
					err = 0;
				end
			end
			-- return budy response
			return response, status, err, cookie;
		end),
		-- Toolkit.Net.HttpRequest.version()
		-- Return the version
		version = (function()
			return Toolkit.Net.__Http.__version;
		end),
		-- Toolkit.Net.HttpRequest:dispose()
		-- Try to free memory and resources 
		dispose = (function(self)      
			if (self.__isConnected) then
				self.__tcpSocket:disconnect();
			end
			self.__tcpSocket = nil;
			self.__url = nil;
			self.__headers = nil;
			self.__body = nil;
			self.__method = nil;
			if pcall(function () assert(self.__tcpSocket~=Net.FTcpSocket) end) then
			Toolkit.Net.__trace("%s.%s::dispose > Successfully disposed", 
			Toolkit.Net.__header, Toolkit.Net.__Http.__header);
		end
		-- make sure all free-able memory is freed
		collectgarbage("collect");
		Toolkit.Net.__trace("%s.%s::dispose > Total memory in use by Lua: %.2f Kbytes", 
		Toolkit.Net.__header, Toolkit.Net.__Http.__header, collectgarbage("count"));
	end)
},
-- Toolkit.Net.isTraceEnabled
-- true for activate trace in HC2 debug window
isTraceEnabled = false,
-- Toolkit.Net.HttpRequest(host, port)
-- Give object instance for make http request
-- host (string)	- host
-- port (intager)	- port
-- Return HttpRequest object
HttpRequest = (function(host, port)
	assert(host~=Toolkit.Net, "Cannot call HttpRequest like that!");
	assert(host~=nil, "host invalid input");
	assert(port==nil or tonumber(port), "port invalid input");
	-- make sure all free-able memory is freed to help process
	collectgarbage("collect");
	Toolkit.Net.__host = host;
	Toolkit.Net.__port = port;
	local _c = Toolkit.Net.__Http;
	_c.__tcpSocket = Net.FTcpSocket(host, port);
	_c.__isConnected = true;
	Toolkit.Net.__trace("%s.%s > Total memory in use by Lua: %.2f Kbytes", 
	Toolkit.Net.__header, Toolkit.Net.__Http.__header, collectgarbage("count"));
	Toolkit.Net.__trace("%s.%s > Create Session on port: %d, host: %s", 
	Toolkit.Net.__header, Toolkit.Net.__Http.__header, port, host);
	return _c;
end),
-- Toolkit.Net.version()
version = (function()
	return Toolkit.Net.__version;
end)
};

Toolkit:traceEx("red", Toolkit.Net.__header.." loaded in memory...");
-- benchmark code
if (Toolkit.Debug) then Toolkit.Debug:benchmark(Toolkit.Net.__header.." lib", "elapsed time: %.3f cpu secs\n", "fragment", true); end;
end;


function deep_print(tbl)
	for i, v in pairs(tbl) do
		if type(v) == "table" then
			deep_print(v)
		else
			print(i, v)
		end
	end
end

function do_http_request( args )
	--http.request(url [, body])
	--http.request{
	--  url = string,
	--  [sink = LTN12 sink,]
	--  [method = string,]
	--  [headers = header-table,]
	--  [source = LTN12 source],
	--  [step = LTN12 pump step,]
	--  [proxy = string,]
	--  [redirect = boolean,]
	--  [create = function]
	--}
	--
	--
	local resp, r = {}, {}
	local headers = args.headers;
	local req_body = args.source;
	local retry_count = 1;
	if args.retry then
		if args.retry == true then
			retry_count = 3
		end
	end
	if args.endpoint then
		local params = ""
		--if args.method == "POST" and headers == nil then
		headers = {
			"Content-Type: application/x-www-form-urlencoded",
		};
		if sid ~= nil then
			headers[2]="Cookie: stay_login=0; id=" .. sid ;
		end
		--end

		if args.method == nil or args.method == "GET" then
			if args.params then
				for i, v in pairs(args.params) do
					params = params .. i .. "=" .. v .. "&"
				end
			end
		end
		params = string.sub(params, 1, -2)
		local url = ""
		-- if params then url = args.endpoint .. "?" .. args.source else url = args.endpoint end
		url = args.endpoint .. "?" .. args.source
		if debug == true then
			fibaro:debug("url = " .. url)
			fibaro:debug("body = " .. req_body)
		end

		local response, status, errorCode, cookie

		for loop=1,retry_count do
			local httpClient = Toolkit.Net.HttpRequest(ip, port);
			httpClient:setReadTimeout(commandTimeOut);

			-- httpClient:request avec injection de X-Context et du Cookie dans les headers	
			response, status, errorCode, cookie = httpClient:request(args.method, url, headers, args.source);

			-- disconnect socket and release memory...
			httpClient:disconnect();
			httpClient:dispose();

			-- If we do have a valid response, let's continue
			-- unless let's make the retry loop
			if (string.len(response) > 53000) then
				fibaro:debug("WARNING : response lenght is too long, retrying")
				response = ''
			end
			if (response == nil or response == '') and retry_count > 1 then
				fibaro:debug("Failed, let's retry " .. loop .."/" .. retry_count)
				fibaro:sleep(250)
			else
				if (debug == true) then
					fibaro:debug("Returning songs, string length = " .. string.len(response))
				end
				break
			end
		end
		--client, code, headers, status = http.request{url=url, sink=ltn12.sink.table(resp),
		--                                           method=args.method or "GET", headers=headers, source=args.source,
		--                                          step=args.step, proxy=args.proxy, redirect=args.redirect, create=args.create }
		r['code'], r['status'], r['response'] = errorCode, status, response 
	else
		error("endpoint is missing")
	end
	return r
end

function string:split(delimiter)
	local result = { }
	local from = 1
	local delim_from, delim_to = string.find( self, delimiter, from )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from )
	end
	table.insert( result, string.sub( self, from ) )
	return result
end

function check_success(response_data)
	if (string.find(response_data['response'],'"success":true')) then
		return true;
	end
	return false
end
-- creates string source
function source_string(s)
	if s then
		local i = 1
		return function()
			local chunk = string.sub(s, i, i+2048-1)
			i = i + 2048
			if chunk ~= "" then return chunk
			else return nil end
		end
	else return nil end
end

function login()
	local endpoint="/webapi/auth.cgi"
	local req_body= "api=SYNO.API.Auth&version=2&method=login&account=" .. user .. "&passwd=" .. password .. session_url.."&format=cookie"
	local response = do_http_request{endpoint=endpoint, method="GET", size=#req_body, source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("Cannot login to " .. base_url .. "with user=" .. user .. " and password=" .. password)
		return nil
	end

	local sid = nil;
	if (string.find(response['response'],'"data":')) then
		sid = string.match(response['response'], '.*sid":"(.*)"}.*');
	end

	if (check_success(response) == false) then
		fibaro:debug("Cannot authentificate on " .. base_url .. "with user=" .. user .. " and password=" .. password .. "");
	end

	return sid
end

function logout()
	local endpoint="/webapi/auth.cgi"
	local req_body= "api=SYNO.API.Auth&version=1&method=logout".. session_url
	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("logout: Cannot communicate with " .. base_url )
		return false
	end

	return check_success(response)
end


function get_random_songs(args)
	quantity=100
	if args then
		if args.quantity then
			quantity=args.quantity
		end
	end
	local songs = nil
	local endpoint="/webapi/AudioStation/song.cgi"
	-- raw dump :   limit=100&method=list&library=shared&api=SYNO.AudioStation.Song&additional=song_tag%2Csong_audio%2Csong_rating&sort_by=random&version=2
	local req_body="limit=".. quantity .."&method=list&library=shared&api=SYNO.AudioStation.Song&additional=song_tag,song_audio,song_rating&sort_by=random&version=2"
	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body, retry=true}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("add_random_songs: Cannot communicate with " .. base_url )
		return songs
	end

	if (check_success(response) == false) then
		return songs
	end

	local num_songs = 0

	for music_id in string.gmatch(response['response'], '"id":"(music_%d+)"') do
		if num_songs == 0 then
			songs = music_id
		else
			songs = songs .."%2C" .. music_id
		end
		num_songs = num_songs + 1
	end
	fibaro:debug("Got " .. num_songs .. " songs from the library")
	return songs
end

function get_status()
	if player_id == nil then
		return nil
	end
	local endpoint="/webapi/AudioStation/remote_player_status.cgi"
	local req_body="api=SYNO.AudioStation.RemotePlayerStatus&method=getstatus&id=" .. player_id .."&additional=song_tag%2Csong_audio%2Csubplayer_volume&version=1"
	--raw dump https://192.168.1.2:5001/webapi/AudioStation/remote_player_status.cgi?_dc=1441828916457&SynoToken=9vE1YlwNO7s0g&api=SYNO.AudioStation.RemotePlayerStatus&method=getstatus&id=00A0DE8F41F8&additional=song_tag%2Csong_audio%2Csubplayer_volume&version=1

	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("get_status: Cannot communicate with " .. base_url )
		return nil
	end
	if check_success(response) == false then
		return nil;
	end

	return json.decode(response['response'])
end

function get_playlist_size()
	local status = get_status()
	if status then
		return status.data["playlist_total"]
	end
	return -1
end


function extract_current_volume(status)
	if status then
		return status.data["volume"]
	end
	return 0
end

function extract_current_title(status)
	if status then
		if type(status.data.song) ~= "userdata" then
			title = status.data.song["title"]
			if status.data.song.additional.song_tag["artist"] then
				title = title .. " - " .. status.data.song.additional.song_tag["artist"]
			end
			return title
		end
	end
	return ""
end


function get_current_volume()
	return extract_current_volume(get_status())
end

function delete_playlist()
	local playlist_size = get_playlist_size()
	fibaro:debug("delete_playlist: About to delete " .. playlist_size .. " songs from playlist")
	local endpoint="/webapi/AudioStation/remote_player.cgi"
	-- raw dump api=SYNO.AudioStation.RemotePlayer&method=updateplaylist&library=shared&id=00A0DE8F41F8&offset=0&limit=6&play=false&version=2&updated_index=-2
	local req_body="api=SYNO.AudioStation.RemotePlayer&method=updateplaylist&library=shared&id=".. player_id .."&offset=0&limit="..playlist_size .."&play=false&version=2&updated_index=-2"
	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("delete_playlist: Cannot communicate with " .. base_url )
		return false
	end

	return check_success(response)
end

function add_songs_to_playlist( args )
	local playlist_name = "shared"
	if args.playlist ~= nil then
		playlist_name = args.playlist
	end
	fibaro:debug("Adding songs to " .. playlist_name .." playlist")
	local endpoint="/webapi/AudioStation/remote_player.cgi"
	-- raw dump : api=SYNO.AudioStation.RemotePlayer&method=updateplaylist&library=shared&id=00A0DE8F41F8&offset=0&limit=0&play=true&version=2&songs=music_92991%2Cmusic_101957%2Cmusic_99850%2Cmusic_100946%2Cmusic_94461%2Cmusic_90734%2Cmusic_99190%2Cmusic_93974%2Cmusic_89252%2Cmusic_101838%2Cmusic_96467%2Cmusic_90146%2Cmusic_99114%2Cmusic_105745%2Cmusic_106421%2Cmusic_107979%2Cmusic_101295%2Cmusic_109016%2Cmusic_93710%2Cmusic_106160%2Cmusic_99439%2Cmusic_96890%2Cmusic_104606%2Cmusic_98656%2Cmusic_89201%2Cmusic_95571%2Cmusic_90466%2Cmusic_91366%2Cmusic_103793%2Cmusic_96785%2Cmusic_100434%2Cmusic_103773%2Cmusic_107857%2Cmusic_107255%2Cmusic_91556%2Cmusic_111901%2Cmusic_94906%2Cmusic_98338%2Cmusic_104100%2Cmusic_88904%2Cmusic_91795%2Cmusic_94756%2Cmusic_96072%2Cmusic_105218%2Cmusic_105176%2Cmusic_105580%2Cmusic_96733%2Cmusic_97150%2Cmusic_99861%2Cmusic_97841%2Cmusic_100186%2Cmusic_106705%2Cmusic_98084%2Cmusic_94850%2Cmusic_94248%2Cmusic_107514%2Cmusic_104459%2Cmusic_90621%2Cmusic_105858%2Cmusic_94969%2Cmusic_94280%2Cmusic_101434%2Cmusic_99830%2Cmusic_108921%2Cmusic_97369%2Cmusic_99210%2Cmusic_101400%2Cmusic_88990%2Cmusic_101772%2Cmusic_104251%2Cmusic_103201%2Cmusic_97200%2Cmusic_90398%2Cmusic_89702%2Cmusic_92789%2Cmusic_91109%2Cmusic_100605%2Cmusic_106710%2Cmusic_110166%2Cmusic_103803%2Cmusic_106290%2Cmusic_112508%2Cmusic_97676%2Cmusic_109301%2Cmusic_96993%2Cmusic_94053%2Cmusic_90892%2Cmusic_98786%2Cmusic_95868%2Cmusic_101137%2Cmusic_108098%2Cmusic_106492%2Cmusic_102488%2Cmusic_108661%2Cmusic_91074%2Cmusic_89510%2Cmusic_105946%2Cmusic_104231%2Cmusic_97420%2Cmusic_90727&containers_json=%5B%5D
	local req_body="api=SYNO.AudioStation.RemotePlayer&method=updateplaylist&library=" .. playlist_name .. "&id=" .. player_id .. "&offset=0&limit=0&play=true&version=2&songs=".. args.songs .. "&containers_json=%5B%5D"
	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("add_songs_to_playlist: Cannot communicate with " .. base_url )
		return false
	end
	return check_success(response)

end

function get_playlist()
	local endpoint="/webapi/AudioStation/remote_player.cgi"
	-- raw dump     api=SYNO.AudioStation.RemotePlayer&method=getplaylist&id=00A0DE8F41F8&additional=song_tag%2Csong_audio%2Csong_rating&offset=0&limit=8192&version=2
	local req_body="api=SYNO.AudioStation.RemotePlayer&method=getplaylist&id=" .. player_id .. "&additional=song_tag%2Csong_audio%2Csong_rating&offset=0&limit=8192&version=2"
	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("get_playlist: Cannot communicate with " .. base_url )
		return nil
	end

	if (check_success(response) == false) then
		return nil
	end
	return json.decode(response['response'])
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end
 
function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end
 
function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

function find_player_id(lookup_name)
	local endpoint="/webapi/AudioStation/remote_player.cgi"
	local req_body="api=SYNO.AudioStation.RemotePlayer&method=list&version=2"
	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("stop: Cannot communicate with " .. base_url )
		return nil
	end

	players = json.decode(response['response'])
	if players.data then
		if players.data.players then
			for i = 1, #players.data.players do
				player = players.data.players[i]
				fibaro:debug("Found player '".. player.name .. "', id = " .. player.id)
				if string.lower(player.name) == string.lower(lookup_name) then
					return player.id
				end
			end
		end
	end

	return nil
end

function simple_control(action)
	local endpoint = "/webapi/AudioStation/remote_player.cgi"
	local req_body = "api=SYNO.AudioStation.RemotePlayer&method=control&id=" .. player_id .. "&version=2&action=" .. action
	-- raw dump : api=SYNO.AudioStation.RemotePlayer&method=control&id=00A0DE8F41F8&version=2&action=next
	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("simple_control(" .. action .. "): Cannot communicate with " .. base_url )
		return false
	end

	return check_success(response)
end

function next_song()
	fibaro:debug("Getting next song for player " .. player_name )
	return simple_control("next")
end

function previous_song()
	fibaro:debug("Getting previous song for player " .. player_name )
	return simple_control("prev")
end

function pause()
	fibaro:debug("Pausing song for player " .. player_name )
	return simple_control("pause")
end

function stop()
	fibaro:debug("Stopping player " .. player_name )
	return simple_control("stop")
end

function play(position)
	fibaro:debug("Starting player " .. player_name )
	if (position ~= nil) then
		return simple_control("play&value=" .. position)
	else
		return simple_control("play")
	end
end

function set_volume( volume )
	if volume < 0 then
		volume = 0
	end

	if volume > 100 then
		volume = 100
	end

	fibaro:debug("Adjusting volume of " .. player_name .. " to " .. volume .. "%")
	local endpoint = "/webapi/AudioStation/remote_player.cgi"
	local req_body = "api=SYNO.AudioStation.RemotePlayer&method=control&id=" .. player_id .. "&version=2&action=set_volume&value=" .. volume
	--raw dump : api=SYNO.AudioStation.RemotePlayer&method=control&id=00A0DE8F41F8&version=2&action=set_volume&value=36
	local response = do_http_request{endpoint=endpoint, method="GET", source=req_body}
	if (tonumber(response['status']) ~= 200) then
		fibaro:debug("set_volume: Cannot communicate with " .. base_url )
		return false
	end

	return check_success(response)
end

local clock = os.clock
function sleep(n)  -- seconds
	local t0 = clock()
	while clock() - t0 <= n do end
end

function stream_random_songs(args)
	songs = get_random_songs{quantity=args.quantity}
	if (songs == nil) then
		fibaro:debug("Cannot add random songs !")
		return
	end

	if (delete_playlist() == false) then
		fibaro:debug("Cannot delete playlist")
		return
	end

	if (add_songs_to_playlist{songs=songs} == false) then
		fibaro:debug("Cannot add songs to playlist")
		return
	end

	if (stop() == false) then
		fibaro:debug("Cannot stop music !")
		return
	end

	if (play(0) == false) then
		fibaro:debug("Cannot play music !")
		return
	end

end


function connect()
	sid=login()
	if (sid == nil) then
		fibaro:debug("Cannot find a valid SID in the response");
		return false
	end

	fibaro:debug("### Connected to DSAudio with user " .. user .. " ! ###");

	player_id = find_player_id(player_name)
	if player_id == nil then
		fibaro:debug("Cannot find any player matching '".. player_name .. "', Exiting !")
		return false
	end

	fibaro:debug("Using player " .. player_name)
	return true
end


fibaro:debug("<< DSAudio plugin version " .. version .. "-" .. release .. " by Erwan Velu >>")
fibaro:debug("<< Download the latest version at https://github.com/ErwanAliasr1/hc2-addons >>")
fibaro:debug("<< Enjoy ! >>")
fibaro:setGlobal("DSAudio_Control", "nop")
if (fibaro:getGlobalValue("DSAudio_Control") ~= "nop") then
	fibaro:debug("Please create a DSAudio_Control global variable, Exiting !")
	return
end
if connect() == true then
	fibaro:debug("Entering main loop")
	local current_volume = 0
	while true do
		local control = fibaro:getGlobalValue("DSAudio_Control")
		if control == "play" then
			fibaro:debug('Received Play request')
			fibaro:setGlobal("DSAudio_Control", "nop")
			play()
		else if control == "stop" then
			fibaro:debug('Received Stop request')
			fibaro:setGlobal("DSAudio_Control", "nop")
			stop()
		else if control == "pause" then
			fibaro:debug('Received Pause request')
			fibaro:setGlobal("DSAudio_Control", "pause")
			pause()
		else if control == "previous" then
			fibaro:debug('Received Previous request')
			fibaro:setGlobal("DSAudio_Control", "nop")
			previous_song()
		else if control == "next" then
			fibaro:debug('Received Next request')
			fibaro:setGlobal("DSAudio_Control", "nop")
			next_song()
		else if string.match(control, "volume_%d+") then
			fibaro:debug('Received Volume request')
			fibaro:setGlobal("DSAudio_Control", "nop")
			current_volume = tonumber(string.match(control, "volume_(%d+)"))
			set_volume(current_volume)
		else if control == "random" then
			fibaro:debug('Received Random request')
			fibaro:setGlobal("DSAudio_Control", "nop")
			stream_random_songs{quantity=75}
		end
		end
		end
		end
		end
		end
		end
		-- Did we got another action since ?
		-- If so, let's handle it right now
		control = fibaro:getGlobalValue("DSAudio_Control")
		if (control == "nop") then
			-- Nothing required, don't flood NAS with get_status()
			fibaro:sleep(250)
			current_status = get_status()
			if current_status == nil then
				fibaro:debug("Lost link with DSAudio, trying to reconnect")
				connect()
			else
				fibaro:call(fibaro:getSelfId(), "setProperty", "ui.label_3_4.value", extract_current_title(current_status))
				new_volume = extract_current_volume(current_status)
				if new_volume >= 0 then
					if new_volume ~= current_volume then
						fibaro:call(fibaro:getSelfId(), "setProperty", "ui.slider_1_1.value", new_volume)
						current_volume = new_volume
					end
				end
			end
		end
	end	
	-- If you put that code in a slider, just use the following
	--set_volume(_sliderValue_)

	-- If you put that code in a set of buttons, just use the following:
	-- stop()
	-- previous_song()
	-- next_song()
	-- pause()
	-- play()

	-- set_volume(default_volume)
	-- stream_random_songs{quantity=75}
end

if (logout() == false) then
	fibaro:debug("Cannot logout properly")
else
	fibaro:debug("No more connected with DSAudio")
end
