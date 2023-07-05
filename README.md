imagen aqui

- - -

Godot 2D essentials is a collection of production ready components to speed up the development of your 2d games. This components handles basic behaviours without affecting the particular logic of your game.

We provide you a few examples on how to use them in the folder **examples** that you can find in this repository

# Requirements
- We only provide support for Godot 4+ versions

# ✨Installation
You can download this plugin from the official [godot asset library](https://godotengine.org/asset-library/asset) or manually download it from this repository directly in your project addons folder
# 🐱‍🏍Getting started
This is nothing more than a collection of new nodes that you can add as a new scene like you usually do when working with the Godot game engine.

![example_adding_new_component](images/example_adding_new_component.PNG)


# 🐱‍🚀Available components
Here you can find the full available list of components, be sure to read the documentation for each component before use in your project to get the most out of it.
# 💖HealthComponent
This one manages all related to taking damage and health on the parent node, usually you add this to a **CharacterBody2D** but nothing prevents from being used in a **StaticRigidBody2D** if you want to make alive a tree or any other game object.

### Setup
Add this component as a child in which node you want to add a life and damage logic, the next steps are:
- Set the initial values you desire for this component
![health_component_parameters](images/health_component_parameters.PNG)

- (Optional) To enable health regen you need to add a value greater than zero for the parameter `health regen per second` and add a Timer as a child with the name `HealthRegenTimer`
- (Optional) To enable the possibility to activate invulnerability you need to add another Timer as a child with the name `InvulnerabilityTimer`

### Taking damage
Easy as call the function `damage` inside the component, a signal `health_changed` is emitted everytime receives damage while checking if the current health has reached zero, in which case it additionaly emits a `died` signal.

If the variable `is_invulnerable` is true, the damage received will be zero but signals will continue to be broadcast normally.

```python
health_component.damage(10)
```
### Health
The behavior is the exact same as damage but this time add health to the component, it can never reach the `max_health` defined. A signal `health_changed` is emitted everytime this health function is called.

```python
health_component.health(25)
```

### Health regeneration per second
By default, the health regeneration is set to be **every second** and need to be activated as we describe in the Setup section above. When the health component call the function `damage()` the regeneration is enabled until reach the max health where it will be deactivated.

You can change the amount per second dinamically using the function `enable_health_regen` or set to zero if you want to disable it:

```python
health_component.enable_health_regen(10)
# or disable it
health_component.enable_health_regen(0)

```
### Invulnerability
You can disable or enable the invulnerability using the function `enable_invulnerability(enable: bool, time: float = 0.05)` passing as parameters if is active and the time in seconds that will be invulnerable where it will be deactivated when reachs the timeout.

```python
health_component.enable_invulnerability(true, 2.5)

# you can deactivating it manually with
health_component.enable_invulnerability(false)

```
### Signals
```python
# You can access the action type in the health_changed signal
# to determine what kind of action was taken and act accordingly to the flow of your game.
enum TYPES {
	DAMAGE,
	HEALTH,
	REGEN
}

signal health_changed(amount: int, type: TYPES)
signal invulnerability_changed(active: bool)
signal died
```

![health_component_signals](images/health_component_signals.PNG)
## 🚀VelocityComponent2D
Whether top-down, platformer or grid-based, this component offers the functionality you need without having to rewrite it yourself for each project. The movement can be made flexible with the exposed parameters and contains an internal api that facilitates the most common actions that can occur in a 2d game.

🧇***(This component does not register inputs, it is a headless component that only applies movement to one node. The logic of when to do this is up to you as the developer)***

## Speed group
### Move
This is a shorcut that update the velocity and call the method `move_and_slide()`. Can receive the `CharacterBody2D` node via parameter or access the parent to whom this component belongs.

### Accelerate in direction
This define the direction *(Vector2)* is going to accelerate smoothly using the **Speed** group parameters defined in the component, by itself does not move the node, you have to chain the call to the method `move` 

```python
var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

velocity_component_2d.accelerate_in_direction(direction).move()
```

### Accelerate to target 
Same behavior as `accelerate_in_direction` but this time taking a target *(Node2D)* as parameter that will define the direction in which it will move.

```python
velocity_component_2d.accelerate_to_target(player).move()
```

### Decelerate
Stop moving the node gradually to `Vector2.ZERO` velocity

```python
velocity_component_2d.decelerate()
```

## Dash group
To use it, you will need to add a Timer node with the name DashCooldownTimer and it will define the loading time between dashes.
You can define a number of dashes to be performed before the cooldown is activated.

### Dash
This function moves the node fastly in the last faced direction of the node by default. You can provide a different direction as parameter:

```python
if Input.is_just_action_pressed("dash"):
    velocity_component_2d.dash()
```
### Enable or disable Dash
You can enable or disable the dash feature using the function `enable_dash` passing the new cooldown between dashes as parameter:
```python
velocity_component_2d.enable_dash(3.0)
# or disable it
velocity_component_2d.enable_dash(0.0)

```

## Knockback
When the method `knockback()` is called, a force will be applied which is defined on parameter `knockback_power` that simulates a knockback effect. You can choose the direction in which it will be pushed and other power amount instead of the default one.

```python
func _on_slash_attack_area_entered(area: Area2D):
	var target = area.get_parent() as Player
	
    target.velocity_component_2d.knockback(self.velocity_component_2d.velocity)
    # or new knockback power
    target.velocity_component_2d.knockback(self.velocity_component_2d.velocity, 500)
```