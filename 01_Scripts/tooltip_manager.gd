class_name TooltipManager
extends MarginContainer

@export var set_offset : Vector2

@onready var _panel_container : PanelContainer = $PanelContainer
@onready var _margin_container : MarginContainer = $PanelContainer/MarginContainer

var _current_tree : Node
var _viewport_size : Vector2
var _tooltip_offset : Vector2
var _panel_size : Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	_viewport_size = get_viewport_rect().size
	_tooltip_offset = Vector2(0,0)
	pass # Replace with function body.

func show_tooltip(show : bool):
	_panel_container.visible = show

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _panel_container.visible:
		_panel_size = _panel_container.size
		var mouse_pos = get_global_mouse_position() + set_offset
		
		if mouse_pos.x + _panel_size.x > _viewport_size.x:
			_tooltip_offset.x = -_panel_size.x
		else:
			_tooltip_offset.x = 0
		if mouse_pos.y + _panel_size.y > _viewport_size.y:
			_tooltip_offset.y = -_panel_size.y
		else:
			_tooltip_offset.y = 0
			
		_panel_container.position = mouse_pos + _tooltip_offset

func clear_tree():
	if _margin_container.get_child_count() > 0:
		_current_tree.queue_free()
		_panel_size = _panel_container.size

func set_tree(scene_tree : PackedScene):
	clear_tree()
	_current_tree = scene_tree.instantiate()
	_margin_container.add_child(_current_tree)
