extends Control

var button_type = null

func _on_start_pressed() -> void:
	button_type = "start"
	$loading.show()
	$loading.get_node("Timer").start()
	$loading/AnimationPlayer.play("load_in")


func _on_settings_pressed() -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://node_3d.tscn")
