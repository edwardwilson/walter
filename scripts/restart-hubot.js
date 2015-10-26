// Description:
//   Kills the node service running Hubot (restart using a watcher like forever.js).
//
// Dependencies:
//   None
//
// Configuration:
//   None
//
// Commands:
//   hubot restart - Kills and restarts the hubot service.
//
// Author:
//   Edward Wilson <edward.wilson@live.com>

(function () {
  'use strict';

  module.exports = function (robot) {
    robot.respond(/restart( yourself)?$/i, function (msg) {
      msg.send("Ok; restarting now...");
      process.exit(1);
    });
  };
} ());