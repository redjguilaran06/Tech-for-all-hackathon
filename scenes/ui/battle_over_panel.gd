class_name BattleOverPanel
extends Panel

const MAIN_MENU = "res://scenes/ui/main_menu.tscn"

enum Type { WIN, LOSE }

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton
@onready var main_menu_button: Button = %MainMenuButton

func _ready() -> void:
	continue_button.pressed.connect(func(): get_tree().change_scene_to_file("res://map2.tscn"))
	main_menu_button.pressed.connect(get_tree().change_scene_to_file.bind(MAIN_MENU))
	Events.battle_over_screen_requested.connect(show_screen)

func show_screen(text: String, type: Type, gained_exp: int = 0) -> void:
	var final_text := text

	if type == Type.WIN:
		# Call PlayerData.gain_exp and append its return message
		final_text += "\n" + PlayerData.gain_exp(gained_exp)

	label.text = final_text
	continue_button.visible = type == Type.WIN
	main_menu_button.visible = type == Type.LOSE
	show()
	get_tree().paused = true
	print("Gained EXP: ", gained_exp)
