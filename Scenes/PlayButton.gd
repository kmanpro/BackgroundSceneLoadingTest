extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	self.connect("button_down", self, "_on_PlayButton_button_down")
	self.grab_focus()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_PlayButton_button_down():
	self.visible = false
	globalStats.startGame()
