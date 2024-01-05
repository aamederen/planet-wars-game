extends Camera

var player

func _ready() -> void:
	player = Globals.player

func _process(delta: float) -> void:
	if (player):
		translation.x = player.translation.x
		translation.y = player.translation.y
	else:
		player = Globals.player
