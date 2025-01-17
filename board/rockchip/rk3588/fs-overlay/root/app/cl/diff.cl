// diff.cl
__kernel void compute_diff(
    __global const ushort* current,
    __global const ushort* last,
    __global ushort* output,
    float rate,
    int width,
    int height)
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    if(x >= width || y >= height)
        return;

    int idx = y * width + x;

    float last_val = convert_float(last[idx]) * rate;
    float curr_val = convert_float(current[idx]);

    float diff = fabs(curr_val - last_val);

    output[idx] = convert_ushort(diff);
}