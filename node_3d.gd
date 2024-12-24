extends Node3D

#@onready var music_player = $AudioStreamPlayer  # Ссылаемся на узел AudioStreamPlayer
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#var music_stream = music_player.stream
	#if music_stream != null:
		#music_stream.loop = true  # Включаем зацикливание в самом потоке аудио
#
	## Воспроизведение музыки
	#music_player.play()  # Музыка начнёт играть сразу после загрузки сцены



func _process(delta: float) -> void:
	Btns()

func Btns():
	if Input.is_action_just_pressed("escape") and !$Blur.visible:
		_on_pause_pressed()
	elif Input.is_action_just_pressed("escape") and $Blur.visible:
		$CanvasLayer/Control/PauseMenu._on_back_pressed()
	elif Input.is_action_just_pressed("inventory") and !$Blur.visible:
		_on_inventory_pressed()
	elif Input.is_action_just_pressed("inventory") and $Blur.visible:
		$Blur/AnimationPlayer.play("blur_out")
		$CanvasLayer/Control/Inventory/AnimationPlayer.play("out")


func _on_pause_pressed() -> void:
	if !$Blur.visible:
		$Blur.visible = true
		$Blur/AnimationPlayer.play("blur_in")
		$CanvasLayer/Control/PauseMenu/AnimationPlayer.play("in")
		$CanvasLayer/Control/pause.visible = false
		$CanvasLayer/Control/inventory.visible = false


func _on_inventory_pressed() -> void:
	if !$Blur.visible:
		$Blur.visible = true
		$Blur/AnimationPlayer.play("blur_in")
		$CanvasLayer/Control/Inventory/AnimationPlayer.play("in")
		$CanvasLayer/Control/pause.visible = false
		$CanvasLayer/Control/inventory.visible = false
