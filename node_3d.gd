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
