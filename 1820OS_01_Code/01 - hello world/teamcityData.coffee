restify = require 'restify'
assert = require 'assert'
Q = require 'q'

get = (path) ->
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
  console.log detail

get('/guestAuth/app/rest/changes?build=id:378336').then((changeArray) ->
  list = (get url.href for url in changeArray.change)
  Q.all(list)
 , (err) ->
    console.log err
).then((changeDetailsArray) ->
  resultMessages = (buildMessage detail for detail in changeDetailsArray)
, (err2) ->
  console.log err2
).done()

