restify = require 'restify'
assert = require 'assert'
Q = require 'q'

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

#Locate build to get local build id
#http://teamcity/guestAuth/app/rest/builds/?locator=buildType:bt2296,number:1848
#build.href

get('/guestAuth/app/rest/builds?locator=buildType:bt2296,number:1848').then((buildInfo) ->
  #console.log buildInfo.build[0]
  get(buildInfo.build[0].href)
, (err) ->
  console.log "failed to get build info" + err
  throw err
).then((changeObj) ->
  #console.log changeObj
  if changeObj.changes.count is 0
    throw new Error("0 changes")
  get changeObj.changes.href
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
  console.log resultMessages
  resultMessages
, (err2) ->
  console.log "error getting change details " + err2
).done()

