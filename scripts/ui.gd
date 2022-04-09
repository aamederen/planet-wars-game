extends CanvasLayer

export var max_event_lines = 20

var logs = []
var player_info = {}
var start_time

func _ready():
	start_time = OS.get_system_time_msecs()

func add_event(message: String) -> void:
	logs.append({"text": message, "time": OS.get_system_time_msecs()})
	if logs.size() > max_event_lines:
		logs.remove(-1)
	
	var events_text:String = ""
	for t in logs:
		var elapsed = t["time"] - start_time
		events_text = "[" + str(elapsed) + "]: " + t["text"] + "\n" + events_text
		
	$EventsContainer/Label.text = events_text

func set_player_info(name: String, info: String) -> void:
	player_info[name] = info

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var players_text:String = ""
	var players_text_arr:Array = []
	
	for p in player_info:
		var info = player_info[p]
		players_text_arr.append(p + ": " + info)
	
	players_text_arr.sort()
	
	for t in players_text_arr:
		players_text += t + "\n"
	
	$StatusContainer/Label.text = players_text
	
