extends Control

var button_type = null

func _on_ready() -> void:
	MusicManager.play_music()
	$Blur.visible = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://entrance.tscn")
	MusicManager.toggle_music()

func _on_settings_pressed() -> void:
	$Blur.visible = true
	$Settings/AnimationPlayer.play("in")
	$Blur/AnimationPlayer.play('blur_in')

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_intro_timer_timeout() -> void:
	$intro_out.visible = false

func _on_blur_animation_finished(anim_name: String) -> void:
	if anim_name == "blur_out":
		$Blur.visible = false
