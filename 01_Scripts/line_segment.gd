class_name LineSegment

var _parameter_extents : Array
var _line : LineData
var _point_extents : Array

func _init(line : LineData, extents: Array):
	_line = line
	_parameter_extents = extents
	_point_extents.append(_line.get_point_at_parameter(_parameter_extents[0]))
	_point_extents.append(_line.get_point_at_parameter(_parameter_extents[1]))

func get_intersection_parameter(line : LineData) -> float:
	return _line.get_intersection_parameter(line)

func get_intersection(line : LineData, error_tolerance : float) -> Vector2:
	var intersection_parameter = get_intersection_parameter(line)
	if (intersection_parameter >= _parameter_extents[0] - error_tolerance and \
	intersection_parameter <= _parameter_extents[1] + error_tolerance) or \
	(intersection_parameter >= _parameter_extents[1] - error_tolerance and \
	intersection_parameter <= _parameter_extents[0] + error_tolerance):
		return _line.get_point_at_parameter(intersection_parameter)
	else:
		return Vector2(INF, INF)

func similar_within_tolerance(a : float, b : float, tolerance : float) -> bool:
	return abs(a - b) < tolerance

func contains_point(point : Vector2, error_tolerance : float) -> bool:
	var x_param = (point.x - _line.single_point.x) / _line.direction_vector.x
	var y_param = (point.y - _line.single_point.y) / _line.direction_vector.y
	return similar_within_tolerance(x_param, y_param, error_tolerance) and \
	(x_param >= _parameter_extents[0] - error_tolerance and \
	x_param <= _parameter_extents[1] + error_tolerance) or \
	(x_param >= _parameter_extents[1] - error_tolerance and \
	x_param <= _parameter_extents[0] + error_tolerance)

func does_coincide_with(segment : LineSegment, error_tolerance : float):
	var parallel = _line.is_parallel(segment._line, error_tolerance)
	var segment_contains_other = contains_point(segment._point_extents[0], error_tolerance) and \
	contains_point(segment._point_extents[1], error_tolerance)
	var other_contains_segment = segment.contains_point(_point_extents[0], error_tolerance) and \
	segment.contains_point(_point_extents[1], error_tolerance)
	return parallel and segment_contains_other and other_contains_segment
