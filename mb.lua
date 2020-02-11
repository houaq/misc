mb = require("libmodbus")
local dev = mb.new_rtu("/dev/ttyS0", 9600, 'N')
local base_address = 0x2000
dev:set_slave(1)
dev:set_response_timeout(5, 0)
dev:connect()
local regs, err = dev:read_registers(base_address, 30)
if not regs then error("read failed: " .. err) end
for r,v in ipairs(regs) do
    print(string.format("register (offset %d) %d: %d (%#x): %#x (%d)",
    r, r, r + base_address - 1, r + base_address -1, v, v))
end
