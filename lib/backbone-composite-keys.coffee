_ = @_ or require 'underscore'

(module ? {}).exports = bind = (Backbone) ->

  # Save the original `set`
  set = Backbone.Model::set

  _.extend Backbone.Model::,

    # Generate an id base on `idAttribute`
    _generateId: (attrs = @attributes) ->
      return attrs[@idAttribute] if typeof @idAttribute is 'string'
      indexes = []
      for index in @idAttribute
        return undefined unless val = attrs[index]
        indexes.push val
      indexes.join '-'

    set: (key, val, options) ->
      return @ unless key?
      if _.isObject key
        attrs = key
        options = val
      else
        (attrs = {})[key] = val
      return false unless @_validate attrs, options || {}
      @_previousId = @id
      @id = @_generateId _.extend {}, @attributes, attrs
      set.apply @, arguments

  # Save the original `_onModelEvent`
  _onModelEvent = Backbone.Collection::_onModelEvent

  _.extend Backbone.Collection::,
    get: (obj) ->
      return undefined unless obj?
      @_idAttr or= @model::idAttribute
      return this._byId[obj.id || obj.cid || @model::_generateId(obj) || obj]

    _onModelEvent: (event, model, collection, options) ->
      if model and event is 'change' and model.id isnt model._previousId
        delete @_byId[model._previousId]
        @_byId[model.id] = model if model.id?
      _onModelEvent.apply @, arguments

  Backbone

bind Backbone if @Backbone
