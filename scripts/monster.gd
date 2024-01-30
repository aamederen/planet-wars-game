extends KinematicBody
class_name Monster

export var max_velocity = 12
export var min_velocity = 8
export var accellaration = 1
export var hit_points = 2
var cur_velocity = 0
var boundaries = null

var brain = null

var target_object = null
var target_position = null
var target_velocity = 0

onready var anim = $monster_mesh_scene/AnimationPlayer

func damage():
	hit_points -= 1
	$AnimationPlayer.play("TakeDamage")

func die():
	$AnimationPlayer.play("Die")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func spin():
	anim.play("Tail Swipe")
	anim.advance(1.3)
	anim.playback_speed = 3.8
	
func is_dead():
	return hit_points <= 0

func _is_hit_boundaries():
	return boundaries && \
		   (translation.x <= boundaries[0].x + 10 || translation.x >= boundaries[1].x - 10 || \
			translation.y <= boundaries[0].y + 10 || translation.y >= boundaries[1].y - 10)

func _physics_process(delta):
	if !anim.is_playing():
		anim.play("Moving Idle")
		
	if anim.assigned_animation == "Moving Idle":
		if (target_object):
			anim.playback_speed = 1.0
			target_position = target_object.translation	
			target_velocity = max_velocity
		else:
			anim.playback_speed = 0.4
		
		# if reached the roaming target or end of camera boundaries
		if !target_position || target_position.distance_squared_to(translation) < 1000 || _is_hit_boundaries():
			var random_pos_range 
			if boundaries:
				random_pos_range = Vector2(abs(boundaries[1].x - boundaries[0].x), abs(boundaries[1].y - boundaries[0].y))
			else:
				random_pos_range = Vector2(500, 500)
			target_position = translation + Vector3(rand_range(-random_pos_range.x/2, random_pos_range.x/2), rand_range(-random_pos_range.y/2, random_pos_range.y/2), 0)
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
		brain.monster_saw_someone(self, body)

func _on_DetectionArea_body_exited(body: Node) -> void:
	if brain:
		brain.monster_lost_someone(self, body)

func _on_CollisionArea_body_entered(body: Node) -> void:
	if brain:
		brain.monster_hit_someone(self, body)

