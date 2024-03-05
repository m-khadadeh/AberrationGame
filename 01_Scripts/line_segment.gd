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
