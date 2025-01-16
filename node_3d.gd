extends Node3D

var is_near_door = false  # Флаг для отслеживания близости к двери

@onready var ray_cast_to_door = $main_character/RayCastToDoor
@onready var interaction_hint = $CanvasLayer/Control/InteractionHint
@onready var main_character = $main_character  # Предполагаем, что это узел сцены главного персонажа
@onready var notification_label: Label = $CanvasLayer/Control/NotificationLabel if has_node("CanvasLayer/Control/NotificationLabel") else null
@onready var task_list = $CanvasLayer/Control/TaskList  # Предполагаем, что TaskList - это VBoxContainer или аналог

var tasks = {
	"Осмотреть квартиру": false,
	"Поговорить с Крысиным": false,
	"Выпить волшебное зелье": false,
	"Найти золото": false,
	"Найти свинью": false,
	"Выбраться наружу": false
}

func _ready() -> void:
	if not interaction_hint:
		print("InteractionHint не найден!")
	else:
		interaction_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		interaction_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var screen_center = get_viewport().size / 2
		var label_half_size = interaction_hint.size / 2
		interaction_hint.position = Vector2(screen_center) - Vector2(label_half_size)

	if not notification_label:
		notification_label = Label.new()
		notification_label.name = "NotificationLabel"
		$CanvasLayer/Control.add_child(notification_label)
	
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification_label.text = ""
	notification_label.visible = false
	
	task_list.add_theme_color_override("font_color", Color(0, 1, 0))

	var notification_position = Vector2(get_viewport().size.x / 2, interaction_hint.position.y - interaction_hint.size.y - 10)
	notification_label.position = notification_position
	
	$Blur.visible = false
	set_process(true)
	if not ray_cast_to_door:
		print("RayCastToDoor не найден!")
	
	# Запуск таймера для автоматического выполнения задачи "осмотреть квартиру"
	var timer = get_tree().create_timer(30.0)
	timer.timeout.connect(_on_explore_room_timer_timeout)

	update_task_list()

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
			get_tree().change_scene_to_file("res://died.tscn")
		else:
			print("Collision detected but not with main_character")
	else:
		print("No collision")

func add_key_to_inventory():
	if main_character:
		main_character.add_item("key")
		print("Ключ добавлен в инвентарь.")
	else:
		print("main_character не найден.")

func check_door_proximity():
	if ray_cast_to_door:
		ray_cast_to_door.force_raycast_update()
		if ray_cast_to_door.is_colliding():
			var collider = ray_cast_to_door.get_collider()
			if collider and collider.name == "Key":  # Предполагаем, что у ключа узел с именем "Key"
				print("Detected key collision!")
				collider.queue_free()  # Удаляем модельку ключа из сцены
				add_key_to_inventory()  # Добавляем ключ в инвентарь
			elif collider and collider.name == "StaticBody3D5":  # Имя узла двери
				is_near_door = true
				if not tasks["Выбраться наружу"]:
					tasks["Выбраться наружу"] = true
					update_task_list()
			else:
				is_near_door = false
		else:
			is_near_door = false

		if is_near_door:
			if interaction_hint:
				# Показываем подсказку
				interaction_hint.text = "Нажми G чтобы открыть дверь"
				interaction_hint.visible = true
				if Input.is_action_just_pressed("open_door"):  # Создайте это действие в Input Map
					if main_character.inventory.has("key"):  # Предполагаем, что inventory - это словарь
						print("Opening door, closing game.")
						get_tree().change_scene_to_file("res://win.tscn")
					else:
						if notification_label:
							notification_label.text = "Нужен ключ!"
							notification_label.visible = true
			else:
				print('Not found')
		else:
			if interaction_hint:
				interaction_hint.visible = false
			if notification_label:
				notification_label.visible = false
	else:
		print("RayCastToDoor не найден!")

func _on_explore_room_timer_timeout():
	if not tasks["Осмотреть квартиру"]:
		tasks["Осмотреть квартиру"] = true
		update_task_list()

func update_task_list():
	for child in task_list.get_children():
		task_list.remove_child(child)
		child.queue_free()
	
	for task in tasks:
		var label = Label.new()
		label.text = task + (" (✅)" if tasks[task] else "")
		task_list.add_child(label)

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
