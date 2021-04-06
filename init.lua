-- check/flash/use LFS support, if possible
if node.getpartitiontable().lfs_size > 0 then
   if file.exists("lfs.img") then
      if file.exists("lfs_lock") then
	 file.remove("lfs_lock")
	 file.rename("lfs.img", "lfs_current.img")
      else
	 local f = file.open("lfs_lock", "w")
	 f:flush()
	 f:close()
	 node.LFS.reload("lfs.img")
      end
   end
   local init = node.LFS.get("_init")
   if (init == nil) then
      print("missing _init() function in LFS. Please load lfs.img!")
   else
      init()
   end
   init = nil
   collectgarbage()
else
   print "Need recent nodeMCU firmware with LFS support!  ABORTING"
end

if ( pcall(LFS.init) ) then
   print("init completed")
else
   print("init FAILED!")
end


