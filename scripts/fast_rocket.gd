extends Spatial
class_name FastRocket

# Declare member variables here. Examples:
export var max_velocity = 200
export var accellaration = 40
var cur_velocity = 0
	
func _physics_process(delta):
	global_translate(rotation.rotated(Vector3(0,0,1), PI/2) * cur_velocity * delta)
	cur_velocity = min(max_velocity, cur_velocity + accellaration * delta)
