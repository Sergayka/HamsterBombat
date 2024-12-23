extends Control

@onready var video_player = $VideoStreamPlayer
var sergo_player: AudioStreamPlayer

func _ready():
	video_player.play()
	
	if not sergo_player:
		sergo_player = AudioStreamPlayer.new()
		add_child(sergo_player)
		sergo_player.stream = preload("res://main_menu_src/ебейшая озвучка.mp3")
		
		sergo_player.volume_db = 0
		sergo_player.play()
	
	$ColorRect.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip"):
		video_player.stop()
		sergo_player.stop()
		_on_timer_timeout()


func _on_video_stream_player_finished() -> void:
	$ColorRect.visible = true
	$ColorRect/Timer.start()
	

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://node_3d.tscn")
