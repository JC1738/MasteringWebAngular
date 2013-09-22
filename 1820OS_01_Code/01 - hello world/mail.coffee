nodemailer = require 'nodemailer'
restify = require 'restify'
assert = require 'assert'
Q = require 'q'

class Test

  myFunction: () ->
    console.log "this is a test"



module.exports = Test

class CallJason
  @client = null
  @payload = null
  constructor: (@url) ->
    @client = restify.createJsonClient
      url : @url,
      version: '*',
      accept: 'application/json'

  handleResponse: (err, req, res, obj) ->
    assert.ifError err
    for change in obj['change']
        console.log change.webLink
    #console.log '%j', obj
    @payload = obj


  get: (path) ->
    console.log 'Call Teamcity'
    @client.get path, (err, req, res, obj) =>
      @handleResponse err, req, res, obj
      @client.close()
      @payload

class SMTPHost
  constructor: (@host) ->
      @hostOptions =
        host: @host

class MailMessage
  constructor: (@to, @subject, @text) ->
    @mailOptions =
      from: "Team City <teamcity@opentable.com>"
      to: @to
      subject: @subject
      text: @text

class SendMessage
  constructor: (@message, @host) ->

  handleResponse: (error, response) ->
    if error
      console.log error
    else
      console.log "Message sent: " + response.message

  send: ->
    smtpTransport = nodemailer.createTransport "SMTP", @host.hostOptions
    smtpTransport.sendMail @message.mailOptions, (error, response) =>    #note fat arrow for call back
      @handleResponse(error, response)
      smtpTransport.close()

#host = new SMTPHost("otcmail.otcorp.opentable.com")

#message = new MailMessage "jcastillo@opentable.com", "Test Coffee", "Message Body"

#sender = new SendMessage message, host
#sender.send()
console.log 'Hello'

client = new CallJason "http://teamcity"

client.get '/guestAuth/app/rest/changes?build=id:378336'


console.log 'Finished'