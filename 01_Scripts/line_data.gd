class_name LineData

var direction_vector : Vector2
var single_point: Vector2

var drawing_endpoints : Array

enum PointRelationship {LEFT, RIGHT}

func _init(_point : Vector2, _direction : Vector2, endpoints = null):
	direction_vector = _direction.normalized()
	single_point = _point
	if endpoints != null:
		drawing_endpoints = endpoints

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

func similar_within_tolerance(a : float, b : float, tolerance : float) -> bool:
	return abs(a - b) < tolerance

func contains_point(point : Vector2, tolerance : float) -> bool:
	var x_param = (point.x - single_point.x) / direction_vector.x
	var y_param = (point.y - single_point.y) / direction_vector.y
	return similar_within_tolerance(x_param, y_param, tolerance)

func is_parallel(line : LineData, tolerance : float) -> bool:
	return (similar_within_tolerance(direction_vector.x, line.direction_vector.x, tolerance) and \
	similar_within_tolerance(direction_vector.y, line.direction_vector.y, tolerance)) or \
	(similar_within_tolerance(-direction_vector.x, line.direction_vector.x, tolerance) and \
	similar_within_tolerance(-direction_vector.y, line.direction_vector.y, tolerance))

func get_perpendicular_direction() -> Vector2:
	return Vector2(direction_vector.y, -direction_vector.x)
	
func get_distance_to_point(point : Vector2) -> float:
	var bisector = LineData.new(point, get_perpendicular_direction())
	return bisector.get_intersection_parameter(self)
