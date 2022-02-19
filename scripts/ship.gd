extends KinematicBody
class_name Ship

# Declare member variables here. Examples:
export var max_velocity = 8
export var min_velocity = 1
export var accellaration = 5
export var deceleration = 40
export var destination:Vector3

var cur_velocity = 0
var task
var infection_rate = 0
var owner_player:Bot

func _init():
	pass
	
func is_active():
	return task != null
	
func arrived_at(target):
	if not target:
		return false
		
	if ! target is Vector3:
		target = target.translation
		
	return target.distance_squared_to(translation) < 101
	
func is_at_destination():
	return arrived_at(self.destination)
	
func set_infection(new_rate):
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
