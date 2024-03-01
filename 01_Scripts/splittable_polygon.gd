class_name SplittablePolygon
extends Polygon2D

@onready var collider = $Area2D/CollisionPolygon2D
@export var fullscreen_polygon : bool

var _polygon_verts : PackedVector2Array

# Called when the node enters the scene tree for the first time.
func _ready():
	if fullscreen_polygon:
		var viewport_rect = get_viewport_rect().size
		var screen_extents : PackedVector2Array
		screen_extents.append(Vector2(0, 0))
		screen_extents.append(Vector2(0, viewport_rect.y))
		screen_extents.append(Vector2(viewport_rect.x, viewport_rect.y))
		screen_extents.append(Vector2(viewport_rect.x, 0))
		set_vertices(screen_extents)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_vertices(vertices: PackedVector2Array):
	_polygon_verts = vertices
	polygon = _polygon_verts
	collider.polygon = _polygon_verts

func _on_area_2d_mouse_entered():
	print("Mouse entered")


func _on_area_2d_mouse_exited():
	print("Mouse exited")
