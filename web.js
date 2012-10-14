// this is the minimal bootstrapping launcher code
// all it does is whatever is minimally necessary
// to launch the main server code which is in 
// coffeescript


require('coffee-script')
process.chdir(__dirname)
require('./server/main')
