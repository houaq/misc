#!/usr/bin/env lua
package.path = './?.lua'.. package.path

local tty = require('tty')

local port = arg[1] or '/dev/ttyS0'

local responses = {
	I = "#Kehua_Tech_Ltd. 20KVA      v1.1_2013 \r",
	F = "#320.0 050 02.13 50.0\r",
	Q1 = {
		"(208.4 140.0 208.4 034 59.9 2.05 35.0 00000000\r",
		"(208.4 140.0 208.4 094 59.9 1.65 55.0 00010000\r",
		"(208.4 140.0 208.4 034 59.9 1.65 55.0 00010000\r",
		"(000.0 140.0 208.4 034 59.9 2.05 35.0 10010000\r"
	},
	G1 = "!240 094 0123 025.0 +35.0 50.1 52.0 50.0\r",
	G2 = "!00000010 00000100 00000000\r",
	G3 = "!222.0/222.0/222.0 221.0/221.0/221.0 220.0/220.0/220.0 014.0/015.0/014.0\r"
}

local portfd, err = tty.open(port, 2400, 0)
if not portfd then
    print('failed to open port:'.. err)
    os.exit(1)
end

while true do
	local ok, line = tty.readline(portfd, '\r')
	if not ok then
		print('readline not ok, line is: '.. line)
	else
		print('Got command: '.. line)
		line = string.gsub(line, '\r', '')
		local resp = responses[line]
		if resp then
			if type(resp) == 'table' then
				resp = resp[math.random(4)]
			end
			print('Responding with: '.. resp)
			tty.write(portfd, resp)
		end
	end
end