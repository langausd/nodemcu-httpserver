-- httpserver.init.lua
-- Part of nodemcu-httpserver, launches the server.
-- Author: Marcos Kirsch

-- Function for starting the server.
-- If you compiled the mdns module, then it will also register with mDNS.
local startServer = function(ip)
   local conf = dofile('httpserver-conf.lua')
   --if ( LFS.httpserver(conf['general']['port']) ) then
   if (LFS.httpserver()(conf['general']['port'])) then
	  lprint(3,"nodemcu-httpserver running at:")
      lprint(3,"   http://" .. ip .. ":" ..  conf['general']['port'])
      if (mdns) then
         mdns.register(conf['mdns']['hostname'], { description=conf['mdns']['description'], service="http", port=conf['general']['port'], location=conf['mdns']['location'] })
         print ('   http://' .. conf['mdns']['hostname'] .. '.local.:' .. conf['general']['port'])
      end
   end
   conf = nil
end

if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then

   -- Connect to the WiFi access point and start server once connected.
   -- If the server loses connectivity, server will restart.
   wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(args)
      lprint(3,"Connected to WiFi Access Point. Got IP: " .. args["IP"])
      startServer(args["IP"])
      wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(args)
         lprint(2,"Lost connectivity! Restarting...")
         node.restart()
      end)
   end)

   -- What if after a while (30 seconds) we didn't connect? Restart and keep trying.
   local watchdogTimer = tmr.create()
   watchdogTimer:register(30000, tmr.ALARM_SINGLE, function (watchdogTimer)
      local ip = wifi.sta.getip()
      if (not ip) then ip = wifi.ap.getip() end
      if ip == nil then
         lprint(2,"No IP after a while. Restarting...")
         node.restart()
      else
         --lprint(5,"Successfully got IP. Good, no need to restart.")
         watchdogTimer:unregister()
      end
   end)
   watchdogTimer:start()


else

   startServer(wifi.ap.getip())

end
