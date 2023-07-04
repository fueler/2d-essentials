extends CharacterBody2D

@onready var animation_tree = $AnimationTree

func _ready():
	animation_tree.active = true
	


func _process(delta):
	pass



func _on_player_detection_area_body_entered(body: Node2D):
	print(body.name)
