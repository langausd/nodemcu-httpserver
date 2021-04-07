-- init.lua (LFS) - do the app initialization

-- provide a convenient/efficient global table named "srv" for
-- user-accessible and/or frequently used HTTP server functions
-- This global requires a bit less RAM than require()ing a real module
srv = LFS.srv()

-- Set up NodeMCU's WiFi
LFS.wifiSetup()

-- Start nodemcu-httpsertver
LFS.srvInit()

---------------------------------------------------
-- your application specific init code goes here --
---------------------------------------------------
