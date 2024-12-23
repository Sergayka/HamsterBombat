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


#func _ready() -> void:
	#$intro_out/AnimationPlayer.play("intro_out")
	#$intro_out/Timer.start()
	#
	#MusicManager.toggle_music()
	#
	#$Blur.visible = false
#
#
#func _on_timer_timeout() -> void:
	#$intro_out.visible = false
#
#
#func _on_pause_pressed() -> void:
	#$Blur.visible = true
	#$Blur/AnimationPlayer.play('blur_in')
	#$CanvasLayer/Control/PauseMenu/AnimationPlayer.play("in")
