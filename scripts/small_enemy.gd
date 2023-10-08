extends KinematicBody
class_name SmallEnemy

export var max_velocity = 8
export var min_velocity = 1
export var accellaration = 5
var cur_velocity = 0

var brain = null

var target_object = null

func _physics_process(delta):
	if (!target_object):
		return
		
	var target = target_object.translation
		
	transform = transform.looking_at(target, Vector3(0,1,0))		
	
	var direction = translation.direction_to(target)
	cur_velocity = min(max_velocity, cur_velocity + accellaration * delta)
	move_and_slide(direction * cur_velocity)
	

func _on_DetectionArea_body_entered(body: Node) -> void:
	if brain:
		brain.enemy_saw_someone(self, body)


func _on_CollisionArea_body_entered(body: Node) -> void:
	if brain:
		brain.enemy_hit_someone(self, body)
