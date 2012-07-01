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

#if !defined(EF_GY_PROJECTION_H)
#define EF_GY_PROJECTION_H

#include <ef.gy/euclidian.h>
#include <ef.gy/matrix.h>
#include <ef.gy/tuple.h>

namespace efgy
{
    namespace geometry
    {
        template <typename Q, unsigned int d>
        class transformation
        {
            public:
                transformation ()
                    {}

                typename euclidian::space<Q,d>::vector operator *
                    (const typename euclidian::space<Q,d>::vector &pV)
                {
                    typename euclidian::space<Q,d>::vector rv;

                    return rv;
                }

                math::matrix<Q,d+1,d+1> transformationMatrix;
        };

        template <typename Q, unsigned int d>
        class translation : public transformation<Q,d>
        {
            public:
                using transformation<Q,d>::transformationMatrix;

                translation(const typename euclidian::space<Q,d>::vector &pFrom)
                    : from(pFrom)
                    {
                        updateMatrix();
                    }

                /* note: this formula was obtained by generalising over the 3d translation matrix.
                 */
                void updateMatrix()
                {
                    for (unsigned int i = 0; i <= d; i++)
                    {
                        for (unsigned int j = 0; j <= d; j++)
                        {
                            if ((i == d) && (j < d))
                            {
                                transformationMatrix.data[i][j] = -from.data[j];
//                                transformationMatrix.data[i][j] = 0;
                            }
                            else if (i == j)
                            {
                                transformationMatrix.data[i][j] = 1;
                            }
                            else
                            {
                                transformationMatrix.data[i][j] = 0;
                            }
                        }
                    }
                }

            protected:
                typename euclidian::space<Q,d>::vector from;
        };

        template <typename Q, unsigned int d>
        class lookAt : public transformation<Q,d>
        {
            public:
                using transformation<Q,d>::transformationMatrix;

                lookAt(typename euclidian::space<Q,d>::vector pFrom, typename euclidian::space<Q,d>::vector pTo)
                    : from(pFrom), to(pTo)
                    {
                        for (unsigned int i = 0; i < (d-2); i++)
                        {
                            for (unsigned int j = 0; j < d; j++)
                            {
                                orthogonalVector.data[i].data[j] = (((i+1) == j) ? 1 : 0);
                            }
                        }
                        updateMatrix();
                    }

                /* note: this formula was obtained by generalising over the 3d-to-2d and 4d-to-3d
                 *       lookat matrices.
                 */
                void updateMatrix()
                {
                    columns.data[(d-1)] = to - from;
                    columns.data[(d-1)] = euclidian::normalise<Q,d>(columns.data[(d-1)]);

                    for (int i = 0; i < (d-1); i++)
                    {
                        math::tuple<d-1,typename euclidian::space<Q,d>::vector> crossVectors;

                        for (int j = i - (d - 2), c = 0; c < (d-1); j++, c++)
                        {
                            if (j < 0)
                            {
                                crossVectors.data[c] = orthogonalVector.data[(j + (d - 2))];
                            }
                            else if (j == 0)
                            {
                                crossVectors.data[c] = columns.data[(d-1)];
                            }
                            else
                            {
                                crossVectors.data[c] = columns.data[(j-1)];
                            }
                        }

                        columns.data[i] = euclidian::getNormal<Q,d>(crossVectors);

                        if (i != (d-2))
                        {
                            columns.data[i] = euclidian::normalise<Q,d>(columns.data[i]);
                        }
                    }

                    for (unsigned int i = 0; i <= d; i++)
                    {
                        for (unsigned int j = 0; j <= d; j++)
                        {
                            if ((i < d) && (j < d))
                            {
                                if (j == (d-1))
                                {
                                    transformationMatrix.data[i][j] = -columns.data[i].data[j];
                                }
                                else
                                {
                                    transformationMatrix.data[i][j] = columns.data[i].data[j];
                                }
                            }
                            else if (i == j)
                            {
                                transformationMatrix.data[i][j] = 1;
                            }
                            else
                            {
                                transformationMatrix.data[i][j] = 0;
                            }
                        }
                    }
                }

                math::tuple<d,typename euclidian::space<Q,d>::vector> columns;

            protected:
                typename euclidian::space<Q,d>::vector from;
                typename euclidian::space<Q,d>::vector to;

                math::tuple<d-2, typename euclidian::space<Q,d>::vector> orthogonalVector;
        };

        template <typename Q, unsigned int d>
        class perspective : public transformation<Q,d>
        {
            public:
                using transformation<Q,d>::transformationMatrix;
            
                perspective(const Q &pNear, const Q &pFar, const Q &pAspect, Q pEyeAngle = M_PI_4)
                    : near(pNear), far(pFar), aspect(pAspect), eyeAngle(pEyeAngle)
                    {
                        updateMatrix();
                    }
            
                void updateMatrix()
                {
                    Q f = 1/tan(eyeAngle/Q(2));

                    for (unsigned int i = 0; i <= d; i++)
                    {
                        for (unsigned int j = 0; j <= d; j++)
                        {
                            if ((i == j) && (i < d))
                            {
                                transformationMatrix.data[i][j] = f;
                            }
                            else
                            {
                                transformationMatrix.data[i][j] = 0;
                            }
                        }
                    }

                    transformationMatrix.data[0][0] = f / aspect;
                    transformationMatrix.data[(d-1)][(d-1)] = (far + near) / (near - far);
                    transformationMatrix.data[(d-1)][d] = -1;
                    transformationMatrix.data[d][(d-1)] = (2 * far * near) / (near - far);
                }
            
            protected:
                Q near;
                Q far;
                Q aspect;
                Q eyeAngle;
        };

        template <typename Q, unsigned int d>
        class perspectiveProjection
        {
            public:
                perspectiveProjection(typename euclidian::space<Q,d>::vector pFrom, typename euclidian::space<Q,d>::vector pTo, Q pEyeAngle = M_PI_4)
                    : from(pFrom), to(pTo), eyeAngle(pEyeAngle), lookAtTransformation(pFrom, pTo)
                    {
                        updateMatrix();
                    }

                void updateMatrix()
                {
                    lookAtTransformation = lookAt<Q,d>(from, to);

                    translation<Q,d> translationTransformation(from);
                    perspective<Q,d> perspectiveTransformation(0.25,500,1.2,eyeAngle);

                    worldTransformation.transformationMatrix
                        //= translationTransformation.transformationMatrix
                    = lookAtTransformation.transformationMatrix;
                        // * perspectiveTransformation.transformationMatrix;

                    T = 1 / tan(eyeAngle / Q(2));
                }

                typename euclidian::space<Q,(d-1)>::vector project
                    (const typename euclidian::space<Q,d>::vector &pP) const
                {
                    typename euclidian::space<Q,(d-1)>::vector result;
#if 0
                    math::matrix<Q,1,d+1> vectorMatrix;

                    typename euclidian::space<Q,d>::vector point = pP;
                    
                    for (unsigned int i = 0; i < d; i++)
                    {
                        /*
                        if (i < (d-1))
                        {
                            vectorMatrix.data[0][i] = pP.data[i] / pP.data[(d-1)];
                        }
                        else
                         */
                        {
                            vectorMatrix.data[0][i] = point.data[i];
                        }
                    }

//                    vectorMatrix.data[0][d] = sqrt(euclidian::lengthSquared<Q,d>(pP - from));
//                    vectorMatrix.data[0][d] = 1;

                    math::matrix<Q,1,d+1> resultMatrix
                        = vectorMatrix
                        * worldTransformation.transformationMatrix;

                    Q divisor = 1;
//                    const Q divisor = (1 / tan(eyeAngle/2)) / dotProduct();

//                    divisor  = 1/atan(eyeAngle/2)/divisor;
//                    divisor *= euclidian::dotProduct<Q,d>(pP, euclidian::normalise<Q,d>(from - to));
//                    divisor *= sqrt(euclidian::lengthSquared<Q,d>(euclidian::dotProduct<Q,d>(point, euclidian::normalise<Q,d>(from - to))));
                    divisor = 1/sqrt(euclidian::lengthSquared<Q,d>(point - from));

//                    divisor *= 1/resultMatrix.data[0][d];
//                    divisor *= 1/resultMatrix.data[0][(d-1)];
//                    divisor *= atan(eyeAngle/2);
//                    divisor = 1;

                    for (unsigned int i = 0; i < (d-1); i++)
                    {
                        result.data[i]  = resultMatrix.data[0][i];
                        result.data[i] *= divisor;
                    }

/*
                    for (unsigned int i = 0; i < (d-1); i++)
                    {
                        result.data[i] =
                            (resultMatrix.data[0][i] - from.data[i]) *
                            (from.data[(d-1)] / resultMatrix.data[0][(d-1)]);

                        result.data[i]  = resultMatrix.data[0][i] / resultMatrix.data[0][d];
                        result.data[i]  = (result.data[i] - from.data[i]);
                    }
 */

#else
                    typename euclidian::space<Q,d>::vector V = pP - from;

                    Q S = T / euclidian::dotProduct<Q,d>(V, lookAtTransformation.columns.data[(d-1)]);

                    for (unsigned int i = 0; i < (d-1); i++)
                    {
                        result.data[i] = S * euclidian::dotProduct<Q,d>(V, lookAtTransformation.columns.data[i]);
                    }
#endif
                    return result;
                }

                typename euclidian::space<Q,d>::vector from;
                typename euclidian::space<Q,d>::vector to;

            protected:
                lookAt<Q,d> lookAtTransformation;
                transformation<Q,d> worldTransformation;

                Q eyeAngle;
                Q T;
            };
    };
};

#endif
