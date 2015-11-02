// Description:
//   Replies with the company values
//
// Dependencies:
//   None
//
// Configuration:
//   None
//
// Commands:
//   hubot what are the company values - responds with our company values
//  
// Author:
//   Edward Wilson<edward.wilson@live.com>

(function () {
  'use strict';
  module.exports = function (robot) {
    robot.respond(/(what are )?the (company )?values(\?)?$/i, function (msg) {
      var payload = {
        message: msg.message,
        content: {
          text: "Show we *care*\nWork better; *together*\n*Trust* each other to deliver\nMake the complex *simple*\nFind our *courage*",
		  mrkdwn_in: ["text"]
        }
      };
      robot.adapter.customMessage(payload);
    });
  };
} ());