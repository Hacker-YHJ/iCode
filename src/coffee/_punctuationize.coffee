module.exports = do ->
  notPunctReg = /[^\s\u2000-\u206F\u2E00-\u2E7F\\'!"#$%&()*+,\-.\/:;<=>?@\[\]^_`{|}~]/g

  makeDefault = (configObj) ->
    config = configObj || {}
    config.space = config.space || 'single'
    config

  punctuationize = (text, configObj) ->
    unless typeof text is 'string' || text instanceof String
      throw new Error("Input #{text} is not a string or string object.")
    res = text.replace(notPunctReg, '')
    config = makeDefault(configObj)
    if config.space is 'none'
      res = res.replace(/\s/g, '')
    else if config.space is 'single'
      # keep only single line break, in unix style
      res = res.replace(/\r\n/g, '\n')
        .replace(/\r/g, '\n')
        .replace(/\n\n+/g, '\n')
      # remove trailing space
        .replace(/\s+$/mg, '')
      # remove leading space
        .replace(/^\s+/mg, '')
      # keep only single space
        .replace(/\s\s+/g, ' ')
    res

  punctuationize
