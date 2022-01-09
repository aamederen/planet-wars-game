extends KinematicBody
class_name Ship

# Declare member variables here. Examples:
export var max_velocity = 20
export var min_velocity = 2
export var accellaration = 10
export var deceleration = 40
export var destination:Vector3

var cur_velocity = 0
var task
var home_planet:Planet
var infection_rate = 0

func _init():
	pass
	
func is_active():
	return task != null
	
func is_at_home():
	if not self.home_planet:
		return false
	
	var distance_to_home = self.home_planet.translation.distance_squared_to(translation)
	
	return distance_to_home < 101
	
func is_at_destination():
	if not self.destination:
		return false
	
	return self.destination.distance_squared_to(translation) < 101

func set_infection_rate(new_rate):
	self.infection_rate = new_rate
	$Label/Viewport/Label.text = "Infection: %d%%" % (self.infection_rate*100)

func _physics_process(delta):
	if is_active():
		var direction = translation.direction_to(destination)
		move_and_slide(direction * cur_velocity)
		
		transform = transform.looking_at(destination, Vector3(0,1,0))
		
		if translation.distance_squared_to(destination) < 101:
			cur_velocity = 0
		elif translation.distance_squared_to(destination) > 151:
			cur_velocity = min(max_velocity, cur_velocity + accellaration * delta)
		else:
			cur_velocity = max(min_velocity, cur_velocity - deceleration * delta)
