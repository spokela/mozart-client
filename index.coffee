#
# This file is part of Mozart
# (c) Spokela 2014
#

MozartClient = require './src/mozart-client'
events = require './src/events'
{IRC_COMMANDS} = require './src/commands'

client = new MozartClient "tcp://127.0.0.1:5551", "tcp://127.0.0.1:5552", [
  events.CHANNEL_JOIN
]

client.on 'ready', ->
  bot = client.createBot "TestBot", "test", "test.spoke.la", "testing bot", "+i"
  bot.on 'ready', ->
    console.log 'bot is ready'
    client.registerBot bot
    # do amazing things here...
    bot.on events.USER_PRIVMSG, (e, sender, target, msg) ->
      console.log "PRIVMSG FROM: #{ sender.nickname }: #{ msg }"
      if msg.indexOf('!') != 0
        return

      tmp = msg.split(' ')
      cmd = tmp[0].substr(1).toLowerCase()

      if cmd == 'quit'
        bot.send(IRC_COMMANDS.USER_CONNECT, null, bot.id, msg.substr(cmd.length+1).trim())
      else if cmd == 'renick' && tmp[1] != undefined && tmp[1].length > 0
        bot.send(IRC_COMMANDS.USER_NICKNAME, null, bot.id, tmp[1])
      else if cmd == 'away'
        bot.send(IRC_COMMANDS.USER_AWAY, null, bot.id, msg.substr(cmd.length+1).trim())
      else if cmd == 'umode' && tmp[1] != undefined && tmp[1].length > 0
        bot.send(IRC_COMMANDS.USER_MODE, null, bot.id, null, tmp[1])
      else if cmd == 'join' && tmp[1] != undefined && tmp[1].length > 0
        bot.send(IRC_COMMANDS.CHANNEL_JOIN, null, bot.id, tmp[1])
      else if cmd == 'part' && tmp[1] != undefined && tmp[1].length > 0
        bot.send(IRC_COMMANDS.CHANNEL_PART, null, bot.id, tmp[1], msg.substr(cmd.length+tmp[1].length+3).trim())
      else if cmd == 'mode' && tmp.length >= 2
        bot.send(IRC_COMMANDS.CHANNEL_MODE, null, bot.id, tmp[1], msg.substr(cmd.length+tmp[1].length+3).trim())
      else if cmd == 'smode' && tmp.length >= 2
        bot.send(IRC_COMMANDS.CHANNEL_MODE, null, null, tmp[1], msg.substr(cmd.length+tmp[1].length+3).trim())
      else if cmd == 'topic' && tmp.length >= 2
        bot.send(IRC_COMMANDS.CHANNEL_TOPIC, null, bot.id, tmp[1], msg.substr(cmd.length+tmp[1].length+3).trim())
      else if cmd == 'stopic' && tmp.length >= 2
        bot.send(IRC_COMMANDS.CHANNEL_TOPIC, null, null, tmp[1], msg.substr(cmd.length+tmp[1].length+3).trim())
      else if cmd == 'say' && tmp.length >= 2
        bot.send(IRC_COMMANDS.PRIVMSG, null, bot.id, tmp[1], msg.substr(cmd.length+tmp[1].length+3).trim())
      else if cmd == 'say-notice' && tmp.length >= 2
        bot.send(IRC_COMMANDS.NOTICE, null, bot.id, tmp[1], msg.substr(cmd.length+tmp[1].length+3).trim())
      else if cmd == 'scnotice' && tmp.length >= 2
        bot.send(IRC_COMMANDS.NOTICE, null, null, tmp[1], msg.substr(cmd.length+tmp[1].length+3).trim())
      else if cmd == 'kick' && tmp.length >= 3
        bot.send(IRC_COMMANDS.CHANNEL_KICK, null, bot.id, tmp[1], tmp[2], msg.substr(cmd.length+tmp[1].length+tmp[2].length+4).trim())
      else if cmd == 'skick' && tmp.length >= 3
        bot.send(IRC_COMMANDS.CHANNEL_KICK, null, null, tmp[1], tmp[2], msg.substr(cmd.length+tmp[1].length+tmp[2].length+4).trim())

  client.startBot bot

client.on events.CHANNEL_JOIN, (channel, user) ->
  console.log "CHANNEL JOINED: #{ channel.name }"
  console.log user

client.start()
