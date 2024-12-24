extends Node3D

func _ready() -> void:
	$Blur.visible = false

func _process(delta: float) -> void:
	Btns()

func Btns():
	if Input.is_action_just_pressed("escape") and !$Blur.visible:
		_on_pause_pressed()
	elif Input.is_action_just_pressed("escape") and $Blur.visible:
		_on_pause_closed()
	elif Input.is_action_just_pressed("inventory") and !$Blur.visible:
		_on_inventory_pressed()
	elif Input.is_action_just_pressed("inventory") and $Blur.visible:
		_on_inventory_closed()


func _on_pause_pressed() -> void:
	if !$Blur.visible:
		$Blur.visible = true
		$Blur/AnimationPlayer.play("blur_in")
		$CanvasLayer/Control/PauseMenu/AnimationPlayer.play("in")
		$CanvasLayer/Control/pause.visible = false
		$CanvasLayer/Control/inventory.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_pause_closed() -> void:
	if $Blur.visible:
		$Blur/AnimationPlayer.play("blur_out")
		$CanvasLayer/Control/PauseMenu/AnimationPlayer.play("out")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$Blur.visible = false

func _on_inventory_pressed() -> void:
	if !$Blur.visible:
		$Blur.visible = true
		$Blur/AnimationPlayer.play("blur_in")
		$CanvasLayer/Control/Inventory/AnimationPlayer.play("in")
		$CanvasLayer/Control/pause.visible = false
		$CanvasLayer/Control/inventory.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_inventory_closed() -> void:
	if $Blur.visible:
		$Blur/AnimationPlayer.play("blur_out")
		$CanvasLayer/Control/Inventory/AnimationPlayer.play("out")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$Blur.visible = false
