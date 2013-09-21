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


get('/guestAuth/app/rest/changes?build=id:378336').then((data) ->
  #console.log data
  list = (get url.href for url in data.change)
  Q.all(list)
 , (err) ->
    console.log err
).then((data2) ->
  console.log data2
, (err2) ->
  console.log err2
).done()

