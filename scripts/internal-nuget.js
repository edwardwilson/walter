// Description:
//   Replies with the company values
//
// Dependencies:
//   None
//
// Configuration:
//   HUBOT_NUGET_SERVER
//
// Commands:
//   hubot what is our nuget server - responds with the server address
//  
// Author:
//   Edward Wilson<edward.wilson@live.com>

(function () {
  'use strict';

  var serverAddress = process.env.HUBOT_NUGET_SERVER;
  
  module.exports = function (robot) {
    robot.respond(/what is (the|our) nuget server address?(\?)?$/i, function (msg) {
      msg.send("Here is the <"+ serverAddress +"|server address>");
    });
  };
} ());