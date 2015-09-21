'use strict';
var util         = require('util');
var Aim          = require('./AIM.coffee');
var debug        = require('debug')('meshblu-aim');
var EventEmitter = require('events').EventEmitter;

var MESSAGE_SCHEMA = {
  type: 'object',
  properties: {
    payload: {
      type: 'object',
      required: true
    }
  }
};

var OPTIONS_SCHEMA = {
  type: 'object',
  properties: {
    host: {
      type: 'string',
      required: true
    },
    port: {
      type: 'number',
      required: true,
      default: 12500
    }
  }
};

function Plugin(){
  var self = this;
  self.options = {};
  self.messageSchema = MESSAGE_SCHEMA;
  self.optionsSchema = OPTIONS_SCHEMA;
  return self;
}

util.inherits(Plugin, EventEmitter);

Plugin.prototype.onMessage = function(message){
  var payload = message.payload;
};

Plugin.prototype.onConfig = function(device){
  var self = this;
  debug('on config', device.options);
  self.setOptions(device.options);

  if(!self.options.host || !self.options.port){
    debug('missing options');
    return;
  }
  self.aim = new Aim(self.options, self.aimCallback);
};

Plugin.prototype.setOptions = function(options){
  this.options = options || {};
};

Plugin.prototype.aimCallback = function(message){
  var self = this;
  debug('got a message of ', JSON.stringify(message,null,2));
  self.emit('message', {devices: ['*'], topic: 'message', payload: message});
};

module.exports = {
  messageSchema: MESSAGE_SCHEMA,
  optionsSchema: OPTIONS_SCHEMA,
  Plugin: Plugin
};
