class_name FiniteStateMachine extends Node

signal state_changed(from_state: State, state: State)

@export var current_state: State

var states: Dictionary = {}

func _ready():
	for child in get_children(true):
		if child is State:
			_add_state_to_dictionary(child)
		else:
			for nested_child in child.get_children():
				if nested_child is State:
					_add_state_to_dictionary(nested_child)
		
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

func change_state_by_name(name: String):
	var new_state = get_state(name)
	
	if new_state:
		return change_state(new_state)
		
	push_error("The state {name} does not exists on this FiniteStateMachine".format({"name": name}))
	
func enter_state(state: State):
	state._enter_state()
	state.state_entered.emit()
	

func exit_state(state: State):
	state._exit_state()
	state.state_finished.emit()

func get_state(name: String):
	if has_state(name):
		return states[name]
	
	return null
	
func has_state(name: String) -> bool:
	return states.has(name)
	
func current_state_is(state: State) -> bool:
	if state:
		return state.name.to_lower() == current_state.name.to_lower()
		
	return false

func current_state_name_is(name: String) -> bool:
	return current_state_is(get_state(name))
	
		
func _add_state_to_dictionary(state: State):
	if state.is_inside_tree():
		states[state.name] = get_node(state.get_path())
