# Description:
#   Looks up jira issues when they're mentioned in chat
#
#   Will ignore users set in HUBOT_JIRA_ISSUES_IGNORE_USERS (by default, JIRA and GitHub).
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_JIRA_URL (format: "https://jira-domain.com:9090")
#   HUBOT_JIRA_IGNORECASE (optional; default is "true")
#   HUBOT_JIRA_USERNAME (optional)
#   HUBOT_JIRA_PASSWORD (optional)
#   HUBOT_JIRA_ISSUES_IGNORE_USERS (optional, format: "user1|user2", default is "jira|github")
#
# Commands:
# 
# Author:
#   stuartf

module.exports = (robot) ->
  cache = []

  # In case someone upgrades form the previous version, we'll default to the 
  # previous behavior.
  jiraUrl = process.env.HUBOT_JIRA_URL || "https://#{process.env.HUBOT_JIRA_DOMAIN}"
  jiraUsername = process.env.HUBOT_JIRA_USERNAME
  jiraPassword = process.env.HUBOT_JIRA_PASSWORD
  
  if jiraUsername != undefined && jiraUsername.length > 0
    auth = "#{jiraUsername}:#{jiraPassword}"

  jiraIgnoreUsers = process.env.HUBOT_JIRA_ISSUES_IGNORE_USERS
  if jiraIgnoreUsers == undefined
    jiraIgnoreUsers = "jira|github"

  robot.http(jiraUrl + "/rest/api/2/project")
    .auth(auth)
    .get() (err, res, body) ->
      json = JSON.parse(body)
      jiraPrefixes = ( entry.key for entry in json )
      reducedPrefixes = jiraPrefixes.reduce (x,y) -> x + "-|" + y
      jiraPattern = "/\\b(" + reducedPrefixes + "-)(\\d+)\\b/g"
      ic = process.env.HUBOT_JIRA_IGNORECASE
      if ic == undefined || ic == "true"
        jiraPattern += "i"

      robot.hear eval(jiraPattern), (msg) ->
        return if msg.message.user.name.match(new RegExp(jiraIgnoreUsers, "gi"))
        for i in msg.match
          issue = i.toUpperCase()
          # now = new Date().getTime()
          # if cache.length > 0
          #   cache.shift() until cache.length is 0 or cache[0].expires >= now

          # msg.send item.message for item in cache when item.issue is issue
		  
          # if cache.length == 0 or (item for item in cache when item.issue is issue).length == 0
          robot.http(jiraUrl + "/rest/api/2/issue/" + issue)
            .auth(auth)
            .get() (err, res, body) ->
              try
                json = JSON.parse(body)
                key = json.key
                
                fields = []
                
                msg.send JSON.stringify json.fields.assignee
                  
                # Ticket assignee
                assignee = "unassigned"
                if json.fields.assignee
                  if ('value' of json.fields.assignee or 'displayName' of json.fields.assignee)
                    if (json.fields.assignee.name == "assignee" and json.fields.assignee.value.displayName)
                      assignee = json.fields.assignee.value.displayName
                    else if (json.fields.assignee and json.fields.assignee.displayName)
                      assignee = json.fields.assignee.displayName
          
                fields.push
                  title: "Assignee"
                  value: assignee
                  short: true
                  
                # Ticket priority
                fields.push
                  title: "Reporter"
                  value: json.fields.reporter.displayName
                  short: true
                                                        
                # Ticket status 
                fields.push
                  title: "Status"
                  value: json.fields.status.name
                  short: true
                  
                # Ticket priority
                if json.fields.priority and json.fields.priority.name
                  fields.push
                    title: "Priority"
                    value: json.fields.priority.name
                    short: true
  
              
                payload = 
                  message: msg.message
                  content:
                    title_link: jiraUrl + "/browse/" + key
                    title: key
                    text: json.fields.summary
                    fallback: "[" + key + "] " + json.fields.summary
                    fields: fields
                
                robot.adapter.customMessage payload
                
                #cache.push({issue: issue, expires: now + 120000, message: payload.content})
              catch error
                try
                  msg.send "[*ERROR*] " + json.errorMessages[0]
                catch reallyError
                  msg.send "[*ERROR*] " + reallyError


