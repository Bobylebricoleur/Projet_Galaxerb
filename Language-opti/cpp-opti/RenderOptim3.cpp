/*
 *  Copyright (c) 2022 Bertrand LE GAL
 *
 *  This software is provided 'as-is', without any express or
 *  implied warranty. In no event will the authors be held
 *  liable for any damages arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute
 *  it freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented;
 *  you must not claim that you wrote the original software.
 *  If you use this software in a product, an acknowledgment
 *  in the product documentation would be appreciated but
 *  is not required.
 *
 *  2. Altered source versions must be plainly marked as such,
 *  and must not be misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any
 *  source distribution.
 *
 */
#include "RenderOptim3.hpp"
#include <strings.h>
#include <omp.h>
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
RenderOptim3::RenderOptim3( struct galaxy g ) : galaxie( g )
{
    const int max_threads = omp_get_num_procs(); // no division by two there is no logical cores in ARM systems
    omp_set_num_threads(max_threads);

}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
RenderOptim3::RenderOptim3( Galaxy& g ) : galaxie( g )
{
    const int max_threads = omp_get_num_procs(); // no division by two there is no logical cores in ARM systems
    omp_set_num_threads(max_threads);
}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
void RenderOptim3::execute()
{
    startExec();    // this is for fps computation

    //
    // On calcule les nouvelles positions de toutes les particules
    //
    #pragma omp parallel for
    for(int i = 0; i < galaxie.size; i += 1)
    {
        float pos_xi = galaxie.pos_x[i];
        float pos_yi = galaxie.pos_y[i];
        float pos_zi = galaxie.pos_z[i];

        float accel_x = 0;
        float accel_y = 0;
        float accel_z = 0;

        for(int j = 0; j < galaxie.size; j += 1)
        {
            const float massj = galaxie.mass[j];
            const float dx = galaxie.pos_x[j] - pos_xi;
            const float dy = galaxie.pos_y[j] - pos_yi;
            const float dz = galaxie.pos_z[j] - pos_zi;
            float dij = dx * dx + dy * dy + dz * dz;
            const float dij_max = fmaxf(dij,1.0f);
            const float d = sqrtf(dij_max) * sqrtf(dij_max) * sqrtf(dij_max);
            const float inv_d3 = 1.0f / d ;
            const float d3 = 10.0f * massj * inv_d3;
            
            accel_x += (dx * d3);
            accel_y += (dy * d3);
            accel_z += (dz * d3);
            
        }
        galaxie.vel_x[i] = galaxie.vel_x[i] + (accel_x * 2.0f);
        galaxie.vel_y[i] = galaxie.vel_y[i] + (accel_y * 2.0f);
        galaxie.vel_z[i] = galaxie.vel_z[i] + (accel_z * 2.0f);

        galaxie.pos_x_new[i] = galaxie.pos_x[i] + (galaxie.vel_x[i] * dt);
        galaxie.pos_y_new[i] = galaxie.pos_y[i] + (galaxie.vel_y[i] * dt);
        galaxie.pos_z_new[i] = galaxie.pos_z[i] + (galaxie.vel_z[i] * dt);
    }

    #pragma omp parallel for
    for(int i = 0; i < galaxie.size; i += 1)
    {
        galaxie.pos_x[i] = galaxie.pos_x_new[i];
        galaxie.pos_y[i] = galaxie.pos_y_new[i];
        galaxie.pos_z[i] = galaxie.pos_z_new[i];
    }

    stopExec();    // this is for fps computation
}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
RenderOptim3::~RenderOptim3()
{

}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
Galaxy* RenderOptim3::particules()
{
    return &galaxie;
}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
