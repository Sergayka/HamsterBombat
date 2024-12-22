extends CharacterBody3D

@export var animation_player: AnimationPlayer
@export var move_speed: float = 5.0
@export var jump_strength: float = 10.0
@export var gravity: float = 30.0
@export var raycast: RayCast3D

@export var camera: Camera3D
@export var camera_distance: float = -3.0
@export var camera_height: float = 1.5

@export var max_pitch: float = 80.0
@export var min_pitch: float = 0.0
@export var max_yaw: float = 45.0
@export var min_yaw: float = -45.0

var vertical_velocity = 0.0
var is_falling = false
var pitch: float = 0.0
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

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * 0.1
		pitch -= event.relative.y * 0.1

		pitch = clamp(pitch, min_pitch, max_pitch)
		yaw = clamp(yaw, min_yaw, max_yaw)

		update_camera_position()

func _process(delta):
	var move_direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		move_direction.z -= 1
	if Input.is_action_pressed("move_back"):
		move_direction.z += 1
	if Input.is_action_pressed("move_right"):
		move_direction.x += 1
	if Input.is_action_pressed("move_left"):
		move_direction.x -= 1

	if move_direction != Vector3.ZERO:
		move_direction = move_direction.normalized()

	# Поворот персонажа
	if move_direction != Vector3.ZERO:
		var look_direction = Vector2(move_direction.x, move_direction.z)  # Исправлено направление Z
		var new_rotation = atan2(look_direction.x, look_direction.y)
		rotation.y = lerp_angle(rotation.y, new_rotation, 0.1)  # Сглаживаем поворот

	move_direction = -global_transform.basis.z * move_direction.z + global_transform.basis.x * move_direction.x

	if is_on_ground() and Input.is_action_just_pressed("jump"):
		vertical_velocity = jump_strength
		play_jump_animation()

	if not is_on_ground():
		vertical_velocity -= gravity * delta
		is_falling = true
		play_falling_animation()
	else:
		if vertical_velocity < 0:
			vertical_velocity = 0
		if is_falling:
			play_falling_impact_animation()
		is_falling = false

	velocity = move_direction * move_speed
	velocity.y = vertical_velocity

	move_and_slide()

	if move_direction != Vector3.ZERO:
		play_run_animation()
	else:
		if not is_falling:
			play_idle_animation()

func is_on_ground() -> bool:
	return raycast.is_colliding()

func update_camera_position():
	if camera:
		var combined_yaw = yaw + rotation.y  # Суммируем повороты камеры и персонажа
		var camera_rotation = Basis()
		camera_rotation = camera_rotation.rotated(Vector3.UP, deg_to_rad(combined_yaw))
		camera_rotation = camera_rotation.rotated(Vector3.RIGHT, deg_to_rad(pitch))

		var offset = Vector3(0, camera_height, -camera_distance)
		var camera_position = camera_rotation * offset

		camera.global_transform.origin = global_transform.origin + camera_position
		camera.look_at(global_transform.origin, Vector3.UP)

# Анимационные функции (оставлены без изменений)
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
	if animation_player.current_animation != "fallingFlatImpact":
		animation_player.play("fallingFlatImpact")
