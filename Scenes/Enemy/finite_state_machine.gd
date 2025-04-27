extends Node2D
 
var current_state: State
var previous_state: State
 
func _ready():
	current_state = get_child(0) as State
	previous_state = current_state
	current_state.enter()
 
func change_state(state):
	var new_state = find_child(state) as State

	if new_state == null:
		print("⚠️ State", state, "not found in FSM")
		return

	if current_state:
		current_state.exit()

	previous_state = current_state
	current_state = new_state
	current_state.enter()
