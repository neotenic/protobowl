generateName = ->
	pick = (list) -> 
		n = list.split(',')
		n[Math.floor(n.length * Math.random())]

	adjective = 'flaming,aberrant,agressive,warty,hoary,breezy,dapper,edgy,feisty,gutsy,hardy,intrepid,jaunty,karmic,lucid,gastric,maverick,natty,oneric,precise,quantal,quizzical,curious,derisive,bodacious,nefarious,nuclear,nonchalant,marvelous,greedy,omnipotent,loquacious,rabid,redundant,dazzling,jolly,autoerotic,gloomy,valiant,pedantic,demented,prolific,scientific,pedagogical,robotic,sluggish,lethargic,bioluminescent,stationary,quirky,spunky,stochastic,bipolar,brownian,relativistic,defiant,rebellious,rhetorical,irradiated,electric,tethered,polemic,nostalgic,ninja,wistful,wintry,narcissistic,foreign,deistic,eclectic,discordant,cacophonous,drunk,racist,secular'
	animal = 'monkey,axolotl,warthog,hedgehog,badger,drake,fawn,gibbon,heron,ibex,jackalope,koala,lynx,meerkat,narwhal,ocelot,penguin,quetzal,kodiak,cheetah,puma,jaguar,panther,tiger,leopard,lion,neanderthal,walrus,mushroom,dolphin,giraffe,gnat,fox,possum,otter,owl,osprey,oyster,rhinoceros,quail,gerbil,jellyfish,porcupine,anglerfish,unicorn,seal,macaw,kakapo,squirrel,squid,rabbit,raccoon,turtle,tortoise,iguana,gecko,werewolf,traut'
	pick(adjective) + " " + pick(animal)

generatePage = ->
	pick = (list) -> 
		n = list.split(',')
		n[Math.floor(n.length * Math.random())]

	people = 'kirk,picard,feynman,einstein,erdos,huxley,robot,ben,batman,panda,pinkman,superhero,celebrity,traitor,alien,lemon,police,whale,astronaut,chicken,kitten,cats,shakespeare,dali,cherenkov,stallman,sherlock,sagan,irving,copernicus,kepler,astronomer'
	verb = 'on,enveloping,eating,drinking,in,near,sleeping,destroying,arresting,cloning,around,jumping,scrambling,painting,stalking,vomiting,defrauding,rappelling'
	noun = 'mountain,drugs,house,asylum,elevator,scandal,planet,school,brick,rock,pebble,lamp,water,paper,friend,toilet,airplane,cow,pony,egg,chicken,meat,book,wikipedia,turd,rhinoceros,paris,sunscreen,canteen,earwax,printer,staple,endorphins,trampoline,helicopter,feather,cloud,skeleton,uranus,neptune,earth,venus,mars,mercury,pluto,moon,jupiter,saturn,electorate'
	pick(people) + "-" + pick(verb) + "-" + pick(noun)

exports.generatePage = generatePage if exports?
exports.generateName = generateName if exports?