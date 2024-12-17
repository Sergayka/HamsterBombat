extends Control

@onready var animaton_player = $AnimationPlayer

func _ready():
	$VBoxContainer/Volume.value = MusicManager.music_player.volume_db


func _on_volume_value_changed(value: float) -> void:
	MusicManager.set_volume(value)


func _on_check_box_pressed() -> void:
	MusicManager.toggle_music()


func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1152, 648))
	


func _on_back_pressed() -> void:
	$AnimationPlayer.play("sett_out")
	
