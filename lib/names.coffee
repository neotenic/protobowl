do ->
	generateName = ->
		adjective = 'flaming,aberrant,agressive,warty,hoary,breezy,dapper,edgy,feisty,gutsy,hardy,intrepid,jaunty,karmic,lucid,maverick,natty,oneric,precise,quantal,quizzical,curious,derisive,bodacious,nefarious,nuclear,nonchalant'
		animal = 'monkey,axolotl,warthog,hedgehog,badger,drake,fawn,gibbon,heron,ibex,jackalope,koala,lynx,meerkat,narwhal,ocelot,penguin,quetzal,kodiak,cheetah,puma,jaguar,panther,tiger,leopard,lion,neanderthal,walrus,mushroom,dolphin'
		pick = (list) -> 
			n = list.split(',')
			n[Math.floor(n.length * Math.random())]
		pick(adjective) + " " + pick(animal)

	generatePage = ->
		people = 'kirk,feynman,huxley,robot,ben,batman,panda,pinkman,superhero,celebrity,traitor,alien,lemon,police,whale,astronaut'
		verb = 'on,enveloping,eating,drinking,in,near,sleeping,destruction,arresting,cloning,around,jumping,scrambling'
		noun = 'mountain,drugs,house,asylum,elevator,scandal,planet,school,brick,lamp,water,paper,friend,toilet,airplane,cow,pony'
		pick = (list) -> 
			n = list.split(',')
			n[Math.floor(n.length * Math.random())]
		pick(people) + "-" + pick(verb) + "-" + pick(noun)

	exports.generatePage = generatePage
	exports.generateName = generateName