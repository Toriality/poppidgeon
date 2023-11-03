extends Line2D

var point = Vector2()
var sb = StaticBody2D
var colision = CollisionShape2D
var segment = SegmentShape2D

func _ready():
	sb = StaticBody2D.new()
	self.add_child(sb)
	sb.collision_layer = 2
	colision = CollisionShape2D.new()
	segment = SegmentShape2D.new()
	sb.add_child(colision)
	colision.shape = segment

func _process(delta):
	self.global_position = Vector2(0,0)
	self.global_rotation = 0

	point = get_parent().global_position
	self.add_point(point)
	segment.a = self.get_point_position(0)
	segment.b = self.get_point_position(self.get_point_count() - 1)
	self.points.size()
