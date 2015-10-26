# Description:
#   Restarts the build servers
#
# Dependencies:
#   "wait": "*"
#
# Commands:
#   hubot restart build servers - restarts all the build servers
#   hubot restart <server> - restarts the specified server
#
# Configuration:
#   HUBOT_BUILD_SERVERS
#
# Author:
#   ewilson
#
#require 'wait'

buildServers = process.env.HUBOT_BUILD_SERVERS;

module.exports = (robot) ->
  # getLock(lockName) ->
  #   return robot.brain.get('lockName')
  
  restartServers = (msg) ->
    unless buildServers?
      msg.send "Missing HUBOT_BUILD_SERVERS in environment: please set and try again"
      return
    for server in buildServers.split ","
      restartServer(msg, server)
  
  restartServer = (msg, servers) ->
    @exec = require('child_process').exec
    
    for server in servers.split ","
      @exec "shutdown /r /m \\\\#{server} /t 5", (error, stdout, stderr) ->
      if error
         msg.send error
      msg.send "Restarting #{server}"


  robot.brain.on 'loaded', ->
    # Clear the lock on startup in case Hubot has restarted and Hubot's brain has persistence.
    # We don't want any orphaned locks preventing us from running commands.
    robot.brain.remove('restartBuildServersLock')
    
  robot.respond /restart (the )?build (server(s)?)?/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'development')
      #lock = robot.brain.get('restartBuildServersLock')
      #if lock?
        #msg.reply "I'm sorry, I'm afraid I can't do that. I'm already restarting the servers for #{lock.user.name}."
        #return
      #robot.brain.set('restartBuildServersLock', msg.message)  # includes user, room, etc about who locked
      restartServers(msg)
    else
      msg.reply "Sorry you can't ask me to restart those servers, you're not in the development team"
      
      #([\w\.\-_ ]+)(, (.+))?
  robot.respond /restart (([\w\s]+-?[\w\s]+)(?:\,([\w\s]+-?[\d\s]+))+)/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'development')
      servername = msg.match[1].toLowerCase();
    
      #lock = robot.brain.get("restartBuildServersLock")
      #serverLock = robot.brain.get("restart#{servername}Lock")
      #if lock?
        #msg.reply "I'm sorry, I'm afraid I can't do that. I'm already restarting the server for #{lock.user.name}."
        #return
      #robot.brain.set("restart#{servername}Lock", msg.message)  # includes user, room, etc about who locked
      restartServer(msg, servername)
    else
      msg.reply "Sorry you can't ask me to restart those servers, you're not in the development team"