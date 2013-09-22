nodemailer = require 'nodemailer'
restify = require 'restify'
assert = require 'assert'
Q = require 'q'

exports.UserObj =
  class UserObj
    constructor: (@name) ->
      console.log "#{ @name } called as a module"

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

