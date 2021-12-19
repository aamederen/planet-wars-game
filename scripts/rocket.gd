extends KinematicBody

# Declare member variables here. Examples:
export var max_velocity = 200
export var accellaration = 10
export var deceleration = 80
export var destination:Vector3 = Vector3(25, 20, 0)
var cur_velocity = 0
var speeding = true

func _ready():
	pass # Replace with function body.
	
	
func _physics_process(delta):
	var direction = translation.direction_to(destination)
	move_and_slide(direction * cur_velocity)
	
	if (speeding):
		transform = transform.looking_at(destination, Vector3(0,1,0))
		
	if translation.distance_squared_to(destination) < 1:
		cur_velocity = 0
	elif speeding:
		cur_velocity = min(max_velocity, cur_velocity + accellaration * delta)
	else:
		cur_velocity = max(0, cur_velocity - deceleration * delta)
		
	if Input.is_action_just_pressed("ui_accept"):
		speeding = !speeding
		
	if translation.distance_squared_to(destination) < 25:
		speeding = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
