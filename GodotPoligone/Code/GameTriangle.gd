extends Node2D

export(float) var StartRadius = 200.0
export(int) var CountPoints = 4
export(bool) var Debug = true
export(int) var Precision = 1000
export(float) var MainPointSize = 3.0
export(float) var RecursivePointSize = 1.0
export(float) var StartAngle = -90.0

var line = Line2D.new()
var R

var base_points = Array()
var recursive_points = Array()

var bBasePointChanges = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	draw_start_triangle()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		var point = find_nearest_base_point(get_local_mouse_position())
		
		var point_pos = get_local_mouse_position()
		var positions = PoolVector2Array([point_pos, point_pos + Vector2(1, 1)])
		point.set_points(positions)
		bBasePointChanges = true
	
	if bBasePointChanges:
		for node in recursive_points:
			node.queue_free()
		
		recursive_points.clear()
		draw_recursive(Precision)
		bBasePointChanges = false
	pass


func draw_recursive(count: int):
	var last_point = R
	for i in range(count):
		var index = get_vertex_index()
		var middle = (get_point_by_index(index) + last_point.get_points()[0]) / 2
		last_point = draw_point(middle, Color.purple, false, RecursivePointSize)
		recursive_points.append(last_point)
	pass

func find_nearest_base_point(p: Vector2):
	var nearest_point = base_points[0]
	
	var points = Array()
	for point in base_points:
		points.append(point)
	points.append(R)
	
	for point in points:
		var near_len = (nearest_point.get_points()[0] - p).length()
		var cmp_len = (point.get_points()[0] - p).length()
		if  near_len > cmp_len:
			nearest_point = point
			
	return nearest_point

func draw_start_triangle():
	var screen_center = get_viewport().size
	
	var step = 360 / CountPoints
	for i in range(CountPoints):
		var pos = move_vector_by_distance_and_angle(screen_center / 2, StartRadius, StartAngle + step * i)
		var point = draw_point(pos, Color.coral, false, MainPointSize)
		base_points.append(point)
	
	R = draw_submain()
	
	self.add_child(line)
	pass

func move_vector_by_distance_and_angle(v: Vector2, dist: float, deg_angle: float):
	var rad_angle = deg2rad(deg_angle)
	var v_angle = Vector2(cos(rad_angle), sin(rad_angle))
	var offset = v_angle * dist
	return v + offset


func get_point_by_index(index: int):
	var result
	return base_points[index - 1].get_points()[0]


func draw_submain(color = Color.chartreuse):
	var screen_size = get_viewport().size
	var index = get_vertex_index()
	
	var random_point = Vector2(rand_range(0, screen_size[0]), rand_range(0, screen_size[1]))
	
	var middle = (get_point_by_index(index) + random_point) / 2
	var point = draw_point(middle, color, false, 15.0)
	
	if Debug:
		draw_point(random_point, Color.red)
		
	return point


func get_vertex_index():
	return int(rand_range(0, base_points.size()))


func draw_point(position: Vector2, color = Color.blue, add_to_last = true, point_size = 1.0):
	var line = Line2D.new()
	line.default_color = color
	line.width = point_size
	line.add_point(position)
	line.add_point(position + Vector2(0.1, 0.1))
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	self.add_child(line)
	return line
