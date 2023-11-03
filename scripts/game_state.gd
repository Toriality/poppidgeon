extends Node

var can_player_fire = true
var player_lives = 5
var is_player_frozen = false
var is_player_invincible = false
var gift_active = false

var player
var balls = []
var coins = []
var coins_collected = 0
var hook
var ui
var current_level_index = 0
var current_level_structure = null
var music_progress = 0.0
var levels: Array[Dictionary] = [
	{ "name": "pop1", "music": "pop", "volume": -6.0},
	{ "name": "pop2", "music": "pop", "volume": -6.0},
	{ "name": "city1", "music": "city", "volume": -6.0},
	{ "name": "city2", "music": "city", "volume": -6.0},
	{ "name": "jungle1", "music": "jungle", "volume": 0.0},
	{ "name": "jungle2", "music": "jungle", "volume": 0.0},
	{ "name": "tower1", "music": "tower", "volume": -12.0},
	{ "name": "tower2", "music": "tower", "volume": -12.0},
	# { "name": "platform1", "music": "platform"},
	# { "name": "platform2", "music": "platform"},
	{ "name": "tunnels1", "music": "tunnels", "volume": -12.0},
	{ "name": "tunnels2", "music": "tunnels", "volume": -12.0},
	{ "name": "cave1", "music": "cave", "volume": -15.0},
	{ "name": "cave2", "music": "cave", "volume": -15.0},
]

func _ready():
	play_intro_music()

func reset_player_status():
	coins_collected = 0
	gift_active = false
	is_player_frozen = false
	is_player_invincible = false

func reset_balls():
	balls = []

func reset_coins():
	coins = []

func _on_player_died(msg):
	player_lives -= 1
	is_player_frozen = false
	is_player_invincible = false
	ui.handle_level_fail(msg)

func _on_gift_collected(type):
	gift_active = true
	if type == Gift.GiftTypes.SLEEP: 
		is_player_frozen = true
	if type == Gift.GiftTypes.HEART:
		player_lives += 1
		ui.handle_player_lives()
	if type == Gift.GiftTypes.INVINCIBILITY:
		is_player_invincible = true
	if type == Gift.GiftTypes.BOMB:
		player.die("BOOM!")
	if type == Gift.GiftTypes.SLOWMO:
		for ball in balls:
			ball.velocity /= 10 
	if type == Gift.GiftTypes.TIME:
		var time_left = ui.level_timer.time_left
		ui.level_timer.stop()
		ui.level_timer.wait_time = time_left + 30
		ui.level_timer.start()
	if type == Gift.GiftTypes.GIFT:
		var random_index = randi_range(0, balls.size() - 1)
		balls[random_index].pop()

func _on_gift_finished(type):
	gift_active = false
	if type == Gift.GiftTypes.SLEEP: 
		is_player_frozen = false
	if type == Gift.GiftTypes.INVINCIBILITY:
		is_player_invincible = false
	if type == Gift.GiftTypes.SLOWMO:
		for ball in balls:
			if ball != null:
				print(ball)
				ball.velocity *= 10 

func _on_ball_popped(ball):
	balls.remove_at(balls.find(ball))
	if balls.size() == 0:
		is_player_frozen = true
		gift_active = true
		ui.handle_level_complete()
		print("all balls popped")

func _on_coin_collected():
	coins_collected += 1
	if coins_collected == coins.size():
		player_lives += 1
		ui.handle_player_lives()
		print("all coins collected")

func _on_time_up():
	player.die("You ran out of time!")

func _on_next_level():
	current_level_index += 1
	if current_level_index >= levels.size():
		get_tree().change_scene_to_file("res://scenes/menus/end.tscn")
		return
	var next_level = levels[current_level_index].name
	var scene = load("res://scenes/levels/" + next_level + ".tscn")
	print("Loading next level: " + next_level)
	reset_player_status()
	reset_balls()
	reset_coins()
	if (
		levels[current_level_index].music !=
		levels[current_level_index - 1].music
	):
		music_progress = 0
	else:
		music_progress = current_level_structure.music.get_playback_position()
	get_tree().change_scene_to_packed(scene)

func _on_level_ready():
	current_level_structure.background.texture = load(
		"res://sprites/backgrounds/" + levels[current_level_index].music + ".png"
	)
	current_level_structure.music.stream = load("res://audio/" + levels[current_level_index].music + ".mp3")
	current_level_structure.music.volume_db = levels[current_level_index].volume
	current_level_structure.music.play(music_progress)

func _on_try_again():
	reset_player_status()
	reset_balls()
	reset_coins()
	music_progress = current_level_structure.music.get_playback_position()
	get_tree().reload_current_scene()

func _on_quit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")
	play_intro_music()
	player_lives = 5
	current_level_index = 0
	current_level_structure = null
	reset_balls()
	reset_coins()
	reset_player_status()

func _on_resume():
	ui.hide_pause_menu()
	get_tree().paused = false

func cheat():
	if balls.size() != 0:
		var random_ball = balls[randi_range(0, balls.size() - 1)]
		random_ball.pop()

func pause_game():
	ui.show_pause_menu()
	get_tree().paused = true

func play_intro_music():
	var music = AudioStreamPlayer.new()
	music.add_to_group("music")
	music.volume_db = -15.0
	add_child(music)
	music.stream = load("res://audio/menu.mp3")
	music.play()

func stop_intro_music():
	get_tree().get_nodes_in_group("music")[0].queue_free()
