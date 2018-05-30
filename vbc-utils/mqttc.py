#!/usr/bin/python3

import paho.mqtt.client as mqtt
import struct
import time

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe("bx/zd/cap_sensor/+")
    
def on_message(client, userdata, msg):
    #print(msg.topic+" "+str(msg.payload))
    node = msg.topic[msg.topic.rfind("/")+1:]
    if len(msg.payload) != 140:
        print(node + " " + "Error mqtt message!")
        return

    #payload  = str(struct.unpack('I6fI6fI6fI6fI6f', msg.payload)).strip('()')
    #print(node+" "+payload)

    if node not in fdic:
        fdic[node] = open(node, 'ab')   
    fdic[node].write(struct.pack("I",int(time.time()))) 
    fdic[node].write(msg.payload)
    fdic[node].flush()

fdic = {}
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.username_pw_set("bxadmin","node5p")

client.connect("localhost", 1883, 60)
client.loop_forever()
