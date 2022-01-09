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
	
func add_ship(ship):
	ships.append(ship)

func add_planet(planet):
	planet.set_title(player_name)
	planet.set_infection(0)
	planets.append(planet)

func remove_planet(planet):
	planet.set_title("")
	planets.remove(planets.find(planet))
	# TODO: Assign ships to another planet
	# Destroy the bot if all planets are dead

func think_and_play(bb, world):
	# here comes the AI
	_log("thinking...")
	
	# TODO: if there's an enemy nearby and have excess money, attack it
	
	# if I have money and enemy is not close, create a trading ship
	if money > 500:
		_log("decided to create a ship")
		randomize()
		var random_planet = planets[randi() % planets.size()]
		bb.create_ship(self, "trading", random_planet)
		
	# Find a trading target
	var visible_planets = []
	for obj in world:
		if obj.has_method("get_player_name"): # If the object is a user...
			for plnt in obj.planets:
				visible_planets.append(plnt)
	
	# Check my current ships and assign tasks to the idle ones
	for ship in ships:
		if not ship.is_active():
			_log("activating a ship...")
			
			if visible_planets.size() == 0:
				continue
			
			visible_planets.shuffle()
			var trade_target = visible_planets[0]
			
			bb.assign_task({
				"type": "trade",
				"ship": ship,
				"target": trade_target
			})
			
	
	_log("my money is %d" % money) 
	
func get_player_name():
	return player_name
	
func _log(msg):
	print("[", player_name, "] ", msg)
	
