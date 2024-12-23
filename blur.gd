extends ColorRect


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "blur_out":
		var blur = get_parent().get_node("Blur")
		blur.visible = false
