class_name FiniteStateMachine extends Node

@export var current_state: State

signal state_changed(state: State)

func _ready():
	if current_state is State:
		change_state(current_state, true)
	
func change_state(new_state: State, force: bool = false):
	if not force and current_state_is(new_state):
		return
		
	if current_state is State:
		current_state._exit_state()
		
	new_state._enter_state()
	current_state = new_state
	
	state_changed.emit(current_state)
	
func current_state_is(state: State) -> bool:
	return state.name.to_lower() == current_state.name.to_lower()
