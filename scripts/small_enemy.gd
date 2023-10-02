extends KinematicBody

export var max_velocity = 8
export var min_velocity = 1
export var accellaration = 5
var cur_velocity = 0

var target = null

func _physics_process(delta):
	if (!target):
		return
		
	transform = transform.looking_at(target, Vector3(0,1,0))		
	
	var direction = translation.direction_to(target)
	cur_velocity = min(max_velocity, cur_velocity + accellaration * delta)
	move_and_slide(direction * cur_velocity)
	
