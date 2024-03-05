class_name GutterManager
extends Node2D

@onready var _gutter_scene : PackedScene = preload("res://00_Scenes/gutter_polygon.tscn")
var _hovered : Array

var gutters_hovered : bool

signal gutters_entered
signal gutters_exited

# Called when the node enters the scene tree for the first time.
func _ready():
	_hovered.clear()
	gutters_hovered = false

func add_gutter(points : PackedVector2Array):
	var new_gutter = _gutter_scene.instantiate() as GutterPolygon
	add_child(new_gutter)
	var index = _hovered.size()
	_hovered.append(false)
	new_gutter.area.mouse_entered.connect(on_mouse_entered_gutter.bind(index))
	new_gutter.area.mouse_exited.connect(on_mouse_exited_gutter.bind(index))
	new_gutter.initialize(points)
	
func on_mouse_entered_gutter(gutter_index: int):
	_hovered[gutter_index] = true
	calculate_gutters_hovered()

func on_mouse_exited_gutter(gutter_index: int):
	_hovered[gutter_index] = false
	calculate_gutters_hovered()

func calculate_gutters_hovered():
	var running_bool = false
	var index = 0
	while index < _hovered.size() and not running_bool:
		running_bool = running_bool or _hovered[index]
		index += 1
	if running_bool != gutters_hovered:
		if running_bool:
			gutters_entered.emit()
		else:
			gutters_exited.emit()
	gutters_hovered = running_bool
