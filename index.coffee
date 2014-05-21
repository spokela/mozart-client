#
# This file is part of Mozart
# (c) Spokela 2014
#

MozartClient = require './src/mozart-client'
events = require './src/events'

client = new MozartClient "tcp://127.0.0.1:5551", "tcp://127.0.0.1:5552", [
  events.CHANNEL_JOIN
]

client.on 'ready', ->
  bot = client.createBot "TestBot", "test", "test.spoke.la", "testing bot", "+i"
  bot.on 'ready', ->
    console.log 'bot is ready'
    # do amazing things here...

  client.startBot bot

client.on events.CHANNEL_JOIN, (channel, user) ->
  console.log "CHANNEL JOINED: #{ channel.name }"
  console.log user

client.start()
