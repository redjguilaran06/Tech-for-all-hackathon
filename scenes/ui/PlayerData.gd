extends Node

# Global Player Data
var exp: int = 0
var level: int = 1
var exp_to_next: int = 100

const SAVE_PATH := "user://player_save.json"

func _ready() -> void:
	load_player_data()

func gain_exp(gained_exp: int) -> String:
	exp += gained_exp
	var message := "You gained %d EXP!\n" % gained_exp

	# Level up check
	while exp >= exp_to_next:
		exp -= exp_to_next
		level += 1
		message += "🎉 Level up! You are now level %d.\n" % level
		exp_to_next = int(exp_to_next * 1.2)

	message += "Current EXP: %d/%d" % [exp, exp_to_next]

	# Save progress whenever exp changes
	save_player_data()

	return message


# --- SAVE / LOAD SYSTEM ---

func save_player_data() -> void:
	var data := {
		"exp": exp,
		"level": level,
		"exp_to_next": exp_to_next
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_player_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return  # no save yet

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		var data = JSON.parse_string(content)

		if typeof(data) == TYPE_DICTIONARY:
			exp = data.get("exp", 0)
			level = data.get("level", 1)
			exp_to_next = data.get("exp_to_next", 100)
