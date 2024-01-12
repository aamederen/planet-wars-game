extends KinematicBody

var max_speed = 25
var speed = 0
var direction = Vector3(1, 0, 0)
var acceleration = 5
var time_to_shoot = 0
var shoot_time_needed = 2
var rotation_speed = 2.5

var brain = null
var targets = []

func _physics_process(delta):
	var is_key_pressed = false
	
	if Input.is_action_pressed("player_left"):
		direction = direction.rotated(Vector3(0, 0, 1), rotation_speed * delta)
	elif Input.is_action_pressed("player_right"):
		direction = direction.rotated(Vector3(0, 0, 1), -rotation_speed * delta)
		
	if Input.is_action_pressed("player_up"):
		speed = min(max_speed, speed + acceleration * delta)
	elif Input.is_action_pressed("player_down"):
		speed = max(0, speed - acceleration * delta)
	
	rotation.z = direction.signed_angle_to(Vector3(1,0,0), Vector3(0,0,-1))
		
	move_and_slide(direction * speed)
	
func _process(delta):
	time_to_shoot = max(0, time_to_shoot - delta)
	if time_to_shoot == 0:
		targets.shuffle()
		for target in targets:
			if target.is_queued_for_deletion():
				targets.erase(target)
				continue
				
			brain.create_fast_rocket(target)
			print ("shooting a missile")
			time_to_shoot = shoot_time_needed
			break

func _on_FireRangeArea_body_entered(body: Node) -> void:
	if body.is_in_group("Monster"):
		targets.append(body)


func _on_FireRangeArea_body_exited(body: Node) -> void:
	if body.is_in_group("Monster"):
		targets.erase(body)
