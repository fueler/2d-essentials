extends Node


@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D

@onready var wall_collision_polygon_2d = $StaticWall/CollisionPolygon2D
@onready var wall_polygon_2d = $StaticWall/CollisionPolygon2D/Polygon2D

@onready var inverted_wall_collision_polygon_2d = $InvertedStaticWall/CollisionPolygon2D
@onready var inverted_wall_polygon_2d = $InvertedStaticWall/CollisionPolygon2D/Polygon2D


func _ready():
	polygon_2d.polygon = collision_polygon_2d.polygon
	wall_polygon_2d.polygon = wall_collision_polygon_2d.polygon
	inverted_wall_polygon_2d.polygon = inverted_wall_collision_polygon_2d.polygon

