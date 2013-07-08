console.log("screenshot");
var page = require('webpage').create();
page.viewportSize = {width: 1280, height: 1024};

page.open('http://protobowl.com/lobby', function(status){
	setTimeout(function(){
		page.render('protobowl.png');
		phantom.exit();
	}, 1000);
})
