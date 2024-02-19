extends Node

export var show_halos:bool = false
var player:Node

func _ready():
	print("Globals...")
	reset()
	
func reset():
	player = null
	show_halos = false
