#!/bin/env node

main();

function main() {
    if (process.argv.length < 3) {
        console.log("usage: ./mqttlog.js <topic>");
        process.exit(1);
    }
    var mqtt = require('mqtt');
    var Cursor = require('terminal-cursor');
    console.log('[2J');
    var cur = new Cursor(1, 1);
    cur.hide();
    var mc = mqtt.connect('mqtt://mqtt.eyun100.com', 'vbdnode', 'node3p');
    mc.subscribe(process.argv[2]);
    mc.on('message', function (topic, message) {
        var ts = message.readUint32LE(0);
        var az = message.readInt16LE(4);
        cur.movePos(1, 1);
				console.log('data:');
        console.log(ts, az);
    });
}

