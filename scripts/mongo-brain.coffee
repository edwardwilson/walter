# Description:
#   Enhances hubot-brain with MongoDB for better persistance. Falls back 
#   to memory brain if Mongo connection fails for local testing.
#
# Dependencies:
#   "mongodb": "*"
#   "lodash" : "*"
#
# Configuration:
#   MONGODB_HOST
#   MONGODB_PORT
#   MONGODB_DB
#
# Author:
#   Edward Wilson <edward.wilson@live.com>

_           = require 'lodash'
MongoClient = require('mongodb').MongoClient

deepClone = (obj) -> JSON.parse JSON.stringify obj

error = (err) ->
  robot.logger.debug err

module.exports = (robot) ->
  host = process.env.MONGODB_HOST || "localhost"
  port = process.env.MONGODB_PORT || "27017"
  dbname = process.env.MONGODB_DB || "hubot"
  mongoUrl = "mongodb://#{host}:#{port}/#{dbname}"
  
  robot.logger.debug "hubot-mongodb-brain: Connecting to mongo db - #{mongoUrl}"
  
  MongoClient.connect mongoUrl, (err, db) ->
    robot.logger.debug "hubot-mongodb-brain: Failed to connect to mongo db" if err
    robot.logger.debug err if err

    robot.logger.debug "hubot-mongodb-brain: Successfully connected to mongo db"
    robot.brain.setAutoSave true

    cache = {}

    ## restore data from mongodb
    db.createCollection 'brain', (err, collection) ->
      collection.find({}).toArray (err, docs) ->
        return robot.logger.error err if err
        data = {}
        for doc in docs
          data[doc.key] = doc.value
        cache = deepClone data
        robot.brain.mergeData data
        robot.brain.resetSaveInterval 10
        robot.brain.setAutoSave true

    ## save data into mongodb
    robot.brain.on 'save', (data) ->
      db.collection 'brain', (err, collection) ->
        for k,v of data
          do (k,v) ->
            return if _.isEqual cache[k], v  # skip not modified key
            robot.logger.debug "save \"#{k}\" into mongodb-brain"
            cache[k] = deepClone v
            collection.update
              key:  k
            ,
              $set:
                value: v
            ,
              upsert: true
            , (err, res) ->
              robot.logger.error err if err
            return
            
    ## Close db when brain closes        
    robot.brain.on 'close', ->
      db.close()