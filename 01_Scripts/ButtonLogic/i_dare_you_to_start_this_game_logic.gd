class_name IDareYouToStartThisGameLogic
extends ButtonLogic

@export_multiline var label_text : String
@export var split_amount : int

func on_ready(button : SplittableButton):
	button.clear_control_tree()
	button.add_tree_to_control(create_control_tree())
	if split_amount > 0:
		game_container.queue_split(split_amount)

func on_button_clicked(button : SplittableButton):
	if not button.is_locked():
		game_container.play_sound_effect("button_click")
	else:
		game_container.play_sound_effect("sad_button_click")
	game_container.increment_clicks()
	
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
	new_node.text = "[center]" + label_text + "[/center]"
	new_node.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
	return new_node
