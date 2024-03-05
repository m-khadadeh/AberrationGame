class_name SplittableButton

extends Node2D

@export var regular_color : Color
@export var hover_color: Color

@onready var polygon : SplittablePolygon = $SplittablePolygon

@onready var _mouse_on_button : bool = false
@onready var _mouse_on_gutters : bool = false
@onready var _can_select_buttons : bool = false

enum State {NORMAL, HOVERED, HELD, HELD_UNHOVERED, LOCKED}
@onready var state : State = State.NORMAL

# Called when the node enters the scene tree for the first time.
func _ready():
	polygon.area.mouse_entered.connect(on_mouse_enter_button)
	polygon.area.mouse_exited.connect(on_mouse_exit_button)

func initialize(edge_dictionary : Dictionary, gutter_manager : GutterManager, reset = true):
	polygon.initialize(edge_dictionary, regular_color)
	if reset:
		gutter_manager.gutters_entered.connect(on_gutters_hovered)
		gutter_manager.gutters_exited.connect(on_gutters_unhovered)

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

func run_button_logic():
	# Button logic here
	pass

func show_button_hover_effects(show : bool):
	#Button hover effects here
	if show:
		polygon.color = hover_color
	else:
		polygon.color = regular_color
	pass

func switch_state(new_state : State):
	# exit logic
	match state:
		State.NORMAL:
			pass
		State.HOVERED:
			if new_state == State.HELD:
				# button has been clicked under proper conditions
				run_button_logic()
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
	# print("Hover check values: " + str(_mouse_on_button) + " " + str(_mouse_on_gutters))
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
