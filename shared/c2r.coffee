parse2 = (answer) ->
	remove_diacritics = removeDiacritics

	answer = answer.replace(/[\[\]\<\>\{\}][\w\-]+?[\[\]\<\>\{\}]/g, '')
	console.log answer

	clean = (part.trim() for part in answer.split(/[^\w]or[^\w]|\[|\]|\{|\}|\;|\,|\<|\>|\(|\)/g))
	clean = (part for part in clean when part isnt '')
	pos = []
	neg = []
	prompt = []
	for part in clean 
		part = remove_diacritics(part) #clean out some non-latin characters
		part = part.replace(/\"|\'|\“|\”|\.|’|\:/g, '')
		part = part.replace(/-/g, ' ')
		
		if /equivalent|word form|other wrong/.test part
			# log 'equiv-', part
		else if /do not|dont/.test part
			# log 'neg-', part
			neg.push part
		else if /accept/.test part 
			comp = part.split(/before|until/)
			if comp.length > 1
				neg.push comp[1]
			pos.push comp[0]
			# log 'pos-', comp
		else if /prompt/.test part
			prompt.push part
		else
			pos.push part
	[pos, prompt, neg]
