extends Spatial
class_name Planet

# Spatial properties
export var axis_angle:float = 20.0
export var rotation_speed:float = 0.5
var rotation_axis = null
export var radius = 10

# Game properties
var infection_rate = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	rotation_axis = Vector3(0,1,0).rotated(Vector3(0,0,-1), axis_angle * PI / 360)
	# $planetmesh.rotate(rotation_axis, rotation_speed * delta)
	rotate(rotation_axis, rotation_speed * delta)

func set_infection(new_rate):
	self.infection_rate = new_rate
	$HealthSprite/Viewport/Label.text = "Infection: %d%%" % (new_rate*100)

func set_title(text):
	$LabelSprite/Viewport/Label.text = text
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area_mouse_entered():
	$Halo.visible = true
	print("MERABAAA")

func _on_Area_mouse_exited():
	$Halo.visible = false
	print("BAYBAY")

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	print("BI EVENT")
