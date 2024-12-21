extends Camera3D

# Скорость вращения
var mouse_sensitivity: float = 10

# Углы вращения
var rotation_x: float = 0.0
var rotation_y: float = 0.0

# Ограничение вращения по вертикали
var max_pitch_angle: float = 180.0

func _ready():
	# Прячем курсор и захватываем его в окно
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# Изменяем углы вращения на основе движения мыши
		rotation_y -= event.relative.x * mouse_sensitivity *0.01
		rotation_x -= event.relative.y * mouse_sensitivity * 0.1

		# Ограничиваем вертикальное вращение
		rotation_x = clamp(rotation_x, -rad_to_deg(max_pitch_angle), rad_to_deg(max_pitch_angle))

		# Применяем вращение
		rotation_degrees = Vector3(rad_to_deg(rotation_x), 0, 0)

	# Если пользователь нажимает Esc, освобождаем курсор
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
