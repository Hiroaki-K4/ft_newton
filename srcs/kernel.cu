#include "kernel.cuh"


__global__ void update_particle_kernel(glm::vec3 *cu_position, glm::vec3 *cu_velocity, const float mass,
    const float delta_time, const int num_particles, const float collision_distance) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= num_particles) {
        return;
    }

    glm::vec3 all_accel(0.0f);
    for (int j = 0; j < num_particles; j++) {
        if (i == j) {
            continue;
        }
        float dist = glm::distance(cu_position[i], cu_position[j]);
        if (dist <= collision_distance) {
            // Calculate collision
            cu_velocity[i] = cu_velocity[i] - (glm::dot(
                cu_velocity[i] - cu_velocity[j], cu_position[i] - cu_position[j]) / (dist * dist))
                * (cu_position[i] - cu_position[j]);
        } else {
            // Calculate gravity
            float G = 6.67430e-11;
            float accel_power = G * (mass * mass) / (dist * dist);
            glm::vec3 accel = (cu_position[j] - cu_position[i]) / dist * accel_power;
            all_accel += accel;
        }
    }
    cu_velocity[i] += all_accel * delta_time;
    cu_position[i] += cu_velocity[i] * delta_time;
}
