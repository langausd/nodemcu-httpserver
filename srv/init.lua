-- init.lua (LFS) - do the app initialization

-- provide a convenient/efficient global table named "srv" for
-- user-accessible and/or frequently used HTTP server functions
-- This global requires a bit less RAM than require()ing a real module
srv = LFS.srv()

-- reduce output by using dprint
-- possible levels:
-- 0 - emergency
-- 1 - errors
-- 2 - warnings
-- 3 - normal log output
-- 4 - debug output
-- 5 or higher - very chatty debugging
---------------------------------------

verbosity=1
function dprint(level, ...)
   if level <= verbosity then
      print(unpack(arg))
   end
end

lprint=dprint

-- Set up NodeMCU's WiFi
LFS.wifiSetup()

-- Start nodemcu-httpsertver
LFS.srvInit()

---------------------------------------------------
-- your application specific init code goes here --
---------------------------------------------------

function noop()
end

-- disable console output completely, so the UART port isn't cluttered
-- lprint=noop

