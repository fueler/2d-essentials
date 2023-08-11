extends Control

@onready var label = $Label
@onready var finite_state_machine = $"../FiniteStateMachine"

# Called when the node enters the scene tree for the first time.
func _ready():
	finite_state_machine.state_changed.connect(on_state_changed)

func on_state_changed(state: State):
	label.text = state.name
