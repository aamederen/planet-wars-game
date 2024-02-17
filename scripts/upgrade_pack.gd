extends Spatial

var type_to_label = {"time_to_shoot": "Fire Faster", "max_speed": "Move Faster", "rotation_speed": "Turn Faster"}

var type
var brain:BigBrain
onready var rotation_vector:Vector3 = Vector3(randf(), randf(), randf()).normalized()
onready var body:Spatial = $Body

func _on_CollisionArea_body_entered(body):
	if brain:
		brain.upgrade_pack_hit_something(self, body)

func _physics_process(delta):
	body.rotate(rotation_vector, delta)
	
func set_label(type:String):
	$Label/Viewport/Label.text = type_to_label[type]
	
func picked():
	$AnimationPlayer.play("Picked")
