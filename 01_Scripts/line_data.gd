class_name LineData

var direction_vector : Vector2
var single_point: Vector2
var extent_points : PackedVector2Array

func get_intersecton_with_line(other_line : LineData) -> Vector2:
	var numerator = other_line.direction_vector.cross(single_point - other_line.single_point)
	var denominator = direction_vector.cross(other_line.direction_vector)
	
	var parameter = numerator / denominator
	
	return single_point + (parameter * direction_vector)
