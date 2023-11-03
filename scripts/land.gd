@tool
extends StaticBody2D

func _ready():
	if not Engine.is_editor_hint():
		var coll := CollisionPolygon2D.new()
		coll.polygon = $Polygon2D.polygon
		add_child(coll)
	
func _process(delta):
	if Engine.is_editor_hint():
		var points := PackedVector2Array($Polygon2D.polygon)
		points.append($Polygon2D.polygon[0])
		$Line2D.points = points

