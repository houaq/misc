#!/bin/env node

var mqtt = require('mqtt');
var Cursor = require('terminal-cursor');

const rows = 40;
const cols = 139;

var cur = new Cursor(1,1);
cur.hide();

var mc = mqtt.connect('mqtt://192.168.8.221');
mc.subscribe('/test/wifi/message')

var table = {};

mc.on('message', function (topic, message) {
	var line = message.toString();
  var record = line.split(', ');
	var ip = record[0];
	var row = table[ip];
	if (!row) {
		var i = Object.keys(table).length + 1;
		table[ip] = row = { i: i, age: 0 };
	} else
		row.age = 0;

	cur.movePos(row.i, 1);
	console.log('%s %s', ' '.repeat(10), line);
});

setInterval(function () {
	// aging record
	for (var ip in table) {
		var row = table[ip];
		if (row.age < cols) {
			row.age++;
			cur.movePos(row.i, 1);
			console.log('>'.repeat(row.age));
		}
	}
}, 1000);
