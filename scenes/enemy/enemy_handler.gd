class_name EnemyHandler
extends Node2D

var acting_enemies: Array[Enemy] = []

func _ready() -> void:
	Events.enemy_died.connect(_on_enemy_died)
	Events.enemy_action_completed.connect(_on_enemy_action_completed)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)


func setup_enemies(battle_stats: BattleStats) -> void:
	if not battle_stats:
		return

	# Clear existing enemies
	for enemy: Enemy in get_children():
		enemy.queue_free()

	var all_new_enemies := battle_stats.enemies.instantiate()
	var new_enemies: Array[Enemy] = []

	for new_enemy: Node2D in all_new_enemies.get_children():
		var new_enemy_child: Enemy = new_enemy.duplicate() as Enemy
		new_enemies.append(new_enemy_child)

	all_new_enemies.queue_free()

	_spawn_enemies_with_dynamic_layout(new_enemies)



func _spawn_enemies_with_dynamic_layout(enemies: Array[Enemy]) -> void:
	var screen_size = get_viewport_rect().size
	var max_per_row: int = 4
	var padding: Vector2 = Vector2(260, 120)
	var start_y: float = 1015.0

	var count: int = enemies.size()
	var row: int = 0
	var column: int = 0

	for i in enemies.size():
		var enemy: Enemy = enemies[i]

		row = int(i / max_per_row)
		column = i % max_per_row

		var enemies_in_row: int = min(max_per_row, count - row * max_per_row)
		var row_width: float = float(enemies_in_row - 1) * padding.x
		var start_x: float = (screen_size.x - row_width) / 2.0

		var x: float = start_x + column * padding.x +300.0
		var y: float = start_y + row * padding.y

		enemy.position = Vector2(x, y)

		add_child(enemy)
		enemy.status_handler.statuses_applied.connect(_on_enemy_statuses_applied.bind(enemy))



func reset_enemy_actions() -> void:
	for enemy: Enemy in get_children():
		enemy.current_action = null
		enemy.update_action()


func start_turn() -> void:
	if get_child_count() == 0:
		return

	acting_enemies.clear()
	for enemy: Enemy in get_children():
		acting_enemies.append(enemy)

	_start_next_enemy_turn()


func _start_next_enemy_turn() -> void:
	if acting_enemies.is_empty():
		Events.enemy_turn_ended.emit()
		return

	acting_enemies[0].status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)


func _on_enemy_statuses_applied(type: Status.Type, enemy: Enemy) -> void:
	match type:
		Status.Type.START_OF_TURN:
			enemy.do_turn()
		Status.Type.END_OF_TURN:
			acting_enemies.erase(enemy)
			_start_next_enemy_turn()


func _on_enemy_died(enemy: Enemy) -> void:
	var is_enemy_turn := acting_enemies.size() > 0
	acting_enemies.erase(enemy)

	if is_enemy_turn:
		_start_next_enemy_turn()


func _on_enemy_action_completed(enemy: Enemy) -> void:
	enemy.status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)


func _on_player_hand_drawn() -> void:
	for enemy: Enemy in get_children():
		enemy.update_intent()
