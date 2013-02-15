# parse2 = (answer) ->
# 	remove_diacritics = removeDiacritics

# 	answer = answer.replace(/[\[\]\<\>\{\}][\w\-]+?[\[\]\<\>\{\}]/g, '')
# 	console.log answer

# 	clean = (part.trim() for part in answer.split(/[^\w]or[^\w]|\[|\]|\{|\}|\;|\,|\<|\>|\(|\)/g))
# 	clean = (part for part in clean when part isnt '')
# 	pos = []
# 	neg = []
# 	prompt = []
# 	for part in clean 
# 		part = remove_diacritics(part) #clean out some non-latin characters
# 		part = part.replace(/\"|\'|\“|\”|\.|’|\:/g, '')
# 		part = part.replace(/-/g, ' ')
		
# 		if /equivalent|word form|other wrong/.test part
# 			# log 'equiv-', part
# 		else if /do not|dont/.test part
# 			# log 'neg-', part
# 			neg.push part
# 		else if /accept/.test part 
# 			comp = part.split(/before|until/)
# 			if comp.length > 1
# 				neg.push comp[1]
# 			pos.push comp[0]
# 			# log 'pos-', comp
# 		else if /prompt/.test part
# 			prompt.push part
# 		else
# 			pos.push part
# 	[pos, prompt, neg]



# ["Jerome David Salinger", "Salinger", "JD Salinger", "J.D. Salinger", "Jerome", "David"]
# ["Works Progress Administration", "WPA"]

# qwerty = "1234567890qwertyuiopasdfghjkl;'\\zxcvbnm,./"

# letter_coord = (letter) ->
# 	index = qwerty.indexOf(letter.toLowerCase())
# 	return [-1, -1] if index < 0
# 	[Math.floor(index / 10), index % 10]

# letter_cost = (a, b) ->
# 	return 0 if a.toLowerCase() == b.toLowerCase()
# 	[Ax, Ay] = letter_coord a
# 	[Bx, By] = letter_coord b
# 	return 1 if Ax < 0 or Bx < 0
# 	dist = Math.sqrt((Ax - Bx) * (Ax - Bx) + (Ay - By) * (Ay - By))
# 	return 1 if dist > 1
# 	return 0.5



# for letter in "dumrvfpvjr"
	

# "synecdoche"


# var levenshtein = (function(){

# 	var qwerty = "1234567890qwertyuiopasdfghjkl;'\\zxcvbnm,./";
# 	function letter_coord(letter){
# 		var index = qwerty.indexOf(letter.toLowerCase())
# 		if(index < 0) return [-1, -1];
# 		return [Math.floor(index / 10), index % 10]
# 	}

	
# 	function levenshtein( a, b ) {

# 		var lastDx = 0, lastDy = 0, last_offset = [0, 0];
		
# 		function letter_cost(A, B) {
			
# 			if(A.toLowerCase() == B.toLowerCase()) return 0;

# 			var Axy = letter_coord(A), Bxy = letter_coord(B);
			
# 			if(Axy[0] < 0 || Bxy[0] < 0) return 1;
			
# 			var Dx = Axy[0] - Bxy[0], Dy = Axy[1] - Bxy[1];
# 			last_offset = [Dx, Dy];

# 			var dist = Math.sqrt(Dx * Dx + Dy * Dy);
# 			if(dist > 1) return 1;
			
# 			if(lastDx == Dx && lastDy == Dy){
# 				return 0.01;
# 			}
# 			return 0.99;
# 		}



# 		var i, j, cost, d = [];

# 		if ( a.length == 0 ) return b.length;
# 		if ( b.length == 0 ) return a.length;
	 
# 		for ( i = 0; i <= a.length; i++ ) d[i] = [i];
# 		for ( j = 0; j <= b.length; j++ ) d[0][j] = j;
	 
# 		for ( i = 1; i <= a.length; i++ ){
# 			for ( j = 1; j <= b.length; j++ ){

# 				cost = letter_cost( a.charAt( i - 1 ),  b.charAt( j - 1 ))
	 			
# 				d[i][j] = Math.min( d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost );
				
# 				if(d[i][j] == d[i - 1][j - 1] + cost){
# 					// if this cost was indeed the lowest
# 					lastDx = last_offset[0];
# 					lastDy = last_offset[1];
# 				}
				
# 				if(i > 1 && j > 1 && a.charAt(i - 1) == b.charAt(j-2) && a.charAt(i-2) == b.charAt(j-1)){
# 					d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + cost)
# 				}
# 			}
# 		}
# 		return d[a.length][b.length];
# 	}

# 	return levenshtein;

# })()