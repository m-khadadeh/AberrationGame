class_name SplitOnClickLogic
extends ButtonLogic

func on_ready(button : SplittableButton):
	var lock_logic = load("res://03_Resources/ButtonLogic/lock_button_logic.tres")
	next_button_logic = lock_logic
	split_button_logic_next = lock_logic
	split_button_logic_replace = self
	button.clear_control_tree()
	button.add_tree_to_control(create_control_tree())

func on_button_clicked(button : SplittableButton):
	game_container.queue_split()
	super(button)
	
func on_neighbor_clicked(button : SplittableButton):
	pass

func on_applied(button : SplittableButton):
	pass

func on_hovered(button : SplittableButton):
	super(button)
	
func create_control_tree() -> Node:
	var new_node = RichTextLabel.new()
	new_node.bbcode_enabled = true
	new_node.fit_content = true
	new_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	new_node.theme = preload("res://06_Themes/game_theme.tres")
	new_node.theme_type_variation = "CrystalLabel"
	new_node.text = "[center]Split[/center]"
	new_node.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
	return new_node
