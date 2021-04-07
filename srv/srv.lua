-- srv.lua
-- Part of nodemcu-httpserver
-- this file contains the functions that are available to user scripts via the global "srv" table 
-- Author: Marcos Kirsch, Siggi Langauf

local srv = {}

-- send HTTP headers
function srv.header(connection, code, extension, isGzipped, extraHeaders)
   
   local function getHTTPStatusString(code)
      local codez = { [200] = "OK", [400] = "Bad Request", [401] = "Unauthorized", [404] = "Not Found", [405] = "Method Not Allowed", [500] = "Internal Server Error", [501] = "Not Implemented", }
      local myResult = codez[code]
      -- enforce returning valid http codes all the way throughout?
      if myResult then return myResult else return "Not Implemented" end
   end

   local function getMimeType(ext)
      -- A few MIME types. Keep list short. If you need something that is missing, let's add it.
      local mt = {css = "text/css", gif = "image/gif", html = "text/html", ico = "image/x-icon", jpeg = "image/jpeg", 
         jpg = "image/jpeg", js = "application/javascript", json = "application/json", png = "image/png", xml = "text/xml"}
      if mt[ext] then return mt[ext] else return "application/octet-stream" end
   end

   local mimeType = getMimeType(extension)
   local statusString = getHTTPStatusString(code)
   
   connection:send("HTTP/1.0 " .. code .. " " .. statusString .. "\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType .. "\r\n")
   if isGzipped then
      connection:send("Cache-Control: private, max-age=2592000\r\nContent-Encoding: gzip\r\n")
   end
   if (extraHeaders) then
      for i, extraHeader in ipairs(extraHeaders) do
         connection:send(extraHeader .. "\r\n")
      end
   end

   connection:send("Connection: close\r\n\r\n")
   return statusString
end


-- handle sending static files to client.
-- Author: Gregor Hartmann
function srv.static (connection, req, args)

   local buffer = dofile("srvBuffer.lc"):new()
   srv.header(buffer, req.code or 200, args.ext, args.isGzipped)
   -- Send header and return fileInfo
   connection:send(buffer:getBuffer())
   
   return { file = args.file, sent = 0}
end

-- handle sending error pages to client.
-- Author: Marcos Kirsch, Gregor Hartmann
function srv.error (connection, req, args)
   local statusString = srv.header(connection, args.code, "html", false, args.headers)
   connection:send("<html><head><title>" .. args.code .. " - " .. statusString .. "</title></head><body><h1>" .. args.code .. " - " .. statusString .. "</h1></body></html>\r\n")
end


-- httpserver-basicauth.lua
-- Part of nodemcu-httpserver, authenticates a user using http basic auth.
-- Author: Sam Dieck
-- Returns true if the user/password match one of the users/passwords in httpserver-conf.lua.
-- Returns false otherwise.
function loginIsValid(user, pwd, users)
   if user == nil then return false end
   if pwd == nil then return false end
   if users[user] == nil then return false end
   if users[user] ~= pwd then return false end
   return true
end

-- Parse basic auth http header.
-- Returns the username if header contains valid credentials,
-- nil otherwise.
function srv.authenticate(header)
   local conf = dofile("httpserver-conf.lua")
   local credentials_enc = header:match("Authorization: Basic ([A-Za-z0-9+/=]+)")
   if not credentials_enc then
      return nil
   end
   local credentials = LFS.srvB64decode(credentials_enc)
   local user, pwd = credentials:match("^(.*):(.*)$")
   if loginIsValid(user, pwd, conf.auth.users) then
      print("httpserver-basicauth: User \"" .. user .. "\": Authenticated.")
      return user
   else
      print("httpserver-basicauth: User \"" .. user .. "\": Access denied.")
      return nil
   end
end

function srv.authErrorHeader()
   local conf = dofile("httpserver-conf.lua")
   return "WWW-Authenticate: Basic realm=\"" .. conf.auth.realm .. "\""
end


return srv
