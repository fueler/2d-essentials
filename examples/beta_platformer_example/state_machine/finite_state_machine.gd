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
		exit_state(current_state)
		
	enter_state(new_state)

	state_changed.emit(current_state, new_state)
	current_state = new_state

	
func enter_state(state: State):
	state._enter_state()
	state.state_entered.emit()
	

func exit_state(state: State):
	state._exit_state()
	state.state_finished.emit()
		
func current_state_is(state: State) -> bool:
	if state:
		print(state.name, current_state.name)
		return state.name.to_lower() == current_state.name.to_lower()
		
	return false


