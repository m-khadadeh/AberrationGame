class_name SplittableButton

extends Node2D

@export var hover_color: Color

@onready var polygon : SplittablePolygon = $SplittablePolygon
@onready var _control_parent : Control = $SplittablePolygon/Control
@onready var _label : RichTextLabel = $SplittablePolygon/Control/VBoxContainer/RichTextLabel

@onready var _mouse_on_button : bool = false
@onready var _mouse_on_gutters : bool = false
@onready var _can_select_buttons : bool = false

enum State {NORMAL, HOVERED, HELD, HELD_UNHOVERED, LOCKED}
@onready var state : State = State.NORMAL

var _logic : ButtonLogic

# Called when the node enters the scene tree for the first time.
func _ready():
	polygon.area.mouse_entered.connect(on_mouse_enter_button)
	polygon.area.mouse_exited.connect(on_mouse_exit_button)

func initialize(edge_dictionary : Dictionary, gutter_manager : GutterManager, error_tolerance : float, logic : ButtonLogic, reset = true):	
	var points : Array = edge_dictionary.keys()
	
	var centroid = Vector2(0,0)
	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y
	for point in points:
		centroid += point
		if point.x < min_x:
			min_x = point.x
		elif point.x > max_x:
			max_x = point.x
		if point.y < min_y:
			min_y = point.y
		elif point.y > max_y:
			max_y = point.y
	
	centroid /= edge_dictionary.keys().size()
	
	polygon.initialize(edge_dictionary, logic.color, error_tolerance, centroid)
	var size = Vector2(max_x - min_x, max_y - min_y)
	
	_control_parent.set_size(size)
	_control_parent.set_position(centroid - (size / 2))
	
	if reset:
		gutter_manager.gutters_entered.connect(on_gutters_hovered)
		gutter_manager.gutters_exited.connect(on_gutters_unhovered)
	
	set_button_logic(logic)

func _unhandled_input(event):
	match state:
		State.NORMAL:
			pass
		State.HOVERED:
			if event.is_action_pressed("left_click") and not event.is_echo():
				get_viewport().set_input_as_handled()
				_logic.on_button_clicked(self)
				switch_state(State.HELD)
		State.HELD:
			if event.is_action_released("left_click"):
				if _can_select_buttons:
					switch_state(State.HOVERED)
				else:
					switch_state(State.NORMAL)
		State.HELD_UNHOVERED:
			if event.is_action_released("left_click"):
				switch_state(State.NORMAL)
		State.LOCKED:
			pass

func split_across_line(line : LineData) -> Array:
	return polygon.split_across_line(line)

func on_mouse_enter_button():
	_mouse_on_button = true
	hover_check()
	
func on_mouse_exit_button():
	_mouse_on_button = false
	hover_check()

func on_gutters_hovered():
	_mouse_on_gutters = true
	hover_check()

func on_gutters_unhovered():
	_mouse_on_gutters = false
	hover_check()
	
func on_enter_button_selection_game_state():
	_can_select_buttons = true
	hover_check()

func on_exit_button_selection_game_state():
	_can_select_buttons = false
	hover_check()

func show_button_hover_effects(show : bool):
	#Button hover effects here
	if show:
		polygon.set_polygon_color(hover_color)
		# print("Hovering" + name)
		pass
	else:
		polygon.set_polygon_color(_logic.color)
		pass
	pass

func switch_state(new_state : State):
	# exit logic
	match state:
		State.NORMAL:
			pass
		State.HOVERED:
			if new_state != State.HOVERED:
				show_button_hover_effects(false)
		State.HELD:
			pass
		State.HELD_UNHOVERED:
			pass
		State.LOCKED:
			pass
	
	state = new_state
	
	# entry logic
	match state:
		State.NORMAL:
			pass
		State.HOVERED:
			show_button_hover_effects(true)
		State.HELD:
			pass
		State.HELD_UNHOVERED:
			pass
		State.LOCKED:
			pass

func hover_check():
	# If the button can reach or leave a hovered state, then check and move accordingly
	match state:
		State.NORMAL:
			if _can_select_buttons and _mouse_on_button and not _mouse_on_gutters:
				switch_state(State.HOVERED)
		State.HOVERED:
			if (not _can_select_buttons) or _mouse_on_gutters or not _mouse_on_button:
				switch_state(State.NORMAL)
		State.HELD:
			if not _can_select_buttons:
				switch_state(State.NORMAL)
			elif _mouse_on_gutters or not _mouse_on_button:
				switch_state(State.HELD_UNHOVERED)
		State.HELD_UNHOVERED:
			if not _can_select_buttons:
				switch_state(State.NORMAL)
			elif _mouse_on_button and not _mouse_on_gutters:
				switch_state(State.HELD)

func get_edges() -> Array:
	return polygon._edge_dictionary.values()

func set_label_text(text : String):
	_label.text = text
	
func set_button_logic(logic : ButtonLogic):
	_logic = logic
	_logic.on_ready(self)
	polygon.set_polygon_color(_logic.color)
