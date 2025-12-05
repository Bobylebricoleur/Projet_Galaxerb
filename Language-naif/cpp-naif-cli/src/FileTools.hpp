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
#pragma once
#include <string>
#include <vector>
#include <iostream>     // std::cout
#include <fstream>      // std::ifstream
#include <iomanip>   // pour std::scientific et std::setprecision
#include <sstream>      // std::stringstream
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
#include "Galaxy.hpp"
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
struct Galaxy* CreateGalaxy(const int n)
{
    Galaxy* g = new Galaxy( n );

    srand( n );
    for (unsigned long iBody = 0; iBody < n; iBody++)
    {
        // srand(iBody);
        float mi, ri, qix, qiy, qiz, vix, viy, viz;

        if (iBody == 0) {
            mi = 2.0e24;
            ri  = 0.0e6;
            qix = 0.0;
            qiy = 0.0;
            qiz = 0.0;
            vix = 0;
            viy = 0;
            viz = 0;
        }
        else {
            mi = ((rand() / (float)RAND_MAX) * 5e20);
            ri = mi * 2.5e-15;

            float horizontalAngle = ((RAND_MAX - rand()) / (float)(RAND_MAX)) * 2.0 * M_PI;
            float verticalAngle   = ((RAND_MAX - rand()) / (float)(RAND_MAX)) * 2.0 * M_PI;
            float distToCenter    = ((RAND_MAX - rand()) / (float)(RAND_MAX)) * 1.0e8 + 1.0e8;

            qix = std::cos(verticalAngle) * std::sin(horizontalAngle) * distToCenter;
            qiy = std::sin(verticalAngle) * distToCenter;
            qiz = std::cos(verticalAngle) * std::cos(horizontalAngle) * distToCenter;

            vix =  qiy * 4.0e-6;
            viy = -qix * 4.0e-6;
            viz = 0.0e2;
        }

        g->pos_x[iBody] = qix;
        g->pos_y[iBody] = qiy;
        g->pos_z[iBody] = qiz;
        g->vel_x[iBody] = vix;
        g->vel_y[iBody] = viy;
        g->vel_z[iBody] = viz;
        g->mass [iBody] = mi;
        g->color[iBody] = 200;
    }

    return g;
}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
Galaxy* load_tab_from_file(const std::string filename, const int step)
{
    //
    // On cree la structure pour la galaxie
    //
    std::ifstream ifile( filename );
    if( ifile.is_open() == false )
    {
        std::cout << "(EE) Error opening file (" << filename << ")" << std::endl;
        exit( EXIT_FAILURE );
    }
    //
    // On lit les lignes du fichier une par une mais on filtre step by step
    //
    std::vector<std::string> liste;
    int lineNumber = 0;
    std::string line;
    while( std::getline(ifile, line) )
    {
        if( lineNumber%step == 0 )
        {
            liste.push_back( line );
        }
        lineNumber += 1;
    }
    //
    //
    /////////////////////////////////////////////////////////////////////////////
    //
    //
    if( liste.size() == 0 )
    {
        std::cout << "(EE) Error the file is empty, no particule is loaded" << std::endl;
        exit( EXIT_FAILURE );
    }
    //
    // On parse les lignes apres les autres et on charge la structure
    //
    Galaxy* g = new Galaxy( liste.size() );
    
    for(int i = 0; i < (int)liste.size(); i += 1)
    {
        std::string buffer;
        std::stringstream ss( liste[i] );
        std::getline(ss, buffer, ' '); g->mass [i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->pos_x[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->pos_y[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->pos_z[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->vel_x[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->vel_y[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->vel_z[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->color[i] = std::stoi( buffer );
    }
    //
    // ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... 
    //
#if 0
    std::cout << "(II) The puncturing is set to (" << step << ")"   << std::endl;
    std::cout << "(II) The file was loaded (" << filename << ")"   << std::endl;
    std::cout << "(II) # of particules in file = " << lineNumber   << std::endl;
    std::cout << "(II) # of loaded particules  = " << liste.size() << std::endl;
#endif
    return g;
}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
Galaxy* load_gxy_from_file(const std::string filename, const int step)
{
    //
    // On cree la structure pour la galaxie
    //
    std::ifstream ifile( filename );
    if( ifile.is_open() == false )
    {
        std::cout << "(EE) Error opening file (" << filename << ")" << std::endl;
        exit( EXIT_FAILURE );
    }


    //
    // On lit les lignes du fichier une par une mais on filtre step by step
    //


    std::vector<std::string> liste;
    int lineNumber = 0;
    std::string line;
    while( std::getline(ifile, line) )
    {
        if( lineNumber%step == 0 )
        {
            liste.push_back( line );
        }
        lineNumber += 1;
    }

    if( liste.size() == 0 )
    {
        std::cout << "(EE) Error the file is empty, no particule is loaded" << std::endl;
        exit( EXIT_FAILURE );
    }

    //
    // On parse les lignes apres les autres et on charge la structure
    //
    Galaxy* g = new Galaxy( liste.size() );
    for(int i = 0; i < (int)liste.size(); i += 1)
    {
        std::string buffer;
        std::stringstream ss( liste[i] );

        std::getline(ss, buffer, ' '); g->pos_x[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->pos_y[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->pos_z[i] = std::stof( buffer );

        std::getline(ss, buffer, ' '); g->vel_x[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->vel_y[i] = std::stof( buffer );
        std::getline(ss, buffer, ' '); g->vel_z[i] = std::stof( buffer );

        std::getline(ss, buffer, ' '); g->mass [i] = std::stof( buffer );

        std::getline(ss, buffer, ' '); g->color[i] = std::stoi( buffer );
#if 0
        printf("%1.3f | ", g->mass [i]);
        printf("%1.3f | %1.3f | %1.3f | ",  g->pos_x[i], g->pos_y[i], g->pos_y[i]);
        printf("%1.3f | %1.3f | %1.3f |\n", g->vel_x[i], g->vel_y[i], g->vel_z[i]);
#endif
    }


    //
    // ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...
    //
#if 0
    std::cout << "(II) The puncturing is set to (" << step << ")"   << std::endl;
    std::cout << "(II) The file was loaded (" << filename << ")"   << std::endl;
    std::cout << "(II) # of particules in file = " << lineNumber   << std::endl;
    std::cout << "(II) # of loaded particules  = " << liste.size() << std::endl;
#endif
    return g;
}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
Galaxy* load_from_file(const std::string filename, const int step)
{
    if( filename.find(".gxy") != std::string::npos )
    {
        return load_gxy_from_file(filename, step);
    }
    else if( filename.find(".tab") != std::string::npos )
    {
        return load_tab_from_file(filename, step);
    }
    else
    {
        std::cout << "(EE) The file format is not yet supported " << filename << std::endl;
        exit( EXIT_FAILURE );
    }
}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
void save_to_file(const Galaxy* g, const std::string& filename, const std::string& fmt = "tab")
{
    std::ofstream ofile(filename);
    if (!ofile.is_open())
    {
        std::cerr << "(EE) Impossible d'ouvrir le fichier en écriture : " << filename << std::endl;
        return;
    }

    // On force l'écriture en notation scientifique avec 8 chiffres significatifs
    ofile << std::scientific << std::setprecision(8) << std::showpos;

    for (int i = 0; i < g->size; i++)
    {
        if (fmt == "tab")
        {
            ofile << std::setw(15) << g->mass[i]  << " "
                  << std::setw(15) << g->pos_x[i] << " "
                  << std::setw(15) << g->pos_y[i] << " "
                  << std::setw(15) << g->pos_z[i] << " "
                  << std::setw(15) << g->vel_x[i] << " "
                  << std::setw(15) << g->vel_y[i] << " "
                  << std::setw(15) << g->vel_z[i] << " "
                  << std::noshowpos << std::setw(6) << (int)g->color[i] << std::showpos
                  << "\n";
        }
        else if (fmt == "gxy")
        {
            //cout << "chaine de caractere gxy" << v_char << " " << v_int << " " << v_float << endl;
            
            //printf("chaine de caractere gxy %c %d %f\n", v_char, v_int, v_float);

            ofile << std::setw(15) << g->pos_x[i] << " "
                  << std::setw(15) << g->pos_y[i] << " "
                  << std::setw(15) << g->pos_z[i] << " "
                  << std::setw(15) << g->vel_x[i] << " "
                  << std::setw(15) << g->vel_y[i] << " "
                  << std::setw(15) << g->vel_z[i] << " "
                  << std::setw(15) << g->mass[i]  << " "
                  << std::noshowpos << std::setw(6) << (int)g->color[i] << std::showpos
                  << "\n";
        }
        else
        {
            std::cerr << "(EE) Format non supporté : " << fmt << std::endl;
            ofile.close();
            return;
        }
    }

    ofile.close();
    std::cout << "(II) Galaxie sauvegardée dans " << filename << " (format " << fmt << ")" << std::endl;
}
//
//
//
/////////////////////////////////////////////////////////////////////////////
//
//
//
