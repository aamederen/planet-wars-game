extends Spatial

export var cameraSpeed = 0.5
export var cameraBounds = [Vector3(-200, -200, 10), Vector3(200,200,100)]
export var cameraFreeForm = false

signal ui_details_changed

export var bot_count:int = 2
export var monster_count:int = 3
export var min_planet_per_bot:int = 1
export var max_planet_per_bot:int = 1
export var empty_planets:int = 10
export var starting_money:int = 500
export var enemy_planets:int = 2

var green_planet = preload("res://scenes/objects/green_planet.tscn")
var yellow_planet = preload("res://scenes/objects/yellow_planet.tscn")
var fast_ship = preload("res://scenes/objects/fast_ship.tscn")
var big_ship = preload("res://scenes/objects/big_ship.tscn")
var fast_rocket = preload("res://scenes/objects/fast_rocket.tscn")
var big_rocket = preload("res://scenes/objects/big_rocket.tscn")
var player = preload("res://scenes/objects/player.tscn")
var monster = preload("res://scenes/objects/monster.tscn")
var upgrade_pack = preload("res://scenes/objects/upgrade_pack.tscn")


onready var sounds = {
	"build_ship": $Sounds/ConstructionCompleted,
	"build_rocket": $Sounds/RocketCreated,
	"rocket_hit": $Sounds/RocketHit,
	"infected_ship": $Sounds/EnemyAction,
	"infected_planet": $Sounds/EnemyAction,
	"created_monster": $Sounds/MonsterCreated,
	"enemy_owned_planet": $Sounds/EnemyAction,
	"enemy_owned_ship": $Sounds/EnemyAction,
	"player_eliminated": $Sounds/EnemyAction,
	"monster_damaged": $Sounds/MonsterDamaged,
	"monster_dead": $Sounds/MonsterDead,
	"upgrade_created": $Sounds/UpgradeCreated,
	"upgrade_picked": $Sounds/UpgradePicked,
	"trade_completed": $Sounds/TradeCompleted,
	"fire": $Sounds/Fire,
	"player_died": $Sounds/Died,
	"won": $Sounds/Won
}

var rng = RandomNumberGenerator.new()
var bb:BigBrain

var colors = [Color.aqua, Color.webpurple, Color.webgreen, Color.tomato, Color.teal, Color.steelblue, Color.aquamarine, Color.red, Color.darkgray]

# Some picked from https://www.fantasynamegenerators.com/planet-names.php
var planet_names = ["Iguzuno", "Zelvegantu", "Sachides", "Chagreshan", "Seilara", "Ucury", "Phicetov", "Thadithea", "Troth 475", "Creon K38",
				   "Callepra", "Helmaomia", "Ostrade", "Yangippe", "Uestea", "Duiphus", "Gnobamia", "Gnoleyama", "Cholla LG8", "Crypso FGLM",
				   "Ilgaz", "Tanriyar", "Knidos", "Petrapo", "Kastumanna", "Gas Tumoni", "Fullosaf", "New Ancyra", "Erean", "Ecosh"]
var colony_names = ["Gokboru", "Karagu", "Kizgil Boys", "Pecenek", "Daday Corp", "Sorkun Dynasty", "Bashak", "Tea Road"]
var upgrade_types = ["rotation_speed", "max_speed", "time_to_shoot"]

func _ready():
	print("Welcome to the random space!!")
	generate_space()

func _physics_process(delta):
	handle_camera()
	handle_details()
	
func handle_camera():
	if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down"):
		cameraFreeForm = true
	
	if Input.is_action_just_pressed("ui_lock"):
		cameraFreeForm = false
	
	if cameraFreeForm:
		if Input.is_action_pressed("ui_left"):
			$Camera.translation.x -= cameraSpeed
		elif Input.is_action_pressed("ui_right"):
			$Camera.translation.x += cameraSpeed
			
		if Input.is_action_pressed("ui_up"):
			$Camera.translation.y += cameraSpeed
		elif Input.is_action_pressed("ui_down"):
			$Camera.translation.y -= cameraSpeed
	else:
		$Camera.translation.x = bb.player.translation.x
		$Camera.translation.y = bb.player.translation.y
		
	if Input.is_action_pressed("ui_zoom_out"):
		$Camera.translation.z += cameraSpeed
	elif Input.is_action_pressed("ui_zoom_in"):
		$Camera.translation.z -= cameraSpeed
		
	$Camera.translation.x = max(cameraBounds[0].x, min(cameraBounds[1].x, $Camera.translation.x))
	$Camera.translation.y = max(cameraBounds[0].y, min(cameraBounds[1].y, $Camera.translation.y))
	$Camera.translation.z = max(cameraBounds[0].z, min(cameraBounds[1].z, $Camera.translation.z))
	
	# Compensate the camera angle
	$Camera.translation.y -= tan($Camera.rotation.x) * $Camera.translation.z
	
	$UI.update_lock_button(cameraFreeForm)

func generate_space():
	colors.shuffle()
	rng.randomize()
	var bots = []
	
	# Remove all objects, maybe useful for restarts?
	for x in $Objects.get_children():
		$Objects.remove_child(x)
		
	# (big) Brain controls the bots, disease and objects
	bb = $Brain
		
	# Let's generate some bots
	for i in bot_count:
		var planet_count = rng.randi_range(min_planet_per_bot, max_planet_per_bot)
		
		var colony_name_index = rng.randi_range(0, colony_names.size()-1)
		var name = colony_names[colony_name_index]
		colony_names.remove(colony_name_index)
		
		var upgrade_type = upgrade_types[rng.randi_range(0, upgrade_types.size() - 1)]

		var bot = Bot.new(name, starting_money, colors[i], upgrade_type)
		
		# Let's give them some planets
		for j in planet_count:
			var planet = create_random_planet(green_planet)
			bot.add_planet(planet)
		
		# Let the brain control the bot
		bb.register_bot(bot)
	
	# Generate GAIA, some random planets here and there
	for i in empty_planets:
		bb.register_gaia(create_random_planet(green_planet))	
		
	for i in monster_count:
		bb.register_monster(create_random_monster())
		
	for i in enemy_planets:
		bb.register_enemy_planet(create_random_planet(green_planet))
	
	bb.register_gaia(create_random_planet(yellow_planet))
	
	bb.register_player(place_player())
	
	bb.set_bounds(cameraBounds)

func _random_pos_around_planet(planet):
	var pos_rad = rng.randf_range(-PI, PI)
	var offset = planet.radius * Vector3(sin(pos_rad), cos(pos_rad), 0)
	return planet.translation + offset

func create_new_ship(type, planet):
	if type == "trading":
		var ship = big_ship.instance()
		ship.translation = planet.translation
		ship.translation.z = -50
		$Objects.add_child(ship)
		connect("ui_details_changed", ship, "update_halo")
		return ship as Ship
		
func create_big_rocket(planet):
	var rocket = big_rocket.instance()
	rocket.translation = planet.translation
	rocket.translation.z = -50
	$Objects.add_child(rocket)
	connect("ui_details_changed", rocket, "update_halo")
	return rocket as Rocket
	
func create_random_monster():
	var m = create_random_object(monster)
	m.boundaries = cameraBounds
	return m
	
func create_monster(planet):
	var position = _random_pos_around_planet(planet)
	var m = create_random_monster()
	m.translation = position
	return m

func create_upgrade_pack(planet):
	var position = _random_pos_around_planet(planet)
	var u = create_random_object(upgrade_pack)
	u.translation = position
	return u
	
func create_random_planet(scene):
	var pos = find_pos_for_planet()
	var planet = create_random_object(scene, pos)
	planet.axis_angle = rng.randf_range(-30, 30)
	planet.rotation_speed = rng.randf_range(0.02, 0.2)
	connect("ui_details_changed", planet, "update_halo")
	return planet
	
func place_player():
	var theplayer = create_random_object(player)
	add_child(theplayer, true)
	$Camera.translation.x = theplayer.translation.x
	$Camera.translation.y = theplayer.translation.y
	return theplayer
	
func find_pos_for_planet():
	while (true):
		var candidate = random_vec3()
		var violated = false
		
		for o in $Objects.get_children():
			var distance_sq = o.translation.distance_squared_to(candidate)
			if distance_sq < 20000:
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
	
func create_fast_rocket(loc):
	return create_random_object(fast_rocket, loc)
	
func create_random_big_rocket():
	var ship = create_random_object(big_rocket)
	ship.max_velocity = rng.randf_range(2, 4)
	ship.accellaration = rng.randf_range(50, 100)
	ship.deceleration = rng.randf_range(20, 40)
	ship.destination = random_vec3()
	
func create_random_object(scene, loc=find_pos_for_planet()):
	var node = scene.instance()
	node.translate(loc)
	$Objects.add_child(node)
	return node
	
func play_sound(sound):
	print("playing sound " + sound)
	sounds[sound].play()

func stop_music():
	$Sounds/BackgroundMusic.stop()

func random_vec3(minVec3 = cameraBounds[0], maxVec3 = cameraBounds[1]):
	return Vector3(rng.randf_range(minVec3.x, maxVec3.x), \
	  			   rng.randf_range(minVec3.y, maxVec3.y), \
				   0)
				
func handle_details():
	if Input.is_action_just_pressed("ui_toggle_details"):
		Globals.show_halos = !Globals.show_halos
		$UI.update_details_button(Globals.show_halos)
		emit_signal("ui_details_changed")
