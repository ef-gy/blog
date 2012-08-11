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

#if !defined(EF_GY_RENDER_OPENGL_H)
#define EF_GY_RENDER_OPENGL_H

#include <ef.gy/euclidian.h>
#include <ef.gy/projection.h>
#include <OpenGL/OpenGL.h>
#include <GLUT/GLUT.h>

#undef GL3D
#define GL3D

namespace efgy
{
    namespace render
    {
        template<typename Q, unsigned int d>
        class opengl
        {
            public:
                opengl
                    (const geometry::perspectiveProjection<Q,d> &pProjection,
                     const opengl<Q,d-1> &pLoweRenderer)
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
                const opengl<Q,d-1> &lowerRenderer;
        };

#if defined(GL3D)
        template<typename Q>
        class opengl<Q,3>
        {
            public:
                void drawLine
                    (const typename geometry::euclidian::space<Q,3>::vector &pA,
                     const typename geometry::euclidian::space<Q,3>::vector &pB) const;

                template<unsigned int q>
                void drawFace
                    (const math::tuple<q, typename geometry::euclidian::space<Q,3>::vector> &pV) const;

            protected:
        };
#endif

        template<typename Q>
        class opengl<Q,2>
        {
            public:
                void drawLine
                    (const typename geometry::euclidian::space<Q,2>::vector &pA,
                     const typename geometry::euclidian::space<Q,2>::vector &pB) const;

                template<unsigned int q>
                void drawFace
                    (const math::tuple<q, typename geometry::euclidian::space<Q,2>::vector> &pV) const;

            protected:
        };

        template<typename Q, unsigned int d>
        void opengl<Q,d>::drawLine
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
        void opengl<Q,d>::drawFace
            (const math::tuple<q, typename geometry::euclidian::space<Q,d>::vector> &pV) const
        {
            math::tuple<q, typename geometry::euclidian::space<Q,d-1>::vector> V;

            for (unsigned int i = 0; i < q; i++)
            {
                V.data[i] = projection.project(pV.data[i]);
            }

            lowerRenderer.drawFace(V);
        }

#if defined(GL3D)
        template<typename Q>
        void opengl<Q,3>::drawLine
            (const typename geometry::euclidian::space<Q,3>::vector &pA,
             const typename geometry::euclidian::space<Q,3>::vector &pB) const
        {
            const GLdouble a0 = Q(pA.data[0]);
            const GLdouble a1 = Q(pA.data[1]);
            const GLdouble a2 = Q(pA.data[2]);
            const GLdouble b0 = Q(pB.data[0]);
            const GLdouble b1 = Q(pB.data[1]);
            const GLdouble b2 = Q(pB.data[2]);

            glBegin(GL_LINES);
            glVertex3d(a0, a1, a2);
            glVertex3d(b0, b1, b2);
            glEnd();
        }

        template<typename Q>
        template<unsigned int q>
        void opengl<Q,3>::drawFace
            (const math::tuple<q, typename geometry::euclidian::space<Q,3>::vector> &pV) const
        {
            glBegin(GL_POLYGON);
            for (unsigned int i = 0; i < q; i++)
            {
                const GLdouble a0 = Q(pV.data[i].data[0]);
                const GLdouble a1 = Q(pV.data[i].data[1]);
                const GLdouble a2 = Q(pV.data[i].data[2]);
                glVertex3d(a0, a1, a2);
            }
            glEnd();
        }
#endif

        template<typename Q>
        void opengl<Q,2>::drawLine
            (const typename geometry::euclidian::space<Q,2>::vector &pA,
             const typename geometry::euclidian::space<Q,2>::vector &pB) const
        {
            const GLdouble a0 = Q(pA.data[0]);
            const GLdouble a1 = Q(pA.data[1]);
            const GLdouble b0 = Q(pB.data[0]);
            const GLdouble b1 = Q(pB.data[1]);
            
            glBegin(GL_LINES);
            glVertex2d(a0, a1);
            glVertex2d(b0, b1);
            glEnd();
        }

        template<typename Q>
        template<unsigned int q>
        void opengl<Q,2>::drawFace
            (const math::tuple<q, typename geometry::euclidian::space<Q,2>::vector> &pV) const
        {
            glBegin(GL_POLYGON);
            for (unsigned int i = 0; i < q; i++)
            {
                const GLdouble a0 = Q(pV.data[i].data[0]);
                const GLdouble a1 = Q(pV.data[i].data[1]);
                glVertex2d(a0, a1);
            }
            glEnd();
        }
    };
};

#endif
