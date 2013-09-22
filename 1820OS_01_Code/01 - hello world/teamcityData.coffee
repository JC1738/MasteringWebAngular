restify = require 'restify'
assert = require 'assert'
Q = require 'q'
stdio = require 'stdio'
{UserObj} = require "./mail"
{SMTPHost} = require "./mail"
{MailMessage} = require "./mail"
{SendMessage} = require "./mail"

#User = new UserObj "Example"


emailBody = ""
buildObj = null

ops = stdio.getopt(
  build:
    key: "b"
    args: 1
    mandatory: true
)

# print process.argv
#process.argv.forEach (val, index) ->
#  console.log index + ": " + val

#console.log ops.build  if ops.build

get = (path) ->
  #console.log path
  client = restify.createJsonClient
    url : 'http://teamcity',
    version: '*',
    accept: 'application/json'
  deferred = Q.defer()
  client.get path, (err, req, res, obj) ->
    if err
      deferred.reject err
    else
      deferred.resolve obj

  deferred.promise

buildMessage = (detail) ->
  message = ""
  message += detail.username + ": "
  message += detail.comment
  message

extractBuild = (build, results) ->
  msg = "\n\nBuild: #{ build.number } Tests: #{ build.statusText } Status: #{ build.status }\n\n"
  msg += "#{ build.webUrl }\n\n"
  msg += "Commits:\n\n"
  for change in results
    msg += "#{ change }"
  msg

#Locate build to get local build id
#http://teamcity/guestAuth/app/rest/builds/?locator=buildType:bt2296,number:1848
#build.href

url = "/guestAuth/app/rest/builds?locator=buildType:bt2296,number:#{ ops.build }"
#console.log url

get(url).then((buildInfo) ->
  #console.log buildInfo.build[0]
  get(buildInfo.build[0].href)
, (err) ->
  console.log "failed to get build info" + err
  throw err
).then((build) ->
  #console.log build
  if build.changes.count is 0
    throw new Error("0 changes")
  buildObj = build
  get build.changes.href
, (err0) ->
    console.log "error getting changeURL" + err0
    throw err0
).then((changeArray) ->
  list = (get url.href for url in changeArray.change)
  Q.all(list)
 , (err1) ->
    console.log "error getting change array " + err1
    throw err1
).then((changeDetailsArray) ->
  resultMessages = (buildMessage detail for detail in changeDetailsArray)
  #console.log resultMessages
  resultMessages
, (err2) ->
  console.log "error getting change details " + err2
  throw err2
).done((results) ->
  #console.log results
  emailBody = extractBuild buildObj, results
  #console.log emailBody

  host = new SMTPHost "otcmail.otcorp.opentable.com"

  message = new MailMessage "jcastillo@opentable.com", "New Build Email", emailBody

  sender = new SendMessage message, host
  sender.send()

, (finalError) ->
  console.log "Final Error: " + finalError
)
