MajiHistory = require('maji_history')
Backbone = require('backbone')

describe 'MajiHistory', ->

  beforeEach ->
    @history = new MajiHistory
    @history.options = root: '/'

  afterEach ->
    @history.stop()
    @history = null

  it 'triggers \'loadingUrl\' when url is loading', ->
    @history.start()
    spy = sinon.spy()
    @history.once('loadingUrl', spy)
    @history.loadUrl 'my/fancy/route'
    expect(spy).to.have.been.calledWith('my/fancy/route')

  describe 'loadingUrl', ->

    describe 'loadingUrl trigger', ->

      beforeEach ->
        Backbone.history = @history
        @router = new class extends Backbone.Router
          routes:
            'myroute': 'myroute'
          myroute: sinon.spy()
        @history.start()

      afterEach ->
        @router = null

      it 'fires trigger before routing', ->
        triggerSpy = sinon.spy()
        @history.on 'loadingUrl', triggerSpy
        @history.navigate 'myroute', trigger: yes

        expect(triggerSpy).to.have.been.called
        expect(@router.myroute).to.have.been.called
        expect(triggerSpy).to.have.been.calledBefore @router.myroute

    describe 'leaveRoute trigger', ->

      beforeEach ->
        Backbone.history = @history

        @router = new class extends Backbone.Router
          routes:
            'stub-route': 'stubAction'
            'stub-routeWithArgs/:product': 'stubActionWithArgs'
            'redirect-route': 'redirectAction'
          stubActionWithArgs: sinon.stub()
          stubAction: sinon.spy()
          redirectAction: ->
            setTimeout =>
              @navigate 'stub-route', trigger: yes
        @history.start()

      afterEach ->
        @router = null

      it 'keeps track of last invoked router', ->
        Backbone.history.navigate('stub-route', trigger: yes)
        expect(Backbone.history.activeRoute.router).to.eql @router

      it 'keeps track of last invoked action', ->
        Backbone.history.navigate('stub-route', trigger: yes)
        expect(Backbone.history.activeRoute.action).to.equal 'stubAction'

      it 'fires a leaveRoute on the router', ->
        Backbone.history.navigate('stub-route', trigger: yes)
        spy = sinon.spy()
        @router.once('leaveRoute:stubAction', spy)
        Backbone.history.navigate('something', trigger: yes)
        expect(spy).to.have.been.calledWith(@router)

      it 'ignores query strings of the route', ->
        path = "stub-routeWithArgs/foobar?_ga=efvef"
        Backbone.history.navigate(path, trigger: yes)
        expect(@router.stubActionWithArgs).to.have.been.calledWith('foobar')

      it 'fires the leaveRoute only once', ->
        Backbone.history.navigate('stub-route', trigger: yes)
        spy = sinon.spy()
        @router.on('leaveRoute:stubAction', spy)
        Backbone.history.navigate('something', trigger: yes)
        expect(spy).to.have.been.calledWith(@router)
        spy.reset()

        Backbone.history.navigate('something-again', trigger: yes)
        expect(spy).to.not.have.been.calledWith(@router)

      it 'doesn\'t fire leaveRoute when navigation to same route multiple times', ->
        Backbone.history.navigate('stub-route', trigger: yes)
        spy = sinon.spy()
        @router.on('leaveRoute:stubAction', spy)
        Backbone.history.navigate('stub-route', trigger: yes)
        expect(spy).to.not.have.been.calledWith(@router)

      it 'fires if route redirects', (done) ->
        spy = sinon.spy()
        @router.on('leaveRoute:redirectAction', spy)
        Backbone.history.navigate('redirect-route', trigger: yes)
        setTimeout(
          =>
            expect(spy).to.have.been.calledWith(@router)
            done()
          20
        )

  describe '#hashQuery', ->
    beforeEach ->
      window.location.hash = '#hello?a=b&c=d'

    it 'parses the hash query string', ->
      expect(@history.hashQuery()).to.eql(a: 'b', c: 'd')

    describe 'without query string', ->
      beforeEach ->
        window.location.hash = '#bye'

      it 'parses the hash query string', ->
        expect(@history.hashQuery()).to.eql({})

