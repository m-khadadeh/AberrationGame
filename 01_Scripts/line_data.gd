class_name LineData

var direction_vector : Vector2
var single_point: Vector2

enum PointRelationship {LEFT, RIGHT}

func _init(_point : Vector2, _direction : Vector2):
	direction_vector = _direction.normalized()
	single_point = _point

func get_point_at_parameter(t : float) -> Vector2:
	return single_point + (t * direction_vector)

func get_intersection_parameter(other_line : LineData) -> float:
	var numerator = other_line.direction_vector.cross(single_point - other_line.single_point)
	var denominator = direction_vector.cross(other_line.direction_vector)
	return numerator / denominator

func get_intersecton_with_line(other_line : LineData) -> Vector2:
	return single_point + (get_intersection_parameter(other_line) * direction_vector)
	
func get_point_relationship(point : Vector2) -> PointRelationship:
	var vector_to_point = (point - single_point).normalized()
	var det = direction_vector.cross(vector_to_point)
	if det > 0:
		return PointRelationship.RIGHT
	else:
		return PointRelationship.LEFT
