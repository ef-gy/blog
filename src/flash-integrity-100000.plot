writecount=100000
set title "Drive Wear After Continuous Writing to Flash Memory at 6Gb/s (w/ 8b/10b Coding) with Average Lifespan of Flash Cell Approximated at 100k Writes"
set xtics ("1 month" 2628000, "3 months" 7884000, "6 months" 15770000, "1 year" 31540000, "3 years" 94610000, "6 years" 189200000)
set label "53 days"  at 4649840,0.1 point lt 1 pt 2 ps 2 offset 1,-1
set label "108 days" at 9299680,0.1 point lt 1 pt 2 ps 2 offset 1,-1
set label "215 days" at 18599400,0.1 point lt 1 pt 2 ps 2 offset 1,-1
set label "430 days" at 37198700,0.1 point lt 1 pt 2 ps 2 offset 1,-1
set xrange [800000:60000000]
load "src/flash-integrity.plot"

plot flashwear(32,x) title "32GB Drive", \
     flashwear(64,x) title "64GB Drive", \
     flashwear(128,x) title "128GB Drive", \
     flashwear(256,x) title "256GB Drive", \
     0.1 title "10% Threshold"
