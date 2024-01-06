extends KinematicBody
class_name Monster

export var max_velocity = 8
export var min_velocity = 3
export var accellaration = 2
var cur_velocity = 0

var brain = null

var target_object = null
var target_position = null
var target_velocity = 0

onready var anim = $monster_mesh_scene/AnimationPlayer

func _physics_process(delta):
	anim.play("Moving Idle")
	if (target_object):
		anim.playback_speed = 1.0
		target_position = target_object.translation	
		target_velocity = max_velocity
	else:
		anim.playback_speed = 0.4
		if !target_position || target_position.distance_squared_to(translation) < 10:
			target_position = translation + Vector3(rand_range(-100, 100), rand_range(-100, 100), 0)
		target_velocity = min_velocity
	
	var direction = translation.direction_to(target_position)
	rotation.z = direction.signed_angle_to(Vector3(1,0,0), Vector3(0,0,-1))
	
	if cur_velocity < target_velocity:
		cur_velocity = min(target_velocity, cur_velocity + accellaration * delta)
	else:
		cur_velocity = max(target_velocity, cur_velocity - accellaration * delta)
	
	move_and_slide(direction * cur_velocity)
	
	

func _on_DetectionArea_body_entered(body: Node) -> void:
	if brain:
		brain.enemy_saw_someone(self, body)

func _on_DetectionArea_body_exited(body: Node) -> void:
	if brain:
		brain.enemy_lost_someone(self, body)

func _on_CollisionArea_body_entered(body: Node) -> void:
	if brain:
		brain.enemy_hit_someone(self, body)

