class_name Splitter

extends Node2D

@export var height_padding : float
@export var snap_range: float

@onready var _start_marker = $Marker2DStart
@onready var _start_marker_sprite = $Marker2DStart/Sprite2D
@onready var _end_marker = $Marker2DEnd
@onready var _end_marker_sprite = $Marker2DEnd/Sprite2D
@onready var _line_renderer = $Line2D

var _screen_size : Vector2
var _line_slope : float
var _endpoints = [Vector2(0,0),Vector2(0,0)]
var _difference_btw_points : Vector2
var _mouse_position : Vector2
var _snap_points : PackedVector2Array

enum State {SELECTING_POINT_1, SELECTING_POINT_2, APPLYING}
var _state : State

# Called when the node enters the scene tree for the first time.
func _ready():
	_screen_size = get_viewport_rect().size
	_state = State.SELECTING_POINT_1
	_start_marker.position = _screen_size / 2
	_end_marker.position = get_global_mouse_position()
	_start_marker_sprite.visible = false
	_end_marker_sprite.visible = false
	_state = State.SELECTING_POINT_1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_mouse_position = get_global_mouse_position()
	match _state:
		State.SELECTING_POINT_1:
			var snap_value = process_snap_logic(_mouse_position)
			if snap_value > -1:
				_start_marker.position = _snap_points[snap_value]
				_start_marker_sprite.visible = true
			else:
				_start_marker.position = _mouse_position
				_start_marker_sprite.visible = false
		State.SELECTING_POINT_2:
			var snap_value = process_snap_logic(_mouse_position)
			if snap_value > -1:
				_end_marker.position = _snap_points[snap_value]
				_end_marker_sprite.visible = true
			else:
				_end_marker.position = _mouse_position
				_end_marker_sprite.visible = false
			_difference_btw_points = _end_marker.position - _start_marker.position

			_line_slope = _difference_btw_points.y / _difference_btw_points.x
			_endpoints[0] = Vector2((0 - _end_marker.position.y - height_padding) / _line_slope + _end_marker.position.x, - height_padding)
			_endpoints[1] = Vector2((_screen_size.y - _end_marker.position.y + height_padding) / _line_slope + _end_marker.position.x, _screen_size.y + height_padding)
			
			_line_renderer.points = _endpoints
		State.APPLYING:
			pass
	
	

func initialize(snap_points : PackedVector2Array):
	_snap_points = snap_points

func process_snap_logic(mouse_position : Vector2) -> int:
	for i in range(_snap_points.size()):
		if mouse_position.distance_to(_snap_points[i]) <= snap_range:
			return i
	return -1

func advance_on_click() -> bool:
	match _state:
		State.SELECTING_POINT_1:
			change_state(State.SELECTING_POINT_2)
			return false
		State.SELECTING_POINT_2:
			change_state(State.APPLYING)
			return true
		State.APPLYING:
			pass
	return false

func change_state(state : State):
	# exit conditions
	match _state:
		State.SELECTING_POINT_1:
			_start_marker_sprite.visible = true
		State.SELECTING_POINT_2:
			pass
		State.APPLYING:
			pass
	
	_state = state
	#enter conditions
	match _state:
		State.SELECTING_POINT_1:
			_line_renderer.visible = false
			_start_marker_sprite.visible = false
		State.SELECTING_POINT_2:
			_line_renderer.visible = true
			_end_marker_sprite.visible = false
		State.APPLYING:
			_line_renderer.visible = false
			_start_marker_sprite.visible = false
			_end_marker_sprite.visible = false

func get_line_data() -> LineData:
	var line_data = LineData.new(_endpoints[0], (_endpoints[1] - _endpoints[0]).normalized())
	
	return line_data
