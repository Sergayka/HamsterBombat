extends Control

func _ready():
	$VBoxContainer/Volume.value = MusicManager.music_player.volume_db


func _on_volume_value_changed(value: float) -> void:
	MusicManager.set_volume(value)

func _on_mute_pressed() -> void:
	MusicManager.toggle_music()

func _on_back_pressed() -> void:
	var blur = get_parent().get_node("Blur");
	var blur_player = blur.get_node("AnimationPlayer");
	blur_player.play("blur_out");
	$AnimationPlayer.play("out");
	

func _on_blur_animation_finished(anim_name: String) -> void:
	if anim_name == "blur_out":
		var blur = get_parent().get_node("Blur")
		blur.visible = false
