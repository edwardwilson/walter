// Description:
//   Allows hubot to update itself using git pull and npm update.
//   If updates are downloaded you'll need to restart hubot, for example using "walt die" (restart using a watcher like forever.js).
//
// Dependencies:
//   None
//
// Configuration:
//   None
//
// Commands:
//   hubot update - Performs a git pull and npm udate.
//   hubot pending update - Informs if there are pending updates (hubot needs a restart)
//
// Author:
//   Edward Wilson <edward.wilson@live.com>

(function () {
  'use strict';
  var child_process = require('child_process');
  var pjson = require('../package.json');
  var downloaded_updates = false;

  function SendUpdateStatus(msg) {
    if (downloaded_updates) {
      return msg.send("I have some pending updates, I NEED RESTARTING!");
    } else {
      return msg.send("I'm up-to-date!");
    }
  }

  module.exports = function (robot) {
    robot.respond(/pending updates?\??$/i, function (msg) {
      SendUpdateStatus(msg);
    });
    
    robot.respond(/version$/i, function (msg) {
      msg.send(pjson.version)
    });

    robot.respond(/update( yourself)?$/i, function (msg) {
      var changes = false;
      var error;
      
      // Try to pull from git
      try {
        msg.send("git pull...");
        
        child_process.exec('git pull', function (error, stdout, stderr) {
          var output;
          
          if (error) {
            msg.send("git pull failed: " + stderr);
          } else {
            output = stdout + '';
            if (!/Already up\-to\-date/.test(output)) {
              msg.send("my source code changed:\n" + output);
              changes = true;
            } else {
              msg.send("my source code is up-to-date");
            }
          }
          
          // Try npm update
          try {
            msg.send("npm update...");
            child_process.exec('npm update', function (error, stdout, stderr) {
              if (error) {
                msg.send("npm update failed: " + stderr);
              } else {
                output = stdout + '';
                if (/node_modules/.test(output)) {
                  msg.send("some dependencies updated:\n" + output);
                  changes = true;
                } else {
                  msg.send("all dependencies are up-to-date");
                }
              }
              if (changes) {
                downloaded_updates = true;
                return msg.send("I downloaded some updates, I NEED RESTARTING!");
              } else {
                SendUpdateStatus(msg);
              }
            });
            
          } catch (_error) {
            error = _error;
            return msg.send("npm update failed: " + error);
          }
        });
        
      } catch (_error) {
        error = _error;
        return msg.send("git pull failed: " + error);
      }
    });
  };
} ());