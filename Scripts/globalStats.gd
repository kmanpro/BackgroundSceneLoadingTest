extends Node

signal game_state_changed(currentState, previousState)

const PREGAME = "PREGAME"
const RUNNING = "RUNNING"
const PAUSED = "PAUSED"
const LOADING = "LOADING"

var gameState = PREGAME
var current_scene
var thread = Thread.new()

func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS)
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		pass
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
		togglePaused()

func togglePaused():
	match gameState:
		PAUSED:
			changeGameState(RUNNING)
		_:
			changeGameState(PAUSED)

func startGame():
	changeGameState(LOADING)
	goto_scene("res://Scenes/Level3.tscn")

func resumeGame():
	changeGameState(RUNNING)

func restartLevel():
	get_tree().reload_current_scene()
	changeGameState(RUNNING)

func quit():
	get_tree().quit()
	
func changeGameState(newState):
	var previousState = gameState
	gameState = newState
	
	match gameState:
		PREGAME:
			get_tree().paused = false
		RUNNING:
			get_tree().paused = false
		PAUSED:
			get_tree().paused = true
		LOADING:
			get_tree().paused = false
	
	emit_signal("game_state_changed", gameState, previousState)

func _input(event):
	if Input.is_action_just_pressed("cancel"):
		if(gameState == PREGAME):
			get_tree().quit()
		else:
			togglePaused()
			
func goto_scene(path):
	changeGameState(LOADING)
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	OS.delay_usec(16000*4) # wait 1 frame
	thread.start(self, "prep_scene", path) 
	
func prep_scene(path):
	print("print prepscene")
	var scn = ResourceLoader.load(path)
	call_deferred("_on_load_level_done")
	return scn;
			
func _on_load_level_done():
	var level_res = thread.wait_to_finish()
	current_scene.queue_free()
	current_scene = level_res.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	changeGameState(RUNNING)

func alert(msg):
	print(str(msg))