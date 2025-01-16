extends CharacterBody3D

# Экспортируемые переменные для настройки через инспектор
@export var animation_player: AnimationPlayer
@export var move_speed: float = 3.0               # Скорость ходьбы
@export var staying_duration: float = 10.0        # Время между "staying" анимациями
@export var rotation_speed: float = 10.0          # Скорость поворота модели
@export var main_character: NodePath               # Путь к главному персонажу

# Переменные состояния
enum State { WALKING, STAYING }
var current_state: State = State.WALKING

# Таймер для состояния "staying"
@onready var staying_timer = $StayingTimer

# Ссылки на RayCast3D узлы
@onready var ray_forward = $RayCastForward
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight

# Ссылки на узлы AudioStreamPlayer (опционально)
#@onready var audio_walk: AudioStreamPlayer = $AudioStreamPlayer_walk

# Направление движения
var direction: Vector3 = Vector3.ZERO

# Ссылка на главного персонажа
var main_char: CharacterBody3D = null

func _ready():
	# Проверка наличия AnimationPlayer
	if animation_player == null:
		animation_player = $AnimationPlayer
		print("AnimationPlayer назначен.")
	else:
		print("AnimationPlayer уже назначен.")
	
	# Подключение сигнала таймера
	if staying_timer:
		staying_timer.connect("timeout", Callable(self, "_on_StayingTimer_timeout"))
		staying_timer.start(staying_duration)  # Начать отсчет для staying
		print("StayingTimer подключен к сигналу timeout.")
	else:
		print("StayingTimer не найден!")

	# Начать движение
	choose_new_direction()
	
	# Получаем ссылку на главного персонажа
	if main_character:
		main_char = get_node(main_character)
	else:
		print("Путь к главному персонажу не указан.")

func _process(delta):
	match current_state:
		State.WALKING:
			# Движение персонажа
			velocity = direction * move_speed
			move_and_slide()
			
			# Поворот модели в направлении движения
			rotate_model(delta)
			
			if is_moving_towards_obstacle():
				# Остановиться, выбрать новое направление и начать staying
				#stop_walk_sound()
				current_state = State.STAYING
				play_staying_animation()
				choose_new_direction()  # Выбираем новое направление при столкновении
				print("Столкновение с препятствием. Переход в состояние: Staying")
			else:
				play_walk_animation()
				#play_walk_sound()
		State.STAYING:
			pass  # NPC остается на месте

# Функция для выбора нового направления
func choose_new_direction():
	var angle = randf_range(0, 2 * PI)
	direction = Vector3(cos(angle), 0, sin(angle)).normalized()
	print("Выбрано направление: ", direction)

# Проверка наличия препятствий
func is_moving_towards_obstacle() -> bool:
	ray_forward.force_raycast_update()
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()
	
	if ray_forward.is_colliding() or ray_left.is_colliding() or ray_right.is_colliding():
		return true
	return false

# Поворот модели в направлении движения
func rotate_model(delta):
	var target_rotation = Vector3(0, atan2(direction.x, direction.z), 0)
	var current_rotation = self.rotation
	var new_rotation = current_rotation.lerp(target_rotation, rotation_speed * delta)
	self.rotation = new_rotation

# Обработчик таймера staying
func _on_StayingTimer_timeout():
	if current_state == State.WALKING:
		current_state = State.STAYING
		play_staying_animation()
		#stop_walk_sound()
		print("Переход в состояние: Staying")
		# Устанавливаем таймер для возврата к ходьбе через 2 секунды
		await get_tree().create_timer(2.0).timeout
		resume_walking()
	elif current_state == State.STAYING:
		# Если NPC уже в состоянии STAYING, но таймер сработал, возвращаем его к ходьбе
		resume_walking()

# Возобновление ходьбы после staying
func resume_walking():
	if main_char:
		var player_position = main_char.global_position
		var npc_position = self.global_position
		var new_direction = (player_position - npc_position).normalized()
		
		# Убедимся, что NPC не подходит слишком близко к игроку
		if (player_position - npc_position).length() < 5.0:  # Например, 5 единиц - это дистанция, на которой NPC решает сменить направление
			choose_new_direction()  # Смена направления
		else:
			direction = new_direction  # Движение к игроку
			
	current_state = State.WALKING
	play_walk_animation()
	staying_timer.start(staying_duration)  # Перезапуск таймера для следующей staying анимации
	print("Переход в состояние: Ходьба")

# Анимационные функции
func play_walk_animation():
	if animation_player and animation_player.current_animation != "walk":
		animation_player.play("walk")
		print("Воспроизводится анимация: walk")

func play_staying_animation():
	if animation_player and animation_player.current_animation != "staying":
		animation_player.play("staying")
		print("Воспроизводится анимация: staying")

# Управление звуками ходьбы
#func play_walk_sound():
	#if audio_walk and !audio_walk.playing:
		#audio_walk.play()
		#print("Воспроизводится walk звук")
#
#func stop_walk_sound():
	#if audio_walk and audio_walk.playing:
		#audio_walk.stop()
		#print("Останавливается walk звук")
