extends Control

func _ready():
	pass

func _on_buttontitleplay_pressed():
	var scene = load("res://scenes/settings/random_space.tscn")
	get_tree().change_scene_to(scene)
