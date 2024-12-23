extends Node3D


func _ready() -> void:
	$intro_out/AnimationPlayer.play("intro_out")
	$intro_out/Timer.start()
	
	MusicManager.toggle_music()
	
	$Blur.visible = false

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
