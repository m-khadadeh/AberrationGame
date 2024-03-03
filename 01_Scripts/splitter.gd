class_name Splitter

extends Node2D

@export var max_distance_btw_markers : float
@export var lerp_speed : float
@export var height_padding : float

@onready var start_marker = $Marker2DStart
@onready var end_marker = $Marker2DEnd
@onready var line_renderer = $Line2D

var _screen_size : Vector2
var _line_slope : float
var _endpoints = [Vector2(0,0),Vector2(0,0)]
var _difference_btw_points : Vector2
var _mouse_position : Vector2

var _lerp_position_start : Vector2
var _lerp_position_end : Vector2
var _lerp_parameter : float
var _should_lerp : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	_screen_size = get_viewport_rect().size
	end_marker.position = get_global_mouse_position()
	start_marker.position = _screen_size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_mouse_position = get_global_mouse_position()
	
	_difference_btw_points = _mouse_position - start_marker.position
	
	if _difference_btw_points.length() > max_distance_btw_markers:
		var slope = end_marker.position - start_marker.position
		var parameter = ((_difference_btw_points.y * slope.y) - (_difference_btw_points.x * slope.x)) / ((slope.y * slope.y) - (slope.x * slope.x))
		var closest_point = start_marker.position + (parameter * slope)
		var distance_to_closest_point = (closest_point - _mouse_position).length()
		var other_side_length = sqrt((distance_to_closest_point * distance_to_closest_point) + (max_distance_btw_markers * max_distance_btw_markers))
		_lerp_position_start = start_marker.position
		_lerp_position_end = closest_point - (slope.normalized() * other_side_length)
		_should_lerp = true
		_lerp_parameter = 0
	
	if _should_lerp:
		_lerp_parameter += lerp_speed * delta
		if _lerp_parameter >= 1:
			_lerp_parameter = 1
			_should_lerp = false
		start_marker.position = lerp(_lerp_position_start, _lerp_position_end, _lerp_parameter)	
	
	end_marker.position = _mouse_position
	_difference_btw_points = end_marker.position - start_marker.position
	
	
	_line_slope = _difference_btw_points.y / _difference_btw_points.x
	_endpoints[0] = Vector2((0 - end_marker.position.y - height_padding) / _line_slope + end_marker.position.x, - height_padding)
	_endpoints[1] = Vector2((_screen_size.y - end_marker.position.y + height_padding) / _line_slope + end_marker.position.x, _screen_size.y + height_padding)
	
	line_renderer.points = _endpoints

func get_line_data() -> LineData:
	var line_data = LineData.new(_endpoints[0], (_endpoints[1] - _endpoints[0]).normalized())
	
	return line_data
