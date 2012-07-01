//
//  main.cpp
//  tesseract
//
//  Created by Magnus Deininger on 25/06/2012.
//  Copyright (c) 2012 ef.gy. All rights reserved.
//

#include <iostream>

#include <math.h>

#include <ef.gy/primitive.h>

#include <ef.gy/polytope.h>
#include <ef.gy/projection.h>
#include <ef.gy/euclidian.h>

#include <ef.gy/render-json.h>

std::stringstream JSONOutput;

typedef efgy::math::primitive<float> FP;

efgy::geometry::euclidian::space<FP,4>::vector from4, to4;
efgy::geometry::euclidian::space<FP,3>::vector from3, to3;

efgy::geometry::perspectiveProjection<FP,4> project4(from4, to4);
efgy::geometry::perspectiveProjection<FP,3> project3(from3, to3);

efgy::render::json<FP,2> render2(JSONOutput);
efgy::render::json<FP,3> render3(project3, render2);
efgy::render::json<FP,4> render4(project4, render3);

efgy::geometry::cube<FP,3,efgy::render::json<FP,3> > cube3(render3);
efgy::geometry::cube<FP,4,efgy::render::json<FP,4> > cube4(render4);

efgy::geometry::axeGraph<FP,3,efgy::render::json<FP,3> > axe3(render3);
efgy::geometry::axeGraph<FP,4,efgy::render::json<FP,4> > axe4(render4);

//efgy::geometry::sphere<FP,2,efgy::render::json<FP,3> > sphere2(render3);
efgy::geometry::sphere<FP,3,efgy::render::json<FP,4> > sphere3(render4);
//efgy::geometry::sphere<FP,4,efgy::render::json<FP,5> > sphere4(render5);

static double origin4i = M_PI_2;
static double origin4j = M_PI_2;
static double origin4k = M_PI_2;

static double origin3i = -1;
static double origin3j = 1;

std::string currentJSON;

extern "C"
{
    int updateProjection();
    const char *getProjection();
    const char *getAxisGraph3();
    const char *getAxisGraph4();
    int addOrigin3 (int, int);
    int setOrigin3 (int, int);
    int addOrigin4 (int, int, int);
    int setOrigin4 (int, int, int);
}

int updateProjection()
{
    from4.data[0] = 2.5 * cos(origin4i);
    from4.data[1] = 2.5 * sin(origin4i) * cos (origin4j);
    from4.data[2] = 2.5 * sin(origin4i) * sin (origin4j) * cos (origin4k);
    from4.data[3] = 2.5 * sin(origin4i) * sin (origin4j) * sin (origin4k);

    to4.data[0] = 0;
    to4.data[1] = 0;
    to4.data[2] = 0;
    to4.data[3] = 0;

    from3.data[0] = 2 * cos(origin3i);
    from3.data[1] = 2 * sin(origin3i) * cos (origin3j);
    from3.data[2] = 2 * sin(origin3i) * sin (origin3j);

    to3.data[0] = 0;
    to3.data[1] = 0;
    to3.data[2] = 0;

    project4.from = from4;
    project4.updateMatrix();

    project3.from = from3;
    project3.updateMatrix();

    return 0;
}

const char *getProjection()
{
    JSONOutput.str("");

    JSONOutput << "[ 'wireframe'";

//    sphere2.renderWireframe();
//    sphere3.renderWireframe();

    cube4.renderWireframe();

    JSONOutput << "]";

    currentJSON = JSONOutput.str();

    return currentJSON.c_str();
}

const char *getAxisGraph3()
{
    JSONOutput.str("");

    JSONOutput << "[ 'axisGraph3'";

    axe3.renderWireframe();

    JSONOutput << "]";

    currentJSON = JSONOutput.str();

    return currentJSON.c_str();
}

const char *getAxisGraph4()
{
    JSONOutput.str("");

    JSONOutput << "[ 'axisGraph4'";

    axe4.renderWireframe();

    JSONOutput << "]";

    currentJSON = JSONOutput.str();

    return currentJSON.c_str();
}

int addOrigin3 (int i, int j)
{
    origin3i += (double)i / 1000.f;
    origin3j += (double)j / 1000.f;

    return 0;
}

int setOrigin3 (int i, int j)
{
    origin3i = (double)i / 1000.f;
    origin3j = (double)j / 1000.f;

    return 0;
}

int addOrigin4 (int i, int j, int k)
{
    origin4i += (double)i / 1000.f;
    origin4j += (double)j / 1000.f;
    origin4k += (double)k / 1000.f;

    return 0;
}

int setOrigin4 (int i, int j, int k)
{
    origin4i = (double)i / 1000.f;
    origin4j = (double)j / 1000.f;
    origin4k = (double)k / 1000.f;

    return 0;
}

