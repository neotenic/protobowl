var levenshtein = (function(){
	// this is the standard qwerty keyboard,
	// we can ignore all those weird dvorak people
	
	// var qwerty = "1234567890qwertyuiopasdfghjkl;'\\zxcvbnm,./";
	var qwerty = "qwertyuiopasdfghjkl;zxcvbnm,./";

	function letter_coord(letter){
		var index = qwerty.indexOf(letter.toLowerCase())
		if(index < 0) return [-1, -1];
		return [index % 10, Math.floor(index / 10)]
	}
	var vowels = 'aeiouy', parseltongue = 'zsck';
	
	function letter_cost(A, B) {
		if(A.toLowerCase() == B.toLowerCase()) return 0;
		if(/\d/.test(A) && /\d/.test(B)) return 1.2;
		
		if(vowels.indexOf(A.toLowerCase()) != -1 && vowels.indexOf(B.toLowerCase()) != -1) return 0.2;
		if(parseltongue.indexOf(A.toLowerCase()) != -1 && parseltongue.indexOf(B.toLowerCase()) != -1) return 0.2;

		var Axy = letter_coord(A), Bxy = letter_coord(B);
		if(Axy[0] < 0 || Bxy[0] < 0) return 1;
		var Dx = Axy[0] - Bxy[0], Dy = Axy[1] - Bxy[1]
		
		// var dist = Math.sqrt(Dx * Dx + Dy * Dy);
		// if(dist > 1) return 1;

		if(Math.abs(Dx) > 1 || Math.abs(Dy) > 1) return 1;
		
		if(Dy == 0) return 0.5;

		return 0.7;
	}

	function levenshtein( a, b ) {

		var i, j, cost, d = [];

		if ( a.length == 0 ) return b.length;
		if ( b.length == 0 ) return a.length;
	 
		for ( i = 0; i <= a.length; i++ ) d[i] = [i];
		for ( j = 0; j <= b.length; j++ ) d[0][j] = j;
	 
		for ( i = 1; i <= a.length; i++ ){
			for ( j = 1; j <= b.length; j++ ){

				cost = letter_cost( a.charAt( i - 1 ),  b.charAt( j - 1 ))
	 
				d[i][j] = Math.min( d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost );
				
				if(i > 1 && j > 1 && a.charAt(i - 1) == b.charAt(j-2) && a.charAt(i-2) == b.charAt(j-1)){
					// transposition
					d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + 0.4)
				}
			}
		}
		return d[a.length][b.length];
	}

	return levenshtein;

})()

// function levenshtein( a, b ) {

// 	var i, j, cost, d = [];

// 	if ( a.length == 0 ) return b.length;
// 	if ( b.length == 0 ) return a.length;
 
// 	for ( i = 0; i <= a.length; i++ ) d[i] = [i];
// 	for ( j = 0; j <= b.length; j++ ) d[0][j] = j;
 
// 	for ( i = 1; i <= a.length; i++ ){
// 		for ( j = 1; j <= b.length; j++ ){
// 			if ( a.charAt( i - 1 ) == b.charAt( j - 1 ) ){
// 				cost = 0;
// 			}else{
// 				cost = 1;
// 			}
 
// 			d[i][j] = Math.min( d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost );
			
// 			if(i > 1 && j > 1 && a.charAt(i - 1) == b.charAt(j-2) && a.charAt(i-2) == b.charAt(j-1)){
// 				d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + cost)
// 			}
// 		}
// 	}
// 	return d[a.length][b.length];
// }

if(typeof exports !== "undefined"){
	exports.levenshtein = levenshtein;
}