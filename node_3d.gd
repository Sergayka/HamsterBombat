extends Node3D


func _ready() -> void:
	$intro_out/AnimationPlayer.play("intro_out")
	$intro_out/Timer.start()
	
	MusicManager.toggle_music()
	
	$Blur.visible = false


func _on_timer_timeout() -> void:
	$intro_out.visible = false


func _on_pause_pressed() -> void:
	$Blur.visible = true
	$Blur/AnimationPlayer.play('blur_in')
	$CanvasLayer/Control/PauseMenu/AnimationPlayer.play("in")
