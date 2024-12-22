extends Node2D

@onready var anim_player = $AnimationPlayer
var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = preload("res://main_menu_src/neon.mp3")
	music_player.volume_db = -5
	music_player.play()
	
	anim_player.play('load')

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://MainScreen.tscn")
