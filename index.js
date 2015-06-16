'use strict';
var util = require('util');
var EventEmitter = require('events').EventEmitter;
var debug = require('debug')('meshblu-aim');
var Aim = require('./AIM');

var MESSAGE_SCHEMA = {
  type: 'object',
  properties: {
    action: {
      type: 'string',
      required: true,
      enum : ['GetViewerEvents', 'GetAudienceStatus', 'GetAudienceDetails', 'StopViewerEvents']
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

var self;

function Plugin(){
  self = this;
  this.options = {};
  this.messageSchema = MESSAGE_SCHEMA;
  this.optionsSchema = OPTIONS_SCHEMA;
  return this;
}

util.inherits(Plugin, EventEmitter);

Plugin.prototype.onMessage = function(message){
  var self = this;
  var action = message.action || message.payload.action;
  if(action){
    if(action === 'GetViewerEvents'){
      self.aim.getViewerEvents(function(viewerEvents){
        debug('The viewer events are', viewerEvents);
        self.emit('data', viewerEvents);
      });
    } else if (action === 'GetAudienceStatus'){
      self.aim.getAudienceStatus(function(audienceStatus){
        debug('The audience status is', audienceStatus);
        self.emit('data', audienceStatus);
      });
    } else if(action === 'GetAudienceDetails'){
      self.aim.getAudienceStatus(function(audienceStatus){
        debug('The audience status is', audienceStatus);
        self.emit('data', audienceStatus);
      });
    }
  }
};

Plugin.prototype.onConfig = function(device){
  this.setOptions(device.options||{});
  this.aim = new Aim(this.options);
};

Plugin.prototype.setOptions = function(options){
  this.options = options;
};

Plugin.prototype.aimCallback = function(message){
  debug('Got a message of ', JSON.stringify(message,null,2));
  self.emit('message', {devices: ['*'], topic: 'message', payload: message});
}

module.exports = {
  messageSchema: MESSAGE_SCHEMA,
  optionsSchema: OPTIONS_SCHEMA,
  Plugin: Plugin
};
