extends RigidBody2D

class_name Gift

enum GiftTypes {
	SLEEP,
	HEART,
	INVINCIBILITY,
	BOMB,
	SLOWMO,
	TIME,
	GIFT
}

@export var type = GiftTypes.SLEEP
@onready var sprite: AnimatedSprite2D = $GiftGFX
@onready var hitbox: Area2D = $Hitbox
@onready var timer: Timer = $Timer
@onready var ui: CanvasLayer = $"../UI"

signal gift_collected
signal gift_finished

func _ready():
	self.connect("gift_collected", Callable(GameState, "_on_gift_collected"))
	self.connect("gift_collected", Callable(ui, "_on_gift_collected"))
	self.connect("gift_finished", Callable(GameState, "_on_gift_finished"))
	self.connect("gift_finished", Callable(ui, "_on_gift_finished"))
	if type == GiftTypes.SLEEP:
		sprite.play("sleep")
	elif type == GiftTypes.HEART:
		sprite.play("heart")
	elif type == GiftTypes.INVINCIBILITY:
		sprite.play("diamond")
	elif type == GiftTypes.BOMB:
		sprite.play("bomb")
	elif type == GiftTypes.SLOWMO:
		sprite.play("flower")
	elif type == GiftTypes.TIME:
		sprite.play("time")
	elif type == GiftTypes.GIFT:
		sprite.play("gift")

func _on_collision(body):
	if body.name == "Hook": 
		self.queue_free()
		#TODO: pop animation and sound
	if body.name == "Player" and !GameState.gift_active:
		self.gift_collected.emit(self.type)
		self.visible = false
		self.hitbox.queue_free()
		if (
			self.type == GiftTypes.HEART or
			self.type == GiftTypes.BOMB or
			self.type == GiftTypes.TIME or
			self.type == GiftTypes.GIFT
			):
			self.timer.wait_time = 1
		self.timer.start()

func _on_timer_timeout():
	self.gift_finished.emit(self.type)
	self.queue_free()
