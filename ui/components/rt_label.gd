extends Label

@onready var simulation_manager: SimulationManager = $"../../../../../../SimulationManager"

func _ready() -> void:
	simulation_manager.average_time_updated.connect(_on_step_completed)

func _on_step_completed(time: float) -> void:
	text = "RT: %.1fms" % (time * 1000)
