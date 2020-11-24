#################################################################################
####################################  BT549 Cells  ##############################
#################################################################################


################## Needed packages
install.packages("ggplot2")
install.packages("tidyverse")
install.packages("igraph")

library(tidyverse)
library(igraph)
library(ggplot2)
##################



################# Needed data
# All the needed data are available at: https://github.com/ocbe-uio/CellMAPtracer/tree/master/Data/BT549%20tracking%20data
##################



# The notebook consists of four  sections


###########################################################################################################
################### Sction # 1: Studying Dividing Daughter Cells
###########################################################################################################


############ Loading the data after converting each file into csv
df1<- read.table(file.choose(),sep=",",header=T)     #### A3_1_Feb12 Dividing Daughter Cells.csv
df2<- read.table(file.choose(),sep=",",header=T)     #### A3_2_Feb12 Dividing Daughter Cells.csv
df3<- read.table(file.choose(),sep=",",header=T)     #### C10_2_Feb12 Dividing Daughter Cells.csv
df<-rbind(df1,df2,df3)
head(df)
dim(df)

############## Computing the doubling time of BT549 cells
TrajectoryTime<-df[,9]/60
sd(TrajectoryTime)
summary(TrajectoryTime)
# Computing the mode of the doubling time 
getmode <- function(v) {
   uniqv <- unique(v)
   uniqv[which.max(tabulate(match(v, uniqv)))]
}
result <- getmode(TrajectoryTime)
print(result)


#################### Plotting the density of the doubling time 
x <- TrajectoryTime
hx5 <- TrajectoryTime
dens <- density(hx5, cut=10)
n <- length(dens$y)                       #
dx <- mean(diff(dens$x))                  # Typical spacing in x 
y.unit <- sum(dens$y) * dx                # Check: this should integrate to 1 
dx <- dx / y.unit                         # Make a minor adjustment
x.mean <- sum(dens$y * dens$x) * dx
y.mean <- dens$y[length(dens$x[dens$x < x.mean])]
x.mode <- dens$x[i.mode <- which.max(dens$y)]
y.mode <- dens$y[i.mode]                  
y.cs <- cumsum(dens$y)                    
x.med <- dens$x[i.med <- length(y.cs[2*y.cs <= y.cs[n]])] 
y.med <- dens$y[i.med]                                    
#
# Plotting the density and the statistics.
plot(dens, type="l", col="black",lwd=0.1,xlim=c(0,72),cex=1.5,cex.lab=1.3, cex.axis=1.3,
     xlab="The doubling time of BT549 cells (h)")
polygon(dens, col="black")
temp <- mapply(function(x,y,c) lines(c(x,x), c(0,y), lwd=2, col=c,las=1), 
               c(x.mean, x.med, x.mode), c(y.mean, y.med, y.mode), c("orange", "Green", "Red"))
legend(43, 0.047, c("Doubling Time Density", "Mode", "Median", "Mean"), col = c("black","Red","green", "orange"),
       text.col = "black", lty = 1,lwd=2,cex = 0.65,merge = TRUE)


###############  Characterizing the trajectory movement of a population of Dividing Daughter BT549 cells

######### Directionality
Directionality=df[,10]
summary(Directionality)
sd(Directionality)
Group= c(rep(1,length(Directionality)))
Da<-data.frame(Directionality,Group)
data_summary <- function(x) {     ######  Add mean and standard deviation within violin plot
   m <- mean(x)
   ymin <- m-sd(x)
   ymax <- m+sd(x)
   return(c(y=m,ymin=ymin,ymax=ymax))
}
p <- ggplot(Da, aes(x=Group, y=Directionality)) + 
    geom_violin(trim=FALSE,fill="lightgreen")+ geom_point(size=2.5,color="black")
p + stat_summary(fun.data=data_summary, geom="pointrange", color="red",size = 1)

########### Speed
Average_Speed=df[,11]*60
summary(Average_Speed)
sd(Average_Speed)
Group= c(rep(1,length(Average_Speed)))
Da<-data.frame(Average_Speed,Group)
data_summary <- function(x) {
   m <- mean(x)
   ymin <- m-sd(x)
   ymax <- m+sd(x)
   return(c(y=m,ymin=ymin,ymax=ymax))
}
p <- ggplot(Da, aes(x=Group, y=Average_Speed)) + 
    geom_violin(trim=FALSE,fill="yellow")+ geom_point(size=2.5,color="black")
p + stat_summary(fun.data=data_summary,geom="pointrange", color="red",size = 1)

####################################  Correlation Analysis

#################################### Finding the correlation between doubling time and Total Distance
DT=df[,9]/60    # doubling time
f=df[,7]        # Total Distance
ff<-as.numeric(gsub(",", ".", f))
plot(DT,f,xlab="Doubling time (h)",ylab="Total Distance (um)",pch=16,las=0,cex=1.5,cex.lab=1.3, cex.axis=1.3)
c<-cor.test( ~ DT+ ff, method = "pearson",exact=FALSE)
c 
reg<-lm(ff~DT)
cc<-unlist(c[4])
ccPV<-round(cc, digits = 2)
abline(reg,untf=T,col="red",lwd=2) 
text(18, 1875, "r= 0.62",cex = 1.5)
text(19, 1750, "P< 0.001",cex = 1.5)



############### Finding the correlation between doubling time and Directionality
DT=df[,9]/60    # doubling time
f=df[,10]       # Directionality
plot(DT,f,xlab="Doubling time (h)",ylab="Directionality",pch=16,las=1,ylim=c(0,.65))
c<-cor.test( ~ DT+ f, method = "pearson",exact=FALSE) 
c
reg<-lm(f~DT)
cc<-unlist(c[4])
ccPV<-round(cc, digits = 2)
abline(reg,untf=T,col="red",lwd=2) 
text(19, 0.65, "r= -0.14",cex = 1)
text(19.4, 0.6, "P= 0.057",cex = 1)



############### Finding the correlation between doubling time and Average Speed
DT=df[,9]/60    # doubling time
f=df[,11]*60    # Average Speed
plot(DT,f,xlab="Doubling time (h)",ylab="Average Speed (um/h)",pch=16,las=1,ylim=c(10,60))
c<-cor.test( ~ DT+ f, method = "pearson",exact=FALSE) 
c
reg<-lm(f~DT)
cc<-unlist(c[4])
ccPV<-round(cc, digits = 2)
abline(reg,untf=T,col="red",lwd=2) 
text(40.1, 60, "r= -0.12",cex = 1)
text(40, 57, "P= 0.1",cex = 1)
#####################################################################################################





###########################################################################################################
################### Sction # 2: Plotting the lineage tree 
###########################################################################################################


##############################  Loading the data, we use here all cells from one tiff file data
df<- read.table(file.choose(),sep=",",header=T)     #### C10_2_Feb12 All Cells_Results.csv


############ Plotting the lineage tree of each cell and its descendants
DF=df
ID<-DF[,3]
SS<-sub("*\\..*", "", unlist(ID))
DF<-data.frame(ID,SS)
DFF<-split(DF[,1],DF[,2])
DFFF<-DFF
for (j in 1: length(DFF)){
	if (length(DFF[[j]])<2){
		DFFF[j]<-NULL
	}
}
length(DFFF)
DFF=DFFF
for (j in 1: length(DFF)){
	parents<-c()
	Offspring<-c()
	col=c()
	test<-sub("*\\..d*$", "", unlist(DFF[[j]]))
	for (i in 1:length(test)){
		if (!test[i]==DFF[[j]][i]){
			parents<-c(parents,test[i])
			Offspring<-c(Offspring,DFF[[j]][i])
		}
	}
	d = tibble(Offspring,parents)
	d2 = data.frame(from=d$parents, to=d$Offspring)
	g=graph_from_data_frame(d2)
	ordered.vertices <-get.data.frame(g, what="vertices")
	for (n in 1: length(parents)){
		if (Offspring[n] %in% parents){
			col=c(col,Offspring[n])
		}
	}
	COLOR<-c(rep("gray",length(ordered.vertices[,1])))
	for (i in 1:length(ordered.vertices[,1])){
		if (ordered.vertices[i,1]%in% col){
			COLOR[i]="lightgreen"
		}
	}
	co=layout.reingold.tilford(g, flip.y=T)
	pdf(paste0(j,".plot.pdf")) 
	par(mar=c(0,0,0,0)+.1)
	plot(g,layout=co,edge.arrow.size=1.5,vertex.shape="circle",vertex.size=26,
	vertex.color=COLOR,vertex.label.cex=0.8,vertex.label.font=2,vertex.label.color="black")
	dev.off()
}
#####################################################################################################




############ Plotting the lineage tree of a particular cell and its descendants
DF=df
ID<-DF[,3]
SS<-sub("*\\..*", "", unlist(ID))
DF<-data.frame(ID,SS)
DFF<-split(DF[,1],DF[,2])
DFFF<-DFF
for (j in 1: length(DFF)){
	if (length(DFF[[j]])<2){
		DFFF[j]<-NULL
	}
}
length(DFFF)
DFF=DFFF
j=5    ###### Changing this value will change the target cell and generat different lineage tree
parents<-c()
Offspring<-c()
col=c()
test<-sub("*\\..d*$", "", unlist(DFF[[j]]))
for (i in 1:length(test)){
	if (!test[i]==DFF[[j]][i]){
		parents<-c(parents,test[i])
		Offspring<-c(Offspring,DFF[[j]][i])
	}
}
d = tibble(Offspring,parents)
d2 = data.frame(from=d$parents, to=d$Offspring)
g=graph_from_data_frame(d2)
ordered.vertices <-get.data.frame(g, what="vertices")
for (n in 1: length(parents)){
	if (Offspring[n] %in% parents){
		col=c(col,Offspring[n])
	}
}
COLOR<-c(rep("gray",length(ordered.vertices[,1])))
for (i in 1:length(ordered.vertices[,1])){
	if (ordered.vertices[i,1]%in% col){
		COLOR[i]="lightgreen"
	}
}
co=layout.reingold.tilford(g, flip.y=T)
par(mar=c(0,0,0,0)+.1)
plot(g,layout=co,edge.arrow.size=1.5,vertex.shape="circle",vertex.size=26,
vertex.color=COLOR,vertex.label.cex=0.8,vertex.label.font=2,vertex.label.color="black")
#####################################################################################################













###########################################################################################################
################### Sction # 3: Generation plot for all the data
###########################################################################################################



#################### Loading the data after converting each file into csv
df1<- read.table(file.choose(),sep=",",header=T)     #### A3_1_Feb12 All Cells.csv
df2<- read.table(file.choose(),sep=",",header=T)     #### A3_2_Feb12 All Cells.csv
df3<- read.table(file.choose(),sep=",",header=T)     #### C10_2_Feb12 All Cells_Results.csv
df<-rbind(df1,df2,df3)
head(df)
dim(df)
mothers<-c()
first<-c()
second<-c()
third<-c()
fourth<-c()
for (i in 1:length(df[,1])){
	st<-strsplit(df[i,3], regex("\\.", multiline = TRUE))
	L=length(st[[1]])-1
	if (L==0){mothers=c(mothers,L)}
	if (L==1){first=c(first,L)}
	if (L==2){second=c(second,L)}
	if (L==3){third=c(third,L)}
	if (L==4){fourth=c(fourth,L)}
}
generations=c(length(third),length(second),length(first),length(mothers))
barplot(generations,horiz=T,col=c("bisque1","bisque2","bisque3","bisque4"),xlab="Number of cells",xlim=c(0,275))
box()
#####################################################################################################
















###########################################################################################################
################### Sction # 4: Heterogeneity between daughter cells
###########################################################################################################


################# Loading the data after converting each file into csv
df1<- read.table(file.choose(),sep=",",header=T)     #### A3_1_Feb12 Daughter Cells.csv

##### twining the daughter cells in df1
implode <- function(..., sep='') {
     paste(..., collapse=sep)
}
newDF1<-data.frame()
for (i in 1: length(df1[,1])){
	w<-strsplit(df1[i,3], "")
	ww<-w[[1]][length(w[[1]])]
	ww<-as.numeric(w[[1]][length(w[[1]])])
	if (ww==1){
		w[[1]][length(w[[1]])]<-2
		se<-implode(w[[1]])
		wh<-which(df1[,3]==paste0(se))
		if (length(wh)>0){
			newDF1<-rbind(newDF1,df1[i,],df1[wh,])
		}
	}
}


df2<- read.table(file.choose(),sep=",",header=T)     #### A3_2_Feb12 Daughter Cells.csv
##### twining the daughter cells in df2
implode <- function(..., sep='') {
     paste(..., collapse=sep)
}
newDF2<-data.frame()
for (i in 1: length(df2[,1])){
	w<-strsplit(df2[i,3], "")
	ww<-w[[1]][length(w[[1]])]
	ww<-as.numeric(w[[1]][length(w[[1]])])
	if (ww==1){
		w[[1]][length(w[[1]])]<-2
		se<-implode(w[[1]])
		wh<-which(df2[,3]==paste0(se))
		if (length(wh)>0){
			newDF2<-rbind(newDF2,df2[i,],df2[wh,])
		}
	}
}



df3<- read.table(file.choose(),sep=",",header=T)     #### C10_2_Feb12 Daughter Cells.csv
##### twining the daughter cells in df3
implode <- function(..., sep='') {
     paste(..., collapse=sep)
}
newDF3<-data.frame()
for (i in 1: length(df3[,1])){
	w<-strsplit(df3[i,3], "")
	ww<-w[[1]][length(w[[1]])]
	ww<-as.numeric(w[[1]][length(w[[1]])])
	if (ww==1){
		w[[1]][length(w[[1]])]<-2
		se<-implode(w[[1]])
		wh<-which(df3[,3]==paste0(se))
		if (length(wh)>0){
			newDF3<-rbind(newDF3,df3[i,],df3[wh,])
		}
	}
}

dcells<-rbind(newDF1,newDF2,newDF3)
head(dcells)
dim(dcells)
firstDC<-c()     # selecting the first DCell
num=c(1:length(dcells[,1]))
for (k in num){
	if(!(k %% 2) == 0) {
		firstDC=c(firstDC,k)
	} 
}

sdDiff=18                   #### no trajectory time difference larger than 3 hours between the two daughter cells
minStep=60                  #### minimum trajectory time of 10 hours
selectedrows=c() 
for (i in firstDC){
	if (abs(dcells[i,6]-dcells[i+1,6])<=sdDiff & dcells[i,6]>= minStep & dcells[i+1,6]>= minStep){
		selectedrows=c(selectedrows,i)
	}
}
Fselectedrows=c(selectedrows,(selectedrows+1))   ##########  including the other cell
Fselectedrows=sort(Fselectedrows)
Fdcells=dcells[Fselectedrows,]
diffDC<-dcells[selectedrows,]
for (i in selectedrows){
	diffDC[which(selectedrows %in% i),5:11]<-abs(dcells[i,5:11]-dcells[i+1,5:11])
}
length(diffDC[,1])         ##############  Number of pairs of daughter cells included in the analysis
summary(diffDC[,11]*60)    ## speed difference
summary(diffDC[,7])        ## total distance difference
summary(diffDC[,10]*100)   ## directionality difference (%)
summary(diffDC[,8])        ## displacement difference
par(mfrow=c(1,4))
boxplot(diffDC[,11]*60, ylab="Average Speed difference (um/h)",cex.lab=1.2, cex.axis=1.2,col="yellow",ylim=c(0,10))
boxplot(diffDC[,10]*100, ylab="Directionality difference (%)",cex.lab=1.2, cex.axis=1.2,col="lightgreen",ylim=c(0,40))
boxplot(diffDC[,7],ylab="Total Distance difference (um)",cex.lab=1.2, cex.axis=1.2,col="lightblue",ylim=c(0,200))
boxplot(diffDC[,8], ylab="Displacement difference (um)",cex.lab=1.2, cex.axis=1.2,col="blue",ylim=c(0,200))



########## Computing the Time Diffrence between divisions of BT549 daughter cells 
TimeDifferences=c()
for (i in firstDC){
	if (dcells[i,4]==TRUE & dcells[i+1,4]==TRUE){
		h=abs(dcells[i,9]-dcells[i+1,9])
		TimeDifferences=c(TimeDifferences,h)
	}
}
length(TimeDifferences)    ##############  Number of pairs of daughter cells included in the analysis


summary(TimeDifferences/60)
sd(TimeDifferences/60)
# Computing the mode
getmode <- function(v) {
   uniqv <- unique(v)
   uniqv[which.max(tabulate(match(v, uniqv)))]
}
result <- getmode(TimeDifferences)
print(result)

## Boxplot
boxplot(TimeDifferences/60, ylab="Time difference between the division of daughter cells (h)",
cex.lab=1.2, cex.axis=1.2,col="gray",ylim=c(0,40),las=1)
## Violin plot
TD=TimeDifferences/60
Group= c(rep(1,length(TD)))
Da<-data.frame(TD,Group)
data_summary <- function(x) {
   m <- mean(x)
   ymin <- m-sd(x)
   ymax <- m+sd(x)
   return(c(y=m,ymin=ymin,ymax=ymax))
}
p <- ggplot(Da, aes(x=Group, y=TD)) + 
    geom_violin(trim=FALSE,fill="gray")+ geom_point(size=2.5,color="black")
p + stat_summary(fun.data=data_summary,geom="pointrange", color="red",size = 1)
###################################################################################################







