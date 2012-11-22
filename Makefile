#all: fortune js/tesseract.js
all: fortune

fortune: src/fortune.cpp include/ef.gy/http.h
	clang++ -Iinclude/ -O2 src/fortune.cpp -lboost_system -lboost_regex -lboost_filesystem -lboost_iostreams -o fortune && strip -x fortune

js/tesseract.js: src/tesseract.cpp
	em++ -v --llvm-opts 2 --closure 1 -s EXPORTED_FUNCTIONS="['_main','_updateProjection','_getProjection','_getAxisGraph3','_getAxisGraph4','_addOrigin3','_setOrigin3','_addOrigin4','_setOrigin4','cwrap']" -Iinclude src/tesseract.cpp -o js/tesseract.js

run-fortune: fortune
	killall fortune; rm -f /var/tmp/fortune.socket && (nohup ./fortune /var/tmp/fortune.socket &) && sleep 1 && chmod a+w /var/tmp/fortune.socket
