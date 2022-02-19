extends Node
class_name BigBrain

# TODO: Seperate the responsibilities of rendering vs modeling
# Models should be managed by the big brain and 
# the rendering should be taken care of by the Space

var rng = RandomNumberGenerator.new()
var bots = []
var gaia = []
var enemy:Enemy = Enemy.new()
var aitimer:Timer = Timer.new()
var turntimer:Timer = Timer.new()
var next_money_turns_left = 5
var processes = []

func _ready():
	aitimer.set_autostart(true)
	aitimer.wait_time = 2 # seconds
	aitimer.connect("timeout", self, "_on_aitimer_timeout")
	aitimer.start()
	add_child(aitimer)
	
	turntimer.set_autostart(true)
	turntimer.wait_time = 1 # seconds
	turntimer.connect("timeout", self, "_on_turntimer_timeout")
	turntimer.start()
	add_child(turntimer)
	
	rng.randomize()
	
func _physics_process(delta):
	# TODO: handle collisions
	pass
		
func _on_aitimer_timeout(): # Allow bots to behave!
	for bot in bots:
		bot.think_and_play(self, _get_world_of_bot(bot))
	
	enemy.think_and_play(self, _get_world())

func _on_turntimer_timeout():
	next_money_turns_left -= 1
	
	if next_money_turns_left == 0:
		next_money_turns_left = 5
		for bot in bots:
			var money = bot.planets.size() * 10 + rng.randi_range(0, 10)
			bot.add_money(money)
	
	# Control the ships
	for bot in bots:
		for ship in bot.ships:
			if ship.is_active() and ship.task["type"] == "trade" and ship.is_at_destination():
				if ship.arrived_at(ship.task["source"]):
					bot.add_money(ship.task["value"])
					ship.task = null
				else:
					ship.task["state"] = "returning_to_base"
					ship.destination = ship.task["source"].translation
			
	var processes_to_be_removed = []
	for process in processes:
		if process["turns_left"] == 0:
			complete_process(process)
			processes_to_be_removed.append(process)
		else:
			process["turns_left"] -= 1
			
	for p in processes_to_be_removed:
		processes.erase(p)
		
	enemy.grow(self, _get_world())
	
	_manage_world()

func _manage_world():
	pass
	# TODO: Remove Control of Players in infected planets
	for bot in bots:
		for planet in bot.planets:
			if planet.infection_rate == 1:
				bot.remove_planet(planet)
	
	# Destroy completely infected ships
	
func _owner_of_planet(p:Planet):
	for bot in bots:
		for planet in bot.planets:
			if planet == p:
				return bot
	
	return null

func _get_world():
	randomize()
	var world = bots + gaia
	world.shuffle()
	return world

func _get_world_of_bot(bot:Bot):
	# TODO: everyone can see everything for now, but this should change later
	var world = _get_world()
	return world
	
func _get_objects_near(t:Vector3):
	return [] # TODO: fill

func explode_ship(ship:Ship):
	var bot = ship.owner_player
	
	print("SHIP EXPLODED!")
	bot.remove_ship(ship)
	ship.queue_free()
	
func assign_task(task):
	var ship = task["ship"]
	
	if task["type"] == "trade":
		var target_planet := task["target"] as Planet
		var source_planet := task["source"] as Planet
		
		task["value"] = target_planet.translation.distance_squared_to(source_planet.translation)
		
		if (ship.arrived_at(source_planet)):
			task["state"] = "going_to_target"
			ship.destination = target_planet.translation
		else:
			task["state"] = "going_to_base"
			ship.destination = source_planet.translation
		
	ship.task = task

func complete_process(process):
	if process["type"] == "build_ship":
		var planet = process["planet"]
		var bot = process["bot"]
		var ship = get_owner().create_new_ship(process["ship_type"], planet)
		ship.owner_player = bot
		ship.set_infection(0)
		bot.add_ship(ship)

func register_bot(bot:Bot):
	bots.append(bot)

func register_gaia(object:Planet):
	gaia.append(object)
	
func create_ship(bot:Bot, type:String, planet:Planet):
	if type == "trading":
		bot.remove_money(500)
		var process = {
			"bot": bot,
			"planet": planet,
			"type": "build_ship",
			"ship_type": "trading",
			"turns_left": 5
		}
		processes.append(process)
