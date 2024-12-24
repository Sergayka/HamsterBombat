extends Area3D

var in_dialogue = false

func _on_area_entered(area):
	print('123123')
	start_dialogue()

func start_dialogue():
	if in_dialogue:
		return
	in_dialogue = true
	print("Привет, я крыса! Как дела?")
	# Здесь вы можете вызвать UI-систему диалогов
	call_deferred("_end_dialogue")

# Завершение диалога
func _end_dialogue():
	in_dialogue = false
