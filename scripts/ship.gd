extends KinematicBody
class_name Ship

# Declare member variables here. Examples:
export var max_velocity = 8
export var min_velocity = 1
export var accellaration = 5
export var deceleration = 40
export var destination:Vector3

var cur_velocity = 0
var task
var infection_rate = 0
var owner_player:Bot
var halo_color = null

func _init():
	pass
	
func is_active():
	return task != null
	
func arrived_at(target):
	if not target:
		return false
		
	if ! target is Vector3:
		target = target.translation
		
	return target.distance_squared_to(translation) < 101
	
func is_at_destination():
	return arrived_at(self.destination)
	
func set_infection(new_rate):
	self.infection_rate = new_rate
	$Label/Viewport/Label.text = "Infection: %d%%" % (self.infection_rate*100)

func _physics_process(delta):
	if is_active():
		var direction = translation.direction_to(destination)
		move_and_slide(direction * cur_velocity)
		
		transform = transform.looking_at(destination, Vector3(0,1,0))
		
		if translation.distance_squared_to(destination) < 101:
			cur_velocity = 0
		elif translation.distance_squared_to(destination) > 151:
			cur_velocity = min(max_velocity, cur_velocity + accellaration * delta)
		else:
			cur_velocity = max(min_velocity, cur_velocity - deceleration * delta)

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
