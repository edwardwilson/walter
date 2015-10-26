# Description:
#   Looks up jira issues when they're mentioned in chat
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_LIVEENVIRONMENT_VERSIONSTORE_URL
#   HUBOT_LIVEENVIRONMENT_JENKINSJOB_URL 
#
# Author:
#   ewilson

iniFileUrl = process.env.HUBOT_LIVEENVIRONMENT_VERSIONSTORE_URL;
jenkinsUrl = process.env.HUBOT_LIVEENVIRONMENT_JENKINSJOB_URL;

getDetails = (robot, msg) ->
  unless iniFileUrl?
      msg.send "Missing HUBOT_VERSIONSTORE_LIVEENVIRONMENT_URI in environment: please set and try again"
      return
  
    unless jenkinsUrl?
      msg.send "Missing HUBOT_LIVEENVIRONMENT_VERSIONSTORE_URL in environment: please set and try again"
      return

    robot.http(iniFileUrl).get() (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "Encountered an error getting server name:( #{err}"
        return
      env = String(body)
      
      robot.http(jenkinsUrl).get() (err, res, body) ->
        if res.statusCode isnt 200
          msg.send "Encountered an error getting deployment time:( #{err}"
          return
            
        data = JSON.parse body
        deployedDate = new Date(data.timestamp)
        msg.reply "The live server is #{env}It was deployed on _#{deployedDate}_"
         

module.exports = (robot) ->
  robot.hear /(wh(ich|at))? (server|env(ironment)?) is live$/i, (msg) ->
    getDetails(robot, msg)
    
  robot.hear /(wh(ich|at))? is the live (server|env(ironment)?)$/i, (msg) ->
    getDetails(robot, msg)