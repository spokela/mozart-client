#
# This file is part of Mozart
# (c) Spokela 2014
#
{EventEmitter} = require 'events'
{IRC_COMMANDS} = require './commands'

class Bot extends EventEmitter
  constructor: (@nickname, @ident, @hostname, @realname, @umodes) ->
    @slot = null
    @slotCallback = null
    @id = null

  init: (slot) ->
    @slot = slot

    self = @
    @slot.on 'message', (data) ->
      obj = JSON.parse(data)

      console.log obj
      if typeof self.slotCallback == 'function'
        self.slotCallback(obj)

      self.slotCallback = null

    @send(
      IRC_COMMANDS.USER_CONNECT,
      (response) ->
        if response.status != 'OK'
          throw new Error 'Cannot create bot: '+ response.error
        self.id = response.data
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