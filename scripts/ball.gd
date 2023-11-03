class_name Ball
extends RigidBody2D

@export var velocity = Vector2(200,200)
@export var balls_left = 3
var current_scale = Vector2(1,1)

@onready var colision = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var label = $Label

var screen_width
var screen_height

signal ball_popped

func _ready():
	screen_height = get_viewport_rect().size.y
	screen_width = get_viewport_rect().size.x

	GameState.balls.append(self)
	self.connect("ball_popped", Callable(GameState, "_on_ball_popped"))
	self.label.text = str(self.balls_left)

func _physics_process(delta):
	var colision_info = self.move_and_collide(velocity * delta)
	if colision_info:
		var collider = colision_info.get_collider()
		velocity = velocity.bounce(colision_info.get_normal())
		if collider.name == "Hook": 
			collider.queue_free()
			pop()
	if (
		self.position.x < 0 or
		self.position.x > screen_width or
		self.position.y < 0 or
		self.position.y > screen_height
	):
		print("Ball out of bounds")
		pop()
	
func pop():
	balls_left -= 1
	if balls_left == 0:
		if randf() < 0.1:
			var gift = preload("res://scenes/gift.tscn").instantiate()
			gift.position = self.position
			gift.type = randi_range(0, gift.GiftTypes.size() - 1) 
			self.add_sibling(gift)
		self.ball_popped.emit(self)
		queue_free()
	else:
		var left_child = load("res://scenes/ball.tscn").instantiate()
		var right_child = load("res://scenes/ball.tscn").instantiate()
		left_child.position = Vector2(self.position.x - 50, self.position.y)
		right_child.position = Vector2(self.position.x + 50, self.position.y)
		self.add_sibling(left_child)
		self.add_sibling(right_child)
		set_params(left_child)
		set_params(right_child)
		left_child.velocity = Vector2(-velocity.x, velocity.y)
		right_child.velocity = Vector2(velocity.x, velocity.y)
		self.ball_popped.emit(self)
		queue_free()

func set_params(ball):
	ball.colision.scale = self.colision.scale / 2.0 
	ball.sprite.scale = self.sprite.scale / 2.0 
	ball.balls_left = self.balls_left
	ball.label.text = str(self.balls_left)
	ball.label.add_theme_font_size_override("font_size", self.label.get_theme_font_size("font_size") / 2.0)

func _on_quit():
	get_tree().quit()
