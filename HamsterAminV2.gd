extends CharacterBody3D

# Экспортируемые переменные для настройки через инспектор
@export var animation_player: AnimationPlayer
@export var move_speed: float = 5.0               # Обычная скорость
@export var run_speed: float = 8.0                # Скорость при ускорении
@export var jump_strength: float = 10.0
@export var gravity: float = 30.0
@export var raycast: RayCast3D
#@export var RayCastToDoot: Ray

@export var camera: Camera3D
@export var camera_distance: float = -2.5          # Расстояние камеры за хомяком
@export var camera_height: float = 1.5            # Высота камеры

@export var mouse_sensitivity: float = 0.2
@export var max_yaw: float = 360.0
@export var min_yaw: float = 0.0

# Экспортируемые переменные для звуковых эффектов
@export var slow_run_sound: AudioStream
# @export var fast_run_sound: AudioStream   # Уберите, если не используется

var vertical_velocity = 0.0
var yaw: float = 0.0

var audio_slow_run: AudioStreamPlayer
# var audio_fast_run: AudioStreamPlayer   # Уберите, если не используется

var is_jumping = false  # Флаг для отслеживания состояния прыжка

# Добавляем инвентарь
var inventory: Array = ["coin"]  # Массив для хранения предметов

func _ready():
	# Инициализация AnimationPlayer, RayCast3D и Camera3D, если они не назначены
	if animation_player == null:
		animation_player = $AnimationPlayer
	
	if raycast == null:
		raycast = $RayCast3D
	
	if camera == null:
		camera = $Camera3D
		if camera == null:
			print("Camera3D не назначена!")
	else:
		print("Camera3D найдена!")
		
	# Инициализация AudioStreamPlayer
	audio_slow_run = $AudioStreamPlayer_slowRun
	# audio_fast_run = $AudioStreamPlayer_fastRun   # Уберите, если не используется

	# Назначение звуковых файлов через экспортируемые переменные
	if slow_run_sound != null:
		audio_slow_run.stream = slow_run_sound
	else:
		print("slow_run_sound не назначен!")

	# if fast_run_sound != null:
	#     audio_fast_run.stream = fast_run_sound
	# else:
	#     print("fast_run_sound не назначен!")
	
	# Захватываем мышь для управления камерой
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Поворачиваем хомяка по горизонтали на основе движения мыши
		yaw -= event.relative.x * mouse_sensitivity * 0.005  # Регулируем чувствительность
		
		# Ограничиваем yaw в диапазоне [0, 2π)
		yaw = wrapf(yaw, 0, 2 * PI)
		rotation.y = yaw

		# Обновляем позицию камеры
		update_camera_position()

func _process(delta):
	var is_moving_forward = Input.is_action_pressed("move_forward")
	var is_jumping_pressed = Input.is_action_just_pressed("jump")
	var is_running = Input.is_action_pressed("run")  # Проверяем, нажата ли клавиша run (Shift)
	
	# Выбор скорости движения
	var current_speed = move_speed
	if is_running:
		current_speed = run_speed
	
	# Обработка движения вперед
	var move_direction = Vector3.ZERO
	if is_moving_forward:
		# Движение вперед по направлению +Z
		move_direction = transform.basis.z.normalized()
	
	if move_direction != Vector3.ZERO:
		velocity.x = move_direction.x * current_speed
		velocity.z = move_direction.z * current_speed
	else:
		velocity.x = 0
		velocity.z = 0

	# Обработка прыжка
	if is_on_ground():
		if is_jumping_pressed:
			vertical_velocity = jump_strength
			is_jumping = true
			play_jump_animation()
			print("Jump initiated")
	else:
		vertical_velocity -= gravity * delta

	# Проверка завершения прыжка
	if is_jumping and is_on_ground():
		is_jumping = false
		print("Jump ended")
	
	velocity.y = vertical_velocity

	# Применяем движение
	move_and_slide()

	# Обработка анимаций и звуков
	if is_jumping:
		# Во время прыжка воспроизводим анимацию "jump"
		if animation_player.current_animation != "jump":
			play_jump_animation()
			print("Playing jump animation")
	else:
		if is_moving_forward:
			play_forward_animation()
			if is_running:
				play_running_sound(true, false)  # Воспроизводим fastRun звук, если используется
			else:
				play_running_sound(false, true)  # Воспроизводим slowRun звук
		else:
			play_idle_animation()
			stop_running_sound()

	# Можно добавить отладочные сообщения для проверки
	# print("Current Animation: ", animation_player.current_animation)
	# print("Velocity: ", velocity)

func is_on_ground() -> bool:
	return raycast.is_colliding()

func update_camera_position():
	if camera:
		# Позиционируем камеру позади хомяка по +Z
		var camera_position = global_transform.origin + transform.basis.z * camera_distance + Vector3(0, camera_height, 0)
		camera.global_transform.origin = camera_position
		camera.look_at(global_transform.origin + Vector3(0, camera_height, 0), Vector3.UP)

# Анимационные функции
func play_forward_animation():
	if animation_player.current_animation != "slowRun":
		animation_player.play("slowRun")
		print("Playing slowRun animation")

func play_jump_animation():
	if animation_player.current_animation != "jump":
		animation_player.play("jump")
		print("Playing jump animation")

func play_idle_animation():
	if animation_player.current_animation != "idle":
		animation_player.play("idle")
		print("Playing idle animation")
		
# Функции для управления звуками
func play_running_sound(is_fast: bool, is_slow: bool):
	if is_fast:
		# if !audio_fast_run.playing:
			# audio_fast_run.play()
			# print("Playing fast run sound")
		pass
	if is_slow:
		if !audio_slow_run.playing:
			audio_slow_run.play()
			print("Playing slow run sound")

func stop_running_sound():
	# if audio_fast_run.playing:
		# audio_fast_run.stop()
		# print("Stopped fast run sound")
	if audio_slow_run.playing:
		audio_slow_run.stop()
		print("Stopped slow run sound")

# Функции для управления инвентарём (опционально)
func add_item(item):
	inventory.append(item)
	print("Добавлен предмет: ", item)

func remove_item(item):
	if item in inventory:
		inventory.erase(item)
		print("Удалён предмет: ", item)
	else:
		print("Предмет не найден: ", item)

func list_inventory():
	print("Инвентарь:", inventory)
