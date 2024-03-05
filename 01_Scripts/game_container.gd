extends Node2D

@onready var _button_scene : PackedScene = preload("res://00_Scenes/splittable_button.tscn")
@onready var _splitter_scene : PackedScene = preload("res://00_Scenes/splitter.tscn")

@onready var _gutter_parent : GutterManager = $GutterManager
@onready var _button_parent : Node2D = $ButtonParent

var _button_array : Array
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
	_button_array.clear()
	
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
	
	_button_array.append(_create_button(polygon_edge_dictionary))
	
	recalculate_points_of_intersection()
	switch_state_to(GameState.SELECTING_BUTTONS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _create_button(edge_dictionary : Dictionary) -> SplittableButton:
	var new_button : SplittableButton
	new_button = _button_scene.instantiate()
	add_child(new_button)
	
	new_button.initialize(edge_dictionary, _gutter_parent)
	
	return new_button

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
			var buttons_to_append : Array
			for button in _button_array:
				var new_button_dicts = button.split_across_line(line_data)
				if new_button_dicts.size() != 1:
					button.initialize(new_button_dicts[0], _gutter_parent, false)
					var new_button : SplittableButton
					new_button = _button_scene.instantiate()
					_button_parent.add_child(new_button)
					new_button.initialize(new_button_dicts[1], _gutter_parent)
					buttons_to_append.append(new_button)
			for button in buttons_to_append:
				_button_array.append(button)
			
			var scaled_normal_vector = Vector2(line_data.direction_vector.y, -line_data.direction_vector.x).normalized() * split_padding / 2
			var gutter_points : PackedVector2Array
			gutter_points.append(line_data.drawing_endpoints[0] + scaled_normal_vector)
			gutter_points.append(line_data.drawing_endpoints[0] - scaled_normal_vector)
			gutter_points.append(line_data.drawing_endpoints[1] - scaled_normal_vector)
			gutter_points.append(line_data.drawing_endpoints[1] + scaled_normal_vector)
			_gutter_parent.add_gutter(gutter_points)
			
			_current_splitter.queue_free()
			
	# State enter logic
	match new_state:
		GameState.SELECTING_BUTTONS:
			for button in _button_array:
				button.on_enter_button_selection_game_state()
			pass
		GameState.SLICING:
			for button in _button_array:
				button.on_exit_button_selection_game_state()
			var new_splitter = _splitter_scene.instantiate()
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
