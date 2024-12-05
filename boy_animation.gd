extends Node3D

# Переменная для доступа к AnimationPlayer
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Включаем анимацию "hipHopDance" и задаем зацикливание
	animation_player.play("hipHopDance", -1.0, 1.0, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
