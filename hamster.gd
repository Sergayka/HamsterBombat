extends Node3D

# Переменные
@export var move_speed = 5.0
var velocity = Vector3.ZERO

# Функция запускается при старте
func _ready() -> void:
	print("Kitchen is ready!")

# Обработка кадров
func _process(delta: float) -> void:
	handle_input(delta)

# Обработка ввода
func handle_input(delta: float) -> void:
	if Input.is_action_pressed("move_forward"):
		velocity.z -= move_speed * delta
		print("Moving forward")

