extends Spatial

var type
var brain:BigBrain
onready var rotation_vector:Vector3 = Vector3(randf(), randf(), randf()).normalized()

func _on_CollisionArea_body_entered(body):
	if brain:
		brain.upgrade_pack_hit_something(self, body)
func _physics_process(delta):
	rotate(rotation_vector, delta)
