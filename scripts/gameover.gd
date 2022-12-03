extends Control

func _ready():
	pass

func _on_buttontitleok_pressed():
	print("OK :(")
	get_tree().change_scene("res://scenes/settings/menu.tscn")
