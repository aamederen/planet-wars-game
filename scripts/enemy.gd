extends Reference
class_name Enemy

var reapperance_chance = 0.1
var spread_coefficient = 0.01
var growth_coefficient = 0.1
var rng = RandomNumberGenerator.new()

func _init():
	pass

func think_and_play(bb, world):
	# here comes the AI
	_log("enemy thinking")
	
	# Jump to a next object

func grow(bb, world):
	_log("growing")
	var planets = []
	
	for obj in world:
		if obj.has_method("get_player_name"): # If the object is a user...
			for plnt in obj.planets:
				planets.append(plnt)
	
	var total_infection = 0
				
	for planet in planets:
		if planet.infection_rate > 0 && planet.infection_rate < 1:
			planet.infection_rate = min(planet.infection_rate + growth_coefficient, 1)

		total_infection += planet.infection_rate
	
	if total_infection == 0:
		rng.randomize()
		if (rng.randf() < reapperance_chance):
			var random_index = rng.randi() % planets.size()
			var victim_planet = planets[random_index]
			victim_planet.infection_rate = 0.1
			_log("INFECTED PLANET " + str(victim_planet))
	
	
func _log(msg):
	print("[enemy] ", msg)
	
