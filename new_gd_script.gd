extends CharacterBody3D

const SPEED = 5.0          # Скорость движения
const JUMP_FORCE = 5.0     # Сила прыжка
const GRAVITY = -9.8       # Гравитация
const ROTATION_SPEED = 1.5 # Скорость вращения персонажа

func _physics_process(delta):
	# Управление
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction.z += 0.5
	if Input.is_action_pressed("move_backward"):
		direction.z -= 0.5
	if Input.is_action_pressed("move_left"):
		direction.x += 0.5
	if Input.is_action_pressed("move_right"):
		direction.x -= 0.5

	# Нормализация направления
	direction = direction.normalized()

	# Движение
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	# Прыжки и гравитация
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_FORCE
	else:
		velocity.y += GRAVITY * delta

	# Вращение персонажа
	if Input.is_action_pressed("ui_left"):
		rotation.y += ROTATION_SPEED * delta
	if Input.is_action_pressed("ui_right"):
		rotation.y -= ROTATION_SPEED * delta

	# Применяем движение
	move_and_slide()
