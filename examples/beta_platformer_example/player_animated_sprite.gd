extends AnimatedSprite2D

var dash_effect_active: bool = false
@onready var dash_state = $"../FiniteStateMachine/DashState"

func _ready():
	dash_state.state_entered.connect(on_dash_entered)
	dash_state.state_finished.connect(on_dash_finished)
	
func _physics_process(delta):
	if dash_effect_active:
		dash_effect()

func dash_effect():
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = self.sprite_frames.get_frame_texture(self.animation, self.frame)
	
	get_tree().root.add_child(sprite)
	
	sprite.global_position = global_position
	sprite.scale = scale
	sprite.flip_h = flip_h
	sprite.flip_v = flip_v
	
#	sprite.material = ShaderMaterial.new()
#	sprite.material.shader = ''

	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.7).set_trans(tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_callback(sprite.queue_free)

func on_dash_entered():
	dash_effect_active =  true
	
func on_dash_finished():
	dash_effect_active = false
