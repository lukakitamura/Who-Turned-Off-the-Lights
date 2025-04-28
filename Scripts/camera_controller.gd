extends Camera2D

func _draw():
	var half_width = get_viewport().size.x * 0.5 / self.zoom.x
	var half_height = get_viewport().size.y * 0.5 / self.zoom.y

	var cam_x = self.global_position.x
	var cam_y = self.global_position.y

	# Calculate intended bounds
	var left = cam_x - half_width
	var right = cam_x + half_width
	var top = cam_y - half_height
	var bottom = cam_y + half_height

	# Clamp bounds to camera limits
	left = max(left, self.limit_left)
	right = min(right, self.limit_right)
	top = max(top, self.limit_top)
	bottom = min(bottom, self.limit_bottom)

	var top_left = Vector2(left, top)
	var size = Vector2(right - left, bottom - top)

	draw_rect(Rect2(top_left, size), Color.RED, false, 3.0)

func _process(delta):
	_draw()  # Redraw every frame to keep the bounds updated
