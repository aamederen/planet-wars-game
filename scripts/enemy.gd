extends Reference
class_name Enemy

var reapperance_chance = 0.1
var spread_coefficient = 0.01
var growth_coefficient = 0.02
var rng = RandomNumberGenerator.new()

func _init():
	pass

func think_and_play(bb, world):
	# here comes the AI
	rng.randomize()
	
	# Jump from planet to ships
	var planets = _get_planets_with_infection(world)
	
	for planet in planets:
		var ships_near_planet = _get_ships_around_planet(planet, world)
		for ship in ships_near_planet:
			if ship.infection_rate == 0:
				if _should_infect_ship(planet, ship):
					ship.set_infection(min(ship.infection_rate + growth_coefficient, 1))
					planet.set_infection(min(planet.infection_rate / 2, 0.1))
					_log("INFECTED a SHIP!")
					
	# Jump from a ship to another planet
	var ships = _get_ships_with_infection(world)
	
	for ship in ships:
		var planets_near_ship = _get_planets_around_ship(ship, world)
		for planet in planets_near_ship:
			if planet.infection_rate == 0:
				if _should_infect_planet(ship, planet):
					planet.set_infection(growth_coefficient)
					ship.set_infection(0)
					_log("INFECTION JUMPED TO A PLANET")

func grow(bb, world):
	var all_planets = _all_planets(world)
	var planets = _get_planets_with_infection(world)
	var ships = _get_ships_with_infection(world)
	var total_infection = 0
	rng.randomize()
				
	for planet in planets:
		planet.set_infection(min(planet.infection_rate + growth_coefficient, 1))
		total_infection += planet.infection_rate
		
	for ship in ships:
		ship.set_infection(min(ship.infection_rate + growth_coefficient, 1))
		total_infection += ship.infection_rate
		
		if ship.infection_rate == 1:
			bb.explode_ship(ship)
	
	if total_infection == 0:
		if (rng.randf() < reapperance_chance):
			var random_index = rng.randi() % all_planets.size()
			var victim_planet = all_planets[random_index]
			victim_planet.infection_rate = 0.1
			_log("INFECTED PLANET " + str(victim_planet))
			
	_log("Ships: %d, Planets: %d, total: %s" % [ships.size(), planets.size(), total_infection])

func _all_planets(world):
	var planets = []
	for obj in world:
		if obj is Bot:
			for planet in obj.planets:
				planets.append(planet)
	
	return planets

func _get_planets_with_infection(world):
	var planets = []
	var all_planets = _all_planets(world)
	for plnt in all_planets:
		if plnt.infection_rate > 0:
			planets.append(plnt)
				
	return planets
		
func _get_ships_with_infection(world):
	var ships = []
	
	for obj in world:
		if obj.has_method("get_player_name"): # If the object is a user...
			for ship in obj.ships:
				if ship.infection_rate > 0:
					ships.append(ship)
				
	return ships
		
func _get_ships_around_planet(planet,world):
	var ships = []
	
	for obj in world:
		if obj is Bot:
			for ship in obj.ships:
				# TODO: Check distance
				ships.append(ship)
			
	return ships
	
func _get_planets_around_ship(ship, world):
	var planets = []
	
	for obj in world:
		if obj is Bot:
			for planet in obj.planets:
				# TODO: Check distance
				planets.append(planet)
				
	return planets
	
func _should_infect_ship(planet, ship):
	return planet.infection_rate > 0.8 and ship.infection_rate < 0.2 and rng.randf() < 0.3
	
func _should_infect_planet(ship, planet):
	return ship.infection_rate > 0.6 and rng.randf() < 0.1

func _log(msg):
	print("[enemy] ", msg)
	
