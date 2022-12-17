extends Reference
class_name Enemy

var reapperance_chance = 0.1
var spread_coefficient = 0.01
var growth_coefficient = 0.01
var rng = RandomNumberGenerator.new()
var planets = []

func _init():
	pass
	
func add_planet(planet:Planet):
	planet.set_title("ENEMY")
	planet.set_halo_color(Color("#f7d602"))
	planets.append(planet)

func remove_planet(planet):
	planet.set_title("")
	planets.remove(planets.find(planet))
	planet.set_halo_color(null)

func think_and_play(bb, world):
	# here comes the AI
	rng.randomize()
	
	# Jump from planet to ships
	var infected_planets = _get_planets_with_infection(world)
	
	for planet in infected_planets:
		var ships_near_planet = _get_ships_around_planet(planet, world)
		for ship in ships_near_planet:
			if ship.infection_rate == 0:
				if _should_infect_ship(planet, ship):
					ship.set_infection(min(ship.infection_rate + growth_coefficient, 1))
					planet.set_infection(max(planet.infection_rate / 2, 0.1))
					_log("INFECTED a SHIP!")
					
	# Jump from a ship to another planet
	var ships = _get_ships_with_infection(world)
	
	for ship in ships:
		var planets_near_ship = _get_planets_around_ship(ship, world)
		var ships_near_ship = _get_ships_around_ship(ship, world)
		
		if ship.infection_rate == 1:
			for planet in planets_near_ship:
				if planet.infection_rate == 0 && rng.randf() < 0.05:
					planet.set_infection(growth_coefficient)
					_log("EXPLOSION JUMPED TO PLANET")
					
			for s in ships_near_ship:
				if s.infection_rate == 0 && rng.randf() < 0.1:
					s.set_infection(growth_coefficient)
					_log("EXPLOSION JUMPED TO SHIP")
					
			bb.explode_ship(ship)
			continue
		
		for planet in planets_near_ship:
			if planet.infection_rate == 0:
				if _should_infect_planet(ship, planet):
					planet.set_infection(growth_coefficient)
					ship.set_infection(0)
					_log("INFECTION JUMPED TO A PLANET")

func grow(bb, world):
	var all_planets = _bot_planets(world)
	if all_planets.size() == 0:
		return
	
	var infected_planets = _get_planets_with_infection(world)
	var ships = _get_ships_with_infection(world)
	var total_infection = 0
	rng.randomize()
				
	for planet in infected_planets:
		planet.set_infection(min(planet.infection_rate + growth_coefficient, 1))
		total_infection += planet.infection_rate
		
	for ship in ships:
		ship.set_infection(min(ship.infection_rate + growth_coefficient, 1))
		total_infection += ship.infection_rate
	
	if total_infection == 0:
		if (rng.randf() < reapperance_chance):
			var random_index = rng.randi() % all_planets.size()
			var victim_planet = all_planets[random_index]
			victim_planet.infection_rate = 0.1
			_log("INFECTED PLANET " + str(victim_planet))
	
	var msg = "Ships: %d, Infected Planets: %d, total: %s" % [ships.size(), infected_planets.size() + planets.size(), total_infection]
	bb.ui.set_player_info("The Enemy", msg)
	_log(msg)

func _bot_planets(world):
	var bot_planets = []
	for bot in world["bots"]:
		for planet in bot.planets:
			bot_planets.append(planet)
	
	return bot_planets

func _get_planets_with_infection(world):
	var infected_planets = []
	var all_bot_planets = _bot_planets(world)
	for plnt in all_bot_planets:
		if plnt.infection_rate > 0:
			infected_planets.append(plnt)
				
	return infected_planets + planets
		
func _get_ships_with_infection(world):
	var ships = []
	
	for bot in world["bots"]:
		for ship in bot.ships:
			if ship.infection_rate > 0:
				ships.append(ship)
				
	return ships
		
func _get_ships_around_planet(planet,world):
	var ships = []
	
	for bot in world["bots"]:
		for ship in bot.ships:
			if planet.translation.distance_squared_to(ship.translation) < 1000:
				ships.append(ship)
			
	return ships
	
func _get_planets_around_ship(ship, world):
	var planets_around_ship = []
	
	for bot in world["bots"]:
		for planet in bot.planets:
			if ship.translation.distance_squared_to(planet.translation) < 1000:
				planets_around_ship.append(planet)
				
	return planets_around_ship
	
func _get_ships_around_ship(ship, world):
	var ships = []
	
	for bot in world["bots"]:
		for s in bot.ships:
			if ship.translation.distance_squared_to(s.translation) < 1000:
				ships.append(s)
				
	return ships
	
func _should_infect_ship(planet, ship):
	return planet.infection_rate > 0.8 and ship.infection_rate < 0.2 and rng.randf() < 0.3
	
func _should_infect_planet(ship, planet):
	return ship.infection_rate > 0.6 and rng.randf() < 0.1

func _log(msg):
	print("[enemy] ", msg)
	
