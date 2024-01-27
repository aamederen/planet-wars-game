extends KinematicBody

var max_speed = 25
var speed = 0
var direction = Vector3(1, 0, 0)
var acceleration = 5
var time_to_shoot = 0
var shoot_time_needed = 2
var rotation_speed = 2.5

onready var boosterleft:Particles = $boosterleft
onready var boosterright:Particles = $boosterright

var brain = null
var targets = []

func upgrade(type):
	if type == "max_speed":
		max_speed = min(40, max_speed + 1)
	elif type == "rotation_speed":
		rotation_speed = min(4, rotation_speed + 0.1)
	elif type == "time_to_shoot":
		shoot_time_needed = max(0.5, shoot_time_needed - 0.1)

func _physics_process(delta):
	
	var rotated = 0
	
	if Input.is_action_pressed("player_left"):
		rotated = -1
		direction = direction.rotated(Vector3(0, 0, 1), rotation_speed * delta)
	elif Input.is_action_pressed("player_right"):
		rotated = 1
		direction = direction.rotated(Vector3(0, 0, 1), -rotation_speed * delta)
		
	if Input.is_action_pressed("player_up"):
		speed = min(max_speed, speed + acceleration * delta)
	elif Input.is_action_pressed("player_down"):
		speed = max(0, speed - acceleration * delta)
	
		
	boosterleft.emitting = speed > 0.1 || rotated > 0
	boosterright.emitting = speed > 0.1 || rotated < 0
	
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
