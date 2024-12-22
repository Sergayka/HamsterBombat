extends CharacterBody3D

@export var animation_player: AnimationPlayer
@export var move_speed: float = 5.0  # Скорость движения хомяка
@export var jump_strength: float = 10.0  # Сила прыжка
@export var gravity: float = 30.0  # Сила гравитации
@export var raycast: RayCast3D  # RayCast для проверки земли

@export var camera: Camera3D  # Камера хомяка
@export var camera_distance: float = -1.0  # Расстояние камеры от хомяка
@export var camera_height: float = 0.5  # Высота камеры относительно хомяка
@export var camera_offset_angle: float = 5.2  # Угол наклона камеры в градусах

var vertical_velocity = 0.0  # Вертикальная скорость для прыжка
var is_falling = false

func _ready():
	if animation_player == null:
		animation_player = $AnimationPlayer
		
	# Убедимся, что RayCast3D подключен
	if raycast == null:
		raycast = $RayCast3D

	# Проверяем, что камера и другие компоненты правильно подключены
	if camera == null:
		print("Camera3D не назначена!")
	else:
		print("Camera3D найдена!")

# Функция обновления игры каждый кадр
func _process(delta):
	var move_direction = Vector3.ZERO

	# Получаем ввод от игрока
	if Input.is_action_pressed("move_forward"):
		move_direction.z += 1
	if Input.is_action_pressed("move_back"):
		move_direction.z -= 1

	# Нормализуем вектор, чтобы движение было равномерным
	if move_direction != Vector3.ZERO:
		move_direction = move_direction.normalized()

	# Преобразуем локальное направление в глобальное
	move_direction = global_transform.basis * move_direction

	# Проверка на прыжок
	if is_on_ground() and Input.is_action_just_pressed("jump"):
		vertical_velocity = jump_strength
		play_jump_animation()

	# Обновляем вертикальную скорость (гравитация)
	if not is_on_ground():
		vertical_velocity -= gravity * delta  # Применяем гравитацию
		is_falling = true
		play_falling_animation()
	else:
		if vertical_velocity < 0:
			vertical_velocity = 0  # Сбрасываем вертикальную скорость при приземлении
		if is_falling:
			play_falling_impact_animation()
		is_falling = false

	# Логирование скорости
	print("Velocity: ", move_direction * move_speed + Vector3(0, vertical_velocity, 0))

	# Обновляем скорость
	velocity = move_direction * move_speed  # Составляем горизонтальную скорость
	velocity.y = vertical_velocity  # Добавляем вертикальную скорость

	# Перемещаем хомяка с учетом коллизий и вертикальной скорости
	move_and_slide()

	# Обновляем анимацию
	if move_direction != Vector3.ZERO:
		play_run_animation()
	else:
		if not is_falling:
			play_idle_animation()

	# Повороты
	if Input.is_action_pressed("move_right"):
		turn_right(delta)
	if Input.is_action_pressed("move_left"):
		turn_left(delta)

	# Обновление позиции камеры
	if camera != null:
		update_camera_position()

# Проверка на землю
func is_on_ground() -> bool:
	return raycast.is_colliding()

# Обновление позиции камеры
func update_camera_position():
	if camera != null:
		var angle_in_radians = deg_to_rad(camera_offset_angle)
		var offset = Vector3(0, camera_height, camera_distance)
		offset = offset.rotated(Vector3.UP, rotation.y)
		offset = offset.rotated(Vector3.RIGHT, angle_in_radians)
		camera.transform.origin = position + offset
		camera.look_at(position, Vector3.UP)

# Функции для анимаций
func play_run_animation():
	if animation_player.current_animation != "slowRun":
		animation_player.play("slowRun")

func play_idle_animation():
	if animation_player.current_animation != "idle":
		animation_player.play("idle")

func play_jump_animation():
	if animation_player.current_animation != "jump":
		animation_player.play("jump")

func play_falling_animation():
	if animation_player.current_animation != "falling":
		animation_player.play("falling")

func play_falling_impact_animation():
	if animation_player.current_animation != "fallingFlatImapct":
		animation_player.play("fallingFlatImapct")

# Повороты
func turn_right(delta):
	rotation.y -= 5.0 * delta  # Поворот направо (на основе времени)
	if animation_player.current_animation != "turnRight":
		animation_player.play("turnRight")

func turn_left(delta):
	rotation.y += 5.0 * delta  # Поворот налево (на основе времени)
	if animation_player.current_animation != "turnLeft":
		animation_player.play("turnLeft")
