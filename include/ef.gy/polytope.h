/*
 * This file is part of the ef.gy project.
 * See the appropriate repository at http://ef.gy/.git for exact file
 * modification records.
*/

/*
 * Copyright (c) 2012, ef.gy Project Members
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
*/

#if !defined(EF_GY_POLYTOPE_H)
#define EF_GY_POLYTOPE_H

#include <ef.gy/euclidian.h>
#include <ef.gy/polar.h>
#include <vector>

namespace efgy
{
    namespace geometry
    {
        template <typename Q, unsigned int d, unsigned int f, typename render>
        class polytope
        {
            public:
                polytope (const render &pRenderer)
                    : renderer(pRenderer)
                    {}

                void renderWireframe () const
                {
                    for (typename std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> >::const_iterator it = lines.begin();
                         it != lines.end(); it++)
                    {
                        renderer.drawLine (it->data[0], it->data[1]);
                    }
                }

                void renderSolid () const
                {
                    for (typename std::vector<math::tuple<f,typename euclidian::space<Q,d>::vector> >::const_iterator it = faces.begin();
                         it != faces.end(); it++)
                    {
                        renderer.drawFace (*it);
                    }
                }

            protected:
                const render &renderer;

                std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> > lines;
                std::vector<math::tuple<f,typename euclidian::space<Q,d>::vector> > faces;
        };

        template <typename Q, unsigned int d, typename render>
        class simplex : public polytope<Q,d,3,render>
        {
            public:
                simplex (const render &pRenderer)
                    : polytope<Q,d,3,render>(pRenderer)
                    {
                        calculateObject(0.8);
                    }

                using polytope<Q,d,3,render>::renderWireframe;
                using polytope<Q,d,3,render>::renderSolid;
                using polytope<Q,d,3,render>::renderer;
                using polytope<Q,d,3,render>::lines;
                using polytope<Q,d,3,render>::faces;

                void recurse (const int r, typename polar::space<Q,d>::vector v, std::vector<typename euclidian::space<Q,d>::vector> &points)
                {
                    if (r == 0)
                    {
                        typename euclidian::space<Q,d>::vector A = v;
                        points.push_back(A);
                    }
                    else
                    {
                        const int q = r-1;

                        v.data[r] = 0;
                        recurse (q, v, points);
                        v.data[r] = M_PI/1.5;
                        recurse (q, v, points);
                    }
                }

                void calculateObject (Q radius)
                {
                    lines = std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> >();
                    faces = std::vector<math::tuple<3,typename euclidian::space<Q,d>::vector> >();

                    std::vector<typename euclidian::space<Q,d>::vector> points;

                    typename polar::space<Q,d>::vector v;
                    v.data[0] = radius;
                    
                    const int r = d-1;
                    const int q = r-1;

                    v.data[r] = -M_PI/1.5;
                    recurse (q, v, points);
                    v.data[r] = 0;
                    recurse (q, v, points);
                    v.data[r] = M_PI/1.5;
                    recurse (q, v, points);

                    std::vector<typename euclidian::space<Q,d>::vector> points2;

                    for (typename std::vector<typename euclidian::space<Q,d>::vector>::iterator it1 = points.begin();
                         it1 != points.end(); it1++)
                    {
                        bool pointInSet = false;

                        for (typename std::vector<typename euclidian::space<Q,d>::vector>::iterator it2 = points2.begin();
                             it2 != points2.end(); it2++)
                        {
                            if (*it1 == *it2)
                            {
                                pointInSet = true;
                                break;
                            }
                        }

                        if (!pointInSet)
                        {
                            points2.push_back (*it1);
                        }
                    }

                    points = points2;

                    std::vector<typename euclidian::space<Q,d>::vector> usedPoints;

                    for (typename std::vector<typename euclidian::space<Q,d>::vector>::iterator it1 = points.begin();
                         it1 != points.end(); it1++)
                    {
                        const typename euclidian::space<Q,d>::vector A = *it1;

                        std::vector<typename euclidian::space<Q,d>::vector> usedPoints2;

                        for (typename std::vector<typename euclidian::space<Q,d>::vector>::iterator it2 = usedPoints.begin();
                             it2 != usedPoints.end(); it2++)
                        {
                            const typename euclidian::space<Q,d>::vector B = *it2;

                            math::tuple<2,typename euclidian::space<Q,d>::vector> newLine;
                            newLine.data[0] = A;
                            newLine.data[1] = B;

                            lines.push_back(newLine);

                            for (typename std::vector<typename euclidian::space<Q,d>::vector>::iterator it3 = usedPoints2.begin();
                                 it3 != usedPoints2.end(); it3++)
                            {
                                const typename euclidian::space<Q,d>::vector C = *it3;

                                math::tuple<3,typename euclidian::space<Q,d>::vector> newTriangle;
                                newTriangle.data[0] = A;
                                newTriangle.data[1] = B;
                                newTriangle.data[2] = C;
                                faces.push_back(newTriangle);
                            }

                            usedPoints2.push_back(B);
                        }

                        usedPoints.push_back(A);
                    }
                }
        };

        template <typename Q, unsigned int d, typename render>
        class cube : public polytope<Q,d,4,render>
        {
            public:
                cube (const render &pRenderer)
                    : polytope<Q,d,4,render>(pRenderer)
                    {
                        calculateObject(0.5);
                    }

                using polytope<Q,d,4,render>::renderWireframe;
                using polytope<Q,d,4,render>::renderSolid;
                using polytope<Q,d,4,render>::renderer;
                using polytope<Q,d,4,render>::lines;
                using polytope<Q,d,4,render>::faces;

                void calculateObject (Q diameter)
                {
                    lines = std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> >();
                    faces = std::vector<math::tuple<4,typename euclidian::space<Q,d>::vector> >();

                    std::vector<typename euclidian::space<Q,d>::vector> points;

                    typename euclidian::space<Q,d>::vector A;
                    
                    points.push_back (A);
                    
                    for (unsigned int i = 0; i < d; i++)
                    {
                        std::vector<typename euclidian::space<Q,d>::vector> newPoints;
                        std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> > newLines;
                        std::vector<math::tuple<4,typename euclidian::space<Q,d>::vector> > newFaces;

                        for (typename std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> >::iterator it = lines.begin();
                             it != lines.end(); it++)
                        {
                            it->data[0].data[i] = -diameter;
                            it->data[1].data[i] = -diameter;

                            math::tuple<2,typename euclidian::space<Q,d>::vector> newLine = *it;

                            newLine.data[0].data[i] = diameter;
                            newLine.data[1].data[i] = diameter;

                            newLines.push_back(newLine);

                            math::tuple<4,typename euclidian::space<Q,d>::vector> newFace;
                            newFace.data[0] = newLine.data [0];
                            newFace.data[1] = newLine.data [1];
                            newFace.data[2] = it->data     [1];
                            newFace.data[3] = it->data     [0];
                            newFaces.push_back(newFace);
                        }

                        for (typename std::vector<math::tuple<4,typename euclidian::space<Q,d>::vector> >::iterator it = faces.begin();
                             it != faces.end(); it++)
                        {
                            it->data[0].data[i] = -diameter;
                            it->data[1].data[i] = -diameter;
                            it->data[2].data[i] = -diameter;
                            it->data[3].data[i] = -diameter;

                            math::tuple<4,typename euclidian::space<Q,d>::vector> newFace = *it;
                            newFace.data[0].data[i] = diameter;
                            newFace.data[1].data[i] = diameter;
                            newFace.data[2].data[i] = diameter;
                            newFace.data[3].data[i] = diameter;
                            newFaces.push_back(newFace);
                        }

                        for (typename std::vector<typename euclidian::space<Q,d>::vector>::iterator it = points.begin();
                             it != points.end(); it++)
                        {
                            math::tuple<2,typename euclidian::space<Q,d>::vector> newLine;
                            
                            it->data[i] = -diameter;
                            
                            newLine.data[0] = *it;
                            newLine.data[1] = *it;
                            newLine.data[1].data[i] = diameter;
                            
                            newPoints.push_back(newLine.data[1]);
                            
                            lines.push_back(newLine);
                        }
                        
                        for (typename std::vector<typename euclidian::space<Q,d>::vector>::iterator it = newPoints.begin();
                             it != newPoints.end(); it++)
                        {
                            points.push_back(*it);
                        }

                        for (typename std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> >::iterator it = newLines.begin();
                             it != newLines.end(); it++)
                        {
                            lines.push_back(*it);
                        }

                        for (typename std::vector<math::tuple<4,typename euclidian::space<Q,d>::vector> >::iterator it = newFaces.begin();
                             it != newFaces.end(); it++)
                        {
                            faces.push_back(*it);
                        }
                    }
                }
        };

        template <typename Q, unsigned int d, typename render>
        class axeGraph
        {
            public:
                axeGraph (const render &pRenderer)
                    : renderer(pRenderer)
                    {}
            
                void renderWireframe ()
                {
                    typename euclidian::space<Q,d>::vector A;
                    typename euclidian::space<Q,d>::vector B;

                    std::vector<typename euclidian::space<Q,d>::vector> points;
                    std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> > lines;

                    for (unsigned int i = 0; i < d; i++)
                    {
                        for (unsigned int j = 0; j < d; j++)
                        {
                            if (i == j)
                            {
                                A.data[i] = 1;
                            }
                            else
                            {
                                A.data[j] = 0;
                            }
                        }

                        renderer.drawLine(A, B);
                    }
                }
            
            protected:
                const render &renderer;
        };

        template <typename Q, unsigned int d, typename render>
        class sphere : public polytope<Q,(d+1),3,render>
        {
            public:
                sphere (const render &pRenderer, const Q &pRadius, const Q pStep = 5)
                    : polytope<Q,(d+1),3,render>(pRenderer), step(Q(M_PI) / pStep)
                    {
                        calculateObject(pRadius);
                    }

                using polytope<Q,(d+1),3,render>::renderWireframe;
                using polytope<Q,(d+1),3,render>::renderSolid;
                using polytope<Q,(d+1),3,render>::renderer;
                using polytope<Q,(d+1),3,render>::lines;
                using polytope<Q,(d+1),3,render>::faces;

                void recurse (const int r, typename polar::space<Q,(d+1)>::vector v)
                {
                    if (r == 0)
                    {
                        const typename euclidian::space<Q,(d+1)>::vector A = v;

                        for (unsigned int i = 1; i <= d; i++)
                        {
                            typename polar::space<Q,(d+1)>::vector v1 = v;

                            v1.data[i] += step;

                            const typename euclidian::space<Q,(d+1)>::vector B = v1;

                            math::tuple<2,typename euclidian::space<Q,(d+1)>::vector> newLine;

                            newLine.data[0] = A;
                            newLine.data[1] = B;

                            lines.push_back(newLine);

                            math::tuple<3,typename euclidian::space<Q,(d+1)>::vector> newFace;

                            newFace.data[0] = A;
                            newFace.data[1] = B;

                            for (unsigned int j = 1; j <= d; j++)
                            {
                                if (i != j)
                                {
                                    v1 = v;
                                    v1.data[j] -= step;

                                    const typename euclidian::space<Q,(d+1)>::vector C = v1;
                                    newFace.data[2] = C;

                                    faces.push_back(newFace);
                                }
                            }
                        }
                    }
                    else
                    {
                        const int q = r-1;

                        for (Q i = -M_PI; i < M_PI; i+= step)
                        {
                            v.data[r] = i;
                            recurse (q, v);
                        }
                    }
                }

                void calculateObject (Q radius, Q pStep)
                {
                    Q usedPrecision = pStep;

                    step = Q(M_PI) / pStep;
                    calculateObject(radius);
                }

                void calculateObject (Q radius)
                {
                    Q usedRadius = radius;

                    lines = std::vector<math::tuple<2,typename euclidian::space<Q,(d+1)>::vector> >();
                    faces = std::vector<math::tuple<3,typename euclidian::space<Q,(d+1)>::vector> >();

                    typename polar::space<Q,(d+1)>::vector v;
                    v.data[0] = radius;

                    const int r = d;
                    const int q = r-1;

                    for (Q i = -M_PI; i < M_PI; i+= step)
                    {
                        v.data[r] = i;
                        recurse (q, v);
                    }
                }

                Q usedRadius;
                Q usedPrecision;

            protected:
                Q step;
        };
    };
};

#endif
