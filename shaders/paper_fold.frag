#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

out vec4 fragColor;

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_texture;

// 2D Random generator
float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation
    vec2 u = f*f*(3.0-2.0*f);

    // Mix 4 corners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

// Fractal Brownian Motion for rich, multi-layered paper wrinkles
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    // Local coordinates (0.0 to 1.0)
    vec2 uv = FlutterFragCoord().xy / u_resolution;
    
    float t = u_time; // Expects an elastically eased time from 0 to 1
    
    // Normalize coordinates to center (-0.5 to 0.5)
    vec2 centeredUV = uv - 0.5;
    float dist = length(centeredUV);
    
    // 1. Asymmetric unfolding: outer edges (corners) unfold later than the center
    float delay = dist * 0.4; // Max distance is ~0.7, so delay up to ~0.28
    
    // Use max(0.0, ...) instead of clamp so we preserve the elastic overshoot > 1.0!
    float localT = max(0.0, (t - delay) / (1.0 - 0.3));
    
    // 2. Paper scale / Perspective folding (expands from a tiny ball)
    // Crumpled ball starts small (scale = 4.0 zooms OUT) and expands to scale 1.0
    float currentScale = mix(3.5, 1.0, localT);
    vec2 distortedUV = centeredUV * currentScale;
    
    // 3. Procedural Paper Wrinkles (Vertex Displacement via UVs)
    // High frequency when crumpled, smooths out when flat
    float freq = mix(20.0, 5.0, localT);
    float n = fbm(uv * freq);
    
    // Displacement intensity fades to 0 as it flattens
    float wrinkleIntensity = mix(0.12, 0.0, localT);
    distortedUV += vec2(n - 0.5) * wrinkleIntensity;
    
    // 4. Random Rotation (Crumpled mass rotates as it unfolds)
    float rot = mix(3.14 * 1.2, 0.0, localT); // 216 degree unspooling rotation
    mat2 rotMat = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
    distortedUV = rotMat * distortedUV;
    
    // 5. Curling Corners (Edge distortion)
    // We pull the corners inward when not fully flattened
    vec2 edgeDist = abs(distortedUV);
    float cornerPull = (edgeDist.x * edgeDist.y) * mix(1.2, 0.0, localT);
    distortedUV -= centeredUV * cornerPull;

    // 6. Back to 0..1 space for texture sampling
    distortedUV += 0.5;
    
    // Discard pixels outside the valid UV range to sculpt the jagged crumpled shape
    if (distortedUV.x < 0.0 || distortedUV.x > 1.0 || distortedUV.y < 0.0 || distortedUV.y > 1.0) {
        fragColor = vec4(0.0);
    } else {
        // 7. Dynamic Lighting across folds (Phong-ish)
        // Compute procedural normals from the mathematical derivative of the noise
        float eps = 0.01;
        float nx = fbm(uv * freq + vec2(eps, 0.0)) - n;
        float ny = fbm(uv * freq + vec2(0.0, eps)) - n;
        
        // Z-axis normal strength flattens out over time
        vec3 normal = normalize(vec3(-nx, -ny, mix(0.1, 2.0, localT)));
        vec3 lightDir = normalize(vec3(0.5, 0.5, 1.0)); // Top-Right directional light
        
        float diffuse = max(dot(normal, lightDir), 0.0);
        float ambient = 0.55;
        
        // Shadows are strong when crumpled, disappear when flat
        float shadowIntensity = mix(0.8, 0.0, localT); 
        float lighting = mix(1.0, diffuse + ambient, shadowIntensity);
        lighting = clamp(lighting, 0.3, 1.2); // Avoid blowing out the colors

        vec4 texColor = texture(u_texture, distortedUV);
        fragColor = vec4(texColor.rgb * lighting, texColor.a);
    }
}
