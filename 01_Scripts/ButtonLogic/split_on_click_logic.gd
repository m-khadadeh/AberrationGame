class_name SplitOnClickLogic
extends ButtonLogic

var _label : RichTextLabel

func on_ready(button_control_parent : Control, tooltip_parent : Control):
	split_button_logic_next = self
	split_button_logic_replace = self
	_label = button_control_parent.get_node("RichTextLabel")
	(_label as RichTextLabel).text = "Slice"

func on_button_clicked(button_control_parent : Control, tooltip_parent : Control):
	game_container.start_splitting()
	
func on_neighbor_clicked(button_control_parent : Control, tooltip_parent : Control):
	pass

func on_applied(button_control_parent : Control, tooltip_parent : Control):
	pass

func on_hovered(button_control_parent : Control, tooltip_parent : Control):
	pass
