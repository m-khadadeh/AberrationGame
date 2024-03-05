class_name SplittablePolygon
extends Polygon2D

@export var error_tolerance : float

@onready var area : Area2D = $Area2D
@onready var collider : CollisionPolygon2D = $Area2D/CollisionPolygon2D

var _polygon_verts : Array
var _segment_array: Array
var _edge_dictionary : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func initialize(edge_dictionary : Dictionary, polygon_color : Color):
	_edge_dictionary = edge_dictionary
	var counter = 0
	_polygon_verts.clear()
	for vertex in edge_dictionary.keys():
		_polygon_verts.append(PolygonVertexData.new(counter, vertex, true))
		counter += 1
	_segment_array = _edge_dictionary.values()
	polygon = _edge_dictionary.keys()
	collider.polygon = polygon
	color = polygon_color

func split_across_line(line : LineData) -> Array:
	var polygon0_verts : Array
	var polygon1_verts : Array
	var split_points_set : Array
	var split_points : Dictionary
	
	for segment_index in range(_segment_array.size()):
		# check if line coincides
		if line.contains_point(_segment_array[segment_index]._point_extents[0], error_tolerance) and \
		line.is_parallel(_segment_array[segment_index]._line, error_tolerance):
			print("Coincident")
			# line coincides wth segment.
			return [_edge_dictionary]
		
		var point_of_intersect = _segment_array[segment_index].get_intersection(line)
		if point_of_intersect.x != INF:
			var point_exists = false
			for point in split_points_set:
				if point.point.distance_to(point_of_intersect) < error_tolerance:
					point_exists = true
					break
			if point_exists:
				continue
			
			var similar_point = -1
			for i in range(_polygon_verts.size()):
				if _polygon_verts[i].point.distance_to(point_of_intersect) < error_tolerance:
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
