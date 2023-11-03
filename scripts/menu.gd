extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready():
	play_button.connect("pressed", Callable(self, "_on_play_pressed"))
	credits_button.connect("pressed", Callable(self, "_on_credits_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))
	play_button.grab_focus()

func _on_play_pressed():
	GameState.stop_intro_music()
	get_tree().change_scene_to_file("res://scenes/levels/pop1.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/credits.tscn")

func _on_quit_pressed():
	get_tree().quit()
