extends "res://scripts/space.gd"

signal ui_details_changed

export var bot_count:int = 2
export var min_planet_per_bot:int = 1
export var max_planet_per_bot:int = 1
export var empty_planets:int = 10
export var starting_money:int = 500

var green_planet = preload("res://scenes/objects/green_planet.tscn")
var yellow_planet = preload("res://scenes/objects/yellow_planet.tscn")
var fast_ship = preload("res://scenes/objects/fast_ship.tscn")
var big_ship = preload("res://scenes/objects/big_ship.tscn")
var fast_rocket = preload("res://scenes/objects/fast_rocket.tscn")
var big_rocket = preload("res://scenes/objects/big_rocket.tscn")

var rng = RandomNumberGenerator.new()
var bb:BigBrain

var colors = [Color.aqua, Color.webpurple, Color.webgreen, Color.tomato, Color.teal, Color.steelblue, Color.aquamarine, Color.red, Color.darkgray]

# Some picked from https://www.fantasynamegenerators.com/planet-names.php
var planet_names = ["Iguzuno", "Zelvegantu", "Sachides", "Chagreshan", "Seilara", "Ucury", "Phicetov", "Thadithea", "Troth 475", "Creon K38",
				   "Callepra", "Helmaomia", "Ostrade", "Yangippe", "Uestea", "Duiphus", "Gnobamia", "Gnoleyama", "Cholla LG8", "Crypso FGLM",
				   "Ilgaz", "Tanriyar", "Knidos", "Petrapo", "Kastumanna", "Gas Tumoni", "Fullosaf", "New Ancyra", "Erean", "Ecosh"]
var colony_names = ["Gokboru", "Karagu", "Kizgil Boys", "Pecenek", "Daday Corp", "Sorkun Dynasty", "Bashak", "Tea Road"]

func _ready():
	print("Welcome to the random space!!")
	generate_space()

func _physics_process(delta):
	.handle_camera()
	handle_details()

func generate_space():
	colors.shuffle()
	rng.randomize()
	var bots = []
	
	for x in $Objects.get_children():
		$Objects.remove_child(x)
		
	bb = $Brain
		
	for i in bot_count:
		var planet_count = rng.randi_range(min_planet_per_bot, max_planet_per_bot)
		
		var colony_name_index = rng.randi_range(0, colony_names.size()-1)
		var name = colony_names[colony_name_index]
		colony_names.remove(colony_name_index)
		
		var bot = Bot.new(name, starting_money, colors[i])
		
		for j in planet_count:
			var planet = create_random_planet(green_planet)
			bot.add_planet(planet)
		
		bb.register_bot(bot)
	
	# Generate GAIA
	for i in empty_planets:
		bb.register_gaia(create_random_planet(green_planet))	
	
	bb.register_gaia(create_random_planet(yellow_planet))

func create_new_ship(type, planet):
	if type == "trading":
		var ship = big_ship.instance()
		var pos_rad = rng.randf_range(-PI, PI)
		ship.translate(planet.translation + Vector3(planet.radius * sin(pos_rad), planet.radius * cos(pos_rad), 0))
		$Objects.add_child(ship)
		connect("ui_details_changed", ship, "update_halo")
		return ship as Ship
		
func create_big_rocket(planet):
	var rocket = big_rocket.instance()
	var pos_rad = rng.randf_range(-PI, PI)
	rocket.translate(planet.translation + Vector3(planet.radius * sin(pos_rad), planet.radius * cos(pos_rad), 0))
	$Objects.add_child(rocket)
	connect("ui_details_changed", rocket, "update_halo")
	return rocket as Rocket
	
func create_random_planet(scene):
	var pos = find_pos_for_planet()
	var planet = create_random_object(scene, pos)
	planet.axis_angle = rng.randf_range(-30, 30)
	planet.rotation_speed = rng.randf_range(0.02, 0.2)
	connect("ui_details_changed", planet, "update_halo")
	return planet
	
func find_pos_for_planet():
	while (true):
		var candidate = random_vec3()
		var violated = false
		
		for o in $Objects.get_children():
			var distance_sq = o.translation.distance_squared_to(candidate)
			if distance_sq < 2000:
				violated = true
				break
		
		if violated:
			continue	
		return candidate
	
func create_random_fast_ship():
	var ship = create_random_object(fast_ship)
	ship.max_velocity = rng.randf_range(10, 20)
	ship.accellaration = rng.randf_range(20, 100)
	ship.deceleration = rng.randf_range(80, 100)
	ship.destination = random_vec3()
	
func create_random_big_ship():
	var ship = create_random_object(big_ship)
	ship.max_velocity = rng.randf_range(2, 8)
	ship.accellaration = rng.randf_range(5, 15)
	ship.deceleration = rng.randf_range(15, 80)
	ship.destination = random_vec3()
	
func create_random_fast_rocket():
	var ship = create_random_object(fast_rocket)
	ship.max_velocity = rng.randf_range(10, 20)
	ship.accellaration = rng.randf_range(20, 100)
	ship.deceleration = rng.randf_range(80, 100)
	ship.destination = random_vec3()
	
func create_random_big_rocket():
	var ship = create_random_object(big_rocket)
	ship.max_velocity = rng.randf_range(2, 4)
	ship.accellaration = rng.randf_range(50, 100)
	ship.deceleration = rng.randf_range(20, 40)
	ship.destination = random_vec3()
	
func create_random_object(scene, loc=random_vec3()):
	var node = scene.instance()
	node.translate(loc)
	$Objects.add_child(node)
	return node
	
func play_sound(sound):
	var sounds = {
		"build_ship": $Sounds/ConstructionCompleted,
		"build_rocket": $Sounds/ConstructionCompleted,
		"infected_ship": $Sounds/EnemyAction,
		"infected_planet": $Sounds/EnemyAction,
		"enemy_owned_planet": $Sounds/EnemyAction,
		"enemy_owned_ship": $Sounds/EnemyAction,
		"player_eliminated": $Sounds/EnemyAction
	}
	
	sounds[sound].play()

func random_vec3(minVec3 = cameraBounds[0], maxVec3 = cameraBounds[1]):
	return Vector3(rng.randf_range(minVec3.x, maxVec3.x), \
	  			   rng.randf_range(minVec3.y, maxVec3.y), \
				   0)
				
func handle_details():
	if Input.is_action_just_pressed("ui_toggle_details"):
		Globals.show_halos = !Globals.show_halos
		$UI.update_details_button(Globals.show_halos)
		emit_signal("ui_details_changed")
