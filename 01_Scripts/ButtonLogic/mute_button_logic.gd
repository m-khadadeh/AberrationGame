class_name MuteButtonLogic
extends ButtonLogic

func on_ready(button : SplittableButton):
	next_button_logic = load("res://03_Resources/ButtonLogic/make_sure_you_read_the_tooltips.tres")
	split_button_logic_next = self
	split_button_logic_replace = self
	button.clear_control_tree()
	button.add_tree_to_control(create_control_tree())

func on_button_clicked(button : SplittableButton):
	game_container.toggle_mute()
	super(button)
	
func on_neighbor_clicked(button : SplittableButton):
	super(button)

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
	new_node.text = "[center]Mute[/center]"
	new_node.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
	return new_node
