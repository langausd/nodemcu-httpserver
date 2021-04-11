-- lib.wifi.setup.lua
-- Part of nodemcu-httpserver, configures NodeMCU's WiFI in boot.
-- Author: Marcos Kirsch

local conf = dofile("httpserver-conf.lua")

wifi.setmode(conf.wifi.mode)

if (conf.wifi.mode == wifi.SOFTAP) or (conf.wifi.mode == wifi.STATIONAP) then
    lprint(3,'AP MAC: ',wifi.ap.getmac())
    wifi.ap.config(conf.wifi.accessPoint.config)
    wifi.ap.setip(conf.wifi.accessPoint.net)
end

if (conf.wifi.mode == wifi.STATION) or (conf.wifi.mode == wifi.STATIONAP) then
    lprint(3,'Client MAC: ',wifi.sta.getmac())
    wifi.sta.config(conf.wifi.station)
end

lprint(4,'chip: ',node.chipid())
lprint(3,'heap: ',node.heap())

conf = nil
collectgarbage()

-- End WiFi configuration
