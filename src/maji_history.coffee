Backbone = require('backbone')
_ = require('underscore')

class MajiHistory extends Backbone.History

  activeRoute:
    router: null
    action: null

  constructor: ->
    super
    @on 'route', @_updateActiveRoute, this

  loadUrl: (fragmentOverride) ->
    fragment = @getFragment fragmentOverride
    @trigger 'loadingUrl', fragment
    @_fireLeaveRoute()
    super # Boolean. True if matched, false otherwise

  getFragment: (fragment, forcePushState) ->
    s = super
    @stripQuery(s)

  stripQuery: (fragment) ->
    return fragment unless _.contains(fragment, '?')
    [route, query] = fragment.split('?')
    route

  _updateActiveRoute: (router, action) ->
    @activeRoute = { router, action }

  _fireLeaveRoute: ->
    if @activeRoute.router?
      @activeRoute.router.trigger("leaveRoute:#{@activeRoute.action}", @activeRoute.router)
    @activeRoute.router = null
    @activeRoute.action = null

  hashQuery: ->
    hash = window.location.hash
    # parse the hash url
    #
    # /t_token/#products/02002?_ga=124124.1241241.124
    # hash: #products/02002?_ga=124124.1241241.124
    # hash query: ?_ga=124124.1241241.124

    result = {}
    if _.contains(hash, '?')
      [route, query] = hash.split('?')
      keyValues = query.split('&')
      for keyValue in keyValues
        [key, value] = keyValue.split('=')
        result[key] = value
    result

module.exports = MajiHistory
