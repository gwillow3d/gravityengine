class_name KeybindingLabel
extends Label

@export var action: String

func _ready() -> void:
	if InputMap.has_action(action):
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event = events[0]
			text += " (%s)" % event.as_text()
