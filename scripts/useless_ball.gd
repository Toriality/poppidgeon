extends RigidBody2D

@export var opacity = 1.0
var size = randf_range(0.25, 0.75)
var velocity = Vector2.ZERO
var label_num = 3

func _ready():
	$Sprite2D.scale *= Vector2(size, size)
	$CollisionShape2D.scale *= Vector2(size, size)
	modulate = Color(1.0, 1.0, 1.0, opacity)
	velocity = Vector2(randf_range(-200.0, 200.0), randf_range(-200.0, 200.0))

func _physics_process(delta):
	var colision_info = self.move_and_collide(velocity * delta)
	if colision_info:
		var collider = colision_info.get_collider()
		velocity = velocity.bounce(colision_info.get_normal())