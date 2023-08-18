extends Control

@onready var label = $Label
@onready var finite_state_machine = $"../FiniteStateMachine"

# Called when the node enters the scene tree for the first time.
func _ready():
	finite_state_machine.state_changed.connect(on_state_changed)
	label.text = finite_state_machine.current_state.name

func on_state_changed(_from_state: State, state: State):
	label.text = state.name
