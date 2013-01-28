# hey wat oh hmm

# this is a list based on the Google somethign list somewhere
dirty_regex = "xxx|a55|bum|cok|cox|cum|sex|fuk|fux|jap|kum|nob|tit|fag|ass|hore|d1ck|pube|pron|twat|tw4t|turd|kock|anal|crap|wank|4r5e|porn|poop|titt|tits|coon|arse|knob|kawk|teez|jizz|cock|jiz |jism|piss|spac|cnut|butt|smut|phuq|fuks|slut|5h1t|feck|5hit|clit|phuk|muff|mofo|mof0|homo|hoer|pawn|p0rn|fcuk|hoar|cl1t|hell|cunt|shit|shi+|cipa|ar5e|dlck|fuck|shag|sh1t|sh!t|sh!+|fags|fook|m0fo|m0f0|cawk|lust|anus|dink|cums|boob|nazi|c0ck|kums|wang|dick|damn|dyke|mo-fo|arrse|twunt|labia|willy|vulva|asses|a_s_s|b!tch|b00bs|b17ch|b1tch|balls|v1gra|bi+ch|jizm |teets|bitch|w00se|horny|spunk|boner|hoare|heshe|sluts|skank|boobs|mutha|n1gga|nigga|chink|pusse|shits|cocks|whore|whoar|wanky|fux0r|fuker|fucks|shite|cunts|penis|dildo|fucka|dinks|phuck|semen|dirsa|phuks|fanyy|fanny|doosh|fagot|porno|s hit|duche|faggs|prick|lmfao|f4nny|pussy|pussi|clits|niggas|wanker|retard|pornos|rimjaw|s.o.b.|sadist|faggot|v14gra|twatty|l3itch|l3i+ch|kummer|tosser|kondum|knobed|biatch|bloody|hotsex|bollok|snatch|smegma|booobs|xrated|goatse|muther|gaysex|buceta|n1gger|nigg3r|nigg4h|bugger|niggah|rectum|niggaz|nigger|cummer|viagra|fukwit|fukkin|fukker|shitey|shited|fuckme|fuckin|fucker|orgasm|fucked|pecker|cyalis|dildos|fooker|vagina|phuked|flange|fecker|fcuker|scrote|fatass|pimpis|pissed|pisser|scroat|pisses|doggin|pissin|fagots|shiting|breasts|fuckwit|titties|titwank|f u c k|willies|nobhead|fukwhit|pussys |niggers|f_u_c_k|pussies|fagging|faggitt|gaylord|pricks |tittie5|god-dam|cumming|pissing|cumshot|t1tties|bitcher|pissers|ballbag|bitches|fcuking|jackoff|phukked|bitchin|fellate|knobead|shitter|knobend|titfuck|shemale|shitted|t1tt1e5|kondums|goddamn|blowjob|kumming|bastard|boiolas|bollock|s_h_i_t|shaggin|lusting|shagger|scrotum|phuking|twunter|shitty |dogging|asshole|fuckers|schlong|rimming|boooobs|fucking|bellend|bestial|nutsack|fuckhead|nobjokey|assfukka|screwing|shitdick|assholes|shitfuck|asswhole|shitfull|shithead|pissoff |twathead|masterb8|phukking|felching|fellatio|ma5terb8|coksucka|ballsack|beastial|cocksuka|fistfuck|cocksuck|testicle|nobjocky|testical|cockhead|phonesex|knobhead|bitchers|bitching|cockface|blow job|blowjobs|orgasms |horniest|booooobs|shagging|shitting|orgasim |fuckings|clitoris|butthole|buttmuch|numbnuts|fuckwhit|gangbang|buttplug|cyberfuc|shitings|dickhead|fistfucks|cocksukka|ejakulate|ejaculate|shitters |goddamned|fuckheads|masochist|orgasims |shittings|jerk-off |knobjocky|tittywank|knobjokey|cockmunch|tittyfuck|pigfucker|mothafuck|cuntlick |pissflaps|assfucker|jack-off |nob jokey|motherfuck|gangbanged|gangbangs |god-damned|booooooobs|kunilingus|c0cksucker|cocksucked|mothafucks|cocksucker|cocksucks |bestiality|cokmuncher|ass-fucker|ma5terbate|masterbat*|fannyflaps|masterbat3|masterbate|masturbate|cunilingus|cuntlicker|ejaculated|mothafucka|dog-fucker|cyberfuck |m45terbate|pornography|cyberfucker|muthafecker|mothafuckaz|penisfucker|ejaculates |cock-sucker|cunnilingus|cunillingus|motherfucks|ejaculation|f u c k e r|cockmuncher|fingerfuck |mothafuckin|mothafucker|fudgepacker|master-bate|cocksucking|mothafuckas|fistfucked |fistfucker |fannyfucker|beastiality|cyberfuckers|cyberfucked |donkeyribber|cuntlicking |ejaculating |ejaculatings|mothafuckers|fingerfucker|motherfuckin|tittiefucker|fingerfucks |fistfuckers |fistfucking |fistfuckings|motherfucker|motherfucked|fudge packer|mutherfucker|mothafucked |bunny fucker|hardcoresex |motherfuckka|masterbation|muthafuckker|fingerfucked |fingerfuckers|mother fucker|mothafuckings|mothafucking |cyberfucking |masterbations|motherfucking|motherfuckers|son-of-a-bitch|fingerfucking |carpet muncher|motherfuckings|fuckingshitmotherfucker"


leet_decode = (str) ->
	unless leet_decode.cache
		leet_decode.cache = {}
		for letter, matches of leet_decode.db
			for match in matches.reverse()
				leet_decode.cache[RegExp.quote(match)] = letter
		
		leet_decode.keys = (key for key of leet_decode.cache).sort (a, b) ->
			b.length - a.length
	
	for key in leet_decode.keys
		str = str.replace(new RegExp(key, 'g'), leet_decode.cache[key])

	return str

# based on http://www.chatslang.com/leet_sheet
# for leetspeek type substitutions

leet_decode.db = {
	'o': ['0', '()', '[]'], 
	's': ['5', '$', 'z'], 
	't': ['7'], 
	'a': ['4', '@', '^', '/\\', '/-\\'],
	'b': ['8', '6', '13', '|3', '/3'],
	'e': ['3', '&', '[-'],
	'l': ['1', '!', '|','|_', '1_'],
	'f': ['|=', '/=', '|#', 'ph'],
	'd': ['|)', '[)', '|>', '|o'],
	'h': ['#', '}{', '|-|', '[-]', ')-(', '(-)', '/-/'],
	'j': [']', '_|', '_/', '</', '(/'],
	'k': ['|<', '|{', '|('],
	'm': ['|v|', '|\\/|', '/\\/\\', '(v)', '/|\\', '//.', '^^'],
	'n': ['|\\|', '/\\/', '[\\]', '</>', '^/'],
	'p': ['|o', '|*', '|>', '|"', '9', '|7'],
	'r': ['2', '/2', 'l2'],
	'u': ['(_)', '|_|', '(_)', 'v'],
	'v': ['\\/'],
	'w': ['\\/\\/', 'VV', "\\'", "'//", '\\|//', '\\^/', '(n)'],
	'x': ['%', '*', '><', '}{', ')('],
	'y': ['j']
}


# here's the magic function
check_profanity = (text) ->
	
	# well if its not hiding, then well, ok
	prefilter = (dirty_regex? and new RegExp(' (' + dirty_regex + ') ', 'i').exec(' ' + text.replace(/[^a-z ]/ig, '') + ' '))
	return true if prefilter
	
	# convert esoteric unicode to ascii
	working = unidecode?(text) || text
	
	# convert leet to ascii
	
	working = leet_decode(working)

	# remove non alpha characters
	working = working.replace(/[^a-z ]/ig, '')
	
	unless leet_decode.dirty_regex
		leet_decode.dirty_regex = (leet_decode(word) for word in dirty_regex.split('|')).join('|')

	dirty = false

	# this allows us to ban creative permutations of things
	for word in working.split(' ')
		remaining = word.replace(new RegExp('(' + leet_decode.dirty_regex + ')', 'ig'), '')
		continue if remaining is word
		removed = word.length - remaining.length
		# console.log remaining, word
		if remaining.length is 0 or (remaining.length > 3 and removed > 3)
			dirty = true
			break

	return dirty