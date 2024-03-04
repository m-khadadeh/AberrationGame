extends Node2D

@onready var polygon_scene = preload(("res://00_Scenes/splittable_polygon.tscn"))
@onready var splitter_scene = preload("res://00_Scenes/splitter.tscn")

var _polygon_array : Array
var _line_array : Array
var _current_splitter : Splitter
var _screen_corners : PackedVector2Array
var _points_of_intersection : PackedVector2Array

enum GameState {SELECTING_BUTTONS, SLICING}
var current_state : GameState
@export var start_state : GameState
@export var split_padding : float

# Called when the node enters the scene tree for the first time.
func _ready():
	_screen_corners.append(Vector2(0,0))
	_screen_corners.append(Vector2(get_viewport_rect().size.x, 0))
	_screen_corners.append(Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y))
	_screen_corners.append(Vector2(0, get_viewport_rect().size.y))
	
	_line_array.append(LineData.new(_screen_corners[0], Vector2(1,0)))
	_line_array.append(LineData.new(_screen_corners[1], Vector2(0,1)))
	_line_array.append(LineData.new(_screen_corners[2], Vector2(-1,0)))
	_line_array.append(LineData.new(_screen_corners[3], Vector2(0,-1)))
	
	var starting_polygon_segments : Array
	starting_polygon_segments.append(LineSegment.new(_line_array[0], [_line_array[0].get_intersection_parameter(_line_array[3]), _line_array[0].get_intersection_parameter(_line_array[1])]))
	starting_polygon_segments.append(LineSegment.new(_line_array[1], [_line_array[1].get_intersection_parameter(_line_array[0]), _line_array[1].get_intersection_parameter(_line_array[2])]))
	starting_polygon_segments.append(LineSegment.new(_line_array[2], [_line_array[2].get_intersection_parameter(_line_array[1]), _line_array[2].get_intersection_parameter(_line_array[3])]))
	starting_polygon_segments.append(LineSegment.new(_line_array[3], [_line_array[3].get_intersection_parameter(_line_array[2]), _line_array[3].get_intersection_parameter(_line_array[0])]))
	
	var polygon_edge_dictionary : Dictionary
	polygon_edge_dictionary[_screen_corners[0]] = starting_polygon_segments[0]
	polygon_edge_dictionary[_screen_corners[1]] = starting_polygon_segments[1]
	polygon_edge_dictionary[_screen_corners[2]] = starting_polygon_segments[2]
	polygon_edge_dictionary[_screen_corners[3]] = starting_polygon_segments[3]
	
	_polygon_array.append(_create_polygon(polygon_edge_dictionary))
	
	recalculate_points_of_intersection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _create_polygon(edge_dictionary : Dictionary) -> SplittablePolygon:
	var new_polygon : SplittablePolygon
	new_polygon = polygon_scene.instantiate()
	add_child(new_polygon)
	
	new_polygon.initialize(edge_dictionary)
	
	return new_polygon

func _input(event):
	match current_state:
		GameState.SELECTING_BUTTONS:
			if event.is_action_pressed("right_click"):
				switch_state_to(GameState.SLICING)
		GameState.SLICING:
			if event.is_action_pressed("left_click"):
				if _current_splitter.advance_on_click():
					switch_state_to(GameState.SELECTING_BUTTONS)

func switch_state_to(new_state : GameState):
	# State exit logic
	match current_state:
		GameState.SELECTING_BUTTONS:
			pass
		GameState.SLICING:
			var line_data = _current_splitter.get_line_data()
			_line_array.append(line_data)
			recalculate_points_of_intersection()
			var polygons_to_append : Array
			for polygon in _polygon_array:
				var new_polys = polygon.split_across_line(line_data)
				if new_polys.size() != 1:
					(polygon as SplittablePolygon).initialize(new_polys[0], false)
					var new_poly : SplittablePolygon
					new_poly = polygon_scene.instantiate()
					add_child(new_poly)
					new_poly.initialize(new_polys[1])
					polygons_to_append.append(new_poly)
			for polygon in polygons_to_append:
				_polygon_array.append(polygon)
			_current_splitter.queue_free()
			
	# State enter logic
	match new_state:
		GameState.SELECTING_BUTTONS:
			pass
		GameState.SLICING:
			var new_splitter = splitter_scene.instantiate()
			add_child(new_splitter)
			new_splitter.initialize(_points_of_intersection)
			_current_splitter = new_splitter
			
	current_state = new_state

func recalculate_points_of_intersection():
	_points_of_intersection.clear()
	for line in _line_array:
		for other_line in _line_array:
			if line != other_line:
				var point_of_intersection = line.get_intersecton_with_line(other_line)
				if is_onscreen(point_of_intersection) and not _points_of_intersection.has(point_of_intersection):
					_points_of_intersection.append(point_of_intersection)
				

func is_onscreen(point : Vector2) -> bool:
	return point.x >= _screen_corners[0].x and \
	point.x <= _screen_corners[2].x and \
	point.y >= _screen_corners[0].y and \
	point.y <= _screen_corners[2].y
