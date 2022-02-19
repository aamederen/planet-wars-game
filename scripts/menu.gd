extends Control


func _ready():
	pass


func _on_buttontitleplay_pressed():
	print("PLAY!")
	get_tree().change_scene("res://scenes/settings/random_space.tscn")
	pass # Replace with function body.
