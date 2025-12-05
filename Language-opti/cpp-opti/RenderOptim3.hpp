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
#ifndef _RenderOptim3_
#define _RenderOptim3_
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
#include "../Kernel.hpp"
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
class RenderOptim3 : public Kernel
{
public:
    RenderOptim3( struct galaxy g );
    RenderOptim3( Galaxy& g );

    void execute();
    void render();
    Galaxy* particules();

    ~RenderOptim3();

private:
    Galaxy galaxie;
};
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
#endif