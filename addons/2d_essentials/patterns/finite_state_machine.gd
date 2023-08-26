class_name GodotEssentialsFiniteStateMachine extends Node

signal state_changed(from_state: State, state: State)

@export var current_state: State = null

var states: Dictionary = {}
var active: bool = true:
	get:
		return active
	set(value):
		if value:
			set_physics_process(true)
			set_process_input(true)
		else:
			set_physics_process(false)
			set_process_input(false)


func _ready():
	_initialize_states_nodes()
	for initialized_state in states.values():
		initialized_state.state_finished.connect(on_finished_state)
	
	if current_state is State:
		change_state(current_state, true)

func _unhandled_input(event):
	current_state.handle_input(event)


func _physics_process(delta):
	current_state.physics_update(delta)


func process(delta):
	current_state.update(delta)
		

func change_state(new_state: State, force: bool = false):
	if not force and current_state_is(new_state):
		return
	
	if current_state is State:
		exit_state(current_state)
	
	state_changed.emit(current_state, new_state)
	
	var previous_state = current_state
	current_state = new_state
	enter_state(new_state, previous_state)


func change_state_by_name(name: String):
	var new_state = get_state(name)
	
	if new_state:
		return change_state(new_state)
		
	push_error("The state {name} does not exists on this FiniteStateMachine".format({"name": name}))


func enter_state(state: State, previous_state: State):
	state._enter({"previous_state": previous_state})
	state.state_entered.emit()
	

func exit_state(state: State):
	state._exit()


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
	
		
func _initialize_states_nodes(node: Node = null):
	var childrens = node.get_children(true) if node else get_children(true)
	
	for child in childrens:
		if child is State:
			_add_state_to_dictionary(child)
		else:
			_initialize_states_nodes(child)


func _add_state_to_dictionary(state: State):
	if state.is_inside_tree():
		states[state.name] = get_node(state.get_path())


func on_finished_state(next_state: String):
	change_state_by_name(next_state)
