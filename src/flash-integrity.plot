speed=6
set yrange [0:1]
#writecount=100000
#set xrange [800000:20000000]

set xlabel "time elapsed"
set ylabel "device wear"

flashwear(size,x) = 0.5*(1+erf(((x*(speed*1000*1000*1000/10)/(size*1000*1000*1000))-writecount)/sqrt(2*((writecount*0.1)**2))))
