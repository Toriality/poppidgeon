class_name Hook
extends StaticBody2D

enum Modes {UP, RIGHT, LEFT, DOWN}
@export var speed = 800
@export var mode = Modes.UP 

func _ready():
	GameState.hook = self

func _physics_process(delta):
	if mode == Modes.RIGHT:
		self.position.x += speed * delta
		self.rotation_degrees = 90
	elif mode == Modes.LEFT:
		self.position.x -= speed * delta
		self.rotation_degrees = -90
	elif mode == Modes.DOWN:
		self.position.y += speed * delta
		self.rotation_degrees = 180
	else:
		self.position.y -= speed * delta	

func _on_screen_exited():
	GameState.hook = null
	self.queue_free()


func _on_area_entered(body):
	if body.is_in_group("structure"):
		GameState.hook = null
		self.queue_free()
