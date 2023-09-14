extends Node
class_name BigBrain

var rng = RandomNumberGenerator.new()
var player = null
var bots = []
var gaia = []
var rockets = []
var enemy:Enemy = Enemy.new()
var aitimer:Timer = Timer.new()
var turntimer:Timer = Timer.new()
var next_money_turns_left = 5
var processes = []
var ui

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
	
	ui = $"../UI"
	
func _physics_process(delta):
	# TODO: handle collisions
	pass
		
func _on_aitimer_timeout(): # Allow bots to behave!
	bots.shuffle()
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
	var bot_planets = []
	for bot in bots:
		for planet in bot.planets:
			bot_planets.append(planet)
	
	if bot_planets.size() == 0:
		get_tree().change_scene("res://scenes/settings/gameover.tscn")
		return

	var bots_to_remove = []

	for bot in bots:
		for planet in bot.planets:
			if planet.infection_rate == 1:
				bot.remove_planet(planet)
				enemy.add_planet(planet)
				play_sound("enemy_owned_planet")
				
		if bot.planets.size() == 0:
			bots_to_remove.append(bot)
			
	for bot in bots_to_remove:
		_eliminate_player(bot)
				
	var rockets_to_be_removed = []
	
	for rocket in rockets:
		if rocket.distance_to_destination() < 100:
			rockets_to_be_removed.append(rocket)
			
			var bot = rocket.owner_bot
			var planet = rocket.target_planet
			
			if planet.infection_rate > 0:
				planet.set_infection(max(planet.infection_rate - 0.1, 0))
				if planet.infection_rate == 0:
					enemy.remove_planet(planet)
					bot.add_planet(planet)
					
	for r in rockets_to_be_removed:
		rockets.remove(rockets.find(r))
		r.queue_free()
	
func _owner_of_planet(p:Planet):
	for bot in bots:
		for planet in bot.planets:
			if planet == p:
				return bot
	
	return null

func _get_world():
	randomize()
	var world = {
		"bots": bots,
		"gaia": gaia,
		"enemy": enemy	
	}
	return world

func _get_world_of_bot(bot:Bot):
	# TODO: everyone can see everything for now, but this should change later
	var world = _get_world()
	return world
	
func _get_objects_near(t:Vector3):
	return [] # TODO: fill
	
func _eliminate_player(p):
	# Remove all ships
	while p.ships.size() != 0:
		explode_ship(p.ships[0])
	
	# Cancel the processes
	var processes_to_be_removed = []
	for process in processes:
		if process["bot"] == p:
			processes_to_be_removed.append(process)
			
	for process in processes_to_be_removed:
		processes.erase(process)
	
	play_sound("player_eliminated")
	
	# No need to remove rockets, as the big brain manages them all
	ui.add_event("Player is eliminated: " + p.get_player_name())
	ui.set_player_info(p.get_player_name(), "eliminated")
	
	bots.erase(p)
	p.queue_free()

func explode_ship(ship:Ship):
	var bot = ship.owner_player
	
	print("SHIP EXPLODED!")
	bot.remove_ship(ship)
	play_sound("enemy_owned_ship")
	ship.queue_free()
	
func play_sound(sound):
	get_owner().play_sound(sound)
	
func assign_task(task):
	var ship = task["ship"]
	
	if task["type"] == "trade":
		var target_planet := task["target"] as Planet
		var source_planet := task["source"] as Planet
		
		task["value"] = target_planet.translation.distance_to(source_planet.translation)
		
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
		ui.add_event("A new ship is created for " + bot.get_player_name())
		play_sound("build_ship")
	elif process["type"] == "build_rocket":
		var from_planet = process["from_planet"]
		var to_planet = process["to_planet"]
		var bot = process["bot"]
		var rocket = get_owner().create_big_rocket(from_planet)
		rocket.set_mission(bot, to_planet)
		rockets.append(rocket)
		play_sound("build_rocket")
		ui.add_event("A new rocket is sent by " + bot.get_player_name())

func register_bot(bot:Bot):
	bots.append(bot)

func register_gaia(object:Planet):
	gaia.append(object)
	
func register_player(player):
	self.player = player
	
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
		
func create_rocket(bot:Bot, type:String, from_planet:Planet, to_planet:Planet):
	if type == "attack":
		bot.remove_money(1000)
		var process = {
			"bot": bot,
			"type": "build_rocket",
			"rocket_type": "attack",
			"from_planet": from_planet,
			"to_planet": to_planet,
			"turns_left": 5
		}
		processes.append(process)
