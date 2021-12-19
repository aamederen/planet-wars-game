extends Spatial
class_name Planet

export var axis_angle:float = 20.0
export var rotation_speed:float = 0.5
var rotation_axis = null
export var radius = 10
var infection_rate = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	rotation_axis = Vector3(0,1,0).rotated(Vector3(0,0,-1), axis_angle * PI / 360)
	rotate(rotation_axis, rotation_speed * delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
