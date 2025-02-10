extends Button
class_name RemapButton

@export var action: String = "Up"  # Change this for each keybind button (Up, Down, Left, Right)

var awaiting_input = false

func _ready():
	toggle_mode = true
	display_key()

func _toggled(button_pressed):
	if button_pressed:
		awaiting_input = true
		text = "Press any key..."
	else:
		awaiting_input = false
		display_key()

func _unhandled_input(event):
	if awaiting_input and event is InputEventKey and event.pressed:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		button_pressed = false
		awaiting_input = false
		
		# Save the new keybind
		UtilitiesData.config.set_value("Controls", action, event)
		UtilitiesData.save_data()

		display_key()

func display_key():
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		text = events[0].as_text()
	else:
		text = "Unbound"
