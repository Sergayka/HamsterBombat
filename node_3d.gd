extends Node3D

var is_near_door = false  # Флаг для отслеживания близости к двери

@onready var ray_cast_to_door = $main_character/RayCastToDoor
@onready var interaction_hint = $CanvasLayer/Control/InteractionHint

func _ready() -> void:
	if not interaction_hint:
		print("InteractionHint не найден!")
	else:
		interaction_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		interaction_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var screen_center = get_viewport().size / 2
		var label_half_size = interaction_hint.size / 2
		interaction_hint.position = Vector2(screen_center) - Vector2(label_half_size)
	$Blur.visible = false
	set_process(true)
	if not ray_cast_to_door:
		print("RayCastToDoor не найден!")

func _process(delta: float) -> void:
	Btns()
	check_raycast_collision()
	check_door_proximity()

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
			#get_tree().quit()# Закрывает игру
			get_tree().change_scene_to_file("res://died.tscn")
		else:
			print("Collision detected but not with main_character")
	else:
		print("No collision")

func check_door_proximity():
	if ray_cast_to_door:
		ray_cast_to_door.force_raycast_update()
		if ray_cast_to_door.is_colliding():
			var collider = ray_cast_to_door.get_collider()
			if collider and collider.name == "StaticBody3D5":  # Имя узла двери
				is_near_door = true
			else:
				is_near_door = false
		else:
			is_near_door = false

		if is_near_door:
			if interaction_hint:
			# Показываем подсказку
				$CanvasLayer/Control/InteractionHint.text = "Нажми G чтобы открыть дверь"
				$CanvasLayer/Control/InteractionHint.visible = true
				# Если нажата клавиша 'G', закрываем игру
				if Input.is_action_just_pressed("open_door"):  # Создайте это действие в Input Map
					print("Opening door, closing game.")
					get_tree().change_scene_to_file("res://win.tscn")
			else:
				print('Not found')
		else:
			if interaction_hint:
				interaction_hint.visible = false
			#$CanvasLayer/Conetrol/InteractionHint.visible = false
	else:
		print("RayCastToDoor не найден!")

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
