extends Node
class_name Bot

var player_name:String

var planets = []
var ships = []
var money:int = 0
var color = null

func _init(name, money, color):
	self.player_name = name
	self.money = money
	self.color = color
	_log(player_name + " joined game")

func add_money(mny:int):
	money += mny
	
func remove_money(mny:int):
	money -= mny
	
func summarize():
	_log("Money: %d, planets: %d, ships: %d" % [self.money, self.planets.size(), self.ships.size()])
	
func add_ship(ship):
	ships.append(ship)
	
func remove_ship(ship):
	ships.remove(ships.find(ship))

func add_planet(planet):
	planet.set_title(player_name)
	planet.set_infection(0)
	planets.append(planet)

func remove_planet(planet):
	planet.set_title("")
	planets.remove(planets.find(planet))
	
	# TODO: Assign ships to another planet
	for s in ships:
		if s.task:
			if s.task["source"] == planet:
				s.task = null
				_log("Canceling ship task because base is destroyed")
			elif s.task["state"] == "going_to_taget" && s.task["target"] == planet:
				s.task = null
				_log("Canceling ship task because the target planet is gone")
			elif s.task["state"] == "returning_to_base" && s.task["target"] == planet:
				s.task["value"] = 10 * s.task["value"]
				_log("Source of goods is gone now, trade value has increased")
	
	# TODO: Destroy the bot if all planets are dead

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
	for obj in world:
		if obj.has_method("planets"): # If the object is a user...
			for plnt in obj.planets:
				visible_planets.append(plnt)
	
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
				"source": closest_planet_to(ship.translation),
				"target": trade_target
			})
			
	# If I have money, attach an enemy-occupied planet
	
			
	summarize()

func closest_planet_to(target:Vector3):
	var min_dist = INF
	var min_planet = null
	for p in planets:
		var dist = p.translation.distance_squared_to(target)
		if dist < min_dist:
			min_planet = p
			min_dist = dist
			
	return min_planet
	
func get_player_name():
	return player_name
	
func _log(msg):
	print("[", player_name, "] ", msg)
	
