extends Spatial
class_name Planet

# Spatial properties
export var axis_angle:float = 20.0
export var rotation_speed:float = 0.5
export var radius = 10
var rotation_axis = null
var halo_color = null

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

func set_halo_color(c):
	if c == null:
		self.halo_color = null
		$Halo.visible = false
	else:
		self.halo_color = Color(c.r, c.g, c.b, 0.1)
		$Halo.visible = true
		$Halo.material = $Halo.material.duplicate() # In order to make sure that color changes only apply to this planet
		$Halo.material.albedo_color = self.halo_color

func _on_Area_mouse_entered():
	$Halo.visible = true
	$Halo.material.albedo_color = Color(0.3, 0.3, 1, 0.3)

func _on_Area_mouse_exited():
	if (halo_color == null):
		$Halo.visible = false
	else:
		$Halo.material.albedo_color = self.halo_color

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Bana tikladilar")
	# print("BI EVENT")
