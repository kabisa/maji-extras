class Infector
  aliasMethodChain: (klass, method, feature) ->
    withoutFeature = klass::[method]
    withFeature = klass::["#{method}With#{feature}"]

    if withFeature and withoutFeature
      klass::["#{method}Without#{feature}"] = withoutFeature
      klass::[method] = withFeature

module.exports = Infector
