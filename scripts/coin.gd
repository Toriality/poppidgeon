extends Area2D

signal coin_collected

func _ready():
	GameState.coins.append(self)
	self.connect("body_entered", Callable(self, "_on_collision"))
	self.connect("area_entered", Callable(self, "_on_area_entered"))
	self.connect("coin_collected", Callable(GameState, "_on_coin_collected"))

func _on_area_entered(area):
	if area.get_parent().name == "Hook":
		self.queue_free()

func _on_collision(body):
	print(body)
	if body.name == "Hook":
		self.queue_free()
		#TODO: pop animation and sound
	if body.name == "Player":
		self.coin_collected.emit()
		self.queue_free()