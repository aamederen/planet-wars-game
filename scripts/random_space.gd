extends "res://scripts/space.gd"

export var bot_count:int = 3

var green_planet = preload("res://scenes/objects/green_planet.tscn")
var yellow_planet = preload("res://scenes/objects/yellow_planet.tscn")
var fast_ship = preload("res://scenes/objects/fast_ship.tscn")
var big_ship = preload("res://scenes/objects/big_ship.tscn")
var fast_rocket = preload("res://scenes/objects/fast_rocket.tscn")
var big_rocket = preload("res://scenes/objects/big_rocket.tscn")

var rng = RandomNumberGenerator.new()
var bb:BigBrain

func _ready():
	print("Welcome to the random space!!")
	generate_space()


func _physics_process(delta):
	.handle_camera()

func generate_space():
	rng.randomize()
	var bots = []
	
	for x in $Objects.get_children():
		$Objects.remove_child(x)
		
	bb = $Brain
		
	for i in bot_count:
		var planet_count = rng.randi_range(1, 4)
		var starting_money = rng.randi_range(300, 600)
		
		var bot = Bot.new("bot %d"%i, starting_money, Color(randf(), randf(), randf()))
		
		for j in planet_count:
			var planet = create_random_planet(green_planet)
			bot.add_planet(planet)
		
		bb.register_bot(bot)
	
	# Generate GAIA
	bb.register_gaia(create_random_planet(green_planet))
	bb.register_gaia(create_random_planet(green_planet))
	
	bb.register_gaia(create_random_planet(yellow_planet))
	
	# TODO: Generate background flying objects
#
#	create_random_fast_ship()
#	create_random_fast_ship()
#	create_random_fast_ship()
#	create_random_fast_ship()
#
#	create_random_big_ship()
#	create_random_big_ship()
#	create_random_big_ship()
#
#	create_random_fast_rocket()
#	create_random_fast_rocket()
#	create_random_fast_rocket()
#	create_random_fast_rocket()
#	create_random_fast_rocket()
#
#	create_random_big_rocket()
#	create_random_big_rocket()

func create_new_ship(type, planet):
	if type == "trading":
		var ship = big_ship.instance()
		var pos_rad = rng.randf_range(-PI, PI)
		ship.translate(planet.translation + Vector3(planet.radius * sin(pos_rad), planet.radius * cos(pos_rad), 0))
		$Objects.add_child(ship)
		return ship as Ship
		
func create_big_rocket(planet):
	var rocket = big_rocket.instance()
	var pos_rad = rng.randf_range(-PI, PI)
	rocket.translate(planet.translation + Vector3(planet.radius * sin(pos_rad), planet.radius * cos(pos_rad), 0))
	$Objects.add_child(rocket)
	return rocket as Rocket
	
func create_random_planet(scene):
	var planet = create_random_object(scene)
	planet.axis_angle = rng.randf_range(-30, 30)
	planet.rotation_speed = rng.randf_range(0.02, 0.2)
	return planet
	
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
	
func create_random_object(scene):
	var node = scene.instance()
	node.translate(random_vec3())
	$Objects.add_child(node)
	return node

func random_vec3(minVec3 = cameraBounds[0], maxVec3 = cameraBounds[1]):
	return Vector3(rng.randf_range(minVec3.x, maxVec3.x), \
	  			   rng.randf_range(minVec3.y, maxVec3.y), \
				   0)
