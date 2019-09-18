#!/usr/bin/env lua
-- 整理贷款档案数据，把合同金额字段里的多个数值转换为多行数据，以便正常导入系统。
--
-- 档案盒号,借款人单位,归档时间,到期时间,合同金额,信贷档案编号,客户编号,payDate,备注
--
local function trim(s)
	s = string.gsub(s, '^%s+', '')
	return string.gsub(s, '%s+$', '')
end

local function splitYe(ye)
	local s, e = string.find(ye, '%s+')
	if not s then return false end
	local t = {}
	for n in string.gmatch(ye, '[%d%.]+') do
		local n = tonumber(n)
		if n then
			table.insert(t, n)
		end
	end
	return #t > 0, t
end

local function split(str, sep)
	local fields = {}
	local s = 1
	repeat
		local pos = string.find(str, sep, s)
		local e = pos and pos - 1
		local f = string.sub(str, s, e)
		table.insert(fields, f)
		if pos then
			s = pos + 1
		else
			break
		end
	until not pos
	return fields
end

local function countPattern(s, p)
	local count = 0
	for m in string.gmatch(s, p) do
		count = count + 1
	end
	return count
end

io.read()	-- skip header
local line = io.read()
while line do
	-- 如果数据中间有回车，需要连接多行
	while countPattern(line, '"') % 2 ~= 0 do
		line = line.. '  '.. io.read()
	end

	local f = split(line, ',')
	local ye = trim(f[5])
	local b, t = splitYe(ye)
	if not b then
		print(line)
	else
		for _,ye in ipairs(t) do
			io.write(f[1], ',', f[2], ',', f[3], ',', f[4], ',', ye, ',',
					 f[6], ',', f[7], ',', f[8], ',', f[9])
			print()
		end
	end
	line = io.read()
end
