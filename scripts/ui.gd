extends CanvasLayer

export var max_event_lines = 17

var logs = []
var player_info = {}
var start_time

var b_up
var b_down
var b_left
var b_right
var b_in
var b_out

func _ready():
	start_time = OS.get_system_time_secs()
	b_up = $ControlsContainer/UpButton
	b_down = $ControlsContainer/DownButton
	b_left = $ControlsContainer/LeftButton
	b_right = $ControlsContainer/RightButton
	b_in = $ControlsContainer/ZoomInButton
	b_out = $ControlsContainer/ZoomOutButton

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
	_stimulate_input_actions()
	
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
	
func _stimulate_input_actions():
	if b_up.is_pressed():
		Input.action_press("ui_up")
	else:
		Input.action_release("ui_up")
		
	if b_down.is_pressed():
		Input.action_press("ui_down")
	else:
		Input.action_release("ui_down")
		
	if b_left.is_pressed():
		Input.action_press("ui_left")
	else:
		Input.action_release("ui_left")
		
	if b_right.is_pressed():
		Input.action_press("ui_right")
	else:
		Input.action_release("ui_right")
		
	if b_in.is_pressed():
		Input.action_press("ui_zoom_in")
	else:
		Input.action_release("ui_zoom_in")
		
	if b_out.is_pressed():
		Input.action_press("ui_zoom_out")
	else:
		Input.action_release("ui_zoom_out")
