// this is the minimal bootstrapping launcher code
// all it does is whatever is minimally necessary
// to launch the main server code which is in
// coffeescript

require('./tools/node_modules/coffee-script');
var protobowl_main = require('./server/main');
var protocompile = require('./tools/watcher');
protocompile.watch(protobowl_main.new_update);


// This is probably the first file you're going to
// look at. Probably because it's the only piece of
// code which appears to reside in the root directory
// of the project, and you're going to look at this
// just to get a little indication of where to start
// to make sense of the logical flow of the project
// or to get a small sample of what the rest of the
// code will look like, to find out how exactly to
// brace for impact. Well, the fact that there are
// only three lines of legitimate code in the entire
// file all rather incidentally matched for length
// does not signify an overall poetic eloquence to
// the way this project is written. It's quite hacky
// but gets the job done rather well. There are some
// parts which are quite over-engineered, and other
// parts which are woefully under-so, but overall,
// this constitutes one of the largest programs that
// I have ever written, at least to this date.

// But anyway, this is isn't so much a commentary
// on the state of protobowl's code, but rather a
// simple plea to the future. This is a time capsule
// embedded in a string of bits and bytes ignored
// by non-human lexers, parsers and compilers. I
// hope that this message gets received, and that
// its audience still exists and remains piqued,
// entertained enough to go through with their part
// of the bargain.

// 2014.

// Right now, it's 2012, rather close to the end
// of it. If those doom-sayers are indeed correct
// protobowl might only have lived six months,
// certainly a pitiful death, but perhaps the worse
// alternative is for protobowl to die with my own
// neglect clutching the figurative knife.

// I'm not really known at all, but if you were to
// know me, I'm rather infamous for leaving projects
// to rot on the sidewalk. In fact my inspiration for
// writing these kinds of messages comes from none
// other than previous dead projects.

// The mission, if you choose to accept it is simple.
// Email me in the distant future, 2014, when it
// comes nigh. Particularly if I haven't committed
// anything to this repository for a while.

// antimatter15@gmail.com