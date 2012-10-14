// this is the minimal bootstrapping launcher code
// all it does is whatever is minimally necessary
// to launch the main server code which is in 
// coffeescript

require('coffee-script')
require('./server/main')




// var  app = require('connect').createServer()
// var assets = require('connect-assets')
// app.use(assets({src: "server/../assets"}))
// css.root = 'less'
// console.log(css("protobowl"))
// app.listen(3590)