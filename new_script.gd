extends Node3D

@export var animation_player: AnimationPlayer
@export var move_speed: float = 5.0  # Скорость движения хомяка
@export var jump_strength: float = 10.0  # Сила прыжка
@export var gravity: float = 30.0  # Сила гравитации
@export var raycast: RayCast3D  # RayCast для проверки земли

@export var camera: Camera3D  # Камера хомяка
@export var camera_distance: float = -1.0  # Высота камеры от хомяка
@export var camera_height: float = 0.5  # Расстояниекамеры относительно хомяка
@export var camera_offset_angle: float = 1.2  # Угол наклона камеры в градусах

var is_turning = false
var is_moving = false
var velocity = Vector3.ZERO  # Вектор скорости хомяка
var vertical_velocity = 0.0  # Вертикальная скорость для прыжка

func _ready():
	if animation_player == null:
		animation_player = $AnimationPlayer  # Получаем узел AnimationPlayer, если не назначен в редакторе
		
	# Убедимся, что AnimationPlayer найден
	if animation_player == null:
		print("AnimationPlayer не найден!")
		return
	
	# Если ссылка на Camera3D не была установлена через инспектор, ищем ее вручную
	if camera == null:
		camera = get_node("Camera3D")  # Получаем камеру, если она не назначена в редакторе

	# Проверяем наличие камеры
	if camera == null:
		print("Camera3D не найдена!")

	# Инициализируем анимацию
	play_idle_animation()

	# Проверка, чтобы RayCast был подключен
	if raycast == null:
		raycast = get_node("RayCast3D")  # Получаем узел RayCast3D, если не назначен в редакторе
	if raycast == null:
		print("RayCast3D не найден!")

func _process(delta):
	# Получаем ввод от игрока
	var move_direction = Vector3.ZERO

	# Если игрок двигается, вычисляем направление движения относительно локальной оси хомяка
	if Input.is_action_pressed("move_forward"):  # W
		move_direction.z += 1
	if Input.is_action_pressed("move_back"):  # S
		move_direction.z -= 1

	# Нормализуем вектор, чтобы движение было равномерным
	if move_direction != Vector3.ZERO:
		move_direction = move_direction.normalized()
		is_moving = true
	else:
		is_moving = false

	# Преобразуем локальное направление в глобальное, используя ориентацию хомяка
	move_direction = global_transform.basis * move_direction # Преобразуем локальный вектор в глобальный

	# Проверка на прыжок
	if is_on_ground() and Input.is_action_just_pressed("jump"):  # Пробел
		vertical_velocity = jump_strength
		play_jump_animation()

	# Обновляем вертикальную скорость (гравитация)
	if not is_on_ground():
		vertical_velocity -= gravity * delta  # Если хомяк не на земле, действуем гравитацией
	else:
		if vertical_velocity < 0:
			vertical_velocity = 0  # Сбрасываем вертикальную скорость при приземлении

	# Обновляем скорость
	velocity = move_direction * move_speed
	velocity.y = vertical_velocity  # Добавляем вертикальную составляющую

	# Перемещаем хомяка только по X и Z
	position += velocity * delta

	# Обновляем анимацию
	if is_moving:
		play_run_animation()
	else:
		play_idle_animation()

	# Повороты
	if Input.is_action_pressed("move_right"):  # Поворот направо
		turn_right(delta)
	if Input.is_action_pressed("move_left"):  # Поворот налево
		turn_left(delta)

	# Обновление позиции камеры
	update_camera_position()


# Функция для обновления позиции камеры относительно хомяка
func update_camera_position():
	# Камера должна быть позади хомяка, с наклоном снизу вверх.
	var angle_in_radians = deg_to_rad(camera_offset_angle)  # Конвертируем угол наклона в радианы

	# Вычисляем смещение камеры относительно хомяка:
	# Смещение камеры по оси Y — это высота относительно хомяка.
	# Смещение по оси Z будет отрицательным, чтобы камера была позади.
	var offset = Vector3(0, camera_height, camera_distance)  # Камера находится немного ниже и позади.
	offset = offset.rotated(Vector3.UP, rotation.y)  # Поворот камеры вокруг хомяка (по оси Y)
	offset = offset.rotated(Vector3.RIGHT, angle_in_radians)  # Наклон камеры по оси X для поднятия снизу вверх

	# Позиция камеры — это позиция хомяка с добавленным смещением
	camera.global_transform.origin = position + offset
	
	# Камера всегда должна смотреть на хомяка
	camera.look_at(position, Vector3.UP)

# Функция для проверки, находится ли хомяк на земле с использованием RayCast
func is_on_ground() -> bool:
	# Проверка, что RayCast направлен вниз и пересекает землю
	return raycast.is_colliding()

# Функция для проигрывания анимации "slow run"
func play_run_animation():
	# Если анимация не проигрывается, то проигрываем "slowRun"
	if animation_player.current_animation != "slowRun":
		animation_player.play("slowRun")

# Функция для проигрывания анимации "idle"
func play_idle_animation():
	# Если анимация не проигрывается, то проигрываем "idle"
	if animation_player.current_animation != "idle":
		animation_player.play("idle")

# Функция для проигрывания анимации прыжка
func play_jump_animation():
	# Если анимация не проигрывается, то проигрываем "jump"
	if animation_player.current_animation != "jump":
		animation_player.play("jump")

# Функция для поворота направо
func turn_right(delta):
	# Поворот хомяка направо
	rotation.y -= 5.0 * delta  # Скорость поворота
	if animation_player.current_animation != "turnRight":
		animation_player.play("turnRight")
		
# Функция для поворота налево
func turn_left(delta):
	# Поворот хомяка налево
	rotation.y += 5.0 * delta  # Скорость поворота
	if animation_player.current_animation != "turnLeft":
		animation_player.play("turnLeft")
