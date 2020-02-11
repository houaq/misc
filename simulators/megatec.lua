#!/usr/bin/env lua

package.path = './?.lua;'.. package.path

local tty = require('tty')

local port = arg[1] or '/dev/ttyS0'

local responses = {
	I = "#Kehua_Tech_Ltd. 20KVA      v1.1_2013 \r",
	F = "#320.0 050 02.13 50.0\r",
	Q1 = {
		-- onbatt cycle
		"(208.4 140.0 208.4 034 59.9 2.23 35.0 00000000\r",
		"(000.0 140.0 208.4 034 59.9 2.13 35.0 00010000\r",
		"(000.0 140.0 208.4 034 59.9 1.80 35.0 00010000\r",
		"(208.4 140.0 208.4 034 59.9 2.20 35.0 00000000\r",

		-- overload & overtemp cycle
		"(208.4 140.0 208.4 094 59.9 1.65 55.0 00000000\r",
		"(208.4 140.0 208.4 094 59.9 1.65 55.0 00000000\r",
		"(208.4 140.0 208.4 094 59.9 1.65 55.0 00000000\r",
		"(208.4 140.0 208.4 034 59.9 1.65 35.0 00000000\r",

		-- all flags
		"(000.0 140.0 208.4 034 59.9 2.05 35.0 11111111\r",
		"(000.0 140.0 208.4 034 59.9 2.05 35.0 11111111\r",
		"(000.0 140.0 208.4 034 59.9 2.05 35.0 11111111\r",
		"(208.4 140.0 208.4 034 59.9 1.65 35.0 00000000\r"
	},
	G1 = {
		"!240 099 0123 025.0 +35.0 50.1 52.0 50.0\r",
		-- onbatt cycle
		"!240 099 0123 025.0 +35.0 50.1 52.0 50.0\r",
		"!240 094 0123 025.0 +35.0 50.1 52.0 50.0\r",
		"!240 044 0123 025.0 +35.0 50.1 52.0 50.0\r",
		"!240 098 0123 025.0 +35.0 50.1 52.0 50.0\r"
	},
	G2 = "!00000010 00000100 00000000\r",
	G3 = "!222.0/222.0/222.0 221.0/221.0/221.0 220.0/220.0/220.0 014.0/015.0/014.0\r"
}

local portfd, err = tty.open(port, 2400, 2)
if not portfd then
    print('failed to open port:'.. err)
    os.exit(1)
end

local pointers = {}
while true do
	local ok, line = tty.readline(portfd, '\r')
	if ok then
		print('Got command: '.. line)
		line = string.gsub(line, '\r', '')
		local resp = responses[line]
		if resp then
			if type(resp) == 'table' then
				local ptr = pointers[line]
				if not ptr or ptr > #resp then
					ptr, pointers[line] = 1, 1
				end
				resp = resp[ptr]
				pointers[line] = pointers[line] + 1
			end
			print('Responding with: '.. resp)
			tty.write(portfd, resp)
		end
	end
end
