// temperature measurement
__kernel void compute_temperature(
    __global const ushort* input,
    __global float* output,
    float a,
    float b,
    float c,
    int width,
    int height)
{
    int x = get_global_id(0);
    int y = get_global_id(1);
    
    if (x >= width || y >= height)
        return;
        
    int idx = y * width + x;
    float val = (float)input[idx];
    output[idx] = a * val * val + b * val + c;
}

__kernel void compute_temperature_exp(
    __global const ushort* input,
    __global float* output,
    float A,
    float B,
    float epsilon,
    int width,
    int height)
{
    int x = get_global_id(0);
    int y = get_global_id(1);
    
    if (x >= width || y >= height)
        return;
        
    int idx = y * width + x;
    float D = (float)input[idx];
    
    // 防止对0取对数
    if (D <= 0.0f) {
        output[idx] = 0.0f;
        return;
    }
    
    // T = B / (ln(A) - ln(εD))
    float ln_A = log(A);
    float ln_eD = log(epsilon * D);
    float denominator = ln_A - ln_eD;
    
    // 防止除0
    if (fabs(denominator) < 1e-6f) {
        output[idx] = 0.0f;
        return;
    }
    
    output[idx] = B / denominator;
}