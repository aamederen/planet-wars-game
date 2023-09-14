extends KinematicBody

var max_speed = 25
var speed = 0
var direction = Vector3(1, 0, 0)
var acceleration = 5
var time_to_shoot = 0
var shoot_time_needed = 5

func _physics_process(delta):
	var is_key_pressed = false
	
	if Input.is_action_pressed("player_left"):
		direction = direction.rotated(Vector3(0, 0, 1), 1 * delta)
	elif Input.is_action_pressed("player_right"):
		direction = direction.rotated(Vector3(0, 0, 1), -1 * delta)
		
	if Input.is_action_pressed("player_up"):
		speed = min(max_speed, speed + acceleration * delta)
	elif Input.is_action_pressed("player_down"):
		speed = max(0, speed - acceleration * delta)
	
	transform = transform.looking_at(translation + direction, Vector3(0,1,0))
		
	move_and_slide(direction * speed)
	
func _process(delta):
	time_to_shoot = max(0, time_to_shoot - delta)
	if Input.is_action_pressed("player_shoot"):
		if time_to_shoot == 0:
			# TODO: Create a missile
			print ("shooting a missile")
			time_to_shoot = shoot_time_needed
			
