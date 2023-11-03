extends CanvasLayer

@onready var player_lives = $Control/PlayerLives/Label
@onready var finish_menu = $Control/FinishMenu
@onready var gift_timer: Timer = $Control/GiftUI/GiftTimer
@onready var gift_progress_bar: TextureProgressBar = $Control/GiftUI/GiftProgressBar
@onready var level_timer: Timer = $LevelTimer
@onready var level_tiemr_label: Label = $Control/LevelTimerLabel

signal scene_reloaded

const SECONDS_PER_MINUTE = 60

func _ready():
	self.connect("scene_reloaded", Callable(GameState, "_on_scene_reloaded"))
	level_timer.connect("timeout", Callable(self, "_on_time_up"))
	level_timer.connect("timeout", Callable(GameState, "_on_time_up"))
	GameState.ui = self
	handle_player_lives()
	finish_menu.visible = false

func _process(delta):
	if GameState.gift_active:
		var time_left = gift_timer.time_left
		var progress = gift_timer.wait_time - time_left
		var percent = progress / gift_timer.wait_time
		gift_progress_bar.value = percent * 100
	
	var secondsRemaining = level_timer.time_left
	var secondsOverMinute = int(secondsRemaining) % SECONDS_PER_MINUTE
	var minutes = int(secondsRemaining) / SECONDS_PER_MINUTE

	var string = ""
	string = str(minutes).pad_zeros(2) + ":" + str(secondsOverMinute).pad_zeros(2)

	level_tiemr_label.text = str(string)

func wait():
	await get_tree().create_timer(0.5).timeout

func handle_player_lives():
	var lives = GameState.player_lives
	player_lives.text = str(lives)

func handle_level_complete():
	reset_finish_menu()
	level_timer.stop()
	wait()

	var label := Label.new()
	var next_level_button := Button.new()
	var quit_button := Button.new()

	label.text = "Level Complete!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	next_level_button.text = "Next Level"
	quit_button.text = "Quit to Menu"

	next_level_button.connect("pressed", Callable(GameState, "_on_next_level"))
	quit_button.connect("pressed", Callable(GameState, "_on_quit"))

	finish_menu.add_child(label)
	finish_menu.add_child(next_level_button)
	finish_menu.add_child(quit_button)

	next_level_button.grab_focus()

	finish_menu.visible = true

func handle_level_fail(msg):
	reset_finish_menu()

	level_timer.stop()
	handle_player_lives()
	wait()

	var label := Label.new()
	var try_again_button := Button.new()
	var quit_button := Button.new()

	label.text = msg
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	try_again_button.text = "Try Again"
	quit_button.text = "Quit to Menu"

	try_again_button.connect("pressed", Callable(GameState, "_on_try_again"))
	quit_button.connect("pressed", Callable(GameState, "_on_quit"))

	finish_menu.add_child(label)
	finish_menu.add_child(try_again_button)
	finish_menu.add_child(quit_button)
	try_again_button.grab_focus()

	if player_lives.text.to_int() == 0:
		try_again_button.visible = false
		quit_button.grab_focus()

	finish_menu.visible = true

func _on_gift_finished(type):
	gift_progress_bar.texture_progress = null
	gift_progress_bar.value = 0
	gift_timer.wait_time = 0

func _on_time_up():
	level_tiemr_label.add_theme_color_override("font_color", Color.RED)	

func _on_gift_collected(type):
	gift_progress_bar.texture_progress = load("res://sprites/gifts/single/" + Gift.GiftTypes.keys()[type].to_lower() + ".png")
	gift_progress_bar.value = 0 
	
	if (
		type == Gift.GiftTypes.HEART or
		type == Gift.GiftTypes.BOMB	or
		type == Gift.GiftTypes.TIME or
		type == Gift.GiftTypes.GIFT
	):
		gift_timer.wait_time = 1
	else:
		gift_timer.wait_time = 5

	gift_timer.start()

func show_pause_menu():
	reset_finish_menu()

	var label := Label.new()
	var resume_button := Button.new()
	var quit_button := Button.new()

	label.text = "Game Paused"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	resume_button.text = "Resume"
	quit_button.text = "Quit to Menu"

	resume_button.connect("pressed", Callable(GameState, "_on_resume"))
	quit_button.connect("pressed", Callable(GameState, "_on_quit"))

	finish_menu.add_child(label)
	finish_menu.add_child(resume_button)
	finish_menu.add_child(quit_button)

	resume_button.grab_focus()

	finish_menu.visible = true

func hide_pause_menu():
	reset_finish_menu()
	finish_menu.visible = false

func reset_finish_menu():
	for child in finish_menu.get_children():
		child.queue_free()