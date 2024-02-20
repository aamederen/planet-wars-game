extends KinematicBody
class_name Rocket

# Declare member variables here. Examples:
export var max_velocity = 200
export var accellaration = 10
export var deceleration = 80
export var destination:Vector3 = Vector3(25, 20, 0)
var cur_velocity = 0
var speeding = true

var owner_bot = null
var target_planet = null
var halo_color = null


func set_mission(owner_bot:Bot, target:Planet):
	self.owner_bot = owner_bot
	self.target_planet = target
	self.destination = target.translation
	self.destination.z = -50
	self.set_halo_color(owner_bot.color)

func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	var direction = translation.direction_to(destination)
	move_and_slide(direction * cur_velocity)
	
	if (speeding):
		transform = transform.looking_at(destination, Vector3(0,1,0))
		
	if translation.distance_squared_to(destination) < 1:
		cur_velocity = 0
	elif speeding:
		cur_velocity = min(max_velocity, cur_velocity + accellaration * delta)
	else:
		cur_velocity = max(0, cur_velocity - deceleration * delta)
		
func distance_to_destination():
	return translation.distance_squared_to(destination)


func update_halo():
	if self.halo_color == null:
		$Halo.visible = false
	else:
		$Halo.visible = Globals.show_halos

func set_halo_color(c):
	self.halo_color = Color(c.r, c.g, c.b, 0.1)
	$Halo.material = $Halo.material.duplicate() # In order to make sure that color changes only apply to this planet
	$Halo.material.albedo_color = self.halo_color
	update_halo()

func _on_Area_mouse_entered():
	$Halo.material.albedo_color = Color(0.3, 0.3, 1, 0.3)
	$Halo.visible = true

func _on_Area_mouse_exited():
	if (self.halo_color != null):
		$Halo.material.albedo_color = self.halo_color
	update_halo()


func _on_Area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	pass # Replace with function body.
