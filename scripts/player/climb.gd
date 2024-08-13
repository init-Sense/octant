extends Node
class_name Climb


const MAX_STEP_HEIGHT: float = 0.5
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF
var _saved_camera_global_pos = null

@onready var player: Player = $"../.."
@onready var stairs_below_ray_cast_3d: RayCast3D = $"../../StairsBelowRayCast3D"
@onready var stairs_ahead_ray_cast_3d: RayCast3D = $"../../StairsAheadRayCast3D"
@onready var motion: Motion = %Motion
@onready var camera_smooth: Node3D = %CameraSmooth


#region CLIMB SMOOTHING
func _save_camera_pos_for_smoothing():
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = camera_smooth.global_position


func _slide_camera_smooth_back_to_origin(delta) -> void:
	if _saved_camera_global_pos == null: return
	camera_smooth.global_position.y = _saved_camera_global_pos.y
	camera_smooth.position.y = clampf(camera_smooth.position.y, -0.7, 0.7)
	var move_amount = max(player.velocity.length() * delta, motion.WALKING_SPEED / 2 * delta)
	_saved_camera_global_pos = camera_smooth.global_position
	if camera_smooth.position.y == 0:
		_saved_camera_global_pos = null
#endregion


func _snap_up_stairs_check(delta) -> bool:
	if not player.is_on_floor() and not _snapped_to_stairs_last_frame: return false
	if player.velocity.y > 0 or (player.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion                 = player.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance: Transform3D = player.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))

	var down_check_result: KinematicCollision3D = KinematicCollision3D.new()
	
	if (player.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result) and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height: float = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - player.global_position).y

		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - player.global_position).y > MAX_STEP_HEIGHT: return false
		stairs_ahead_ray_cast_3d.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		stairs_ahead_ray_cast_3d.force_raycast_update()
		
		if stairs_ahead_ray_cast_3d.is_colliding() and not is_surface_too_steep(stairs_ahead_ray_cast_3d.get_collision_normal()):
			_save_camera_pos_for_smoothing()
			
			player.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			player.apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			
			return true
	return false


func _snap_down_the_stairs_check() -> void:
	var did_snap := false
	var floor_below: bool = stairs_below_ray_cast_3d.is_colliding() and not is_surface_too_steep(stairs_below_ray_cast_3d.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	
	if not player.is_on_floor() and player.velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
		
		if _run_body_test_motion(player.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			_save_camera_pos_for_smoothing()
			
			var translate_y: float = body_test_result.get_travel().y
			
			player.position.y += translate_y
			player.apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap


func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > player.floor_max_angle


func _run_body_test_motion(from_param: Transform3D, motion_param: Vector3, result = null) -> bool:
	if not result: result -= PhysicsTestMotionResult3D.new()
	var params: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	params.from = from_param
	params.motion = motion_param
	
	return PhysicsServer3D.body_test_motion(player.get_rid(), params, result)
