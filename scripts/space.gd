extends Spatial

export var cameraSpeed = 0.5
export var cameraBounds = [Vector3(-200, -200, 10), Vector3(200,200,100)]


func _ready():
	print("Welcome to space!!")


func _physics_process(delta):
	handle_camera()
	
func handle_camera():
	if Input.is_action_pressed("ui_left"):
		$Camera.translation.x -= cameraSpeed
	elif Input.is_action_pressed("ui_right"):
		$Camera.translation.x += cameraSpeed
		
	if Input.is_action_pressed("ui_up"):
		$Camera.translation.y += cameraSpeed
	elif Input.is_action_pressed("ui_down"):
		$Camera.translation.y -= cameraSpeed
		
	if Input.is_action_pressed("ui_zoom_out"):
		$Camera.translation.z += cameraSpeed
	elif Input.is_action_pressed("ui_zoom_in"):
		$Camera.translation.z -= cameraSpeed
		
	$Camera.translation.x = max(cameraBounds[0].x, min(cameraBounds[1].x, $Camera.translation.x))
	$Camera.translation.y = max(cameraBounds[0].y, min(cameraBounds[1].y, $Camera.translation.y))
	$Camera.translation.z = max(cameraBounds[0].z, min(cameraBounds[1].z, $Camera.translation.z))
