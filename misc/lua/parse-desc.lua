#!/usr/bin/env lua
-- --- T2-COPYRIGHT-NOTE-BEGIN ---
-- This copyright note is auto-generated by ./scripts/Create-CopyPatch.
-- 
-- T2 SDE: misc/lua/parse-desc.lua
-- Copyright (C) 2005 - 2006 The T2 SDE Project
-- 
-- More information can be found in the files COPYING and README.
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License. A copy of the
-- GNU General Public License can be found in the file COPYING.
-- --- T2-COPYRIGHT-NOTE-END ---

-- try this:
-- 
-- this file looks quite complicated already, but a comparsion to grep might help:
--
-- time lua misc/lua/parse-desc.lua package/base/*/*.desc > /dev/null
-- time grep "^[[]" package/base/*/*.desc > /dev/null
--

require "misc/lua/sde/desc"

if #arg < 1 then
   print("Usage: lua misc/lua/parse-desc.lua [path-to-desc-file]")
   os.exit(1)
end

function printf(...)
   io.write(string.format(unpack(arg)))
end


-- parse all files
pkgs = {}
for i,file in ipairs(arg) do
   if i > 0 then
      _,_,repo,pkg = string.find(file, "package/([^/]*)/([^/]*)/*");

      -- put all parsed files into a table
      pkgs[pkg] = desc.parse(file)
   end
end

-- output
for pkg,tab in pairs(pkgs) do
   printf("Package %s:\n", pkg);

   for k,v in pairs(tab) do
      if type(v) == "table" then
	 printf("  %s: %s\n", k, table.concat(v,"\n    "));
      else
	 printf("  %s: %s\n", k, v);
      end
   end
end
