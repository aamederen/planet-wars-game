extends CanvasLayer

export var max_event_lines = 17

var logs = []
var player_info = {}
var start_time

func _ready():
	start_time = OS.get_system_time_secs()

func add_event(message: String) -> void:
	logs.append({"text": message, "time": OS.get_system_time_secs()})
	
	_update_events_text()

func set_player_info(name: String, info: String) -> void:
	player_info[name] = info

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
	
	_update_events_text()
	
func _update_events_text():
	if logs.size() == 0:
		return
	
	var now = OS.get_system_time_secs()
	
	while logs.size() > max_event_lines || \
		(logs.size() > 0 && now - logs[0]["time"] > 10):
		logs.remove(0)
	
	var events_text:String = ""
	for t in logs:
		var elapsed_time = t["time"] - start_time
		var elapsed_str = ""
		if elapsed_time > 59:
			elapsed_str = "%dm %ds" % [elapsed_time/60, elapsed_time%60]
		else:
			elapsed_str = "%ds" % elapsed_time
		events_text = "[" + str(elapsed_str) + "] " + t["text"] + "\n" + events_text
		
	$EventsContainer/Label.text = events_text
