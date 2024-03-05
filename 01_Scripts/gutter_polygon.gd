class_name GutterPolygon
extends Polygon2D

@onready var area : Area2D = $Area2D
@onready var collider : CollisionPolygon2D = $Area2D/CollisionPolygon2D

func initialize(points : PackedVector2Array):
	polygon = points
	collider.polygon = points
	pass
