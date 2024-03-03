class_name SplittablePolygon
extends Polygon2D

@onready var collider = $Area2D/CollisionPolygon2D

var _polygon_verts : PackedVector2Array
var _segment_array: Array
var _edge_dictionary : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func initialize(edge_dictionary : Dictionary, random_color = true):
	_edge_dictionary = edge_dictionary
	_polygon_verts = _edge_dictionary.keys()
	_segment_array = _edge_dictionary.values()
	polygon = _polygon_verts
	collider.polygon = polygon
	if random_color:
		color = Color(randf(), randf(), randf())

func _on_area_2d_mouse_entered():
	#print("Mouse entered " + name)
	pass

func _on_area_2d_mouse_exited():
	#print("Mouse exited " + name)
	pass

func split_across_line(line : LineData) -> Array:
	var polygon0_verts : PackedVector2Array
	var polygon1_verts : PackedVector2Array
	var split_points_set : PackedVector2Array
	var split_point_parameters : Array
	var split_points : Dictionary
	
	for segment in _segment_array:
		var point_of_intersect = segment.get_intersection(line)
		if point_of_intersect.x != INF and not split_points_set.has(point_of_intersect):
			split_points[segment] = point_of_intersect
			split_points_set.append(point_of_intersect)
			split_point_parameters.append(segment.get_intersection_parameter(line))
	
	if split_points.size() != 2 or (_polygon_verts.has(split_points_set[0]) and _polygon_verts.has(split_points_set[1])):
		# Less than two intersection points or both intersection points are already part of the polygon so it would be splitting from nothing
		return [_edge_dictionary]

	var prev_side = line.get_point_relationship(_polygon_verts[0])
	var prev_vert = _polygon_verts[0]
	var crossed_over = false
	for i in range(_polygon_verts.size()):
		var vert = _polygon_verts[i]
		var current_side = line.get_point_relationship(vert)
		if split_points_set.has(vert):
			# TODO: Test This
			polygon1_verts.append(vert)
			polygon0_verts.append(vert)
			if prev_side == LineData.PointRelationship.LEFT:
				prev_side = LineData.PointRelationship.RIGHT
			else:
				prev_side = LineData.PointRelationship.LEFT
		else:
			var intersection_parameter = 0.0
			if current_side == LineData.PointRelationship.LEFT:
				if current_side != prev_side:
					var shared_point = split_points[_edge_dictionary[prev_vert]]
					polygon1_verts.append(shared_point)
					polygon0_verts.append(shared_point)
				polygon0_verts.append(vert)
			else:
				if current_side != prev_side:
					var shared_point = split_points[_edge_dictionary[prev_vert]]
					polygon0_verts.append(shared_point)
					polygon1_verts.append(shared_point)
				polygon1_verts.append(vert)
			prev_side = current_side
		prev_vert = vert
	# check the starting vertex one more time without adding it to the lists
	var vert = _polygon_verts[0]
	var current_side = line.get_point_relationship(vert)
	var intersection_parameter = 0.0
	if current_side == LineData.PointRelationship.LEFT:
		if current_side != prev_side:
			var shared_point = split_points[_edge_dictionary[prev_vert]]
			polygon1_verts.append(shared_point)
			polygon0_verts.append(shared_point)
	else:
		if current_side != prev_side:
			var shared_point = split_points[_edge_dictionary[prev_vert]]
			polygon0_verts.append(shared_point)
			polygon1_verts.append(shared_point)

	
	
	# TODO: Edit this polygon and create the new one
	var new_dict : Dictionary
	var new_lines : Array
	var poly1_dict : Dictionary
	var poly1_lines : Array
	for i in range(polygon0_verts.size()):
		new_lines.append(LineData.new(polygon0_verts[i], polygon0_verts[(i + 1) % polygon0_verts.size()] - polygon0_verts[i]))
	for i in range(polygon1_verts.size()):
		poly1_lines.append(LineData.new(polygon1_verts[i], polygon1_verts[(i + 1) % polygon1_verts.size()] - polygon1_verts[i]))
	for i in range(polygon0_verts.size()):
		new_dict[polygon0_verts[i]] = LineSegment.new(new_lines[i], [new_lines[i].get_intersection_parameter(new_lines[(i - 1 + polygon0_verts.size()) % polygon0_verts.size()]), new_lines[i].get_intersection_parameter(new_lines[(i + 1) % polygon0_verts.size()])])
	for i in range(polygon1_verts.size()):
		poly1_dict[polygon1_verts[i]] = LineSegment.new(poly1_lines[i], [poly1_lines[i].get_intersection_parameter(poly1_lines[(i - 1 + polygon1_verts.size()) % polygon1_verts.size()]), poly1_lines[i].get_intersection_parameter(poly1_lines[(i + 1) % polygon1_verts.size()])])
	#initialize(new_dict, true)
	return [new_dict, poly1_dict]
