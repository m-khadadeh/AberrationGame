class_name SplittablePolygon
extends Polygon2D

@export var stroke_width : float

@onready var area : Area2D = $Area2D
@onready var collider : CollisionPolygon2D = $Area2D/CollisionPolygon2D

var _polygon_verts : Array
var _segment_array: Array
var _edge_dictionary : Dictionary
var _error_tolerance : float
	
func initialize(edge_dictionary : Dictionary, polygon_color : Color, tolerance : float, center : Vector2):
	_edge_dictionary = edge_dictionary
	_polygon_verts.clear()
	var vertex_array = _edge_dictionary.keys()
	var new_polygon_points : PackedVector2Array
	var new_UV : PackedVector2Array
	var new_polygon_indices : Array
	var offset_lines : Array
	var offset_points : PackedVector2Array
	for i in range(vertex_array.size()):
		offset_lines.append( \
		LineData.new( \
		LineData.new(vertex_array[i], _edge_dictionary[vertex_array[i]]._line.get_perpendicular_direction()).get_point_at_parameter(-stroke_width), \
		_edge_dictionary[vertex_array[i]]._line.direction_vector))
	for i in range(vertex_array.size()):
		offset_points.append(offset_lines[i].get_intersecton_with_line(offset_lines[(i + 1) % vertex_array.size()]))
	for i in range(vertex_array.size()):
		_polygon_verts.append(PolygonVertexData.new(i, vertex_array[i], true))
		new_polygon_points.append(center)
		new_polygon_points.append(offset_points[i])
		new_polygon_points.append(offset_points[(i - 1 + vertex_array.size()) % vertex_array.size()])
		new_polygon_points.append(vertex_array[i])
		new_polygon_points.append(vertex_array[(i - 1 + vertex_array.size()) % vertex_array.size()])
		new_UV.append(Vector2(0.0,0.0)) #0
		new_UV.append(Vector2(0.9,1.0)) #1
		new_UV.append(Vector2(0.9,0.0)) #2
		new_UV.append(Vector2(1.0,0.0)) #3
		new_UV.append(Vector2(1.0,0.0)) #4
		new_polygon_indices.append([5 * i, 5 * i + 1, 5 * i + 2])
		new_polygon_indices.append([5 * i + 1, 5 * i + 2, 5 * i + 3])
		new_polygon_indices.append([5 * i + 4, 5 * i + 3, 5 * i + 2])
	polygon = new_polygon_points
	uv = new_UV
	polygons = new_polygon_indices
	_segment_array = _edge_dictionary.values()
	_error_tolerance = tolerance
	collider.polygon = vertex_array
	set_polygon_color(polygon_color)

func set_polygon_color(new_color : Color):
	material.set_shader_parameter("polygon_color", new_color)

func split_across_line(line : LineData) -> Array:
	var polygon0_verts : Array
	var polygon1_verts : Array
	var split_points_set : Array
	var split_points : Dictionary
	
	for segment_index in range(_segment_array.size()):
		# check if line coincides
		if line.contains_point(_segment_array[segment_index]._point_extents[0], _error_tolerance) and \
		line.is_parallel(_segment_array[segment_index]._line, _error_tolerance):
			print("Coincident")
			# line coincides wth segment within tolerance
			return []
		
		var point_of_intersect = _segment_array[segment_index].get_intersection(line, _error_tolerance)
		if point_of_intersect.x != INF:
			var point_exists = false
			for point in split_points_set:
				if point.point.distance_to(point_of_intersect) < _error_tolerance:
					point_exists = true
					break
			if point_exists:
				continue
			
			var similar_point = -1
			for i in range(_polygon_verts.size()):
				if _polygon_verts[i].point.distance_to(point_of_intersect) < _error_tolerance:
					similar_point = i
					break
			
			if similar_point == -1:
				var new_vert_data = PolygonVertexData.new(segment_index, point_of_intersect, false)
				split_points[segment_index] = new_vert_data
				split_points_set.append(new_vert_data)
			else:
				split_points[similar_point] = _polygon_verts[similar_point]
				split_points_set.append(_polygon_verts[similar_point])
				
	if split_points.size() < 2:
		# less than 2 intersection points on polygon
		return [_edge_dictionary]

	var side = false # false is polygon0. true is polygon1
	for i in range(_polygon_verts.size()):
		var vert = (_polygon_verts[i] as PolygonVertexData)
		if split_points.has(vert.identifier):
			if not split_points[vert.identifier].original_point:
				# The polygon splits along the edge
				if side:
					polygon1_verts.append(vert)
				else:
					polygon0_verts.append(vert)
			polygon0_verts.append(split_points[vert.identifier])
			polygon1_verts.append(split_points[vert.identifier])
			side = not side
		else:
			# No splits happen on this path or vertex
			if side:
				polygon1_verts.append(vert)
			else:
				polygon0_verts.append(vert)
	
	
	var new_dict : Dictionary
	var new_lines : Array
	var poly1_dict : Dictionary
	var poly1_lines : Array
	for i in range(polygon0_verts.size()):
		new_lines.append(LineData.new(polygon0_verts[i].point, polygon0_verts[(i + 1) % polygon0_verts.size()].point - polygon0_verts[i].point))
	for i in range(polygon1_verts.size()):
		poly1_lines.append(LineData.new(polygon1_verts[i].point, polygon1_verts[(i + 1) % polygon1_verts.size()].point - polygon1_verts[i].point))
	for i in range(polygon0_verts.size()):
		new_dict[polygon0_verts[i].point] = LineSegment.new(new_lines[i], [new_lines[i].get_intersection_parameter(new_lines[(i - 1 + polygon0_verts.size()) % polygon0_verts.size()]), new_lines[i].get_intersection_parameter(new_lines[(i + 1) % polygon0_verts.size()])])
	for i in range(polygon1_verts.size()):
		poly1_dict[polygon1_verts[i].point] = LineSegment.new(poly1_lines[i], [poly1_lines[i].get_intersection_parameter(poly1_lines[(i - 1 + polygon1_verts.size()) % polygon1_verts.size()]), poly1_lines[i].get_intersection_parameter(poly1_lines[(i + 1) % polygon1_verts.size()])])
	#initialize(new_dict, true)
	return [new_dict, poly1_dict]
