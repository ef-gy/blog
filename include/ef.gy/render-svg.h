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

#if !defined(EF_GY_RENDER_SVG_H)
#define EF_GY_RENDER_SVG_H

#include <ef.gy/euclidian.h>
#include <ef.gy/projection.h>
#include <string>
#include <stdio.h>

namespace efgy
{
    namespace render
    {
        template<typename Q, unsigned int d>
        class svg
        {
            public:
                svg
                    (const geometry::perspectiveProjection<Q,d> &pProjection,
                     svg<Q,d-1> &pLoweRenderer)
                    : projection(pProjection), lowerRenderer(pLoweRenderer)
                    {}

                void drawLine
                    (const typename geometry::euclidian::space<Q,d>::vector &pA,
                     const typename geometry::euclidian::space<Q,d>::vector &pB) const;

                template<unsigned int q>
                void drawFace
                    (const math::tuple<q, typename geometry::euclidian::space<Q,d>::vector> &pV) const;

            protected:
                const geometry::perspectiveProjection<Q,d> &projection;
                svg<Q,d-1> &lowerRenderer;
        };

        template<typename Q>
        class svg<Q,2>
        {
            public:
                void drawLine
                    (const typename geometry::euclidian::space<Q,2>::vector &pA,
                     const typename geometry::euclidian::space<Q,2>::vector &pB);

                template<unsigned int q>
                void drawFace
                    (const math::tuple<q, typename geometry::euclidian::space<Q,2>::vector> &pV);

                std::string output;
            protected:
                Q previousX, previousY;
        };

        template<typename Q, unsigned int d>
        void svg<Q,d>::drawLine
            (const typename geometry::euclidian::space<Q,d>::vector &pA,
             const typename geometry::euclidian::space<Q,d>::vector &pB) const
        {
            typename geometry::euclidian::space<Q,d-1>::vector A;
            typename geometry::euclidian::space<Q,d-1>::vector B;

            A = projection.project(pA);
            B = projection.project(pB);

            lowerRenderer.drawLine(A, B);
        }

        template<typename Q, unsigned int d>
        template<unsigned int q>
        void svg<Q,d>::drawFace
            (const math::tuple<q, typename geometry::euclidian::space<Q,d>::vector> &pV) const
        {
            math::tuple<q, typename geometry::euclidian::space<Q,d-1>::vector> V;

            for (unsigned int i = 0; i < q; i++)
            {
                V.data[i] = projection.project(pV.data[i]);
            }

            lowerRenderer.drawFace(V);
        }

        template<typename Q>
        void svg<Q,2>::drawLine
            (const typename geometry::euclidian::space<Q,2>::vector &pA,
             const typename geometry::euclidian::space<Q,2>::vector &pB)
        {
            const double a0 = -Q(pA.data[0]);
            const double a1 = -Q(pA.data[1]);
            const double b0 = -Q(pB.data[0]);
            const double b1 = -Q(pB.data[1]);

            const double a0r = a0 - previousX;
            const double a1r = a1 - previousY;
            const double b0r = b0 - a0;
            const double b1r = b1 - a1;

            char s[1024];
            char sr[1024];
            if ((a0 == previousX) && (a1 == previousY))
            {
                if (pB.data[1] == pA.data[1])
                {
                    snprintf(s,1024,"H%g",b0);
                    snprintf(sr,1024,"h%g",b0r);
                }
                else if (pB.data[0] == pA.data[0])
                {
                    snprintf(s,1024,"V%g",b1);
                    snprintf(sr,1024,"v%g",b1r);
                }
                else
                {
                    snprintf(s,1024,"L%g,%g",b0,b1);
                    snprintf(sr,1024,"l%g,%g",b0r,b1r);
                }
            }
            else
            {
                snprintf(s,1024,"M%g,%g",a0,a1);
                snprintf(sr,1024,"m%g,%g",a0r,a1r);
                if (strlen(sr) >= strlen(s))
                {
                    output += s;
                }
                else
                {
                    output += sr;
                }

                if (pB.data[1] == pA.data[1])
                {
                    snprintf(s,1024,"H%g",b0);
                    snprintf(sr,1024,"h%g",b0r);
                }
                else if (pB.data[0] == pA.data[0])
                {
                    snprintf(s,1024,"V%g",b1);
                    snprintf(sr,1024,"v%g",b1r);
                }
                else
                {
                    snprintf(s,1024,"L%g,%g",b0,b1);
                    snprintf(sr,1024,"l%g,%g",b0r,b1r);
                }
            }
            if (strlen(sr) >= strlen(s))
            {
                output += s;
            }
            else
            {
                output += sr;
            }
            previousX = b0;
            previousY = b1;
        }

        template<typename Q>
        template<unsigned int q>
        void svg<Q,2>::drawFace
            (const math::tuple<q, typename geometry::euclidian::space<Q,2>::vector> &pV)
        {
            output += "<path d='";
            for (unsigned int i = 0; i < q; i++)
            {
                const double a0 = -Q(pV.data[i].data[0]);
                const double a1 = -Q(pV.data[i].data[1]);

                char s[1024];
                char sr[1024];
                if (i == 0)
                {
                    snprintf(s,1024,"M%g,%g",a0,a1);
                    snprintf(sr,1024,"M%g,%g",a0,a1);
                }
                else
                {
                    const double a0r = a0 + Q(pV.data[(i-1)].data[0]);
                    const double a1r = a1 + Q(pV.data[(i-1)].data[1]);

                    if (pV.data[i].data[1] == pV.data[(i-1)].data[1])
                    {
                        snprintf(s,1024,"H%g",a0);
                        snprintf(sr,1024,"h%g",a0r);
                    }
                    else if (pV.data[i].data[0] == pV.data[(i-1)].data[0])
                    {
                        snprintf(s,1024,"V%g",a1);
                        snprintf(sr,1024,"v%g",a1r);
                    }
                    else
                    {
                        snprintf(s,1024,"L%g,%g",a0,a1);
                        snprintf(sr,1024,"l%g,%g",a0r,a1r);
                    }
                }
                if (strlen(sr) >= strlen(s))
                {
                    output += s;
                }
                else
                {
                    output += sr;
                }
            }
            output += "Z'/>";
        }
    };
};

#endif
