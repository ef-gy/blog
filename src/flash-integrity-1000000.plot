writecount=1000000
set title "Drive Wear After Continuous Writing to Flash Memory at 6Gb/s (w/ 8b/10b Coding) with Average Lifespan of Flash Cell Approximated at 1M Writes"
set label "1.5 years" at 46498400,0.1 point lt 1 pt 2 ps 2 offset 1,-1
set label "2.9 years" at 92996800,0.1 point lt 1 pt 2 ps 2 offset 1,-1
set label "5.9 years" at 185994000,0.1 point lt 1 pt 2 ps 2 offset 1,-1
set label "11.8 years" at 371987000,0.1 point lt 1 pt 2 ps 2 offset 1,-1
set xtics ("1 year" 31540000, "3 years" 94610000, "6 years" 189200000, "12 years" 378400000, "24 years" 756900000)
set xrange [8000000:600000000]
load "src/flash-integrity.plot"

plot flashwear(32,x) title "32GB Drive", \
     flashwear(64,x) title "64GB Drive", \
     flashwear(128,x) title "128GB Drive", \
     flashwear(256,x) title "256GB Drive", \
     0.1 title "10% Threshold"
