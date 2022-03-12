extends CanvasLayer


var logs = []
var player_info = {}


func add_event(message: String) -> void:
	logs.append({"text": message, "time": OS.get_system_time_msecs()})

func set_player_info(name: String, info: String) -> void:
	player_info[name] = info

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_time = OS.get_system_time_msecs()
	
	var events_text:String = ""
	for t in logs:
		if current_time - t["time"] < 10000:
			events_text = t["text"] + "\n" + events_text
	$EventsContainer/Label.text = events_text
	
	var players_text:String = ""
	var players_text_arr:Array = []
	
	for p in player_info:
		var info = player_info[p]
		players_text_arr.append(p + ": " + info)
	
	players_text_arr.sort()
	
	for t in players_text_arr:
		players_text += t + "\n"
	
	$StatusContainer/Label.text = players_text
	
