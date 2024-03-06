class_name SplittableButton

extends Node2D

@export var regular_color : Color
@export var hover_color: Color

@onready var polygon : SplittablePolygon = $SplittablePolygon
@onready var _control_parent : Control = $Control

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
	polygon.initialize(edge_dictionary, regular_color, error_tolerance)
	
	var centroid = Vector2(0,0)
	for point in edge_dictionary.keys():
		centroid += point
	centroid /= edge_dictionary.keys().size()
	_control_parent.set_position(centroid)
	
	_logic = logic
	_logic.on_ready(_control_parent, null)
	
	if reset:
		gutter_manager.gutters_entered.connect(on_gutters_hovered)
		gutter_manager.gutters_exited.connect(on_gutters_unhovered)

func _unhandled_input(event):
	match state:
		State.NORMAL:
			pass
		State.HOVERED:
			if event.is_action_pressed("left_click") and not event.is_echo():
				get_viewport().set_input_as_handled()
				print("Starting Split")
				_logic.on_button_clicked(null, null)
				switch_state(State.HELD)
		State.HELD:
			if event.is_action_released("left_click"):
				if hover_check():
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
		polygon.color = hover_color
		# print("Hovering" + name)
	else:
		polygon.color = regular_color
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
