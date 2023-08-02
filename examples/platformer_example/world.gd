extends Node

@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D


func _ready():
	polygon_2d.polygon = collision_polygon_2d.polygon
