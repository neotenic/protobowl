crypto = require 'crypto'

## Helpers------
RegExp.quote = (str) ->
    return (str+'').replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")

to_regex = (str) ->
	return new RegExp('^' + RegExp.quote(str))

# simple helper functions that hashes things
sha1 = (text) ->
	hash = crypto.createHash('sha1')
	hash.update(text + '')
	hash.digest('hex')

# basic statistical methods for statistical purposes
Avg = (list) -> Sum(list) / list.length
Sum = (list) -> s = 0; s += item for item in list; s
StDev = (list) -> mu = Avg(list); Math.sqrt Avg((item - mu) * (item - mu) for item in list)

# so i hears that robust statistics are bettrawr, so uh, heres it is
Med = (list) -> m = list.sort((a, b) -> a - b); m[Math.floor(m.length/2)] || 0
IQR = (list) -> m = list.sort((a, b) -> a - b); (m[~~(m.length*0.75)]-m[~~(m.length*0.25)]) || 0
MAD = (list) -> m = list.sort((a, b) -> a - b); Med(Math.abs(item - mu) for item in m)

exports.sha1 = sha1
exports.Avg = Avg
exports.Sum = Sum
exports.StDev = StDev
exports.Med = Med
exports.IQR = IQR
exports.MAD = MAD
exports.to_regex = to_regex
