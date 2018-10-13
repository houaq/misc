var express = require('express');
var fs = require('fs')
var router = express.Router();

/* GET home page. */
router.get('/', function (req, res, next) {
  res.render('index', { title: 'Express' });
});

/* GET home page. */
router.get('/config', function (req, res, next) {
  var ts = parseInt(req.query.ts);
  if (ts != NaN && ts > 0) {
    return res.status(304).end();
  }
  res.json({
    adaptors: [
      {
        name: "server",
        driver: "epcs.lua",
        opts: {
          url: "http://eyun100.com:3000/api/setdata",
          siteid: "3242345"
        }
      }
    ],
    devices: [
      {
        name: "controller",
        driver: "hh108.lua",
        opts: {
          port: "/dev/ttyO1",
          polls: [
            { name: "data-1", cmd: "0x55,0x07,0x12,0x34,0xAA", time: 120 },
            { name: "data-2", cmd: "0x55,0x07,0x12,0x34,0xAA", time: 120 },
            { name: "data-3", cmd: "0x55,0x07,0x12,0x34,0xAA", time: 120 }
          ]
        }
      }
    ]
  });
});

router.post('/setdata', function (req, res, next) {
  var fn = '/tmp/epc_res.json';
  if (fs.existsSync(fn)) {
    console.log(fn);
    res.type('application/json');
    res.sendFile(fn);
  } else
    res.end();
});

module.exports = router;
