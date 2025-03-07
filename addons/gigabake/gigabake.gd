@tool
extends EditorPlugin

const BUTTON_NAME = "GigaBake"
const COMPILED_MESH_NAME = "CompiledMesh"

var button_giga_bake: Button
var toolbar_container: HBoxContainer;

func find_node_by_name(base_node: Node, name = "Node3DEditor") -> Node:
	if base_node.name.contains(name):
		return base_node

	for child in base_node.get_children():
		var result = find_node_by_name(child, name);
		if result:
			return result

	return null
	
func _enter_tree():
	toolbar_container = find_node_by_name(find_node_by_name(get_editor_interface().get_base_control(), "Node3DEditor"), "HBoxContainer")

	button_giga_bake = Button.new()
	button_giga_bake.text = BUTTON_NAME;
	button_giga_bake.tooltip_text = "Build CSG Meshes, Unwrap Model, Build Occluder"
	button_giga_bake.pressed.connect(_on_button_pressed)
	toolbar_container.add_child(button_giga_bake)

func _exit_tree():
	if button_giga_bake:
		button_giga_bake.queue_free()

func _on_button_pressed():
	print("[GigaBake] Started");
	var node_root = get_editor_interface().get_edited_scene_root();
	
	var node_csg: CSGCombiner3D;
	var node_occluder: OccluderInstance3D;

	for child in node_root.get_children():
		if (child is CSGCombiner3D):
			node_csg = child;
			continue;
		
		if (child is OccluderInstance3D):
			node_occluder = child;
			continue;
			
		if (child.name.contains(COMPILED_MESH_NAME)):
			child.queue_free();
	
	if (!node_csg):
		print("[GigaBake] Failed to find CSG Combiner for Baking")
		return;
		
	if (node_csg.use_collision):
		node_csg.use_collision = false;
		print("[GigaBake] Turned off Collision for CSG Mesh, not necessary.");
		
	# This unwraps all of UV2 for Lightmaps
	var meshes = node_csg.bake_static_mesh()
	var instance = MeshInstance3D.new();
	node_root.add_child(instance);
	instance.mesh = meshes;

	var old_mesh = instance.mesh;
	var new_mesh = ArrayMesh.new();
	for surface_id in range(old_mesh.get_surface_count()):
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, old_mesh.surface_get_arrays(surface_id));
		var old_mat = old_mesh.surface_get_material(surface_id);
		new_mesh.surface_set_material(surface_id, old_mat);
	new_mesh.lightmap_unwrap(instance.global_transform, 0.4);
	
	instance.create_trimesh_collision()
	instance.mesh = new_mesh;
	instance.owner = node_root;
	instance.name = COMPILED_MESH_NAME;

	# Create Static Body Collision
	var static_body = StaticBody3D.new()
	node_root.add_child(static_body)
	static_body.owner = node_root;
	static_body.name = "StaticBody3D"
	static_body.reparent(instance);
	static_body.collision_layer = 3;
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = instance.mesh.create_trimesh_shape();
	collision_shape.name = "CollisionShape3D";

	node_root.add_child(collision_shape)
	collision_shape.owner = node_root;
	collision_shape.reparent(static_body);
	
	get_editor_interface().mark_scene_as_unsaved();

	# Set Occluder after Bake
	if (!node_occluder):
		print("[GigaBake] Failed to find Occluder for GigaBake");
		return;
	
	node_occluder.occluder = create_occluder_from_mesh(instance.mesh)
	get_editor_interface().mark_scene_as_unsaved();
	print("[GigaBake] Complete");

# Thanks nenad2d for the help on this
func create_occluder_from_mesh(mesh: Mesh) -> ArrayOccluder3D:
	var occluder = ArrayOccluder3D.new()
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	var vertex_offset = 0

	for surface_index in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface_index)
		var surface_vertices = arrays[Mesh.ARRAY_VERTEX]
		var surface_indices = arrays[Mesh.ARRAY_INDEX]

		vertices.append_array(surface_vertices)
		for index in surface_indices:
			indices.append(index + vertex_offset)

		vertex_offset += surface_vertices.size()

	occluder.set_arrays(vertices, indices)
	return occluder
