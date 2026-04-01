#[raygen]

#version 460

#VERSION_DEFINES

#extension GL_EXT_ray_tracing : enable

#define MAX_VIEWS 2
#include "../scene_data_inc.glsl"

layout(set = 0, binding = 0, std140) uniform SceneDataBlock {
	SceneData data;
	SceneData prev_data;
}
scene_data_block;

layout(set = 0, binding = 1, rgba16f) uniform image2D out_image;
layout(set = 0, binding = 2) uniform accelerationStructureEXT tlas;

layout(location = 0) rayPayloadEXT vec2 payload;

void main() {
	vec2 pos = ((vec2(gl_LaunchIDEXT.xy) + 0.5) / vec2(gl_LaunchSizeEXT.xy)) * 2.0 - 1.0;

	mat4 view_matrix = transpose(mat4(scene_data_block.data.inv_view_matrix[0],
			scene_data_block.data.inv_view_matrix[1],
			scene_data_block.data.inv_view_matrix[2],
			vec4(0.0, 0.0, 0.0, 1.0)));

	vec3 dir = normalize((view_matrix * vec4(pos.x / scene_data_block.data.projection_matrix[0][0], pos.y / scene_data_block.data.projection_matrix[1][1], -1.0, 0.0)).xyz);
	vec3 origin = view_matrix[3].xyz;

	traceRayEXT(tlas,
			gl_RayFlagsOpaqueEXT,
			0xFF,
			0, 1, 0,
			origin,
			0.0,
			dir,
			10000.0,
			0);

	imageStore(out_image, ivec2(gl_LaunchIDEXT.xy), vec4(payload, 0.0, 0.0));
}

#[miss]

#version 460

#VERSION_DEFINES

#extension GL_EXT_ray_tracing : enable

layout(location = 0) rayPayloadInEXT vec2 payload;

void main() {
	payload = vec2(0.0);
}

#[closest_hit]

#version 460

#VERSION_DEFINES

#extension GL_EXT_ray_tracing : enable

layout(location = 0) rayPayloadInEXT vec2 payload;
hitAttributeEXT vec2 attribs;

void main() {
	payload = attribs;
}
