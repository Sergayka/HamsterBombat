extends Node

var music_player: AudioStreamPlayer

func _ready():
	# Создаем или находим аудиоплеер
	if not music_player:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
		music_player.stream = preload("res://music.mp3")

		# Проверяем, что поток существует
		if music_player.stream and music_player.stream is AudioStream:
			var stream = music_player.stream as AudioStream
			stream.loop = true
			
		music_player.volume_db = -30

func play_music():
	if music_player and not music_player.playing:
		music_player.play()

func toggle_music():
	if music_player:
		music_player.stream_paused = not music_player.stream_paused


func set_volume(volume: float):
	if music_player:
		music_player.volume_db = volume
