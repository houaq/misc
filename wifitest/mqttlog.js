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
    var mc = mqtt.connect('mqtt://192.168.8.221');
    mc.subscribe(process.argv[2]);
    mc.on('message', function (topic, message) {
        var az = message.readFloatLE(0);
        cur.movePos(1, 1);
        console.log(az);
    });
}

