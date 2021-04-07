local function sendAttr(connection, attr, val, unit)
   --Avoid error when Nil is in atrib=val pair.
   if not attr or not val then
      return
   else
      if unit then
         unit = ' ' .. unit
   else
      unit = ''
   end
      connection:send("<li><b>".. attr .. ":</b> " .. val .. unit .. "<br></li>\n")
   end
end

return function (connection, req, args)
   srv.header(connection, 200, 'html')
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>LFS info (served on nodeMCU LUA)</title></head><body><h1>LFS info</h1><ul>')

   sendAttr(connection, "LFS timestamp"     , node.LFS.time)
   sendAttr(connection, "lfs_base"       , node.LFS.config.lfs_base)
   sendAttr(connection, "lfs_mapped"       , node.LFS.config.lfs_mapped)
   sendAttr(connection, "lfs_size"       , node.LFS.config.lfs_size)
   sendAttr(connection, "lfs_used"       , node.LFS.config.lfs_used)
   sendAttr(connection, "LFS usage"       , node.LFS.config.lfs_used * 100 / node.LFS.config.lfs_size, "%")

   connection:send('</ul><h2>Modules in LFS</h2><ul>')
   for k,v in pairs(node.LFS.list()) do
      sendAttr(connection, k, v)
   end
   
   connection:send('</ul></body></html>')
end
