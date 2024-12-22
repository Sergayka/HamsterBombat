extends CharacterBody3D

@export var animation_player: AnimationPlayer
@export var move_speed: float = 5.0
@export var jump_strength: float = 10.0
@export var gravity: float = 30.0
@export var raycast: RayCast3D

@export var camera: Camera3D
@export var camera_distance: float = -2.0  # Положительное значение для отдаления камеры
@export var camera_height: float = 1.5

@export var mouse_sensitivity: float = 0.2
@export var max_yaw: float = 360.0
@export var min_yaw: float = 0.0

var vertical_velocity = 0.0
var is_falling = false
var yaw: float = 0.0

func _ready():
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
	
	# Захватываем мышь для управления камерой
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Поворачиваем хомяка по горизонтали на основе движения мыши
		yaw -= event.relative.x * mouse_sensitivity * 0.01
		yaw = wrapf(yaw, 0, 2 * PI)  # Ограничиваем значение yaw в диапазоне [0, 2π)
		rotation.y = yaw

		# Обновляем позицию камеры
		update_camera_position()

func _process(delta):
	var is_moving_forward = Input.is_action_pressed("move_forward")
	var is_jumping = Input.is_action_just_pressed("jump")
	
	# Обработка движения вперед
	var move_direction = Vector3.ZERO
	if is_moving_forward:
		# Изменили знак с -z на +z для корректного движения вперед
		move_direction = transform.basis.z.normalized()
	
	if move_direction != Vector3.ZERO:
		velocity = move_direction * move_speed
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

	# Обработка анимаций
	if is_moving_forward:
		play_forward_animation()
	else:
		if not is_falling:
			play_idle_animation()

func is_on_ground() -> bool:
	return raycast.is_colliding()

func update_camera_position():
	if camera:
		# Позиционируем камеру позади хомяка по +z, если движение вперед по +z
		var camera_position = global_transform.origin + transform.basis.z * camera_distance + Vector3(0, camera_height, 0)
		camera.global_transform.origin = camera_position
		camera.look_at(global_transform.origin + Vector3(0, camera_height, 0), Vector3.UP)

# Анимационные функции
func play_forward_animation():
	if animation_player.current_animation != "slowRun":
		animation_player.play("slowRun")

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
