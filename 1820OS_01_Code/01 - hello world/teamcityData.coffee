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

#/guestAuth/app/rest/changes?build=id:378336
get('/guestAuth/app/rest/changes?build=id:378336').then((data) ->
  console.log data
 , (err) ->
    console.log err
).done()

