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

#include <ef.gy/http.h>

#include <cstdlib>

#include <iostream>
#include <boost/regex.hpp>
#include <boost/algorithm/string/replace.hpp>
#include <boost/iostreams/device/mapped_file.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/fstream.hpp>

using namespace boost::filesystem; 
using namespace boost::iostreams;
using namespace boost::asio;
using namespace boost;
using namespace std;

map<string, mapped_file_source> fortuneData;

class cookie
{
    public:
        enum encoding { ePlain, eROT13 } encoding;
        string file;
        size_t offset;
        size_t length;

        cookie (enum encoding pE, const string &pFile, size_t pOffset, size_t pLength)
            : encoding(pE), file(pFile), offset(pOffset), length(pLength)
            {}

        operator string (void) const
        {
            string r(fortuneData[file].data() + offset, length);

            if (encoding == eROT13)
            {
                for (size_t i = 0; i < r.size(); i++)
                {
                    char c = r[i];

                    switch (c)
                    {
                        case 'a':
                        case 'b':
                        case 'c':
                        case 'd':
                        case 'e':
                        case 'f':
                        case 'g':
                        case 'h':
                        case 'i':
                        case 'j':
                        case 'k':
                        case 'l':
                        case 'm':
                        case 'A':
                        case 'B':
                        case 'C':
                        case 'D':
                        case 'E':
                        case 'F':
                        case 'G':
                        case 'H':
                        case 'I':
                        case 'J':
                        case 'K':
                        case 'L':
                        case 'M':
                            r[i] = c + 13;
                            break;
                        case 'n':
                        case 'o':
                        case 'p':
                        case 'q':
                        case 'r':
                        case 's':
                        case 't':
                        case 'u':
                        case 'v':
                        case 'w':
                        case 'x':
                        case 'y':
                        case 'z':
                        case 'N':
                        case 'O':
                        case 'P':
                        case 'Q':
                        case 'R':
                        case 'S':
                        case 'T':
                        case 'U':
                        case 'V':
                        case 'W':
                        case 'X':
                        case 'Y':
                        case 'Z':
                            r[i] = c - 13;
                            break;
                        default:
                            break;
                    }
                }
            }

            return r;
        }
};

vector<cookie> cookies;

bool prepareFortunes
    (const string &pInoffensive = "/usr/share/games/fortunes/",
     const string &pOffensive = "/usr/share/games/fortunes/off/")
{
    static const regex dataFile(".*/[a-zA-Z-]+");
    smatch matches;

    for (unsigned int q = 0; q < 2; q++)
    {
        string dir = (q == 0) ? pInoffensive : pOffensive;
        bool doROT13 = (q == 1);

        if (exists (dir))
        {
            directory_iterator end;
            for (directory_iterator iter(dir); iter != end; ++iter)
            {
                if (is_regular(*iter))
                {
                    string e = iter->path().string();

                    if (regex_match(e, matches, dataFile))
                    {
                        fortuneData[e] = mapped_file_source(e);

                        const mapped_file_source &p = fortuneData[e];
                        const char *data = p.data();
                        size_t start = 0;
                        enum { stN, stNL, stNLP } state = stN;

                        for (size_t c = 0; c < p.size(); c++)
                        {
                            switch (data[c])
                            {
                                case '\n':
                                    switch (state)
                                    {
                                        case stN:
                                            state = stNL;
                                            break;
                                        case stNLP:
                                            cookies.push_back
                                                (cookie((doROT13 ? cookie::eROT13 : cookie::ePlain),
                                                 e, start, c - start - 1));
                                            start = c+1;
                                        default:
                                            state = stN;
                                            break;
                                    }
                                    break;

                                case '%':
                                    switch (state)
                                    {
                                        case stNL:
                                            state = stNLP;
                                            break;
                                        default:
                                            state = stN;
                                            break;
                                    }
                                    break;

                                case '\r':
                                    break;

                                default:
                                    state = stN;
                                    break;
                            }
                        }
                    }
                }
            }
        }
    }

    return true;
}

class processFortune
{
    public:
        bool operator () (efgy::net::http::session<processFortune> &a)
        {
            const int id = rand() % cookies.size();
            const cookie &c = cookies[id];
            char nbuf[20];
            snprintf (nbuf, 20, "%i", id);
            string sc = string(c);

            /* note: this escaping is not exactly efficient, but it's fairly simple
               and the strings are fairly short, so it shouldn't be much of an issue. */
            for (char i = 0; i < 0x20; i++)
            {
                if ((i == '\n') || (i == '\t'))
                {
                    continue;
                }
                const char org [2] = { i, 0 };
                const char rep [3] = { '^', (('A'-1) + i), 0 };
                replace_all (sc, org, rep);
            }

            sc = "<![CDATA[" + sc + "]]>";

            a.reply (200,
                     "Content-Type: text/xml; charset=utf-8\r\n",
                     string("<?xml version='1.0' encoding='utf-8'?>"
                            "<fortune xmlns='http://ef.gy/2012/fortune' quoteID='")
                     + nbuf + "' sourceFile='"
                     + c.file + "'>"
                     + sc
                     + "</fortune>");

            return true;
        }
};

int main (int argc, char* argv[])
{
    prepareFortunes();

    cerr << cookies.size() << " cookie(s) loaded\n";

    srand(time(0));

    cerr << string(cookies[(rand() % cookies.size())]);

    try
    {
        if (argc != 2)
        {
            std::cerr << "Usage: fortune <socket>\n";
            return 1;
        }

        boost::asio::io_service io_service;

        efgy::net::http::server<processFortune> s(io_service, argv[1]);

        io_service.run();
    }
    catch (std::exception &e)
    {
        std::cerr << "Exception: " << e.what() << "\n";
    }

    return 0;
}
