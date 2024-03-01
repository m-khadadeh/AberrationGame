extends Node2D

@onready var polygon_scene = preload(("res://00_Scenes/splittable_polygon.tscn"))
var _polygon_array : Array

var _screen_corners : PackedVector2Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_screen_corners.append(Vector2(0,0))
	_screen_corners.append(Vector2(get_viewport_rect().size.x, 0))
	_screen_corners.append(Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y))
	_screen_corners.append(Vector2(0, get_viewport_rect().size.y))
	_polygon_array.append(_create_polygon(_screen_corners))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _create_polygon(vertices : PackedVector2Array) -> SplittablePolygon:
	var new_polygon : SplittablePolygon
	new_polygon = polygon_scene.instantiate()
	add_child(new_polygon)
	
	new_polygon.set_vertices(vertices)
	
	return new_polygon
