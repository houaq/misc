#!/usr/bin/python3
import sys
import struct
import time

packfmt = "I6hI6hI6hI6hI6h"
argv_len = len(sys.argv)
if argv_len < 2:
    print("Usage: unpack fileName [skip] [count]")
    sys.exit(0)

file = open(sys.argv[1], "rb")
file.seek(0,2)
print("\nTotal:",int(file.tell()/144),"lines\n")
file.seek(0,0)

buff_len = struct.calcsize(packfmt)

if argv_len >= 3:
    skip = int(sys.argv[2]) * buff_len
    if skip >= 0:
        file.seek(skip, 0)
    else:
        file.seek(skip, 2)

if argv_len >= 4:
    count = int(sys.argv[3])
else:
    count = 5

while count > 0:
    buff = file.read(buff_len)
    if len(buff) != buff_len:
        print("File end!")
        file.close()
        sys.exit(0)
    payload  = struct.unpack(packfmt, buff)
    print(time.asctime(time.localtime(payload[0])))
    for i in range(5):
        print(payload[i*7+1], end=", ")
        for j in range(2,8):
            print("%d, " % (payload[i*7+j]), end="")
        print("")
    print("")
    count = count -1

file.close()
