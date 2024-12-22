extends Control


func _on_ready() -> void:
	MusicManager.play_music()
	$intro_out/AnimationPlayer.play("intro_out")
	$intro_out/Timer.start()


func _on_start_pressed() -> void:
	#$loading.show()
	#$loading.get_node("Timer").start()
	#$loading/AnimationPlayer.play("load_in")
	get_tree().change_scene_to_file("res://entrance.tscn")
	MusicManager.toggle_music()


func _on_settings_pressed() -> void:
	$Settings/AnimationPlayer.play("sett_in")


func _on_exit_pressed() -> void:
	get_tree().quit()


#func _on_timer_timeout() -> void:
	#get_tree().change_scene_to_file("res://entrance.tscn")


func _on_intro_timer_timeout() -> void:
	$intro_out.visible = false
