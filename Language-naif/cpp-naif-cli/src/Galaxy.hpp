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
#ifndef _Galaxie_
#define _Galaxie_

#include <stdio.h>
#include <cstring>
#include <stdbool.h>
#include <math.h>
#include <sys/time.h>
#include <cfloat>
#include <chrono>
#include <vector>
#include <cmath>
#include <iostream>

class Galaxy
{
public:	
    Galaxy(const int _size)
    {
        std::cout << "(II) Création d'une galaxie(" << _size << ")" << std::endl;
        size      = _size;
        pos_x     = (float *)malloc(sizeof(float) * size);
        pos_y     = (float *)malloc(sizeof(float) * size);
        pos_z     = (float *)malloc(sizeof(float) * size);

        pos_x_new = (float *)malloc(sizeof(float) * size);
        pos_y_new = (float *)malloc(sizeof(float) * size);
        pos_z_new = (float *)malloc(sizeof(float) * size);

        mass      = (float *)malloc(sizeof(float) * size);

        vel_x     = (float *)malloc(sizeof(float) * size);
        vel_y     = (float *)malloc(sizeof(float) * size);
        vel_z     = (float *)malloc(sizeof(float) * size);
        color     = (int8_t*)malloc(sizeof(int8_t)* size);

        std::cout << "(II) Fin de création" << std::endl;
    }
    
    Galaxy(Galaxy& g)
    {
        std::cout << "(II) Création d'une galaxie(Galaxy& g)" << std::endl;
        size = g.size;

        pos_x = (float *)malloc(sizeof(float) * size);
        pos_y = (float *)malloc(sizeof(float) * size);
        pos_z = (float *)malloc(sizeof(float) * size);

        memcpy(pos_x, g.pos_x, sizeof(float) * size);
        memcpy(pos_y, g.pos_y, sizeof(float) * size);
        memcpy(pos_z, g.pos_z, sizeof(float) * size);

        pos_x_new = (float *)malloc(sizeof(float) * size);
        pos_y_new = (float *)malloc(sizeof(float) * size);
        pos_z_new = (float *)malloc(sizeof(float) * size);

        memcpy(pos_x_new, g.pos_x_new, sizeof(float) * size);
        memcpy(pos_y_new, g.pos_y_new, sizeof(float) * size);
        memcpy(pos_z_new, g.pos_z_new, sizeof(float) * size);

        mass = (float *)malloc(sizeof(float) * size);

        memcpy(mass, g.mass, sizeof(float) * size);

        vel_x     = (float *)malloc(sizeof(float) * size);
        vel_y     = (float *)malloc(sizeof(float) * size);
        vel_z     = (float *)malloc(sizeof(float) * size);

        memcpy(vel_x, g.vel_x, sizeof(float) * size);
        memcpy(vel_y, g.vel_y, sizeof(float) * size);
        memcpy(vel_z, g.vel_z, sizeof(float) * size);
        
        color = (int8_t*)malloc(sizeof(int8_t) * size);
        memcpy(color, g.color,  sizeof(int8_t) * size);
    }
    
    Galaxy(Galaxy* g)
    {
        std::cout << "(II) Création d'une galaxie(Galaxy* g)" << std::endl;
        size = g->size;

        pos_x = (float *)malloc(sizeof(float) * size);
        pos_y = (float *)malloc(sizeof(float) * size);
        pos_z = (float *)malloc(sizeof(float) * size);

        memcpy(pos_x, g->pos_x, sizeof(float) * size);
        memcpy(pos_y, g->pos_y, sizeof(float) * size);
        memcpy(pos_z, g->pos_z, sizeof(float) * size);

        pos_x_new = (float *)malloc(sizeof(float) * size);
        pos_y_new = (float *)malloc(sizeof(float) * size);
        pos_z_new = (float *)malloc(sizeof(float) * size);

        memcpy(pos_x_new, g->pos_x_new, sizeof(float) * size);
        memcpy(pos_y_new, g->pos_y_new, sizeof(float) * size);
        memcpy(pos_z_new, g->pos_z_new, sizeof(float) * size);

        mass = (float *)malloc(sizeof(float) * size);

        memcpy(mass, g->mass, sizeof(float) * size);

        vel_x     = (float *)malloc(sizeof(float) * size);
        vel_y     = (float *)malloc(sizeof(float) * size);
        vel_z     = (float *)malloc(sizeof(float) * size);

        memcpy(vel_x, g->vel_x, sizeof(float) * size);
        memcpy(vel_y, g->vel_y, sizeof(float) * size);
        memcpy(vel_z, g->vel_z, sizeof(float) * size);
        
        color =  (int8_t*)malloc(sizeof(int8_t) * size);
        memcpy(color, g->color,  sizeof(int8_t) * size);
    }

    ~Galaxy()
    {
        delete[] pos_x;
        delete[] pos_y;
        delete[] pos_z;

        delete[] pos_x_new;
        delete[] pos_y_new;
        delete[] pos_z_new;

        delete[] mass;

        delete[] vel_x;
        delete[] vel_y;
        delete[] vel_z;
        
        delete[] color;
    }


	void update()
    {
        for(int i = 0; i < size; i += 1)
        {
            pos_x[i] = pos_x_new[i];
            pos_y[i] = pos_y_new[i];
            pos_z[i] = pos_z_new[i];
        }
    }

    
	float* pos_x;
	float* pos_y;
	float* pos_z;
	float* mass;
	
	float* vel_x;
	float* vel_y;
	float* vel_z;

	float* pos_x_new;
	float* pos_y_new;
	float* pos_z_new;


    int8_t* color;

    int size;

    float min_mass()
    {
        if( _min_mass == FLT_MAX )
        {
            for(int i = 0; i < size; i += 1)
            {
                _min_mass = (_min_mass < mass[i]) ? _min_mass : mass[i];
            }
        }
        return _min_mass;
    }

    float max_mass()
    {
        if( _max_mass == FLT_MIN )
        {
            for(int i = 0; i < size; i += 1)
            {
                _max_mass = (_max_mass > mass[i]) ? _max_mass : mass[i];
            }
        }
        return _max_mass;
    }

    float min_x  ()
    {
        float minv = std::abs( pos_x[0] );
        for(int i = 1; i < size; i += 1)
            minv = (minv < pos_x[i]) ? minv : pos_x[i];
        return minv;
    }

    float min_y  ()
    {
        float minv = pos_y[0];
        for(int i = 1; i < size; i += 1)
            minv = (minv < pos_y[i]) ? minv : pos_y[i];
        return minv;
    }

    float min_z  ()
    {
        float minv = pos_z[0];
        for(int i = 1; i < size; i += 1)
            minv = (minv < pos_z[i]) ? minv : pos_z[i];
        return minv;
    }

    float min_xyz()
    {
        const float minx = min_x();
        const float miny = min_y();
        const float minz = min_z();
        const float mint = (minx > miny) ? minx : miny;
        return (mint > minz) ? mint : minz;
    }

    float max_x  ()
    {
        float maxv = pos_x[0];
        for(int i = 1; i < size; i += 1)
            maxv = (maxv > pos_x[i]) ? maxv : pos_x[i];
        return maxv;
    }

    float max_y  ()
    {
        float maxv = pos_y[0];
        for(int i = 1; i < size; i += 1)
            maxv = (maxv > pos_y[i]) ? maxv : pos_y[i];
        return maxv;
    }

    float max_z  ()
    {
        float maxv = pos_z[0];
        for(int i = 1; i < size; i += 1)
            maxv = (maxv > pos_z[i]) ? maxv : pos_z[i];
        return maxv;
    }

    float max_xyz()
    {
        const float maxx = max_x();
        const float maxy = max_y();
        const float maxz = max_z();
        const float maxt = (maxx > maxy) ? maxx : maxy;
        return (maxt > maxz) ? maxt : maxz;
    }

    

private:
    float _min_mass = FLT_MAX;
    float _max_mass = FLT_MIN;

};

#endif

