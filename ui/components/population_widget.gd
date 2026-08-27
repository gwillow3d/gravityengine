class_name PopualtionWidget
extends Label

func _on_population_changed(population: int) -> void:
	text = "%s particles" % population
