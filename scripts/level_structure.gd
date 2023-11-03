extends StaticBody2D

@onready var music: AudioStreamPlayer = $Music 
@onready var background: TextureRect = $Control/Background

func _ready():
	self.connect("ready", Callable(GameState, "_on_level_ready"))
	GameState.current_level_structure = self

