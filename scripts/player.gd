extends CharacterBody2D

@export var speed = 250.0
@export var jump_velocity = -700.0
@onready var animated_sprite = $PlayerGFX

var direction = 0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var dead = false
signal player_died

func _ready():
	self.connect("player_died", Callable(GameState, "_on_player_died"))
	GameState.player = self

func _physics_process(delta):
	if dead or GameState.is_player_frozen: return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		animated_sprite.play("move")
		animated_sprite.flip_h = direction < 0
		velocity.x = direction * speed
	else:
		if self.is_on_floor(): animated_sprite.play("stand")
		else: animated_sprite.play("jump")
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("cheat"): 
		GameState.cheat()
	if Input.is_action_just_pressed("ui_cancel") and not self.dead:
		GameState.pause_game()

	if GameState.is_player_frozen: return
	if dead: 
		self.rotation_degrees += 200 * delta
		self.position.y += 200 * delta
	if Input.is_action_just_pressed("fire") and !GameState.hook:
		var hook = preload("res://scenes/hook.tscn").instantiate()
		hook.position = self.position
		self.add_sibling(hook)
		if Input.is_action_pressed("aim_down"):
			hook.mode = hook.Modes.DOWN
		elif direction == 0: 
			hook.mode = hook.Modes.UP
		elif direction > 0: 
			hook.mode = hook.Modes.RIGHT
		else: 
			hook.mode = hook.Modes.LEFT

func _on_collision(body):
	if body.is_in_group("ball") and !dead and !GameState.is_player_invincible:
		die("You died!")

func die(msg):
	player_died.emit(msg)
	dead = true
	animated_sprite.play("jump")
