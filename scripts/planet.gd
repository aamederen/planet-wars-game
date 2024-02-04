extends Spatial
class_name Planet

# Spatial properties
export var axis_angle:float = 20.0
export var rotation_speed:float = 0.5
export var radius = 40
export var belongs_to:String = ""

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
	$planetmesh.rotate(rotation_axis, rotation_speed * delta)

func set_infection(new_rate):
	self.infection_rate = new_rate
	$HealthSprite/Viewport/Label.text = "Infection: %d%%" % (new_rate*100)

func set_title(text):
	$LabelSprite/Viewport/Label.text = text
	belongs_to = text

func update_halo():
	if $Halo == null:
		return

	$Halo.visible = Globals.show_halos && self.halo_color != null

func set_halo_color(c):
	if c == null:
		self.halo_color = null
		$MinimapIndicator.mesh = $MinimapIndicator.mesh.duplicate()
		$MinimapIndicator.mesh.material = $MinimapIndicator.mesh.material.duplicate()
		$MinimapIndicator.mesh.material.albedo_color = Color(0.3, 0.3, 1)
	else:
		self.halo_color = Color(c.r, c.g, c.b, 0.1)
		$Halo.material = $Halo.material.duplicate() # In order to make sure that color changes apply only to this planet
		$Halo.material.albedo_color = self.halo_color
		$MinimapIndicator.mesh = $MinimapIndicator.mesh.duplicate()
		$MinimapIndicator.mesh.material = $MinimapIndicator.mesh.material.duplicate()
		$MinimapIndicator.mesh.material.albedo_color = self.halo_color
	update_halo()
	
func enemy_captured_planet():
	$DiseaseParticles.emitting = true
	$DiseaseParticles.visible = true
	$HealParticles.visible = false
	
func heal_rocket_hit_planet():
	$HealParticles.visible = true
	$HealParticles.amount = 10
	$HealParticles.emitting = true
	
func enemy_wiped_from_planet():
	$DiseaseParticles.emitting = false
	$DiseaseParticles.visible = false
	$HealParticles.visible = true
	$HealParticles.amount = 100
	$HealParticles.emitting = true
	
func _on_Area_mouse_entered():
	$Halo.material.albedo_color = Color(0.3, 0.3, 1, 0.3)
	$Halo.visible = true

func _on_Area_mouse_exited():
	if (self.halo_color != null):
		$Halo.material.albedo_color = self.halo_color
	update_halo()

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Bana tikladilar")
	# print("BI EVENT")
