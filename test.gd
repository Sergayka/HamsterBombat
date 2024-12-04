extends Node3D

@export var animation_player: AnimationPlayer
@export var move_speed: float = 5.0  # Скорость передвижения хомяка
@export var jump_strength: float = 10.0  # Сила прыжка
@export var gravity: float = 30.0  # Сила гравитации
@export var raycast: RayCast3D  # RayCast для проверки земли
@export var camera: Camera3D  # Камера для слежения за хомяком
@export var camera_offset: Vector3 = Vector3(0, 2, -5)  # Смещение камеры относительно хомяка

var is_moving = false
var is_turning = false  # Флаг поворота, добавлен в область видимости
var velocity = Vector3.ZERO  # Вектор скорости хомяка
var vertical_velocity = 0.0  # Вертикальная скорость для прыжка
var rotation_speed: float = 5.0  # Скорость поворота хомяка и камеры

func _ready():
	# Если ссылка на AnimationPlayer не была установлена через инспектор, ищем узел вручную
	if animation_player == null:
		animation_player = $AnimationPlayer  # Получаем узел AnimationPlayer, если не назначен в редакторе

	# Убедимся, что AnimationPlayer найден
	if animation_player == null:
		print("AnimationPlayer не найден!")
		return

	# Инициализируем анимацию по умолчанию
	play_idle_animation()

	# Проверка, чтобы RayCast был подключен
	if raycast == null:
		raycast = $RayCast3D  # Получаем узел RayCast3D, если не назначен в редакторе
	if raycast == null:
		print("RayCast3D не найден!")

	# Если камера не назначена, то пытаемся найти её
	if camera == null:
		camera = $Camera3D

func _process(delta):
	# Получаем ввод от игрока
	var move_direction = Vector3.ZERO

	# Если игрок двигается, вычисляем направление движения
	if Input.is_action_pressed("move_forward"):  # W
		move_direction.z += 1
	if Input.is_action_pressed("move_back"):  # S
		move_direction.z -= 1
	if Input.is_action_pressed("move_left"):  # A
		move_direction.x += 1
	if Input.is_action_pressed("move_right"):  # D
		move_direction.x -= 1

	# Нормализуем вектор, чтобы движение было равномерным
	if move_direction != Vector3.ZERO:
		move_direction = move_direction.normalized()
		is_moving = true
	else:
		is_moving = false

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

	# Обновляем скорость (только по оси X и Z для движения)
	velocity = move_direction * move_speed
	velocity.y = vertical_velocity  # Добавляем вертикальную составляющую

	# Перемещаем хомяка только по X и Z
	position += velocity * delta

	# Обновляем анимацию в зависимости от состояния
	if is_moving:
		play_run_animation()
	else:
		play_idle_animation()

	# Проверка на повороты
	if Input.is_action_pressed("move_right"):  # Поворот направо
		rotate_right(delta)
		play_turn_right_animation()

	if Input.is_action_pressed("move_left"):  # Поворот налево
		rotate_left(delta)
		play_turn_left_animation()

	# Обновляем позицию камеры
	update_camera_position()

# Функция для проверки, находится ли хомяк на земле с использованием RayCast
func is_on_ground() -> bool:
	# Проверка, что RayCast направлен вниз и пересекает землю
	return raycast.is_colliding()  # Проверка нормали столкновения

# Функция для проигрывания анимации "slow run"
func play_run_animation():
	if animation_player.current_animation != "slowRun":
		animation_player.play("slowRun")

# Функция для проигрывания анимации "idle" (стояние)
func play_idle_animation():
	if animation_player.current_animation != "idle":
		animation_player.play("idle")

# Функция для проигрывания анимации прыжка
func play_jump_animation():
	if animation_player.current_animation != "jump":
		animation_player.play("jump")

# Функция для проигрывания анимации поворота направо
func play_turn_right_animation():
	# Останавливаем движение
	is_turning = true
	velocity = Vector3.ZERO  # Останавливаем движение хомяка по оси X и Z
	if animation_player.current_animation != "turnRight":
		animation_player.play("turnRight")

# Функция для проигрывания анимации поворота налево
func play_turn_left_animation():
	# Останавливаем движение
	is_turning = true
	velocity = Vector3.ZERO  # Останавливаем движение хомяка по оси X и Z
	if animation_player.current_animation != "turnLeft":
		animation_player.play("turnLeft")

# Функция для поворота хомяка направо
func rotate_right(delta: float):
	# Поворот хомяка по оси Y
	rotation.y -= rotation_speed * delta
	# Поворот камеры (для слежения)
	camera.rotation.y = rotation.y

# Функция для поворота хомяка налево
func rotate_left(delta: float):
	# Поворот хомяка по оси Y
	rotation.y += rotation_speed * delta
	# Поворот камеры (для слежения)
	camera.rotation.y = rotation.y

# Функция для обновления позиции камеры
func update_camera_position():
	# Камера должна следовать за хомяком с фиксированным смещением
	var camera_position = position + camera_offset
	camera.global_transform.origin = camera_position
