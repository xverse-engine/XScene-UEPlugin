#include <torch/extension.h>
#include <cooperative_groups.h>
#include <algorithm>
#include <iostream>

namespace cg = cooperative_groups;

#define G_00 0.001028380123898387f
#define G_01 0.0075987582094967365f
#define G_02 0.036000773310661316f
#define G_03 0.10936068743467331f
#define G_04 0.21300552785396576f
#define G_05 0.26601171493530273f
#define G_06 0.21300552785396576f
#define G_07 0.10936068743467331f
#define G_08 0.036000773310661316f
#define G_09 0.0075987582094967365f
#define G_10 0.001028380123898387f

#define G_000 0.0000010576f
#define G_001 0.0000078144f
#define G_002 0.0000370225f
#define G_003 0.0001124644f
#define G_004 0.0002190506f
#define G_005 0.0002735612f
#define G_006 0.0002190506f
#define G_007 0.0001124644f
#define G_008 0.0000370225f
#define G_009 0.0000078144f
#define G_010 0.0000010576f
#define G_011 0.0000078144f
#define G_012 0.0000577411f
#define G_013 0.0002735612f
#define G_014 0.0008310054f
#define G_015 0.0016185775f
#define G_016 0.0020213588f
#define G_017 0.0016185775f
#define G_018 0.0008310054f
#define G_019 0.0002735612f
#define G_020 0.0000577411f
#define G_021 0.0000078144f
#define G_022 0.0000370225f
#define G_023 0.0002735612f
#define G_024 0.0012960557f
#define G_025 0.0039370693f
#define G_026 0.0076683639f
#define G_027 0.0095766271f
#define G_028 0.0076683639f
#define G_029 0.0039370693f
#define G_030 0.0012960557f
#define G_031 0.0002735612f
#define G_032 0.0000370225f
#define G_033 0.0001124644f
#define G_034 0.0008310054f
#define G_035 0.0039370693f
#define G_036 0.0119597595f
#define G_037 0.0232944302f
#define G_038 0.0290912241f
#define G_039 0.0232944302f
#define G_040 0.0119597595f
#define G_041 0.0039370693f
#define G_042 0.0008310054f
#define G_043 0.0001124644f
#define G_044 0.0002190506f
#define G_045 0.0016185775f
#define G_046 0.0076683639f
#define G_047 0.0232944302f
#define G_048 0.0453713536f
#define G_049 0.0566619672f
#define G_050 0.0453713536f
#define G_051 0.0232944302f
#define G_052 0.0076683639f
#define G_053 0.0016185775f
#define G_054 0.0002190506f
#define G_055 0.0002735612f
#define G_056 0.0020213588f
#define G_057 0.0095766271f
#define G_058 0.0290912241f
#define G_059 0.0566619672f
#define G_060 0.0707622319f
#define G_061 0.0566619672f
#define G_062 0.0290912241f
#define G_063 0.0095766271f
#define G_064 0.0020213588f
#define G_065 0.0002735612f
#define G_066 0.0002190506f
#define G_067 0.0016185775f
#define G_068 0.0076683639f
#define G_069 0.0232944302f
#define G_070 0.0453713536f
#define G_071 0.0566619672f
#define G_072 0.0453713536f
#define G_073 0.0232944302f
#define G_074 0.0076683639f
#define G_075 0.0016185775f
#define G_076 0.0002190506f
#define G_077 0.0001124644f
#define G_078 0.0008310054f
#define G_079 0.0039370693f
#define G_080 0.0119597595f
#define G_081 0.0232944302f
#define G_082 0.0290912241f
#define G_083 0.0232944302f
#define G_084 0.0119597595f
#define G_085 0.0039370693f
#define G_086 0.0008310054f
#define G_087 0.0001124644f
#define G_088 0.0000370225f
#define G_089 0.0002735612f
#define G_090 0.0012960557f
#define G_091 0.0039370693f
#define G_092 0.0076683639f
#define G_093 0.0095766271f
#define G_094 0.0076683639f
#define G_095 0.0039370693f
#define G_096 0.0012960557f
#define G_097 0.0002735612f
#define G_098 0.0000370225f
#define G_099 0.0000078144f
#define G_100 0.0000577411f
#define G_101 0.0002735612f
#define G_102 0.0008310054f
#define G_103 0.0016185775f
#define G_104 0.0020213588f
#define G_105 0.0016185775f
#define G_106 0.0008310054f
#define G_107 0.0002735612f
#define G_108 0.0000577411f
#define G_109 0.0000078144f
#define G_110 0.0000010576f
#define G_111 0.0000078144f
#define G_112 0.0000370225f
#define G_113 0.0001124644f
#define G_114 0.0002190506f
#define G_115 0.0002735612f
#define G_116 0.0002190506f
#define G_117 0.0001124644f
#define G_118 0.0000370225f
#define G_119 0.0000078144f
#define G_120 0.0000010576f

#define BX 32
#define BY 32
#define BLOCK_DIM 16


template <int C>
__device__ float get_pix_value(const float* img, const int c, const int y, const int x, const int H, const int W) {
    if (x >= W || y >= H || x < 0 || y < 0) {
        return 0.0f;
    } else {
        return img[c * H * W + y * W + x];
    }
}

/*
 * Copyright 1993-2007 NVIDIA Corporation.  All rights reserved.
 *
 * NOTICE TO USER:
 *
 * This source code is subject to NVIDIA ownership rights under U.S. and
 * international Copyright laws.  Users and possessors of this source code
 * are hereby granted a nonexclusive, royalty-free license to use this code
 * in individual and commercial software.
 *
 * NVIDIA MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS SOURCE
 * CODE FOR ANY PURPOSE.  IT IS PROVIDED "AS IS" WITHOUT EXPRESS OR
 * IMPLIED WARRANTY OF ANY KIND.  NVIDIA DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOURCE CODE, INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE.
 * IN NO EVENT SHALL NVIDIA BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL,
 * OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
 * OF USE, DATA OR PROFITS,  WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
 * OR OTHER TORTIOUS ACTION,  ARISING OUT OF OR IN CONNECTION WITH THE USE
 * OR PERFORMANCE OF THIS SOURCE CODE.
 *
 * U.S. Government End Users.   This source code is a "commercial item" as
 * that term is defined at  48 C.F.R. 2.numIterations1 (OCT 1995), consisting  of
 * "commercial computer  software"  and "commercial computer software
 * documentation" as such terms are  used in 48 C.F.R. 12.212 (SEPT 1995)
 * and is provided to the U.S. Government only as a commercial end item.
 * Consistent with 48 C.F.R.12.212 and 48 C.F.R. 227.7202-1 through
 * 227.7202-4 (JUNE 1995), all U.S. Government End Users acquire the
 * source code with only those rights set forth herein.
 *
 * Any use of this source code in individual and commercial software must
 * include, in the user documentation and internal comments to the code,
 * the above Disclaimer and U.S. Government End Users Notice.
 */
template<int C>
__global__ void transposeCUDA(float *odata, float *idata, int width, int height)
{
	__shared__ float block[BLOCK_DIM][BLOCK_DIM+1];
    const int num_pix = width * height;
	
    for (int c = 0; c < C; ++c) {
        unsigned int xIndex = blockIdx.x * BLOCK_DIM + threadIdx.x;
        unsigned int yIndex = blockIdx.y * BLOCK_DIM + threadIdx.y;
        if((xIndex < width) && (yIndex < height))
        {
            unsigned int index_in = yIndex * width + xIndex;
            block[threadIdx.y][threadIdx.x] = idata[num_pix * c + index_in];
        }

        __syncthreads();

        xIndex = blockIdx.y * BLOCK_DIM + threadIdx.x;
        yIndex = blockIdx.x * BLOCK_DIM + threadIdx.y;
        if((xIndex < height) && (yIndex < width))
        {
            unsigned int index_out = yIndex * height + xIndex;
            odata[num_pix * c + index_out] = block[threadIdx.x][threadIdx.y];
        }
        __syncthreads();
    }
}

template <int C>
__global__ void separableConvCUDA(
    const float* __restrict__ input,
    float* __restrict__ output,
    const int H,
    const int W)
{
	auto block = cg::this_thread_block();
    const int pix_y = block.group_index().y * block.dim_threads().y + block.thread_index().y;
    const int pix_x = block.group_index().x * block.dim_threads().x + block.thread_index().x;
    const int pix_id = pix_y * W + pix_x;
    const int num_pix = H * W;

    __shared__ float pixels[BY][BX + 10];
    const int start_y = block.group_index().y * block.dim_threads().y;
    const int start_x = block.group_index().x * block.dim_threads().x;
    
    const int cnt = BY * (BX + 10);
    const int num_blocks = (cnt + BX * BY - 1) / (BX * BY);

    for (int i = 0; i < C; ++i) {

        for (int b = 0; b < num_blocks; ++b) {
            int tid = b * (BX * BY) + block.thread_rank();
            if (tid < cnt) {
                int local_y = tid / (BX + 10);
                int local_x = tid % (BX + 10);
                int y = start_y + local_y;
                int x = start_x + local_x;
                pixels[local_y][local_x] = get_pix_value<C>(input, i, y, x - 5, H, W);
            }
        }
        block.sync();

        if (pix_x < W && pix_y < H) {
            int local_y = block.thread_index().y;
            int local_x = block.thread_index().x + 5;
            float val = 0.0f;
            val += G_00 * pixels[local_y][local_x - 5];
            val += G_01 * pixels[local_y][local_x - 4];
            val += G_02 * pixels[local_y][local_x - 3];
            val += G_03 * pixels[local_y][local_x - 2];
            val += G_04 * pixels[local_y][local_x - 1];
            val += G_05 * pixels[local_y][local_x    ];
            val += G_06 * pixels[local_y][local_x + 1];
            val += G_07 * pixels[local_y][local_x + 2];
            val += G_08 * pixels[local_y][local_x + 3];
            val += G_09 * pixels[local_y][local_x + 4];
            val += G_10 * pixels[local_y][local_x + 5];
            output[i * num_pix + pix_id] = val;
        }
        block.sync();
    }
}

template <int C>
__global__ void convCUDA(
    const float* __restrict__ input,
    float* __restrict__ output,
    const int H,
    const int W)
{
	auto block = cg::this_thread_block();
    const int pix_y = block.group_index().y * block.dim_threads().y + block.thread_index().y;
    const int pix_x = block.group_index().x * block.dim_threads().x + block.thread_index().x;
    const int pix_id = pix_y * W + pix_x;
    const int num_pix = H * W;

    __shared__ float pixels[BY + 10][BX + 10];
    const int start_y = block.group_index().y * block.dim_threads().y;
    const int start_x = block.group_index().x * block.dim_threads().x;
    
    const int cnt = (BY + 10) * (BX + 10);
    const int num_blocks = (cnt + BX * BY - 1) / (BX * BY);

    for (int i = 0; i < C; ++i) {

        for (int b = 0; b < num_blocks; ++b) {
            int tid = b * (BX * BY) + block.thread_rank();
            if (tid < cnt) {
                int local_y = tid / (BX + 10);
                int local_x = tid % (BX + 10);
                int y = start_y + local_y;
                int x = start_x + local_x;
                pixels[local_y][local_x] = get_pix_value<C>(input, i, y - 5, x - 5, H, W);
            }
        }
        block.sync();

        if (pix_x < W && pix_y < H) {
            int local_y = block.thread_index().y + 5;
            int local_x = block.thread_index().x + 5;
            float val = 0.0f;

            {
                val += G_000 * pixels[local_y - 5][local_x - 5];
                val += G_001 * pixels[local_y - 5][local_x - 4];
                val += G_002 * pixels[local_y - 5][local_x - 3];
                val += G_003 * pixels[local_y - 5][local_x - 2];
                val += G_004 * pixels[local_y - 5][local_x - 1];
                val += G_005 * pixels[local_y - 5][local_x    ];
                val += G_006 * pixels[local_y - 5][local_x + 1];
                val += G_007 * pixels[local_y - 5][local_x + 2];
                val += G_008 * pixels[local_y - 5][local_x + 3];
                val += G_009 * pixels[local_y - 5][local_x + 4];
                val += G_010 * pixels[local_y - 5][local_x + 5];
                val += G_011 * pixels[local_y - 4][local_x - 5];
                val += G_012 * pixels[local_y - 4][local_x - 4];
                val += G_013 * pixels[local_y - 4][local_x - 3];
                val += G_014 * pixels[local_y - 4][local_x - 2];
                val += G_015 * pixels[local_y - 4][local_x - 1];
                val += G_016 * pixels[local_y - 4][local_x    ];
                val += G_017 * pixels[local_y - 4][local_x + 1];
                val += G_018 * pixels[local_y - 4][local_x + 2];
                val += G_019 * pixels[local_y - 4][local_x + 3];
                val += G_020 * pixels[local_y - 4][local_x + 4];
                val += G_021 * pixels[local_y - 4][local_x + 5];
                val += G_022 * pixels[local_y - 3][local_x - 5];
                val += G_023 * pixels[local_y - 3][local_x - 4];
                val += G_024 * pixels[local_y - 3][local_x - 3];
                val += G_025 * pixels[local_y - 3][local_x - 2];
                val += G_026 * pixels[local_y - 3][local_x - 1];
                val += G_027 * pixels[local_y - 3][local_x    ];
                val += G_028 * pixels[local_y - 3][local_x + 1];
                val += G_029 * pixels[local_y - 3][local_x + 2];
                val += G_030 * pixels[local_y - 3][local_x + 3];
                val += G_031 * pixels[local_y - 3][local_x + 4];
                val += G_032 * pixels[local_y - 3][local_x + 5];
                val += G_033 * pixels[local_y - 2][local_x - 5];
                val += G_034 * pixels[local_y - 2][local_x - 4];
                val += G_035 * pixels[local_y - 2][local_x - 3];
                val += G_036 * pixels[local_y - 2][local_x - 2];
                val += G_037 * pixels[local_y - 2][local_x - 1];
                val += G_038 * pixels[local_y - 2][local_x    ];
                val += G_039 * pixels[local_y - 2][local_x + 1];
                val += G_040 * pixels[local_y - 2][local_x + 2];
                val += G_041 * pixels[local_y - 2][local_x + 3];
                val += G_042 * pixels[local_y - 2][local_x + 4];
                val += G_043 * pixels[local_y - 2][local_x + 5];
                val += G_044 * pixels[local_y - 1][local_x - 5];
                val += G_045 * pixels[local_y - 1][local_x - 4];
                val += G_046 * pixels[local_y - 1][local_x - 3];
                val += G_047 * pixels[local_y - 1][local_x - 2];
                val += G_048 * pixels[local_y - 1][local_x - 1];
                val += G_049 * pixels[local_y - 1][local_x    ];
                val += G_050 * pixels[local_y - 1][local_x + 1];
                val += G_051 * pixels[local_y - 1][local_x + 2];
                val += G_052 * pixels[local_y - 1][local_x + 3];
                val += G_053 * pixels[local_y - 1][local_x + 4];
                val += G_054 * pixels[local_y - 1][local_x + 5];
                val += G_055 * pixels[local_y    ][local_x - 5];
                val += G_056 * pixels[local_y    ][local_x - 4];
                val += G_057 * pixels[local_y    ][local_x - 3];
                val += G_058 * pixels[local_y    ][local_x - 2];
                val += G_059 * pixels[local_y    ][local_x - 1];
                val += G_060 * pixels[local_y    ][local_x    ];
                val += G_061 * pixels[local_y    ][local_x + 1];
                val += G_062 * pixels[local_y    ][local_x + 2];
                val += G_063 * pixels[local_y    ][local_x + 3];
                val += G_064 * pixels[local_y    ][local_x + 4];
                val += G_065 * pixels[local_y    ][local_x + 5];
                val += G_066 * pixels[local_y + 1][local_x - 5];
                val += G_067 * pixels[local_y + 1][local_x - 4];
                val += G_068 * pixels[local_y + 1][local_x - 3];
                val += G_069 * pixels[local_y + 1][local_x - 2];
                val += G_070 * pixels[local_y + 1][local_x - 1];
                val += G_071 * pixels[local_y + 1][local_x    ];
                val += G_072 * pixels[local_y + 1][local_x + 1];
                val += G_073 * pixels[local_y + 1][local_x + 2];
                val += G_074 * pixels[local_y + 1][local_x + 3];
                val += G_075 * pixels[local_y + 1][local_x + 4];
                val += G_076 * pixels[local_y + 1][local_x + 5];
                val += G_077 * pixels[local_y + 2][local_x - 5];
                val += G_078 * pixels[local_y + 2][local_x - 4];
                val += G_079 * pixels[local_y + 2][local_x - 3];
                val += G_080 * pixels[local_y + 2][local_x - 2];
                val += G_081 * pixels[local_y + 2][local_x - 1];
                val += G_082 * pixels[local_y + 2][local_x    ];
                val += G_083 * pixels[local_y + 2][local_x + 1];
                val += G_084 * pixels[local_y + 2][local_x + 2];
                val += G_085 * pixels[local_y + 2][local_x + 3];
                val += G_086 * pixels[local_y + 2][local_x + 4];
                val += G_087 * pixels[local_y + 2][local_x + 5];
                val += G_088 * pixels[local_y + 3][local_x - 5];
                val += G_089 * pixels[local_y + 3][local_x - 4];
                val += G_090 * pixels[local_y + 3][local_x - 3];
                val += G_091 * pixels[local_y + 3][local_x - 2];
                val += G_092 * pixels[local_y + 3][local_x - 1];
                val += G_093 * pixels[local_y + 3][local_x    ];
                val += G_094 * pixels[local_y + 3][local_x + 1];
                val += G_095 * pixels[local_y + 3][local_x + 2];
                val += G_096 * pixels[local_y + 3][local_x + 3];
                val += G_097 * pixels[local_y + 3][local_x + 4];
                val += G_098 * pixels[local_y + 3][local_x + 5];
                val += G_099 * pixels[local_y + 4][local_x - 5];
                val += G_100 * pixels[local_y + 4][local_x - 4];
                val += G_101 * pixels[local_y + 4][local_x - 3];
                val += G_102 * pixels[local_y + 4][local_x - 2];
                val += G_103 * pixels[local_y + 4][local_x - 1];
                val += G_104 * pixels[local_y + 4][local_x    ];
                val += G_105 * pixels[local_y + 4][local_x + 1];
                val += G_106 * pixels[local_y + 4][local_x + 2];
                val += G_107 * pixels[local_y + 4][local_x + 3];
                val += G_108 * pixels[local_y + 4][local_x + 4];
                val += G_109 * pixels[local_y + 4][local_x + 5];
                val += G_110 * pixels[local_y + 5][local_x - 5];
                val += G_111 * pixels[local_y + 5][local_x - 4];
                val += G_112 * pixels[local_y + 5][local_x - 3];
                val += G_113 * pixels[local_y + 5][local_x - 2];
                val += G_114 * pixels[local_y + 5][local_x - 1];
                val += G_115 * pixels[local_y + 5][local_x    ];
                val += G_116 * pixels[local_y + 5][local_x + 1];
                val += G_117 * pixels[local_y + 5][local_x + 2];
                val += G_118 * pixels[local_y + 5][local_x + 3];
                val += G_119 * pixels[local_y + 5][local_x + 4];
                val += G_120 * pixels[local_y + 5][local_x + 5];
            }

            output[i * num_pix + pix_id] = val;
        }
        block.sync();
    }
}


torch::Tensor conv2DForward(torch::Tensor &input) {
    int H = input.size(1);
    int W = input.size(2);
	dim3 grid((W + BX - 1) / BX, (H + BY - 1) / BY, 1);
	dim3 block(BX, BY, 1);

    torch::Tensor aux = torch::zeros({3, H, W}, input.options());
    convCUDA<3><<<grid, block>>>(
		input.contiguous().data<float>(),
		aux.contiguous().data<float>(),
        H, W
    );
    return aux;


    separableConvCUDA<3><<<grid, block>>>(
		input.contiguous().data<float>(),
		aux.contiguous().data<float>(),
        H, W
    );


    // torch::Tensor aux_T = torch::full({3, W, H}, 0, input.options());
	// grid = dim3((W + BLOCK_DIM - 1) / BLOCK_DIM, (H + BLOCK_DIM - 1) / BLOCK_DIM, 1);
    // block = dim3(BLOCK_DIM, BLOCK_DIM, 1);
    // transposeCUDA<3><<<grid, block>>>(
    //     aux_T.contiguous().data<float>(),
    //     aux.contiguous().data<float>(),
    //     W,
    //     H);

    aux = aux.transpose(1,2);

    std::swap(H, W);

    torch::Tensor output_T = torch::full({3, H, W}, 0, input.options());
	grid = dim3((W + BX - 1) / BX, (H + BY - 1) / BY, 1);
    block = dim3(BX, BY, 1);
    separableConvCUDA<3><<<grid, block>>>(
		aux.contiguous().data<float>(),
		output_T.contiguous().data<float>(),
        H, W
    );

    // torch::Tensor output = torch::full({3, W, H}, 0, input.options());
	// grid = dim3((W + BLOCK_DIM - 1) / BLOCK_DIM, (H + BLOCK_DIM - 1) / BLOCK_DIM, 1);
    // block = dim3(BLOCK_DIM, BLOCK_DIM, 1);
    // transposeCUDA<3><<<grid, block>>>(
    //     output.contiguous().data<float>(),
    //     output_T.contiguous().data<float>(),
    //     W,
    //     H);
    // std::swap(H, W);
    return output_T.transpose(1,2);
}



__global__ void ssimrestCUDA(int N, float C1, float C2, float* mu1, float* mu2, float* mim, float* mom, float* mu2_sq, float* sigma2_sq, float* ssim_map)
{
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    if(idx >= N)
        return;

    float mu1_sq = mu1[idx] * mu1[idx];
    float mu1_mu2 = mu1[idx] * mu2[idx];
    float sigma1_sq = mim[idx] - mu1_sq;
    float sigma12 = mom[idx] - mu1_mu2;

    ssim_map[idx] = ((2.0f * mu1_mu2 + C1) * (2.0f * sigma12 + C2)) / ((mu1_sq + mu2_sq[idx] + C1) * (sigma1_sq + sigma2_sq[idx] + C2));
}

__global__ void ssimrest_backCUDA(
    int N, float C1, float C2, float* mu1_, float* mu2_, float* mim_, float* mom_, float* mu2_sq_, float* sigma2_sq_, 
    float* dL,
    float* dL_dmu1,
    float* dL_dmim,
    float* dL_dmom)
{
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    if(idx >= N)
        return;

    float mu1 = mu1_[idx];
    float mu2 = mu2_[idx];
    float mu2_sq = mu2_sq_[idx];
    float mim = mim_[idx];
    float mom = mom_[idx];
    float sigma2_sq = sigma2_sq_[idx];

    float A = (mu1*mu1 + C1 + mu2_sq);
    float B = (- mu1*mu1 + C2 + mim + sigma2_sq);
    float C = (C1 + 2*mu1*mu2);
    float D = (C2 + 2*mom - 2*mu1*mu2);

    float L = dL[idx];
    dL_dmu1[idx] = L * ((2*mu2*D)/(A*B) - (2*mu2*C)/(A*B) + (2*mu1*C*D)/(A*B*B) - (2*mu1*C*D)/(A*A*B));
    dL_dmim[idx] = L * (-(C*D)/(A*B*B));
    dL_dmom[idx] = L * ((2*C)/(A*B));
}

__global__ void lol(float* hnk)
{
    hnk[0] = 42;
}

torch::Tensor ssimrest(
	float C1, 
	float C2, 
	torch::Tensor& mu1, 
	torch::Tensor& mu2, 
	torch::Tensor& mim, 
	torch::Tensor& mom, 
	torch::Tensor& mu2_sq, 
	torch::Tensor& sigma2_sq
)
{
    int N = mu1.size(0) * mu1.size(1) * mu1.size(2);

    torch::Tensor target = torch::zeros_like(mu1).contiguous();
    ssimrestCUDA<<<(N + 255)/256, 256>>>(
        N,
        C1, 
        C2, 
        mu1.contiguous().data<float>(),
        mu2.contiguous().data<float>(),
        mim.contiguous().data<float>(),
        mom.contiguous().data<float>(),        
        mu2_sq.contiguous().data<float>(),
        sigma2_sq.contiguous().data<float>(),
        target.contiguous().data<float>());
    return target;
}

std::tuple<torch::Tensor, torch::Tensor, torch::Tensor> ssimrest_back(
	float C1, 
	float C2, 
	torch::Tensor& mu1, 
	torch::Tensor& mu2, 
	torch::Tensor& mim, 
	torch::Tensor& mom, 
	torch::Tensor& mu2_sq, 
	torch::Tensor& sigma2_sq,
    torch::Tensor& dL
)
{
    int N = mu1.size(0) * mu1.size(1) * mu1.size(2);

    torch::Tensor dL_dmu1 = torch::zeros_like(mu1).contiguous();
    torch::Tensor dL_dmim = torch::zeros_like(mu1).contiguous();
    torch::Tensor dL_dmom = torch::zeros_like(mu1).contiguous();
    ssimrest_backCUDA<<<(N + 255)/256, 256>>>(
        N,
        C1, 
        C2, 
        mu1.contiguous().data<float>(),
        mu2.contiguous().data<float>(),
        mim.contiguous().data<float>(),
        mom.contiguous().data<float>(),        
        mu2_sq.contiguous().data<float>(),
        sigma2_sq.contiguous().data<float>(),
        dL.contiguous().data<float>(),
        dL_dmu1.contiguous().data<float>(),
        dL_dmim.contiguous().data<float>(),
        dL_dmom.contiguous().data<float>());
    return std::make_tuple(dL_dmu1, dL_dmim, dL_dmom);
}

template <int C>
__device__ void load_into_shared(float pixels[BY + 10][BX + 10], float *input1, float *input2, int H, int W, int i, int subtract = 0) {
	auto block = cg::this_thread_block();
    const int start_y = block.group_index().y * (BY - subtract) - subtract / 2;
    const int start_x = block.group_index().x * (BX - subtract) - subtract / 2;

    const int cnt = (BY + 10) * (BX + 10);
    const int num_blocks = (cnt + BX * BY - 1) / (BX * BY);
    for (int b = 0; b < num_blocks; ++b) {
        int tid = b * (BX * BY) + block.thread_rank();
        if (tid < cnt) {
            int local_y = tid / (BX + 10);
            int local_x = tid % (BX + 10);
            int y = start_y + local_y;
            int x = start_x + local_x;
            if (input2 == nullptr) {
                float one = get_pix_value<C>(input1, i, y - 5, x - 5, H, W);
                pixels[local_y][local_x] = one;
            } else {
                float one = get_pix_value<C>(input1, i, y - 5, x - 5, H, W);
                float two = get_pix_value<C>(input2, i, y - 5, x - 5, H, W);
                pixels[local_y][local_x] = one * two;
            }
        }
    }
}

__device__ void write_to_shared(float pixels[BY + 10][BX + 10], float val) {
	auto block = cg::this_thread_block();

    // flush with 0s
    const int cnt = (BY + 10) * (BX + 10);
    const int num_blocks = (cnt + BX * BY - 1) / (BX * BY);
    for (int b = 0; b < num_blocks; ++b) {
        int tid = b * (BX * BY) + block.thread_rank();
        if (tid < cnt) {
            int local_y = tid / (BX + 10);
            int local_x = tid % (BX + 10);
            pixels[local_y][local_x] = 0.0f;
        }
    }
    block.sync();

    // write the values in the central BXxBY zone
    pixels[block.thread_index().y + 5][block.thread_index().x + 5] = val;
}

__device__ void multiply_shared_mem(float pix1[BY + 10][BX + 10], float pix2[BY + 10][BX + 10]) {
	auto block = cg::this_thread_block();
    const int cnt = (BY + 10) * (BX + 10);
    const int num_blocks = (cnt + BX * BY - 1) / (BX * BY);
    for (int b = 0; b < num_blocks; ++b) {
        int tid = b * (BX * BY) + block.thread_rank();
        if (tid < cnt) {
            int local_y = tid / (BX + 10);
            int local_x = tid % (BX + 10);
            float one = pix1[local_y][local_x];
            float two = pix2[local_y][local_x];
            pix1[local_y][local_x] = one * two;
        }
    }
}

__device__ inline float do_sq(float val) {
    return val * val;
}

__device__ float do_conv(float pixels[BY + 10][BX + 10], int H, int W, bool sq = false) {
	auto block = cg::this_thread_block();
    int local_y = block.thread_index().y + 5;
    int local_x = block.thread_index().x + 5;
    float val = 0.0f;
    
        if (sq) {

            val += G_000 * do_sq(pixels[local_y - 5][local_x - 5]);
            val += G_001 * do_sq(pixels[local_y - 5][local_x - 4]);
            val += G_002 * do_sq(pixels[local_y - 5][local_x - 3]);
            val += G_003 * do_sq(pixels[local_y - 5][local_x - 2]);
            val += G_004 * do_sq(pixels[local_y - 5][local_x - 1]);
            val += G_005 * do_sq(pixels[local_y - 5][local_x    ]);
            val += G_006 * do_sq(pixels[local_y - 5][local_x + 1]);
            val += G_007 * do_sq(pixels[local_y - 5][local_x + 2]);
            val += G_008 * do_sq(pixels[local_y - 5][local_x + 3]);
            val += G_009 * do_sq(pixels[local_y - 5][local_x + 4]);
            val += G_010 * do_sq(pixels[local_y - 5][local_x + 5]);
            val += G_011 * do_sq(pixels[local_y - 4][local_x - 5]);
            val += G_012 * do_sq(pixels[local_y - 4][local_x - 4]);
            val += G_013 * do_sq(pixels[local_y - 4][local_x - 3]);
            val += G_014 * do_sq(pixels[local_y - 4][local_x - 2]);
            val += G_015 * do_sq(pixels[local_y - 4][local_x - 1]);
            val += G_016 * do_sq(pixels[local_y - 4][local_x    ]);
            val += G_017 * do_sq(pixels[local_y - 4][local_x + 1]);
            val += G_018 * do_sq(pixels[local_y - 4][local_x + 2]);
            val += G_019 * do_sq(pixels[local_y - 4][local_x + 3]);
            val += G_020 * do_sq(pixels[local_y - 4][local_x + 4]);
            val += G_021 * do_sq(pixels[local_y - 4][local_x + 5]);
            val += G_022 * do_sq(pixels[local_y - 3][local_x - 5]);
            val += G_023 * do_sq(pixels[local_y - 3][local_x - 4]);
            val += G_024 * do_sq(pixels[local_y - 3][local_x - 3]);
            val += G_025 * do_sq(pixels[local_y - 3][local_x - 2]);
            val += G_026 * do_sq(pixels[local_y - 3][local_x - 1]);
            val += G_027 * do_sq(pixels[local_y - 3][local_x    ]);
            val += G_028 * do_sq(pixels[local_y - 3][local_x + 1]);
            val += G_029 * do_sq(pixels[local_y - 3][local_x + 2]);
            val += G_030 * do_sq(pixels[local_y - 3][local_x + 3]);
            val += G_031 * do_sq(pixels[local_y - 3][local_x + 4]);
            val += G_032 * do_sq(pixels[local_y - 3][local_x + 5]);
            val += G_033 * do_sq(pixels[local_y - 2][local_x - 5]);
            val += G_034 * do_sq(pixels[local_y - 2][local_x - 4]);
            val += G_035 * do_sq(pixels[local_y - 2][local_x - 3]);
            val += G_036 * do_sq(pixels[local_y - 2][local_x - 2]);
            val += G_037 * do_sq(pixels[local_y - 2][local_x - 1]);
            val += G_038 * do_sq(pixels[local_y - 2][local_x    ]);
            val += G_039 * do_sq(pixels[local_y - 2][local_x + 1]);
            val += G_040 * do_sq(pixels[local_y - 2][local_x + 2]);
            val += G_041 * do_sq(pixels[local_y - 2][local_x + 3]);
            val += G_042 * do_sq(pixels[local_y - 2][local_x + 4]);
            val += G_043 * do_sq(pixels[local_y - 2][local_x + 5]);
            val += G_044 * do_sq(pixels[local_y - 1][local_x - 5]);
            val += G_045 * do_sq(pixels[local_y - 1][local_x - 4]);
            val += G_046 * do_sq(pixels[local_y - 1][local_x - 3]);
            val += G_047 * do_sq(pixels[local_y - 1][local_x - 2]);
            val += G_048 * do_sq(pixels[local_y - 1][local_x - 1]);
            val += G_049 * do_sq(pixels[local_y - 1][local_x    ]);
            val += G_050 * do_sq(pixels[local_y - 1][local_x + 1]);
            val += G_051 * do_sq(pixels[local_y - 1][local_x + 2]);
            val += G_052 * do_sq(pixels[local_y - 1][local_x + 3]);
            val += G_053 * do_sq(pixels[local_y - 1][local_x + 4]);
            val += G_054 * do_sq(pixels[local_y - 1][local_x + 5]);
            val += G_055 * do_sq(pixels[local_y    ][local_x - 5]);
            val += G_056 * do_sq(pixels[local_y    ][local_x - 4]);
            val += G_057 * do_sq(pixels[local_y    ][local_x - 3]);
            val += G_058 * do_sq(pixels[local_y    ][local_x - 2]);
            val += G_059 * do_sq(pixels[local_y    ][local_x - 1]);
            val += G_060 * do_sq(pixels[local_y    ][local_x    ]);
            val += G_061 * do_sq(pixels[local_y    ][local_x + 1]);
            val += G_062 * do_sq(pixels[local_y    ][local_x + 2]);
            val += G_063 * do_sq(pixels[local_y    ][local_x + 3]);
            val += G_064 * do_sq(pixels[local_y    ][local_x + 4]);
            val += G_065 * do_sq(pixels[local_y    ][local_x + 5]);
            val += G_066 * do_sq(pixels[local_y + 1][local_x - 5]);
            val += G_067 * do_sq(pixels[local_y + 1][local_x - 4]);
            val += G_068 * do_sq(pixels[local_y + 1][local_x - 3]);
            val += G_069 * do_sq(pixels[local_y + 1][local_x - 2]);
            val += G_070 * do_sq(pixels[local_y + 1][local_x - 1]);
            val += G_071 * do_sq(pixels[local_y + 1][local_x    ]);
            val += G_072 * do_sq(pixels[local_y + 1][local_x + 1]);
            val += G_073 * do_sq(pixels[local_y + 1][local_x + 2]);
            val += G_074 * do_sq(pixels[local_y + 1][local_x + 3]);
            val += G_075 * do_sq(pixels[local_y + 1][local_x + 4]);
            val += G_076 * do_sq(pixels[local_y + 1][local_x + 5]);
            val += G_077 * do_sq(pixels[local_y + 2][local_x - 5]);
            val += G_078 * do_sq(pixels[local_y + 2][local_x - 4]);
            val += G_079 * do_sq(pixels[local_y + 2][local_x - 3]);
            val += G_080 * do_sq(pixels[local_y + 2][local_x - 2]);
            val += G_081 * do_sq(pixels[local_y + 2][local_x - 1]);
            val += G_082 * do_sq(pixels[local_y + 2][local_x    ]);
            val += G_083 * do_sq(pixels[local_y + 2][local_x + 1]);
            val += G_084 * do_sq(pixels[local_y + 2][local_x + 2]);
            val += G_085 * do_sq(pixels[local_y + 2][local_x + 3]);
            val += G_086 * do_sq(pixels[local_y + 2][local_x + 4]);
            val += G_087 * do_sq(pixels[local_y + 2][local_x + 5]);
            val += G_088 * do_sq(pixels[local_y + 3][local_x - 5]);
            val += G_089 * do_sq(pixels[local_y + 3][local_x - 4]);
            val += G_090 * do_sq(pixels[local_y + 3][local_x - 3]);
            val += G_091 * do_sq(pixels[local_y + 3][local_x - 2]);
            val += G_092 * do_sq(pixels[local_y + 3][local_x - 1]);
            val += G_093 * do_sq(pixels[local_y + 3][local_x    ]);
            val += G_094 * do_sq(pixels[local_y + 3][local_x + 1]);
            val += G_095 * do_sq(pixels[local_y + 3][local_x + 2]);
            val += G_096 * do_sq(pixels[local_y + 3][local_x + 3]);
            val += G_097 * do_sq(pixels[local_y + 3][local_x + 4]);
            val += G_098 * do_sq(pixels[local_y + 3][local_x + 5]);
            val += G_099 * do_sq(pixels[local_y + 4][local_x - 5]);
            val += G_100 * do_sq(pixels[local_y + 4][local_x - 4]);
            val += G_101 * do_sq(pixels[local_y + 4][local_x - 3]);
            val += G_102 * do_sq(pixels[local_y + 4][local_x - 2]);
            val += G_103 * do_sq(pixels[local_y + 4][local_x - 1]);
            val += G_104 * do_sq(pixels[local_y + 4][local_x    ]);
            val += G_105 * do_sq(pixels[local_y + 4][local_x + 1]);
            val += G_106 * do_sq(pixels[local_y + 4][local_x + 2]);
            val += G_107 * do_sq(pixels[local_y + 4][local_x + 3]);
            val += G_108 * do_sq(pixels[local_y + 4][local_x + 4]);
            val += G_109 * do_sq(pixels[local_y + 4][local_x + 5]);
            val += G_110 * do_sq(pixels[local_y + 5][local_x - 5]);
            val += G_111 * do_sq(pixels[local_y + 5][local_x - 4]);
            val += G_112 * do_sq(pixels[local_y + 5][local_x - 3]);
            val += G_113 * do_sq(pixels[local_y + 5][local_x - 2]);
            val += G_114 * do_sq(pixels[local_y + 5][local_x - 1]);
            val += G_115 * do_sq(pixels[local_y + 5][local_x    ]);
            val += G_116 * do_sq(pixels[local_y + 5][local_x + 1]);
            val += G_117 * do_sq(pixels[local_y + 5][local_x + 2]);
            val += G_118 * do_sq(pixels[local_y + 5][local_x + 3]);
            val += G_119 * do_sq(pixels[local_y + 5][local_x + 4]);
            val += G_120 * do_sq(pixels[local_y + 5][local_x + 5]);
        } else {

            val += G_000 * pixels[local_y - 5][local_x - 5];
            val += G_001 * pixels[local_y - 5][local_x - 4];
            val += G_002 * pixels[local_y - 5][local_x - 3];
            val += G_003 * pixels[local_y - 5][local_x - 2];
            val += G_004 * pixels[local_y - 5][local_x - 1];
            val += G_005 * pixels[local_y - 5][local_x    ];
            val += G_006 * pixels[local_y - 5][local_x + 1];
            val += G_007 * pixels[local_y - 5][local_x + 2];
            val += G_008 * pixels[local_y - 5][local_x + 3];
            val += G_009 * pixels[local_y - 5][local_x + 4];
            val += G_010 * pixels[local_y - 5][local_x + 5];
            val += G_011 * pixels[local_y - 4][local_x - 5];
            val += G_012 * pixels[local_y - 4][local_x - 4];
            val += G_013 * pixels[local_y - 4][local_x - 3];
            val += G_014 * pixels[local_y - 4][local_x - 2];
            val += G_015 * pixels[local_y - 4][local_x - 1];
            val += G_016 * pixels[local_y - 4][local_x    ];
            val += G_017 * pixels[local_y - 4][local_x + 1];
            val += G_018 * pixels[local_y - 4][local_x + 2];
            val += G_019 * pixels[local_y - 4][local_x + 3];
            val += G_020 * pixels[local_y - 4][local_x + 4];
            val += G_021 * pixels[local_y - 4][local_x + 5];
            val += G_022 * pixels[local_y - 3][local_x - 5];
            val += G_023 * pixels[local_y - 3][local_x - 4];
            val += G_024 * pixels[local_y - 3][local_x - 3];
            val += G_025 * pixels[local_y - 3][local_x - 2];
            val += G_026 * pixels[local_y - 3][local_x - 1];
            val += G_027 * pixels[local_y - 3][local_x    ];
            val += G_028 * pixels[local_y - 3][local_x + 1];
            val += G_029 * pixels[local_y - 3][local_x + 2];
            val += G_030 * pixels[local_y - 3][local_x + 3];
            val += G_031 * pixels[local_y - 3][local_x + 4];
            val += G_032 * pixels[local_y - 3][local_x + 5];
            val += G_033 * pixels[local_y - 2][local_x - 5];
            val += G_034 * pixels[local_y - 2][local_x - 4];
            val += G_035 * pixels[local_y - 2][local_x - 3];
            val += G_036 * pixels[local_y - 2][local_x - 2];
            val += G_037 * pixels[local_y - 2][local_x - 1];
            val += G_038 * pixels[local_y - 2][local_x    ];
            val += G_039 * pixels[local_y - 2][local_x + 1];
            val += G_040 * pixels[local_y - 2][local_x + 2];
            val += G_041 * pixels[local_y - 2][local_x + 3];
            val += G_042 * pixels[local_y - 2][local_x + 4];
            val += G_043 * pixels[local_y - 2][local_x + 5];
            val += G_044 * pixels[local_y - 1][local_x - 5];
            val += G_045 * pixels[local_y - 1][local_x - 4];
            val += G_046 * pixels[local_y - 1][local_x - 3];
            val += G_047 * pixels[local_y - 1][local_x - 2];
            val += G_048 * pixels[local_y - 1][local_x - 1];
            val += G_049 * pixels[local_y - 1][local_x    ];
            val += G_050 * pixels[local_y - 1][local_x + 1];
            val += G_051 * pixels[local_y - 1][local_x + 2];
            val += G_052 * pixels[local_y - 1][local_x + 3];
            val += G_053 * pixels[local_y - 1][local_x + 4];
            val += G_054 * pixels[local_y - 1][local_x + 5];
            val += G_055 * pixels[local_y    ][local_x - 5];
            val += G_056 * pixels[local_y    ][local_x - 4];
            val += G_057 * pixels[local_y    ][local_x - 3];
            val += G_058 * pixels[local_y    ][local_x - 2];
            val += G_059 * pixels[local_y    ][local_x - 1];
            val += G_060 * pixels[local_y    ][local_x    ];
            val += G_061 * pixels[local_y    ][local_x + 1];
            val += G_062 * pixels[local_y    ][local_x + 2];
            val += G_063 * pixels[local_y    ][local_x + 3];
            val += G_064 * pixels[local_y    ][local_x + 4];
            val += G_065 * pixels[local_y    ][local_x + 5];
            val += G_066 * pixels[local_y + 1][local_x - 5];
            val += G_067 * pixels[local_y + 1][local_x - 4];
            val += G_068 * pixels[local_y + 1][local_x - 3];
            val += G_069 * pixels[local_y + 1][local_x - 2];
            val += G_070 * pixels[local_y + 1][local_x - 1];
            val += G_071 * pixels[local_y + 1][local_x    ];
            val += G_072 * pixels[local_y + 1][local_x + 1];
            val += G_073 * pixels[local_y + 1][local_x + 2];
            val += G_074 * pixels[local_y + 1][local_x + 3];
            val += G_075 * pixels[local_y + 1][local_x + 4];
            val += G_076 * pixels[local_y + 1][local_x + 5];
            val += G_077 * pixels[local_y + 2][local_x - 5];
            val += G_078 * pixels[local_y + 2][local_x - 4];
            val += G_079 * pixels[local_y + 2][local_x - 3];
            val += G_080 * pixels[local_y + 2][local_x - 2];
            val += G_081 * pixels[local_y + 2][local_x - 1];
            val += G_082 * pixels[local_y + 2][local_x    ];
            val += G_083 * pixels[local_y + 2][local_x + 1];
            val += G_084 * pixels[local_y + 2][local_x + 2];
            val += G_085 * pixels[local_y + 2][local_x + 3];
            val += G_086 * pixels[local_y + 2][local_x + 4];
            val += G_087 * pixels[local_y + 2][local_x + 5];
            val += G_088 * pixels[local_y + 3][local_x - 5];
            val += G_089 * pixels[local_y + 3][local_x - 4];
            val += G_090 * pixels[local_y + 3][local_x - 3];
            val += G_091 * pixels[local_y + 3][local_x - 2];
            val += G_092 * pixels[local_y + 3][local_x - 1];
            val += G_093 * pixels[local_y + 3][local_x    ];
            val += G_094 * pixels[local_y + 3][local_x + 1];
            val += G_095 * pixels[local_y + 3][local_x + 2];
            val += G_096 * pixels[local_y + 3][local_x + 3];
            val += G_097 * pixels[local_y + 3][local_x + 4];
            val += G_098 * pixels[local_y + 3][local_x + 5];
            val += G_099 * pixels[local_y + 4][local_x - 5];
            val += G_100 * pixels[local_y + 4][local_x - 4];
            val += G_101 * pixels[local_y + 4][local_x - 3];
            val += G_102 * pixels[local_y + 4][local_x - 2];
            val += G_103 * pixels[local_y + 4][local_x - 1];
            val += G_104 * pixels[local_y + 4][local_x    ];
            val += G_105 * pixels[local_y + 4][local_x + 1];
            val += G_106 * pixels[local_y + 4][local_x + 2];
            val += G_107 * pixels[local_y + 4][local_x + 3];
            val += G_108 * pixels[local_y + 4][local_x + 4];
            val += G_109 * pixels[local_y + 4][local_x + 5];
            val += G_110 * pixels[local_y + 5][local_x - 5];
            val += G_111 * pixels[local_y + 5][local_x - 4];
            val += G_112 * pixels[local_y + 5][local_x - 3];
            val += G_113 * pixels[local_y + 5][local_x - 2];
            val += G_114 * pixels[local_y + 5][local_x - 1];
            val += G_115 * pixels[local_y + 5][local_x    ];
            val += G_116 * pixels[local_y + 5][local_x + 1];
            val += G_117 * pixels[local_y + 5][local_x + 2];
            val += G_118 * pixels[local_y + 5][local_x + 3];
            val += G_119 * pixels[local_y + 5][local_x + 4];
            val += G_120 * pixels[local_y + 5][local_x + 5];
        }
    return val;
}

template <int CH>
__global__ void fusedssimCUDA(
    int H,
    int W,
    float C1,
    float C2,
    float* img1,
    float* img2,
    float* ssim_map
)
{
	auto block = cg::this_thread_block();
    const int pix_y = block.group_index().y * BY + block.thread_index().y;
    const int pix_x = block.group_index().x * BX + block.thread_index().x;
    const int pix_id = pix_y * W + pix_x;
    const int num_pix = H * W;

    // stats for ssim
    float mu1 = 0.0f;
    float mu2 = 0.0f;
    float sigma1_sq = 0.0f;
    float sigma2_sq = 0.0f;
    float sigma12 = 0.0f;

    // shared memory that will be used to load pixels temporarily
    __shared__ float buf1[BY + 10][BX + 10];
    __shared__ float buf2[BY + 10][BX + 10];

    // mu1 <- Conv(img1)
    // sigma1_sq = Conv(img1 * img1) - mu1_sq
    for (int i = 0; i < CH; ++i) {
        // load into shared
        load_into_shared<CH>(buf1, img1, nullptr, H, W, i);
        block.sync();
        // conv
        mu1 = do_conv(buf1, H, W);
        sigma1_sq = do_conv(buf1, H, W, true) - mu1 * mu1;
        block.sync();

    // mu2 <- Conv(img2)
    // sigma2_sq = Conv(img2 * img2) - mu2_sq
        // load into shared
        load_into_shared<CH>(buf2, img2, nullptr, H, W, i);
        block.sync();
        // conv
        mu2 = do_conv(buf2, H, W);
        sigma2_sq = do_conv(buf2, H, W, true) - mu2 * mu2;
        block.sync();

    // sigma12 = Conv(img1 * img2) - mu1_mu2
        // load into shared
        multiply_shared_mem(buf1, buf2);
        block.sync();
        // conv
        sigma12 = do_conv(buf1, H, W) - mu1 * mu2;
        block.sync();

        float mu1_sq = mu1 * mu1;
        float mu2_sq = mu2 * mu2;
        float mu1_mu2 = mu1 * mu2;
        float C = (2.0f * mu1_mu2 + C1);
        float D = (2.0f * sigma12 + C2);
        float A = (mu1_sq + mu2_sq + C1);
        float B = (sigma1_sq + sigma2_sq + C2);
        float m = (C * D) / (A * B);
        if (pix_x < W && pix_y < H) {
            ssim_map[i * num_pix + pix_id] = m;
        }
    }
}

__device__ bool in_inner_window() {
	auto block = cg::this_thread_block();
    return 5 <= block.thread_index().y && block.thread_index().y < BY - 5 && 5 <= block.thread_index().x && block.thread_index().x < BX - 5;
}

template <int CH>
__global__ void fusedssim_backwardCUDA(
    int H,
    int W,
    float C1,
    float C2,
    float* img1,
    float* img2,
    float *dL_dmap,
    float *dL_dimg1)
{
	auto block = cg::this_thread_block();
    const int pix_y = block.group_index().y * (BY - 10) + block.thread_index().y - 5;
    const int pix_x = block.group_index().x * (BX - 10) + block.thread_index().x - 5;
    const int pix_id = pix_y * W + pix_x;
    const int num_pix = H * W;

    // stats for ssim
    float mu1 = 0.0f;
    float mu2 = 0.0f;
    float sigma1_sq = 0.0f;
    float sigma2_sq = 0.0f;
    float sigma12 = 0.0f;

    // shared memory that will be used to load pixels temporarily
    __shared__ float buf1[BY + 10][BX + 10];
    __shared__ float buf2[BY + 10][BX + 10];

    // mu1 <- Conv(img1)
    // sigma1_sq = Conv(img1 * img1) - mu1_sq
    for (int i = 0; i < CH; ++i) {
        // load into shared
        load_into_shared<CH>(buf1, img1, nullptr, H, W, i, 10);
        block.sync();
        // conv
        mu1 = do_conv(buf1, H, W);
        sigma1_sq = do_conv(buf1, H, W, true) - mu1 * mu1;
        block.sync();

    // mu2 <- Conv(img2)
    // sigma2_sq = Conv(img2 * img2) - mu2_sq
        // load into shared
        load_into_shared<CH>(buf2, img2, nullptr, H, W, i, 10);
        block.sync();
        // conv
        mu2 = do_conv(buf2, H, W);
        sigma2_sq = do_conv(buf2, H, W, true) - mu2 * mu2;
        block.sync();

    // sigma12 = Conv(img1 * img2) - mu1_mu2
        // load into shared
        multiply_shared_mem(buf2, buf1);
        block.sync();
        // conv
        sigma12 = do_conv(buf2, H, W) - mu1 * mu2;
        block.sync();

        float mu1_sq = mu1 * mu1;
        float mu2_sq = mu2 * mu2;
        float mu1_mu2 = mu1 * mu2;
        float C = (2.0f * mu1_mu2 + C1);
        float D = (2.0f * sigma12 + C2);
        float A = (mu1_sq + mu2_sq + C1);
        float B = (sigma1_sq + sigma2_sq + C2);
        float m = (C * D) / (A * B);
        // if (in_inner_window() && pix_x < W && pix_y < H) {
        //     ssim_map[i * num_pix + pix_id] = m;
        //     MU1[i * num_pix + pix_id] = mu1;
        //     MU2[i * num_pix + pix_id] = mu2;
        //     SIGMA1_SQ[i * num_pix + pix_id] = sigma1_sq;
        //     SIGMA2_SQ[i * num_pix + pix_id] = sigma2_sq;
        //     SIGMA12[i * num_pix + pix_id] = sigma12;
        // }

        float dL_dm = 0.0f;
        if (in_inner_window() && pix_x < W && pix_y < H)
            dL_dm = dL_dmap[i * num_pix + pix_id];
        float dL_dmu1 = dL_dm * (
            (mu2 * 2.0f * D) / (A * B)
            -(mu2 * 2.0f * C) / (A * B)
            -(mu1 * 2.0f * C * D) / ( A * A * B)
            +(mu1 * 2.0f * C * D) / (A * B * B)
            );
        float dL_dsigma1_sq = dL_dm * ((-C * D) / (A * B * B));
        float dL_dsigma12 = dL_dm * ((2 * C) / (A * B));

        float dL_dpix = 0.0f;
        float tmp = 0.0f;

        // gradient from mu1
        write_to_shared(buf2, dL_dmu1);
        block.sync();
        tmp = do_conv(buf2, H, W);
        block.sync();
        dL_dpix += tmp;

        // gradient from sigma1_sq
        write_to_shared(buf2, dL_dsigma1_sq);
        block.sync();
        // tmp = get_pix_value<CH>(img1, i, pix_y, pix_x, H, W);
        tmp = buf1[block.thread_index().y + 5][block.thread_index().x + 5];
        tmp *= 2.0f * do_conv(buf2, H, W);
        block.sync();
        dL_dpix += tmp;
        // write_to_shared(buf2, dL_dsigma1_sq * mu1);
        // block.sync();
        // tmp = -2.0f * do_conv(buf2, H, W);
        // block.sync();
        // dL_dpix += tmp;

        // gradient from sigma12
        write_to_shared(buf2, dL_dsigma12);
        block.sync();
        tmp = get_pix_value<CH>(img2, i, pix_y, pix_x, H, W);
        tmp *= do_conv(buf2, H, W);
        block.sync();
        dL_dpix += tmp;
        // write_to_shared(buf2, dL_dsigma12 * mu2);
        // block.sync();
        // tmp = - do_conv(buf2, H, W);
        // block.sync();
        // dL_dpix += tmp;

        if (in_inner_window() && pix_x < W && pix_y < H)
            dL_dimg1[i * num_pix + pix_id] = dL_dpix;
    }
}

torch::Tensor
fusedssim(
    float C1,
    float C2,
    torch::Tensor &img1,
    torch::Tensor &img2
)
{
    int H = img1.size(1);
    int W = img1.size(2);
	dim3 grid((W + BX - 1) / BX, (H + BY - 1) / BY, 1);
	dim3 block(BX, BY, 1);
	// dim3 grid((W + (BX - 10) - 1) / (BX - 10), (H + (BY - 10) - 1) / (BY - 10), 1);
	// dim3 block(BX, BY, 1);

    torch::Tensor target = torch::zeros_like(img1).contiguous();
    fusedssimCUDA<3><<<grid,block>>>(
        H,
        W,
        C1,
        C2,
        img1.contiguous().data<float>(),
        img2.contiguous().data<float>(),
        target.contiguous().data<float>()
    );

    return target;
}

torch::Tensor
fusedssim_backward(
    float C1,
    float C2,
    torch::Tensor &img1,
    torch::Tensor &img2,
    torch::Tensor &dL_dmap
)
{
    int H = img1.size(1);
    int W = img1.size(2);
	dim3 grid((W + (BX - 10) - 1) / (BX - 10), (H + (BY - 10) - 1) / (BY - 10), 1);
	dim3 block(BX, BY, 1);

    torch::Tensor dL_dimg1 = torch::zeros_like(img1).contiguous();

    fusedssim_backwardCUDA<3><<<grid,block>>>(
        H,
        W,
        C1,
        C2,
        img1.contiguous().data<float>(),
        img2.contiguous().data<float>(),
        dL_dmap.contiguous().data<float>(),
        dL_dimg1.contiguous().data<float>()
    );

    return dL_dimg1;
}