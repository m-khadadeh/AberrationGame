class_name IDareYouToStartThisGameLogic
extends ButtonLogic

var _label : RichTextLabel

@export var label_text : String
@export var split_on_ready : bool

func on_ready(button : SplittableButton):
	button.set_label_text("[center]" + label_text + "[/center]")
	if split_on_ready:
		game_container.queue_split()

func on_button_clicked(button : SplittableButton):
	pass
	
func on_neighbor_clicked(button : SplittableButton):
	pass

func on_applied(button : SplittableButton):
	pass

func on_hovered(button : SplittableButton):
	pass
