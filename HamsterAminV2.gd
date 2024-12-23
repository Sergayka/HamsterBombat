extends CharacterBody3D

# Экспортируемые переменные для настройки через инспектор
@export var animation_player: AnimationPlayer
@export var move_speed: float = 5.0               # Обычная скорость
@export var run_speed: float = 8.0                # Скорость при ускорении
@export var jump_strength: float = 10.0
@export var gravity: float = 30.0
@export var raycast: RayCast3D

@export var camera: Camera3D
@export var camera_distance: float = -2.5          # Расстояние камеры за хомяком
@export var camera_height: float = 1.5            # Высота камеры

@export var mouse_sensitivity: float = 0.2
@export var max_yaw: float = 360.0
@export var min_yaw: float = 0.0

@export var turning_duration: float = 0.2        # Продолжительность анимации поворота после движения мышью

# Добавляем экспортируемые переменные для звуковых эффектов
@export var slow_run_sound: AudioStream
@export var fast_run_sound: AudioStream

var vertical_velocity = 0.0
var is_falling = false
var yaw: float = 0.0

# Переменная для управления таймером анимации поворота
var turning_timer: float = 0.0


var audio_slow_run: AudioStreamPlayer
var audio_fast_run: AudioStreamPlayer

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
	audio_fast_run = $AudioStreamPlayer_fastRun

	# Назначение звуковых файлов через экспортируемые переменные
	if slow_run_sound != null:
		audio_slow_run.stream = slow_run_sound
	else:
		print("slow_run_sound не назначен!")

	if fast_run_sound != null:
		audio_fast_run.stream = fast_run_sound
	else:
		print("fast_run_sound не назначен!")
	
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

		# Определяем направление поворота и воспроизводим соответствующую анимацию
		#if event.relative.x > 0:
			#play_turn_right_animation()
		#elif event.relative.x < 0:
			#play_turn_left_animation()
		
		# Сбрасываем таймер поворота
		turning_timer = turning_duration

func _process(delta):
	var is_moving_forward = Input.is_action_pressed("move_forward")
	var is_jumping = Input.is_action_just_pressed("jump")
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
		velocity = move_direction * current_speed
	else:
		velocity = Vector3.ZERO

	# Обработка прыжка
	if is_on_ground():
		if is_jumping:
			vertical_velocity = jump_strength
			play_jump_animation()
	else:
		vertical_velocity -= gravity * delta
		is_falling = true
		play_falling_animation()
	
	if is_on_ground() and is_falling:
		if vertical_velocity < 0:
			vertical_velocity = 0
		play_falling_impact_animation()
		is_falling = false

	velocity.y = vertical_velocity

	# Применяем движение
	move_and_slide()

  # Обработка анимаций и звуков
	if turning_timer > 0:
		# В процессе поворота, анимация уже установлена в _unhandled_input
		turning_timer -= delta
	else:
	# После завершения поворота, переключаемся на анимацию движения или покоя
		if is_moving_forward:
			if is_running:
				play_fast_run_animation()
				play_running_sound(true, false)  # Воспроизводим fastRun звук
			else:
				play_forward_animation()
				play_running_sound(false, true)  # Воспроизводим slowRun звук
		else:
			if not is_falling:
				play_idle_animation()
				stop_running_sound()  # Останавливаем все беговые звуки

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

func play_fast_run_animation():
	if animation_player.current_animation != "fastRun":
		animation_player.play("fastRun")

func play_turn_left_animation():
	if animation_player.current_animation != "turnLeft":
		animation_player.play("turnLeft")

func play_turn_right_animation():
	if animation_player.current_animation != "turnRight":
		animation_player.play("turnRight")

func play_jump_animation():
	if animation_player.current_animation != "jump":
		animation_player.play("jump")

func play_falling_animation():
	if animation_player.current_animation != "falling":
		animation_player.play("falling")

func play_falling_impact_animation():
	if animation_player.current_animation != "fallingFlatImpact":
		animation_player.play("fallingFlatImpact")

func play_idle_animation():
	if animation_player.current_animation != "idle":
		animation_player.play("idle")
		
		
# Функции для управления звуками
func play_running_sound(is_fast: bool, is_slow: bool):
	if is_fast and !audio_fast_run.playing:
		audio_fast_run.play()
	elif is_slow and !audio_slow_run.playing:
		audio_slow_run.play()

func stop_running_sound():
	if audio_fast_run.playing:
		audio_fast_run.stop()
	if audio_slow_run.playing:
		audio_slow_run.stop()
