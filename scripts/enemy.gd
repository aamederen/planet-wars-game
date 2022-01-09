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
	var planets = _get_planets_with_infection(world)
	
	for planet in planets:
		var ships_near_planet = _get_ships_around_planet(planet, world)
		for ship in ships_near_planet:
			if ship.infection == 0:
				if _should_infect_ship(planet, ship):
					ship.set_infection_rate(growth_coefficient)

func grow(bb, world):
	_log("growing")
	
	var planets = _get_planets_with_infection(world)
	var total_infection = 0
				
	for planet in planets:
		if planet.infection_rate > 0 && planet.infection_rate < 1:
			planet.set_infection(min(planet.infection_rate + growth_coefficient, 1))

		total_infection += planet.infection_rate
	
	if total_infection == 0:
		rng.randomize()
		if (rng.randf() < reapperance_chance):
			var random_index = rng.randi() % planets.size()
			var victim_planet = planets[random_index]
			victim_planet.infection_rate = 0.1
			_log("INFECTED PLANET " + str(victim_planet))

func _get_planets_with_infection(world):
	var planets = []
	
	for obj in world:
		if obj.has_method("get_player_name"): # If the object is a user...
			for plnt in obj.planets:
				planets.append(plnt)
				
	return planets
		
func _get_ships_around_planet(planet,world):
	pass # TODO
	return []
	
func _should_infect_ship(planet, ship):
	return false # TODO

func _log(msg):
	print("[enemy] ", msg)
	
