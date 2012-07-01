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
#include <vector>

namespace efgy
{
    namespace geometry
    {
        template <typename Q, unsigned int d>
        class polytope
        {
            public:
                polytope ()
                    {}
        };

/*
        template <typename Q, unsigned int d, typename render>
        class simplex
        {
            public:
                simplex (const render &pRenderer)
                    : renderer(pRenderer)
                    {}
            
                void renderWireframe ()
                {
                }

            protected:
                const render &renderer;
        };
 */

        template <typename Q, unsigned int d, typename render>
        class cube
        {
            public:
                cube (const render &pRenderer)
                    : renderer(pRenderer)
                    {
                        calculateObject(0.5);
                    }

                void renderWireframe ()
                {
                    for (typename std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> >::iterator it = lines.begin();
                         it != lines.end(); it++)
                    {
                        renderer.drawLine (it->data[0], it->data[1]);
                    }
                }

                void calculateObject (Q diameter)
                {
                    lines = std::vector<math::tuple<2,typename euclidian::space<Q,(d)>::vector> >();

                    std::vector<typename euclidian::space<Q,d>::vector> points;
                    
                    typename euclidian::space<Q,d>::vector A;
                    
                    points.push_back (A);
                    
                    for (unsigned int i = 0; i < d; i++)
                    {
                        std::vector<typename euclidian::space<Q,d>::vector> newPoints;
                        std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> > newLines;
                        
                        for (typename std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> >::iterator it = lines.begin();
                             it != lines.end(); it++)
                        {
                            it->data[0].data[i] = -diameter;
                            it->data[1].data[i] = -diameter;
                            
                            math::tuple<2,typename euclidian::space<Q,d>::vector> newLine = *it;
                            
                            newLine.data[0].data[i] = diameter;
                            newLine.data[1].data[i] = diameter;
                            
                            newLines.push_back(newLine);
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
                    }

//                    std::cout << "cube: " << lines.size() << "\n";
                }

            protected:
                const render &renderer;

                std::vector<math::tuple<2,typename euclidian::space<Q,d>::vector> > lines;
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

                        /*
                        for (unsigned int j = 0; j < d; j++)
                        {
                            if (i == j)
                            {
                                B.data[i] = -1;
                            }
                            else
                            {
                                B.data[j] = 0;
                            }
                        }
                         */

                        renderer.drawLine(A, B);
                    }
                }
            
            protected:
                const render &renderer;
        };

        template <typename Q, unsigned int d, typename render>
        class sphere
        {
            public:
                sphere (const render &pRenderer)
                    : renderer(pRenderer)
                    {
                        calculateObject(1.5);
                    }

                void renderWireframe ()
                {
                    for (typename std::vector<math::tuple<2,typename euclidian::space<Q,(d+1)>::vector> >::iterator it = lines.begin();
                         it != lines.end(); it++)
                    {
                        renderer.drawLine (it->data[0], it->data[1]);
                    }
                }

                void calculateObject (Q radius)
                {
                    lines = std::vector<math::tuple<2,typename euclidian::space<Q,(d+1)>::vector> >();

                    const Q step = M_PI_4 / 2;
#if 0
                    for (Q i = -Q(M_PI); i < Q(M_PI); i += step)
                    {
                        for (Q j = -Q(M_PI); j < Q(M_PI); j += step)
                        {
                            typename euclidian::space<Q,(d+1)>::vector A;
                            typename euclidian::space<Q,(d+1)>::vector B;
                            typename euclidian::space<Q,(d+1)>::vector C;

                            A.data[0] = radius * cos (i);
                            A.data[1] = radius * sin (i) * cos (j);
                            A.data[2] = radius * sin (i) * sin (j);

                            B.data[0] = radius * cos (i+step);
                            B.data[1] = radius * sin (i+step) * cos (j+step);
                            B.data[2] = radius * sin (i+step) * sin (j+step);

                            C.data[0] = radius * cos (i);
                            C.data[1] = radius * sin (i) * cos (j+step);
                            C.data[2] = radius * sin (i) * sin (j+step);

                            math::tuple<2,typename euclidian::space<Q,(d+1)>::vector> newLine;

                            newLine.data[0] = A;
                            newLine.data[1] = B;

                            lines.push_back(newLine);

                            newLine.data[0] = A;
                            newLine.data[1] = C;
                            
                            lines.push_back(newLine);
                        }
                    }
#else
                    for (Q i = -Q(M_PI); i < Q(M_PI); i += step)
                    {
                        for (Q j = -Q(M_PI); j < Q(M_PI); j += step)
                        {
                            for (Q k = -Q(M_PI); k < Q(M_PI); k += step)
                            {
                                typename euclidian::space<Q,(d+1)>::vector A;
                                typename euclidian::space<Q,(d+1)>::vector B;
                                typename euclidian::space<Q,(d+1)>::vector C;
                                typename euclidian::space<Q,(d+1)>::vector D;

                                A.data[0] = radius * cos (i);
                                A.data[1] = radius * sin (i) * cos (j);
                                A.data[2] = radius * sin (i) * sin (j) * cos (k);
                                A.data[3] = radius * sin (i) * sin (j) * sin (k);

                                B.data[0] = radius * cos (i+step);
                                B.data[1] = radius * sin (i+step) * cos (j);
                                B.data[2] = radius * sin (i+step) * sin (j) * cos (k);
                                B.data[3] = radius * sin (i+step) * sin (j) * sin (k);

                                C.data[0] = radius * cos (i);
                                C.data[1] = radius * sin (i) * cos (j+step);
                                C.data[2] = radius * sin (i) * sin (j+step) * cos (k);
                                C.data[3] = radius * sin (i) * sin (j+step) * sin (k);

                                D.data[0] = radius * cos (i);
                                D.data[1] = radius * sin (i) * cos (j);
                                D.data[2] = radius * sin (i) * sin (j) * cos (k+step);
                                D.data[3] = radius * sin (i) * sin (j) * sin (k+step);

                                math::tuple<2,typename euclidian::space<Q,(d+1)>::vector> newLine;
                                
                                newLine.data[0] = A;
                                newLine.data[1] = B;
                                
                                lines.push_back(newLine);
                                
                                newLine.data[0] = A;
                                newLine.data[1] = C;
                                
                                lines.push_back(newLine);

                                newLine.data[0] = A;
                                newLine.data[1] = D;
                                
                                lines.push_back(newLine);
                            }
                        }
                    }
#endif

//                    std::cout << "sphere: " << lines.size() << "\n";
                }

            protected:
                const render &renderer;

                std::vector<math::tuple<2,typename euclidian::space<Q,(d+1)>::vector> > lines;
        };
    };
};

#endif
