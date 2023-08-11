class_name FiniteStateMachine extends Node

@export var current_state: State

signal state_changed(from_state: State, state: State)

func _ready():
	if current_state is State:
		change_state(current_state, true)
	
func change_state(new_state: State, force: bool = false):
	if not force and current_state_is(new_state):
		return
		
	if current_state is State:
		current_state._exit_state()
		current_state.state_finished.emit()
		
	new_state._enter_state()
	
	new_state.state_entered.emit()
	state_changed.emit(current_state, new_state)
	
	current_state = new_state
	
	
func current_state_is(state: State) -> bool:
	return state.name.to_lower() == current_state.name.to_lower()
