# ESRB Ratings
# 2013-07-02 via http://www.esrb.org/ratings/search.jsp
ESRBRatingsAges <- c(3, 6, 10, 13, 17, 18)
ESRBRatings <- c(289, 20437, 2260, 6017, 1898, 32)
ESRBRatingsT <- c(0,0,0,289,0,0,20437,0,0,0,2260,0,0,6017,0,0,0,1898,32)

# PEGI Ratings
# 2013-07-02 via http://www.pegi.info/en/index/id/509
PEGIRatingsAges <- c(3, 7, 12, 16, 18)
PEGIRatings <- c(9448, 2861, 4535, 2561, 1271)
PEGIRatingsT <- c(0,0,0,9448,0,0,0,2861,0,0,0,0,4535,0,0,0,2561,0,1271)

# USK Ratings
# 2013-07-02 via http://www.usk.de/titelsuche/titelsuche/
# absolute not not available via that frontend, so they had to be estimated
USKRatingsAges <- c(0,6,12,16,18)
USKRatings <- c(1409,461,613,342,114)*10
USKRatingsT <- c(1409,0,0,0,0,0,461,0,0,0,0,0,613,0,0,0,342,0,114)*10

# BPjM Ratings
# 2013-07-02 via http://bundespruefstelle.de/bpjm/Jugendmedienschutz/statistik,did=39254.html
BPjMRatingsAges <- c(18)
BPjMRatings <- c(658)
BPjMRatingsU <- c(0,0,0,0,658)
BPjMRatingsT <- c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,658)

AgeRange = 0:18

svg('age-rating-distribution.svg', height=6, width=12)
plot(ESRBRatingsAges,ESRBRatings,col="red",xlim=c(0,18),ylim=c(0,20000),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
title(main = "Number of Game Age Ratings as Function of Age", sub = "ESRB (red), PEGI (green), USK (blue), BPjM (black)", xlab = "Rated Age", ylab = "Number of Ratings")
axis(1,0:18)
axis(2,0:20*1000)
par(new=TRUE)
plot(PEGIRatingsAges,PEGIRatings,col="green",xlim=c(0,18),ylim=c(0,20000),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
par(new=TRUE)
plot(USKRatingsAges,USKRatings,col="blue",xlim=c(0,18),ylim=c(0,20000),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
par(new=TRUE)
plot(BPjMRatingsAges,BPjMRatings,col="black",xlim=c(0,18),ylim=c(0,20000),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
dev.off()

svg('age-rating-distribution-1.svg', height=6, width=12)
plot(0:18,cumsum(ESRBRatingsT)/sum(ESRBRatingsT),col="red",xlim=c(0,18),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
title(main = "Relative Number of Game Age Ratings as Function of Age", sub = "ESRB (red), PEGI (green), USK (blue), USK+BPjM (pink)", xlab = "Rated Age", ylab = "% of Games Available at Given Age")
axis(1,0:18)
axis(2,c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1))
par(new=TRUE)
plot(0:18,cumsum(PEGIRatingsT)/sum(PEGIRatingsT),col="green",xlim=c(0,18),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
par(new=TRUE)
plot(0:18,cumsum(USKRatingsT)/sum(USKRatingsT),col="blue",xlim=c(0,18),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
par(new=TRUE)
plot(0:18,cumsum(USKRatingsT+BPjMRatingsT)/sum(USKRatingsT+BPjMRatingsT),col="pink",xlim=c(0,18),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
dev.off()

svg('age-rating-distribution-2.svg', height=6, width=12)
plot(ESRBRatingsAges,cumsum(ESRBRatings)/sum(ESRBRatings),col="red",xlim=c(0,18),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
title(main = "Relative Number of Game Age Ratings as Function of Age", sub = "ESRB (red), PEGI (green), USK (blue), USK+BPjM (pink)", xlab = "Rated Age", ylab = "% of Games Available at Given Age")
axis(1,0:18)
axis(2,c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1))
par(new=TRUE)
plot(PEGIRatingsAges,cumsum(PEGIRatings)/sum(PEGIRatings),col="green",xlim=c(0,18),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
par(new=TRUE)
plot(USKRatingsAges,cumsum(USKRatings)/sum(USKRatings),col="blue",xlim=c(0,18),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
par(new=TRUE)
plot(USKRatingsAges,cumsum(USKRatings+BPjMRatingsU)/sum(USKRatings+BPjMRatingsU),col="pink",xlim=c(0,18),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="",type="b")
dev.off()
