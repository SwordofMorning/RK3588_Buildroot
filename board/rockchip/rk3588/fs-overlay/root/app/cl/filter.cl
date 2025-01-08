// mean_filter.cl
__kernel void mean_filter_nv12(
    __global uchar* input,
    __global uchar* output,
    int width,
    int height,
    int window_size)
{
    int x = get_global_id(0);
    int y = get_global_id(1);
    
    if(x >= width || y >= height)
        return;
        
    int half_window = window_size / 2;
    int sum = 0;
    int count = 0;
    
    // 计算窗口内的平均值
    for(int wy = -half_window; wy <= half_window; wy++) {
        for(int wx = -half_window; wx <= half_window; wx++) {
            int nx = x + wx;
            int ny = y + wy;
            
            // 边界检查
            if(nx >= 0 && nx < width && ny >= 0 && ny < height) {
                sum += input[ny * width + nx];
                count++;
            }
        }
    }
    
    // 写入结果
    output[y * width + x] = (uchar)(sum / count);
}

__kernel void bilateral_filter_nv12(
    __global uchar* input,
    __global uchar* output,
    int width,
    int height,
    float sigma_space,
    float sigma_range)
{
    int x = get_global_id(0);
    int y = get_global_id(1);
    
    if(x >= width || y >= height)
        return;
        
    int radius = (int)(2 * sigma_space);
    float space_coeff = -0.5f / (sigma_space * sigma_space);
    float range_coeff = -0.5f / (sigma_range * sigma_range);
    
    float sum = 0.0f;
    float weight_sum = 0.0f;
    int center_val = input[y * width + x];
    
    // 计算双边滤波
    for(int wy = -radius; wy <= radius; wy++) {
        for(int wx = -radius; wx <= radius; wx++) {
            int nx = x + wx;
            int ny = y + wy;
            
            if(nx >= 0 && nx < width && ny >= 0 && ny < height) {
                int curr_val = input[ny * width + nx];
                
                // 计算空间权重
                float space_dist = (float)(wx * wx + wy * wy);
                float space_weight = exp(space_dist * space_coeff);
                
                // 计算值域权重
                float range_dist = (float)((center_val - curr_val) * (center_val - curr_val));
                float range_weight = exp(range_dist * range_coeff);
                
                // 总权重
                float weight = space_weight * range_weight;
                sum += curr_val * weight;
                weight_sum += weight;
            }
        }
    }
    
    // 写入结果
    output[y * width + x] = (uchar)(sum / weight_sum);
}