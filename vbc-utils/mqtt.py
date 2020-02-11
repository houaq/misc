#!/usr/bin/python

import paho.mqtt.client as mqtt
import struct

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe("mots/data/+")
    
def on_message(client, userdata, msg):
    #print(msg.topic+" "+str(msg.payload))
    node = msg.topic[msg.topic.rfind("/")+1:]
    if len(msg.payload) != 80:
    	print('error payload len: %d' % len(msg.payload))
        return

    payload  = str(struct.unpack('I6hI6hI6hI6hI6h', msg.payload)).strip('()')
    print(node+" "+payload)

    if node not in fdic:
        fdic[node] = open(node, 'a')    
    fdic[node].write(payload + '\n')
    fdic[node].flush()

fdic = {}
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.username_pw_set("vbdnode","node3p")

client.connect("mqtt.eyun100.com", 1883, 60)
client.loop_forever()
