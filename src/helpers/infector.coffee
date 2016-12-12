class Infector
  aliasMethodChain: (klass, method, feature) ->
    klass::__infected ?= [ ]
    klass::__infected.push(method) if klass::__infected.indexOf(method) is -1
    klass::["__original_#{method}"] ?= klass::[method]

    klass.desinfect ?= ->
      for method in this::__infected
        this::[method] = this::["__original_#{method}"]

    withoutFeature = klass::[method]
    withFeature = klass::["#{method}With#{feature}"]

    if withFeature and withoutFeature
      klass::["#{method}Without#{feature}"] = withoutFeature
      klass::[method] = withFeature

module.exports = Infector
