// Description:
//   Replies with the company values
//
// Dependencies:
//   None
//
// Configuration:
//   HUBOT_COMPANYVALUES
//
// Commands:
//   hubot what are the company values - responds with our company values
//  
// Author:
//   Edward Wilson<edward.wilson@live.com>

(function () {
  'use strict';

  var values = process.env.HUBOT_COMPANYVALUES;
  
  module.exports = function (robot) {
    robot.respond(/(what are )?the (company )?values(\?)?$/i, function (msg) {
      msg.send(values);
    });
  };
} ());