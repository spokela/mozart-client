#
# This file is part of Mozart
# (c) Spokela 2014
#
{EventEmitter} = require 'events'
{BOT_COMMANDS, SERVER_COMMANDS} = require './commands'

class Bot extends EventEmitter
  constructor: (@nickname, @ident, @hostname, @realname, @umodes) ->
    @slot = null
    @slotCallback = null

  init: (slot) ->
    @slot = slot

    self = @
    @slot.on 'message', (data) ->
      if typeof self.slotCallback == 'function'
        self.slotCallback(data)
      self.slotCallback = null

    @send(
      BOT_COMMANDS.CONNECT,
      ->
        @emit 'ready'
      @nickname,
      @ident,
      @hostname,
      @realname,
      @umodes
    )

  # Arguments are after the callback because we can send commands without arguments but still waiting for an answer
  send: (cmd, callback, args...) ->
    console.log "Sending via slot: #{ cmd }% #{ JSON.stringify(args) }"
    @slotCallback = callback
    @slot.send "#{ cmd }% #{ JSON.stringify(args) }"

module.exports = Bot