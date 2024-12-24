extends Node3D

func _ready() -> void:
	$Blur.visible = false
	set_process(true)  # Устанавливаем, что _process будет вызываться каждый кадр

func _process(delta: float) -> void:
	Btns()
	check_raycast_collision()

func Btns():
	if Input.is_action_just_pressed("escape") and !$Blur.visible:
		_on_pause_pressed()
	elif Input.is_action_just_pressed("escape") and $Blur.visible:
		_on_pause_closed()
	elif Input.is_action_just_pressed("inventory") and !$Blur.visible:
		_on_inventory_pressed()
	elif Input.is_action_just_pressed("inventory") and $Blur.visible:
		_on_inventory_closed()

func check_raycast_collision():
	$enemy_character/RayCastForward.force_raycast_update()
	if $enemy_character/RayCastForward.is_colliding():
		var collider = $enemy_character/RayCastForward.get_collider()
		if collider and collider.name == "main_character":
			print("Collision detected with main_character! Closing game.")
			#get_tree().quit()# Закрываетигру
			get_tree().change_scene_to_file("res://died.tscn")
		else:
			print("Collision detected but not with main_character")
	else:
		print("No collision")

func _on_pause_pressed() -> void:
	if !$Blur.visible:
		$Blur.visible = true
		$Blur/AnimationPlayer.play("blur_in")
		$CanvasLayer/Control/PauseMenu/AnimationPlayer.play("in")
		$CanvasLayer/Control/pause.visible = false
		$CanvasLayer/Control/inventory.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_pause_closed() -> void:
	if $Blur.visible:
		$Blur/AnimationPlayer.play("blur_out")
		$CanvasLayer/Control/PauseMenu/AnimationPlayer.play("out")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$Blur.visible = false

func _on_inventory_pressed() -> void:
	if !$Blur.visible:
		$Blur.visible = true
		$Blur/AnimationPlayer.play("blur_in")
		$CanvasLayer/Control/Inventory/AnimationPlayer.play("in")
		$CanvasLayer/Control/pause.visible = false
		$CanvasLayer/Control/inventory.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_inventory_closed() -> void:
	if $Blur.visible:
		$Blur/AnimationPlayer.play("blur_out")
		$CanvasLayer/Control/Inventory/AnimationPlayer.play("out")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$Blur.visible = false

func _on_area_3d_area_entered(area: Area3D) -> void:
	pass # Здесь можно добавить дополнительную логику, если это необходимо
