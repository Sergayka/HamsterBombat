extends Node3D


func _ready() -> void:
	$intro_out/AnimationPlayer.play("intro_out")
	$intro_out/Timer.start()
	MusicManager.toggle_music()


func _on_timer_timeout() -> void:
	$intro_out.visible = false

