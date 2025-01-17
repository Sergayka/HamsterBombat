extends CharacterBody3D

# Экспортируемые переменные для настройки через инспектор
@export var animation_player: AnimationPlayer
@export var move_speed: float = 5.0
@export var staying_duration: float = 5.0
@export var rotation_speed: float = 10.0
@export var main_character: NodePath

# Переменные состояния
enum State { WALKING, STAYING }
var current_state: State = State.WALKING

# Таймер для состояния "staying"
@onready var staying_timer = $StayingTimer

# Ссылки на RayCast3D узлы
@onready var ray_forward = $RayCastForward
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight

# Направление движения
var direction: Vector3 = Vector3.ZERO

# Ссылка на главного персонажа
var main_char: CharacterBody3D = null

func _ready():
	if !animation_player:
		animation_player = $AnimationPlayer
		print("AnimationPlayer назначен.")
	
	if staying_timer:
		staying_timer.connect("timeout", Callable(self, "_on_StayingTimer_timeout"))
		staying_timer.start(staying_duration)
		print("StayingTimer подключен к сигналу timeout.")
	else:
		print("StayingTimer не найден!")

	if main_character:
		main_char = get_node(main_character)
	else:
		print("Путь к главному персонажу не указан.")

	choose_new_direction()

func _physics_process(delta):
	match current_state:
		State.WALKING:
			move_and_navigate(delta)
		State.STAYING:
			pass  # Оставаться на месте

func move_and_navigate(delta):
	var target_direction = get_target_direction()
	if target_direction != Vector3.ZERO:
		direction = target_direction.normalized()
	else:
		direction = Vector3.ZERO

	# Скорость поворота для более плавного движения
	var new_rotation = self.rotation
	new_rotation.y = lerp_angle(new_rotation.y, atan2(direction.x, direction.z), rotation_speed * delta)
	self.rotation = new_rotation

	velocity = direction * move_speed
	move_and_slide()

	if is_moving_towards_obstacle():
		current_state = State.STAYING
		play_staying_animation()
		choose_new_direction()
		print("Столкновение с препятствием. Переход в состояние: Staying")
	else:
		play_walk_animation()

func get_target_direction() -> Vector3:
	if main_char:
		var to_player = main_char.global_position - global_position
		to_player.y = 0  # Ignore height differences for 2D-like navigation
		if to_player.length() > 5.0:  # Maintain a minimum distance
			return to_player
	return Vector3.ZERO  # If no player found or too close, return zero vector

func is_moving_towards_obstacle() -> bool:
	ray_forward.force_raycast_update()
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()
	
	if ray_forward.is_colliding() or ray_left.is_colliding() or ray_right.is_colliding():
		return true
	return false

func choose_new_direction():
	var angle = randf_range(0, 2 * PI)
	direction = Vector3(cos(angle), 0, sin(angle)).normalized()
	print("Выбрано новое направление: ", direction)

func _on_StayingTimer_timeout():
	if current_state == State.STAYING:
		resume_walking()
	else:
		current_state = State.STAYING
		play_staying_animation()
		staying_timer.start(2.0)  # Short pause before resuming walking
		print("Переход в состояние: Staying")

func resume_walking():
	current_state = State.WALKING
	play_walk_animation()
	staying_timer.start(staying_duration)
	print("Переход в состояние: Ходьба")

func play_walk_animation():
	if animation_player and animation_player.current_animation != "walk":
		animation_player.play("walk")
		print("Воспроизводится анимация: walk")

func play_staying_animation():
	if animation_player and animation_player.current_animation != "staying":
		animation_player.play("staying")
		print("Воспроизводится анимация: staying")
