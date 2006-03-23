#!/usr/bin/lua
-- --- T2-COPYRIGHT-NOTE-BEGIN ---
-- This copyright note is auto-generated by ./scripts/Create-CopyPatch.
-- 
-- T2 SDE: package/.../sam/sam.lua
-- Copyright (C) 2006 The T2 SDE Project
-- 
-- More information can be found in the files COPYING and README.
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License. A copy of the
-- GNU General Public License can be found in the file COPYING.
-- --- T2-COPYRIGHT-NOTE-END ---

-- identification
local _NAME        = "SAM"
local _VERSION     = "0.0-devel"
local _COPYRIGHT   = "Copyright (C) 2006 The T2 SDE Project"
local _DESCRIPTION = "System Administration Manager for systems based on T2"

-- SAM namespace
sam = sam or {
	-- logging (callable via metatable, see DESCRIPTION)
	log = {
		ERROR  = 0,
		WARN   = 1,
		NOTICE = 2,
		INFO   = 3,
		DEBUG  = 4,
	},
	error  = function(ident,...) sam.log(sam.log.ERROR, ident, unpack(arg)) end,
	warn   = function(ident,...) sam.log(sam.log.WARN, ident, unpack(arg)) end,
	notice = function(ident,...) sam.log(sam.log.NOTICE, ident, unpack(arg)) end,
	info   = function(ident,...) sam.log(sam.log.INFO, ident, unpack(arg)) end,
	dbg    = function(ident,...) sam.log(sam.log.DEBUG, ident, unpack(arg)) end,

	-- command list (extended by modules)
	command = {} 
}	

-- default options
sam.opt = sam.opt or {
	loglevel = sam.log.DEBUG, -- sam.log.WARN
}

--[[ DESCRIPTION ] ----------------------------------------------------------

Provided functions:

* sam.log(required-verbosity-level, identification, printf-format...)

    Print information about SAM processing. The logging level (sam.opt.loglevel)
    has to be equal or higher than "required-verbosity-level". The
    "identification" is printed in square brackets in front of the message.

    Example:
      sam.log(sam.log.ERROR, "Config", "Config file incosistency (%s)",
	          filename)


* sam.error(identification, format...)
* sam.warn(identification, format...)
* sam.notice(identification, format...)
* sam.info(identification, format...)
* sam.dbg(identification, format...)

    Short form for the logging function.
  

* sam.command["command-name"](args...)
* sam.command["command-name"].main(args...)

    Execute a command (extended by modulues) with given arguments.
	The only built-in command currently is "help".

* cli = sam.cli(def)

    Define a CLI command set. The table "def" consist of key->function
	mappings, e.g. sam.cli { help = cli_cmd_help }. The return value is
	a CLI object with the following methods:

	cli:run()
	cli()

	  Start the event loop.

	cli:finish()

	  Leave the event loop.

	cli:send(...)

      Send a message (printf format). A trailing newline is appended
	  automatically.

	cli:get()

	  Used in the event loop: read (and tokenize) input

--]] ------------------------------------------------------------------------

-- printf helpers -----------------------------------------------------------

local function fprintf(stream, ...)
	stream:write(string.format(unpack(arg)))
end

-- LOGGING ------------------------------------------------------------------

-- log_stdout(required-log-level, identification, fmt...)
--   The default logging method is to log to stderr.
local function log_stdout(reqlvl, ident, ...)
	if sam.opt.loglevel >= reqlvl then
		fprintf(io.stderr, "[%s] ", ident)
		fprintf(io.stderr, unpack(arg))
	end
end

-- sam.log(required-log-level, identification, fmt...)
--   sam.log can be called as function via a metatable,
--   default: log_stdout
setmetatable(sam.log, {
	__call = function(self, reqlvl, ident,  ...) 
			log_stdout(reqlvl, ident, unpack(arg))
		 end
})

-- MODULES ------------------------------------------------------------------

-- load_module(name)
--   Load the previously detected module.
local function load_module(name)
	sam.info(_NAME, "Loading module %s (from %s)\n", name, sam.command[name]._module._FILE)

	-- sanity check for module info
	if not sam.command[name] or not sam.command[name]._module then
		sam.error(_NAME, "No such command module '%s', giving up.\n", name)
		return
	end

	-- load and execute the module
	local module = loadfile(sam.command[name]._module._FILE)
	module = module()

	-- module sanity check
	if not module.main or not module._NAME then
		sam.error(_NAME, "Command module '%s' is probably not a SAM module.\n", name)
		return
	end

	-- copy module data
	sam.command[name]._NAME         = module._NAME
	sam.command[name]._DESCRIPTION  = module._DESCRIPTION
	sam.command[name]._module.usage = module.usage
	sam.command[name]._module.main  = module.main

	-- set real methods
	sam.command[name].help  = function(self) fprintf(io.stdout, "  %16s    %s\n", self._NAME, self._DESCRIPTION) end
	sam.command[name].usage = function(self) self._module.usage() end
	sam.command[name].main  = function(self,...) return self._module.main(unpack(arg)) end

	-- set correct metatable
	setmetatable(sam.command[name], {
		__call = function(self, ...) return self._module.main(unpack(arg)) end,
	})
end

-- detect_modules()
--   Detect all SAM modules
local function detect_modules()
	local lfs = require("lfs")
	local moddir = os.getenv("SAM_MODULES") or "/usr/lib/sam"

	for file in lfs.dir( moddir ) do
		local name
		local path

		_,_,name = string.find(file, "^sam_([%a][_%w%a]*).lua")
		path = moddir .. "/" .. file

		if name and lfs.attributes(path).mode == "file" and "sam_" .. name .. ".lua" == file then
			sam.dbg(_NAME, "Found '%s' (%s)\n", name, path)			

			-- preset the module structure of the detected module
			-- for auto-loading
			sam.command[name] = {
				_module = {
					_NAME = name,
					_FILE = path,
				},

				_NAME = name,
				_DESCRIPTION = "-",

				help  = function(self)
						load_module(self._module._NAME)
						self:help()
					end,
				usage = function(self)
						load_module(self._module._NAME)
						self:usage()
					end,
				main  = function(self,...)
						load_module(self._module._NAME)
						return self:main(unpack(arg))
					end,
			}

			-- add a metatable so the commands can be used, however,
			-- it is anly a intermediate metatable, as the module is not
			-- loaded yet. The module gets loaded (dynamic linker alike)
			-- once it is called

			setmetatable(sam.command[name], {
				__call = function(self, ...)
						load_module(self._module._NAME)
						return self:main(unpack(arg))
					end,
			})
						
		end
	end
end

-- COMMANDS -----------------------------------------------------------------
-- helper functions
local function create_command(name, desc, usage_func, func)
	sam.dbg(_NAME, "Creating global SAM command (%s)\n", name)

	-- command structure
	sam.command[name] = {
		_NAME = name,
		_DESCRIPTION = desc,

		_command = {
			usage = usage_func,
			main = func
		},

		help  = function(self) fprintf(io.stdout, "  %16s    %s\n", self._NAME, self._DESCRIPTION) end,
		usage = function(self) self._command.usage() end,
		main  = function(self, ...) return self._command.main(unpack(arg)) end,
	}

	setmetatable(sam.command[name], {
		__call = function(self, ...) return self._command.main(unpack(arg)) end
	})
end

-- commands
local function usage()
	print([[Usage: sam [commands]

Commands:]])

	for k,_ in pairs(sam.command) do
		sam.command[k]:help()
	end
end

function help(...)
	fprintf(io.stderr, "%s v%s %s\n%s\n\n", _NAME, _VERSION, _COPYRIGHT, _DESCRIPTION)
	if #arg == 1 then
		if sam.command[ arg[1] ] then
			sam.command[ arg[1] ]:help()
		else
			usage()
		end
	else
		usage()
	end
end

create_command("help", "Show command reference", usage, help)


-- CLI ----------------------------------------------------------------------

-- sam.shellsplit(some-string)
--   Extend string with a shell alike tokenizer.
--   This is a rather ugly code imo, a better solution
--   is welcome!
function sam.shellsplit(str)
	local idx = {} -- list of indexes to split str

	-- parse thru all characters of the string
	-- and check for quotes and escaping
	local n = 0
	local esc = 0
	local quote = 0
	local last = ' '
	for c in string.gfind(str, ".") do
		n = n + 1
		
		if esc == 0 then
			if c == '\\' then
				esc = 1
			elseif c == '"' or c == "'" then
				if quote == 0 then
					quote = 1
					if last == ' ' then
						-- we found the start of a token
						table.insert(idx, n)
					end
				else 
					quote = 0
				end
			elseif quote == 0 then
				if c == ' ' or c == '\t' then
					if last ~= ' ' then
						-- we found the end of a token
						table.insert(idx, n-1)
					end
					c = ' '
				elseif last == ' ' then
					-- we found the start of a token
					table.insert(idx, n)
				end
			end
		else
			esc = 0
		end

		last = c
	end
	if #idx > 0 then
		-- closing token at end-of-line
		table.insert(idx, n)
	end

	-- assemble the tokens into a table
	local toks = {}
	n = 1
	while n < #idx do 
		table.insert(toks, string.sub(str, idx[n], idx[n+1]))
		n = n+2
	end
	
	return toks
end

-- TODO document
local __cli = {
	ok = true,
	command = {
		-- default wildcard command
		["*"] = function(self,cmd,...) 
				self:send("[ERROR] unknown command: %s", cmd or "<none>")
			end,
		-- default "exit" command
		exit = function(self,...) self:finish() end,
	}
}

function __cli:finish()
	self.ok = false
end

function __cli:get()
	local line = io.stdin:read("*line")
	return sam.shellsplit(line)
end

function __cli:send(...)
	fprintf(io.stdout, unpack(arg))
	fprintf(io.stdout, "\n")
end

function __cli:run()
	-- event loop
	while self.ok do
		-- wait for input
		local args = self:get()
		local cmd = args[1] ; table.remove(args, 1)
	
		-- check command
		if self.command[cmd] then
			self.command[cmd](self, unpack(args or {}))
		else
			self.command['*'](self, cmd, unpack(args or {}))
		end
	end
end

function sam.cli(def)
	sam.info(_NAME, "sam.cli(%s,%d)\n", tostring(def), #def)
	local retval = __cli

	-- install commands
	for k,v in pairs(def) do
		sam.dbg(_NAME, "   installing command '%s'\n", k)
		retval.command[k] = v
	end

	-- make retval executable
	setmetatable(retval, { __call = function(self) self:run() end })

	return retval
end

-- --------------------------------------------------------------------------
-- INITIALIZE SAM
-- --------------------------------------------------------------------------
detect_modules()








-- --------------------------------------------------------------------------
-- TEST
-- --------------------------------------------------------------------------

--sam.command["dummy"]("hello")
--sam.command["dummy"]("world!")
--sam.command["help"]()

sam.command["dummy"]()
