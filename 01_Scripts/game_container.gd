class_name GameContainer
extends Node2D

@onready var _button_scene : PackedScene = preload("res://00_Scenes/splittable_button.tscn")
@onready var _splitter_scene : PackedScene = preload("res://00_Scenes/splitter.tscn")

@onready var _button_parent : Node2D = $ButtonParent
@onready var _tooltip_manager : TooltipManager = $TooltipManager
@onready var _audio_manager : AudioManager = $AudioManager
@onready var _lock_sprite : Sprite2D = $Lock

@onready var _music_started : bool = false

var _button_array : Array
var _line_array : Array
var _current_splitter : Splitter
var _screen_corners : PackedVector2Array
var _points_of_intersection : PackedVector2Array
var _button_graph : Dictionary

var _splitting_queued : bool
var _locking_queued : bool
var _applying_queued : bool

var _splits_queued : int

var _total_clicks : int

var _saved_stats : Array

@onready var show_tooltips : bool = false

enum GameState {SELECTING_BUTTONS, SLICING, LOCKING}
var current_state : GameState
@export var start_state : GameState
@export var split_padding : float
@export var error_tolerance : float
@export var button_logic_types : Array

var starting_polygon_segments : Array
var polygon_edge_dictionary : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	_lock_sprite.visible = false
	_audio_manager.muted = false
	_button_array.clear()
	
	_screen_corners.append(Vector2(0,0))
	_screen_corners.append(Vector2(get_viewport_rect().size.x, 0))
	_screen_corners.append(Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y))
	_screen_corners.append(Vector2(0, get_viewport_rect().size.y))
	
	for button_type in button_logic_types:
		button_type.game_container = self
	
	reset_game(button_logic_types[0])

func reset_game(starting_logic : ButtonLogic, reset_clicks : bool = true):
	_button_array.clear()
	_line_array.clear()
	_points_of_intersection.clear()
	
	if reset_clicks:
		_total_clicks = 0
		_tooltip_manager.show_tooltip(false)
	
	if _button_parent.get_child_count() > 0:
		for button in _button_parent.get_children():
			button.queue_free()
	
	_line_array.append(LineData.new(_screen_corners[0], Vector2(1,0)))
	_line_array.append(LineData.new(_screen_corners[1], Vector2(0,1)))
	_line_array.append(LineData.new(_screen_corners[2], Vector2(-1,0)))
	_line_array.append(LineData.new(_screen_corners[3], Vector2(0,-1)))
	
	starting_polygon_segments.append(LineSegment.new(_line_array[0], [_line_array[0].get_intersection_parameter(_line_array[3]), _line_array[0].get_intersection_parameter(_line_array[1])]))
	starting_polygon_segments.append(LineSegment.new(_line_array[1], [_line_array[1].get_intersection_parameter(_line_array[0]), _line_array[1].get_intersection_parameter(_line_array[2])]))
	starting_polygon_segments.append(LineSegment.new(_line_array[2], [_line_array[2].get_intersection_parameter(_line_array[1]), _line_array[2].get_intersection_parameter(_line_array[3])]))
	starting_polygon_segments.append(LineSegment.new(_line_array[3], [_line_array[3].get_intersection_parameter(_line_array[2]), _line_array[3].get_intersection_parameter(_line_array[0])]))
	
	polygon_edge_dictionary[_screen_corners[0]] = starting_polygon_segments[0]
	polygon_edge_dictionary[_screen_corners[1]] = starting_polygon_segments[1]
	polygon_edge_dictionary[_screen_corners[2]] = starting_polygon_segments[2]
	polygon_edge_dictionary[_screen_corners[3]] = starting_polygon_segments[3]
	
	_button_array.append(_create_button(polygon_edge_dictionary, starting_logic))
	
	recalculate_points_of_intersection()
	recreate_graph()
	
	switch_state_to(GameState.SELECTING_BUTTONS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_state:
		GameState.SELECTING_BUTTONS:
			if _applying_queued:
				var checking_type : ButtonLogic = _button_array[0]._logic
				var all_same = true
				for button in _button_array:
					if button._logic != checking_type:
						all_same = false
						break
				if all_same:
					checking_type.on_applied(_button_array[0])
				_applying_queued = false
			elif _splits_queued > 0:
				switch_state_to(GameState.SLICING)
				_splits_queued -= 1
			elif _locking_queued:
				switch_state_to(GameState.LOCKING)
				_locking_queued = false
		GameState.SLICING:
			pass
		GameState.LOCKING:
			_lock_sprite.position = get_global_mouse_position()

func _create_button(edge_dictionary : Dictionary, logic : ButtonLogic) -> SplittableButton:
	var new_button : SplittableButton
	new_button = _button_scene.instantiate()
	_button_parent.add_child(new_button)
	
	new_button.initialize(self, edge_dictionary, error_tolerance, logic)
	new_button.lock_toggled.connect(on_button_lock_toggled)
	return new_button

func _input(event):
	if event.is_action_pressed("toggle_tooltips") and not event.is_echo():
		print("toggling tooltips")
		show_tooltips = not show_tooltips
		_tooltip_manager.show_tooltip(show_tooltips)

func _unhandled_input(event):
	match current_state:
		GameState.SLICING:
			if not event.is_echo():
				if event.is_action_pressed("left_click"):
					if _current_splitter.advance_on_click():
						if do_split():
							play_sound_effect("split")
							recreate_graph()
							switch_state_to(GameState.SELECTING_BUTTONS)
						else:
							play_sound_effect("bad_split")
							switch_state_to(GameState.SLICING)
					else:
						play_sound_effect("button_click")

func on_button_lock_toggled():
	switch_state_to(GameState.SELECTING_BUTTONS)

func do_split() -> bool:
	var line_data = _current_splitter.get_line_data()
	_line_array.append(line_data)
	recalculate_points_of_intersection()
	var buttons_to_append : Array
	var new_button_new_logic: Array
	var buttons_to_split : Dictionary
	var old_button_new_logic : Dictionary
	var safe_to_continue = true
	for i in range(_button_array.size()):
		var new_button_dicts = _button_array[i].split_across_line(line_data)
		if new_button_dicts.size() == 0:
			# The splitter was not placed well. Do not split anything
			safe_to_continue = false
			break
		elif new_button_dicts.size() > 1:
			# We are safe
			buttons_to_split[i] = new_button_dicts[0]
			old_button_new_logic[i] = _button_array[i]._logic.split_button_logic_replace
			buttons_to_append.append(new_button_dicts[1])
			new_button_new_logic.append(_button_array[i]._logic.split_button_logic_next)
	_current_splitter.queue_free()
	
	if buttons_to_split.size() == 0:
		# line didn't split thru anything
		safe_to_continue = false
	
	if safe_to_continue:
		for button in buttons_to_split:
			_button_array[button].initialize(self, buttons_to_split[button], error_tolerance, old_button_new_logic[button])
		for i in range(buttons_to_append.size()):
			_button_array.append(_create_button(buttons_to_append[i], new_button_new_logic[i]))
			
		queue_apply()
		return true
	return false

func recreate_graph():
	_button_graph.clear()
	for button in _button_array:
		_button_graph[button] = []
		for other_button in _button_array:
			if buttons_are_neighbors(button, other_button):
				_button_graph[button].append(other_button)
				

func buttons_are_neighbors(button0 : SplittableButton, button1 : SplittableButton) -> bool:
	if button0 != button1:
		for edge in button0.get_edges():
			for other_edge in button1.get_edges():
				if edge.does_coincide_with(other_edge, error_tolerance):
					return true
	return false

func switch_state_to(new_state : GameState):
	# State exit logic
	match current_state:
		GameState.SELECTING_BUTTONS:
			for button in _button_array:
				button.on_exit_button_selection_game_state()
			pass
		GameState.SLICING:
			pass
		GameState.LOCKING:
			_lock_sprite.visible = false
			for button in _button_array:
				button.on_exit_locking_game_state()

	# State enter logic
	match new_state:
		GameState.SELECTING_BUTTONS:
			for button in _button_array:
				button.on_enter_button_selection_game_state()
			pass
		GameState.SLICING:
			var new_splitter = _splitter_scene.instantiate()
			add_child(new_splitter)
			new_splitter.initialize(_points_of_intersection)
			_current_splitter = new_splitter
		GameState.LOCKING:
			_lock_sprite.visible = true
			for button in _button_array:
				button.on_enter_locking_game_state()
			
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

func queue_split(amount : int = 1):
	_splits_queued = amount

func queue_lock():
	_locking_queued = true

func click_neighbors(clicked_button : SplittableButton):
	for neighbor in _button_graph[clicked_button]:
		neighbor._logic.on_neighbor_clicked(neighbor)
	
func queue_apply():
	_applying_queued = true

func create_tooltip(scene : PackedScene):
	_tooltip_manager.set_tree(scene)

func start_flood():
	_saved_stats = [_total_clicks, _button_array.size()]
	reset_game(button_logic_types[12], false)

func credits_flood():
	reset_game(button_logic_types[11], false)
	
func quit_flood():
	if _button_parent.get_child_count() > 0:
		for button in _button_parent.get_children():
			button.queue_free()
	get_tree().quit()

func lock_flood():
	for button in _button_array:
		button.toggle_lock()
	play_sound_effect("lock")
	
func slice_flood():
	_splits_queued = randi_range(3, 6)
	
func t_for_tooltips_flood():
	show_tooltips = not show_tooltips
	_tooltip_manager.show_tooltip(show_tooltips)
	for button in _button_array:
		button.on_tooltip_toggle()
	_button_array[0]._logic.on_neighbor_clicked(_button_array[0]) # switches the button to the next type

func increment_clicks():
	_total_clicks += 1
	
func get_stats() -> Array:
	return _saved_stats

func reset_for_real():
	reset_game(button_logic_types[0], true)

func toggle_mute():
	_audio_manager.toggle_mute()
	
func play_sound_effect(sound_name):
	_audio_manager.play_sfx(sound_name)

func start_the_music():
	if not _music_started:
		_music_started = true
		_audio_manager.allow_music()
