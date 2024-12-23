extends Control

func _ready():
	$VBoxContainer/Volume.value = MusicManager.music_player.volume_db

func _on_volume_value_changed(value: float) -> void:
	MusicManager.set_volume(value)

func _on_mute_pressed() -> void:
	MusicManager.toggle_music()

func _on_back_pressed() -> void:
	var parent = get_parent().get_parent().get_parent()
	var blur = parent.get_node("Blur");
	var blur_player = blur.get_node("AnimationPlayer");
	blur_player.play("blur_out");
	$AnimationPlayer.play("out");

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	MusicManager.toggle_music()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://MainScreen.tscn")
