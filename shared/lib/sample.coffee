class AliasMethod
        constructor: (object) ->
                probabilities = []
                @labelmap = [] #handle objects of stuff
                for label of object
                        if object.hasOwnProperty label
                                @labelmap.push label
                                probabilities.push object[label]

                count = probabilities.length
                sum = 0; sum += p for p in probabilities
                #clone and normalize
                probabilities = (p / sum for p in probabilities)

                @alias = []
                @prob = []
                avg = 1 / count
                small = []
                large = []
                for i in [0...count]
                        if probabilities[i] >= avg
                                large.push i
                        else
                                small.push i
                until small.length is 0 or large.length is 0
                        less = small.pop()
                        more = large.pop()
                        @prob[less] = probabilities[less] * count
                        @alias[less] = more
                        probabilities[more] += probabilities[less] - avg
                        if probabilities[more] >= avg
                                large.push more
                        else
                                small.push more
                until small.length is 0
                        @prob[small.pop()] = 1
                until large.length is 0
                        @prob[large.pop()] = 1

        next: ->
                col = Math.floor(Math.random() * @prob.length)
                if Math.random() < @prob[col]
                        return @labelmap[col]
                else 
                        return @labelmap[@alias[col]]

exports.AliasMethod = AliasMethod if exports?