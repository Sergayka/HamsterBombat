extends ColorRect


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "blur_out":
		var blur = get_parent().get_node("Blur")
		blur.visible = false
		if get_parent().has_node("CanvasLayer/Control/pause"):
			get_parent().get_node("CanvasLayer/Control/pause").visible = true
			get_parent().get_node("CanvasLayer/Control/inventory").visible = true
