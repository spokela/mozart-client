#
# This file is part of Mozart
# (c) Spokela 2014
#
zmq = require 'zmq'
{EventEmitter} = require 'events'
Bot = require './bot'

class MozartClient extends EventEmitter
  constructor: (@subscriberAddr, @slotAddr = null, @subscribeTo = []) ->
    @subscriber = null
    @slot = null

  initSubscriber: ->
    if @subscriber != null
      throw new Error 'Subscriber is already initialized'

    @subscriber = zmq.socket 'sub'
    @subscriber.connect @subscriberAddr

    for event in @subscribeTo
      @subscriber.subscribe event

    self = @
    @subscriber.on 'message', (data) ->
      self.handle data

    console.log 'Subscriber connected'

  initSlot: ->
    if @slotAddr == null
      throw new Error 'Slot address is not defined'

    if @slot != null
      throw new Error 'Slot already initialized'

    @slot = zmq.socket 'req'
    @slot.connect @slotAddr

    console.log 'Slot connected'

  start: ->
    @initSubscriber()

    if @slotAddr != null
      @initSlot()

    @emit 'ready'

  handle: (data) ->
    # ignore empty messages
    if data == null || data.length <= 0
      return

    data = data.toString()
    if data.indexOf('% ') == -1
      throw new Error "Invalid message recieved from Subscriber: #{ data }"

    split = data.split('% ')
    args = JSON.parse(split[1])
    args.unshift(split[0])
    @emit.apply(@, args)

  createBot: (nickname, ident = "ident", hostname = "localhost", realname = "mozart-client bot", umodes = "") ->
    bot = new Bot nickname, ident, hostname, realname, umodes
    return bot

  startBot: (bot) ->
    if @slot == null
      throw new Error "Creating a bot require a Slot"

    bot.init @slot

module.exports = MozartClient