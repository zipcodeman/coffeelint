invertObject = (obj) ->
    new_obj = {}
    for prop of obj
        new_obj[obj[prop]] = prop
    new_obj

module.exports = class RuleProcessor
    rule:
        name: 'prefer_english_operator'
        description: "TODO: write me"
        level: 'ignore'
        doubleNotLevel: 'ignore'
        message: 'Don\'t use &&, ||, ==, !=, or ! (or do!)'
        invert: false
    tokens: ['COMPARE', 'UNARY_MATH', 'LOGIC']
    mappings:
        "==": "is",
        "!=": "isnt",
        "||": "or",
        "&&": "and",
        "!": "not"
    replace: (tok, alt) -> "Replace \"#{tok}\" with \"#{alt}\""
    lintToken: (token, tokenApi) ->
        config = tokenApi.config[@rule.name]
        level = config.level
        { first_column, last_column } = token[2]
        line = tokenApi.lines[tokenApi.lineNumber]
        actual_token = line[first_column..last_column]
        if actual_token is '!'
            if tokenApi.peek(1)?[0] is 'UNARY_MATH'
                actual_token = '!!'
            else if tokenApi.peek(-1)?[0] is 'UNARY_MATH'
                return

        context =
            if config.invert is true
                invertedMappings = invertObject(@mappings)
                if actual_token in invertedMappings
                    replace(actual_token, invertedMappings[actual_token])
            else if not config.invert
                if actual_token in @mappings
                    replace(actual_token, @mappings[actual_token])
                else if actual_token is "!!"
                    level = config.doubleNotLevel
                    '"?" is usually better than "!!"'
            else
                undefined

        if context?
            { level, context }
