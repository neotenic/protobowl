// this is the minimal bootstrapping launcher code
// all it does is whatever is minimally necessary
// to launch the main server code which is in
// coffeescript

require('./tools/node_modules/coffee-script');
// var simple = require('./server/simplestatic');
// var protobowl_main = require('./server/main');
// var protocompile = require('./tools/watcher');
// protocompile.watch(protobowl_main.new_update);

require('./tools/watcher');

// require('./build/server/main')
// require('./build/server/static')

// var cp = require('child_process');
// cp.fork(__dirname + '/build/server/main.js')
// cp.fork(__dirname + '/build/server/static.js')