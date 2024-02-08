extends Node
class_name Bot

var player_name:String

var planets = []
var ships = []
var money:int = 0
var color = null
var upgrade_type = null

func _init(name, money, color, upgrade_type):
	self.player_name = name
	self.money = money
	self.color = color
	self.upgrade_type = upgrade_type
	_log(player_name + " joined game")

func add_money(mny:int):
	money += mny
	
func remove_money(mny:int):
	money -= mny
	
func summarize():
	return "Money: %d, planets: %d, ships: %d" % [self.money, self.planets.size(), self.ships.size()]
	
func add_ship(ship):
	ships.append(ship)
	ship.set_halo_color(color)
	
func remove_ship(ship):
	ships.remove(ships.find(ship))

func add_planet(planet:Planet):
	planet.set_title(player_name)
	planet.set_infection(0)
	planet.set_halo_color(color)
	planets.append(planet)

func remove_planet(planet):
	planet.set_title("")
	planet.set_halo_color(null)
	planets.remove(planets.find(planet))
	
	# TODO: Assign ships to another planet
	for s in ships:
		if s.task:
			if s.task["source"] == planet:
				s.task = null
				_log("Canceling ship task because base is destroyed")
			elif s.task["state"] == "going_to_target" && s.task["target"] == planet:
				s.task = null
				_log("Canceling ship task because the target planet is gone")
			elif s.task["state"] == "returning_to_base" && s.task["target"] == planet:
				s.task["value"] = 10 * s.task["value"]
				_log("Source of goods is gone now, trade value has increased")

func think_and_play(bb, world):
	# here comes the AI
	
	if planets.size() == 0:
		return
	
	# if I have money, trade!!!
	if money > 500 && ships.size() < 5:
		randomize()
		var random_planet = planets[randi() % planets.size()]
		bb.create_ship(self, "trading", random_planet)
		
	# Find possible trading targets
	var visible_planets = []
	for bot in world["bots"]:
		for planet in bot.planets:
			visible_planets.append(planet)
	
	# Check my current ships and assign tasks to the idle ones
	for ship in ships:
		if not ship.is_active():
			if visible_planets.size() == 0:
				continue
			
			visible_planets.shuffle()
			var trade_target = visible_planets[0]
			
			bb.assign_task({
				"type": "trade",
				"ship": ship,
				"source": bb.closest_planet_to(planets, ship.translation),
				"target": trade_target
			})

	if money > 1000  and world["enemy"].planets.size() > 0:
		var closest_enemy_planet
		var closest_enemy_planet_distsq = INF
		var my_closest_planet_to_enemy
		
		for enemy_planet in world["enemy"].planets:
			var my_closest_planet = bb.closest_planet_to(planets, enemy_planet.translation)
			var distsq = my_closest_planet.translation.distance_squared_to(enemy_planet.translation)
			
			if (distsq < closest_enemy_planet_distsq):
				closest_enemy_planet_distsq = distsq
				my_closest_planet_to_enemy = my_closest_planet
				closest_enemy_planet = enemy_planet

		bb.create_rocket(self, "attack", my_closest_planet_to_enemy, closest_enemy_planet)

	if money > 1200:
		var target_planet = planets[randi() % planets.size()]
		bb.create_upgrade_pack(self, target_planet)
		
	var msg = summarize()
	_log(msg)
	bb.ui.set_player_info(get_player_name(), msg)

	
func get_player_name():
	return player_name
	
func _log(msg):
	print("[", player_name, "] ", msg)
	
