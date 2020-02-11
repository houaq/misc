--
-- tty.lua: Linux serial port IO (based on posix.termio)
--
-- Copyright(C) 2019, HouAQ
--
local U = require('posix.unistd')

local M = {}

--- open serial port
-- @port the serial port dev
-- @baud baudrate, default: 9600
-- @timeout read timeout in seconds, default: 1s
-- @parity default: no parity
--
M.open = function(port, baud, timeout, parity)
    local T = require('posix.termio')
    local F = require('posix.fcntl')

    local fd, err = F.open(port, F.O_RDWR + F.O_NOCTTY + F.O_EXCL)
    if not fd then
        return nil, err
    end

    baud = baud or 9600
    timeout = timeout or 1

    local cflag = T['B' .. baud] + T.CS8 + T.CLOCAL + T.CREAD
    if parity then
        cflag = cflag + T.PARENB
        if parity == 'odd' then
            cflag = cflag + T.PARODD
        end
    end

    local tio = { cc = {} }
    tio.cflag = cflag
    tio.iflag = T.IGNPAR
    tio.lflag = 0
    tio.oflag = 0
    tio.ispeed = T['B' .. baud]
    tio.ospeed = T['B' .. baud]
    tio.cc[T.VTIME] = timeout * 10
    tio.cc[T.VMIN] = 0

    T.tcsetattr(fd, T.TCSANOW, tio)

    return fd
end

M.write = function(fd, data)
    return U.write(fd, data)
end

M.readline = function(fd, eol)
    local line = ''
    eol = eol or '\n'
    while true do
        local c = U.read(fd, 1)
        if not c or c == '' then
            return false, line
        end

        line = line .. c

        if c == eol then
            return true, line
        end
    end
end

return M
