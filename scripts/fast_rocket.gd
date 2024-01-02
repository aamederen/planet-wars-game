extends Spatial
class_name FastRocket

# Declare member variables here. Examples:
export var max_velocity = 200
export var accellaration = 40
var cur_velocity = 0
var brain = null
	
func _physics_process(delta):
	translate(Vector3(1, 0, 0) * cur_velocity * delta)
	cur_velocity = min(max_velocity, cur_velocity + accellaration * delta)

func _on_CollisionArea_body_entered(body: Node) -> void:
	if brain:
		brain.rocket_collided(self, body) # Replace with function body.
