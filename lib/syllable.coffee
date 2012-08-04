do ->
    syllables = (word) ->
        word = word.toLowerCase().replace(/[^a-z]/g, '')
        problemWords = {
            simile: 3,
            forever: 3,
            shoreline: 2
        }
        return problemWords[word] if word of problemWords

        prefixSuffix = [
            /^un/,
            /^fore/,
            /ly$/,
            /less$/,
            /ful$/,
            /ers?$/,
            /ings?$/
        ]

        count = 0
        for fix in prefixSuffix
            tmp = word.replace(fix, '') 
            count++ if tmp != word
            word = tmp

        subSyllables = [
            /cial/,
            /tia/,
            /cius/,
            /cious/,
            /giu/,
            /ion/,
            /iou/,
            /sia$/,
            /[^aeiuoyt]{2,}ed$/,
            /.ely$/,
            /[cg]h?e[rsd]?$/,
            /rved?$/,
            /[aeiouy][dt]es?$/,
            /[aeiouy][^aeiouydt]e[rsd]?$/,
            /^[dr]e[aeiou][^aeiou]+$/,
            /[aeiouy]rse$/
        ]
        addSyllables = [
            /ia/,
            /riet/,
            /dien/,
            /iu/,
            /io/,
            /ii/,
            /[aeiouym]bl$/,
            /[aeiou]{3}/,
            /^mc/,
            /ism$/,
            /([^aeiouy])\1l$/,
            /[^l]lien/,
            /^coa[dglx]./,
            /[^gq]ua[^auieo]/,
            /dnt$/,
            /uity$/,
            /ie(r|st)$/
        ]

        for part in word.split(/[^aeiouy]+/)
            count++ if part isnt ''

        for sub in subSyllables
            count -= word.split(sub).length - 1

        for add in addSyllables
            count += word.split(add).length - 1

        return Math.max(1, count)

    exports.syllables = syllables