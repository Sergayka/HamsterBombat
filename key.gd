extends StaticBody3D

func _process(delta):
	# Получаем все узлы в группе "player"
	var players = get_tree().get_nodes_in_group("player")
	
	for player in players:
		# Получаем узел RayCastToDoor у игрока
		var raycast = player.get_node_or_null("RayCastToDoor")
		
		if raycast and raycast.is_colliding():
			var collider = raycast.get_collider()
			
			# Проверяем, является ли коллайдер этим ключом
			if collider == self:
				# Добавляем ключ в инвентарь игрока
				if player.has_method("add_item"):
					player.add_item("key")
					print("Ключ добавлен в инвентарь игрока")
				else:
					push_error("У игрока отсутствует метод add_item")
				
				# Удаляем ключ из сцены
				queue_free()
				break  # Выходим из цикла после добавления
