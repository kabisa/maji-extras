_ = require('underscore')
Infector = require('helpers/infector')
memo = require('memo-is')

describe 'Infector', ->

  class Person
    name: -> 'FooBar'

  class PrefixInfector extends Infector
    infectModel: (modelClass) ->
      _.extend(modelClass::,
        nameWithPrefix: ->
          "Lt. #{@nameWithoutPrefix()}"
      )
      @aliasMethodChain(modelClass, 'name', 'Prefix')
      modelClass

  class SuffixInfector extends Infector
    infectModel: (modelClass) ->
      _.extend(modelClass::,
        nameWithSuffix: ->
          "#{@nameWithoutSuffix()} Jr."
      )
      @aliasMethodChain(modelClass, 'name', 'Suffix')
      modelClass

  modelClass = memo().is -> Person

  beforeEach ->
    @model = new (modelClass())()

  afterEach ->
    Person.desinfect?()

  describe 'the basic model', ->

    it 'returns a simple name', ->
      expect(@model.name()).to.eql 'FooBar'

  describe 'using prefix infector', ->
    modelClass.is ->
      (new PrefixInfector).infectModel(Person)

    it 'adds a prefix by default', ->
      expect(@model.name()).to.eql 'Lt. FooBar'

    it 'can still call the original method', ->
      expect(@model.nameWithoutPrefix()).to.eql 'FooBar'

    context 'after desinfection', ->
      it 'restores the original methods', ->
        Person.desinfect()
        expect(@model.name()).to.eql 'FooBar'

  describe 'using suffix infector', ->
    modelClass.is ->
      (new SuffixInfector).infectModel(Person)

    it 'adds a suffix by default', ->
      expect(@model.name()).to.eql 'FooBar Jr.'

  describe 'using suffix and prefix infector', ->
    modelClass.is ->
      (new SuffixInfector).infectModel(Person)
      (new PrefixInfector).infectModel(Person)

    it 'adds a suffix and prefix by default', ->
      expect(@model.name()).to.eql 'Lt. FooBar Jr.'

