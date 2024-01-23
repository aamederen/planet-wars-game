extends Spatial

var type
var brain:BigBrain

func _on_CollisionArea_body_entered(body):
	if brain:
		brain.upgrade_pack_hit_something(self, body)
