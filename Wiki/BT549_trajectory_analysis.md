Needed packages
===============

    require(tidyverse)

    ## Loading required package: tidyverse

    ## ── Attaching packages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✔ ggplot2 3.3.2     ✔ purrr   0.3.4
    ## ✔ tibble  3.0.4     ✔ dplyr   1.0.2
    ## ✔ tidyr   1.1.2     ✔ stringr 1.4.0
    ## ✔ readr   1.4.0     ✔ forcats 0.5.0

    ## ── Conflicts ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

    require(igraph)

    ## Loading required package: igraph

    ## 
    ## Attaching package: 'igraph'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     as_data_frame, groups, union

    ## The following objects are masked from 'package:purrr':
    ## 
    ##     compose, simplify

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     crossing

    ## The following object is masked from 'package:tibble':
    ## 
    ##     as_data_frame

    ## The following objects are masked from 'package:stats':
    ## 
    ##     decompose, spectrum

    ## The following object is masked from 'package:base':
    ## 
    ##     union

    require(ggplot2)

Needed data
===========

All the needed data are available
[here](https://github.com/ocbe-uio/CellMAPtracer/tree/master/Data/BT549%20tracking%20data).

The notebook consists of four sections.

Section 1: Studying Dividing Daughter Cells
===========================================

Loading the data after converting each file into csv
----------------------------------------------------

First we create a `path` string that stores the location of the files:

    path <- "../Data/BT549 tracking data/" # You may need to change this

Now we can properly read the files.

    df1 <- read.csv(file.path(path, "A3_1_Feb12 Dividing Daughter Cells.csv"))
    df2 <- read.csv(file.path(path, "A3_2_Feb12 Dividing Daughter Cells.csv"))
    df3<- read.csv(file.path(path, "C10_2_Feb12 Dividing Daughter Cells.csv"))
    df <- rbind(df1, df2, df3)
    head(df)

    ##   ExperimentName   TiffFileName CellName isDivided isDaughter nImages Distance Displacement TrajectoryTime Directionality AverageSpeed
    ## 1          Feb12 A3_1_Feb12.tif     C1.1      TRUE       TRUE     145    375.9        155.4           1440          0.413        0.261
    ## 2          Feb12 A3_1_Feb12.tif     C1.2      TRUE       TRUE     182    631.8         36.8           1810          0.058        0.349
    ## 3          Feb12 A3_1_Feb12.tif     C7.1      TRUE       TRUE     219    462.8          5.1           2180          0.011        0.212
    ## 4          Feb12 A3_1_Feb12.tif     C7.2      TRUE       TRUE     212    472.0         64.7           2110          0.137        0.224
    ## 5          Feb12 A3_1_Feb12.tif     C9.1      TRUE       TRUE     149    460.1         55.5           1480          0.121        0.311
    ## 6          Feb12 A3_1_Feb12.tif     C9.2      TRUE       TRUE     170    565.6        131.5           1690          0.232        0.335

    dim(df)

    ## [1] 175  11

Computing the doubling time of BT549 cells
------------------------------------------

    TrajectoryTime <- df[, 9] / 60
    sd(TrajectoryTime)

    ## [1] 8.541785

    summary(TrajectoryTime)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   14.33   24.50   30.17   31.10   36.75   61.67

Computing the mode of the doubling time
---------------------------------------

    getmode <- function(v) {
        uniqv <- unique(v)
        uniqv[which.max(tabulate(match(v, uniqv)))]
    }
    result <- getmode(TrajectoryTime)
    print(result)

    ## [1] 24.66667

### Plotting the density of the doubling time

    x <- TrajectoryTime
    hx5 <- TrajectoryTime
    dens <- density(hx5, cut=10)
    n <- length(dens$y)
    dx <- mean(diff(dens$x))                  # Typical spacing in x
    y.unit <- sum(dens$y) * dx                # Check: this should integrate to 1
    dx <- dx / y.unit                         # Make a minor adjustment
    x.mean <- sum(dens$y * dens$x) * dx
    y.mean <- dens$y[length(dens$x[dens$x < x.mean])]
    x.mode <- dens$x[i.mode <- which.max(dens$y)]
    y.mode <- dens$y[i.mode]
    y.cs <- cumsum(dens$y)
    x.med <- dens$x[i.med <- length(y.cs[2 * y.cs <= y.cs[n]])]
    y.med <- dens$y[i.med]

Plotting the density and the statistics.
----------------------------------------

    plot(
        dens, type="l", col="black", lwd=0.1, xlim=c(0,72), cex=1.5, cex.lab=1.3,
        cex.axis=1.3, xlab="The doubling time of BT549 cells (h)"
    )
    polygon(dens, col="black")
    temp <- mapply(
        function(x,y,c) lines(c(x,x), c(0,y), lwd=2, col=c,las=1),
        c(x.mean, x.med, x.mode),
        c(y.mean, y.med, y.mode),
        c("orange", "Green", "Red")
    )
    legend(
        43, 0.047, c("Doubling Time Density", "Mode", "Median", "Mean"),
        col=c("black","Red","green", "orange"), text.col = "black", lty=1, lwd=2,
        cex=0.65, merge=TRUE
    )

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-4-1.png)

Characterizing the trajectory movement of a population of Dividing Daughter BT549 cells
---------------------------------------------------------------------------------------

### Directionality

    Directionality <- df[, 10]
    summary(Directionality)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##  0.0110  0.1075  0.1790  0.2012  0.2855  0.5480

    sd(Directionality)

    ## [1] 0.1242507

    Group <- c(rep(1, length(Directionality)))
    Da <- data.frame(Directionality, Group)

#### Add mean and standard deviation within violin plot

    data_summary <- function(x) {
        m <- mean(x)
        ymin <- m -ssd(x)
        ymax <- m + sd(x)
        return(c(y=m, ymin=ymin, ymax=ymax))
    }
    p <- ggplot(Da, aes(x=Group, y=Directionality)) +
        geom_violin(trim=FALSE, fill="lightgreen") +
        geom_point(size=2.5, color="black")
    p + stat_summary(
        fun.data=data_summary, geom="pointrange", color="red", size = 1
    )

    ## Warning: Computation failed in `stat_summary()`:
    ## could not find function "ssd"

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-6-1.png)

### Speed

    Average_Speed <- df[, 11] * 60
    summary(Average_Speed)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   12.72   16.56   19.50   21.71   23.79   58.26

    sd(Average_Speed)

    ## [1] 7.526684

    Group <- c(rep(1, length(Average_Speed)))
    Da <- data.frame(Average_Speed, Group)
    data_summary <- function(x) {
        m <- mean(x)
        ymin <- m-sd(x)
        ymax <- m+sd(x)
        return(c(y=m,ymin=ymin,ymax=ymax))
    }
    p <- ggplot(Da, aes(x=Group, y=Average_Speed)) +
        geom_violin(trim=FALSE, fill="yellow") +
        geom_point(size=2.5, color="black")
    p + stat_summary(
        fun.data=data_summary, geom="pointrange", color="red", size = 1
    )

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-7-1.png)

### Correlation Analysis

#### Finding the correlation between doubling time and Total Distance

    DT <- df[, 9] / 60 # doubling time
    f <- df[,7]        # Total Distance
    ff <- as.numeric(gsub(",", ".", f))
    plot(
        DT, f, xlab="Doubling time (h)", ylab="Total Distance (um)", pch=16, las=0,
        cex=1.5, cex.lab=1.3, cex.axis=1.3
    )
    c <- cor.test(~ DT + ff, method="pearson", exact=FALSE)
    c

    ## 
    ##  Pearson's product-moment correlation
    ## 
    ## data:  DT and ff
    ## t = 10.358, df = 173, p-value < 2.2e-16
    ## alternative hypothesis: true correlation is not equal to 0
    ## 95 percent confidence interval:
    ##  0.5178691 0.7025485
    ## sample estimates:
    ##       cor 
    ## 0.6186835

    reg <- lm(ff ~ DT)
    cc <- unlist(c[4])
    ccPV <- round(cc, digits=2)
    abline(reg, untf=TRUE, col="red", lwd=2)
    text(18, 1875, "r= 0.62",cex = 1.5)
    text(19, 1750, "P< 0.001",cex = 1.5)

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-8-1.png)

#### Finding the correlation between doubling time and Directionality

    DT <- df[, 9] / 60 # doubling time
    f <- df[,10]       # Directionality
    plot(
        DT, f, xlab="Doubling time (h)", ylab="Directionality", pch=16, las=1,
        ylim=c(0,.65)
    )
    c <- cor.test(~ DT + f, method="pearson", exact=FALSE
    )
    c

    ## 
    ##  Pearson's product-moment correlation
    ## 
    ## data:  DT and f
    ## t = -1.9131, df = 173, p-value = 0.05739
    ## alternative hypothesis: true correlation is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.28616841  0.00450378
    ## sample estimates:
    ##        cor 
    ## -0.1439355

    reg <- lm(f ~ DT)
    cc <- unlist(c[4])
    ccPV <- round(cc, digits=2)
    abline(reg, untf=TRUE, col="red", lwd=2)
    text(19, 0.65, "r= -0.14", cex=1)
    text(19.4, 0.6, "P= 0.057", cex=1)

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-9-1.png)

#### Finding the correlation between doubling time and Average Speed

    DT <- df[, 9] / 60    # doubling time
    f <- df[, 11] * 60    # Average Speed
    plot(
        DT, f, xlab="Doubling time (h)", ylab="Average Speed (um/h)", pch=16, las=1,
        ylim=c(10,60)
    )
    c <- cor.test(~DT + f, method="pearson",exact=FALSE)
    c

    ## 
    ##  Pearson's product-moment correlation
    ## 
    ## data:  DT and f
    ## t = -1.6062, df = 173, p-value = 0.1101
    ## alternative hypothesis: true correlation is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.26479768  0.02762381
    ## sample estimates:
    ##       cor 
    ## -0.121216

    reg <- lm(f ~ DT)
    cc <- unlist(c[4])
    ccPV <- round(cc, digits=2)
    abline(reg, untf=TRUE, col="red", lwd=2)
    text(40.1, 60, "r= -0.12",cex=1)
    text(40, 57, "P= 0.1",cex=1)

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-10-1.png)

Section 2: Plotting the lineage tree
====================================

Loading the data, we use here all cells from one tiff file data
---------------------------------------------------------------

    df <- read.csv(file.path(path, "C10_2_Feb12 All Cells_Results.csv"))

Plotting the lineage tree of each cell and its descendants
----------------------------------------------------------

    DF <- df
    ID <- DF[, 3]
    SS <- sub("*\\..*", "", unlist(ID))
    DF <- data.frame(ID, SS)
    DFF <- split(DF[, 1], DF[, 2])
    DFFF <- DFF
    for (j in 1:length(DFF)) {
        if (length(DFF[[j]]) < 2){
            DFFF[j] <- NULL
        }
    }
    length(DFFF)

    ## [1] 32

    DFF <- DFFF
    for (j in 1:length(DFF)) {
        parents <- c()
        Offspring <- c()
        col <- c()
        test <- sub("*\\..d*$", "", unlist(DFF[[j]]))
        for (i in 1:length(test)){
            if (!test[i] == DFF[[j]][i]) {
                parents <- c(parents, test[i])
                Offspring <- c(Offspring, DFF[[j]][i])
            }
        }
        d <- tibble(Offspring, parents)
        d2 <- data.frame(from=d$parents, to=d$Offspring)
        g <- graph_from_data_frame(d2)
        ordered.vertices <- get.data.frame(g, what="vertices")
        for (n in 1:length(parents)) {
            if (Offspring[n] %in% parents) {
                col=c(col, Offspring[n])
            }
        }
        COLOR <- c(rep("gray", length(ordered.vertices[, 1])))
        for (i in 1:length(ordered.vertices[, 1])) {
            if (ordered.vertices[i, 1] %in% col) {
                COLOR[i] <- "lightgreen"
            }
        }
        co <- layout.reingold.tilford(g, flip.y <- TRUE)
        par(mar = c(0, 0, 0, 0) + .1)
    }

Plotting the lineage tree of a particular cell and its descendants
------------------------------------------------------------------

    DF <- df
    ID <- DF[, 3]
    SS <- sub("*\\..*", "", unlist(ID))
    DF <- data.frame(ID, SS)
    DFF <- split(DF[, 1], DF[, 2])
    DFFF <- DFF
    for (j in 1:length(DFF)) {
        if (length(DFF[[j]]) < 2) {
            DFFF[j] <- NULL
        }
    }
    length(DFFF)

    ## [1] 32

    DFF <- DFFF
    j <- 5 # this changes the target cell and generat different lineage tree
    parents <- c()
    Offspring <- c()
    col <- c()
    test <- sub("*\\..d*$", "", unlist(DFF[[j]]))
    for (i in 1:length(test)) {
        if (!test[i] == DFF[[j]][i]) {
            parents <- c(parents, test[i])
            Offspring <- c(Offspring, DFF[[j]][i])
        }
    }
    d <- tibble(Offspring,parents)
    d2 <- data.frame(from=d$parents, to=d$Offspring)
    g <- graph_from_data_frame(d2)
    ordered.vertices <- get.data.frame(g, what="vertices")
    for (n in 1:length(parents)) {
        if (Offspring[n] %in% parents) {
            col <- c(col,Offspring[n])
        }
    }
    COLOR <- c(rep("gray", length(ordered.vertices[, 1])))
    for (i in 1:length(ordered.vertices[, 1])) {
        if (ordered.vertices[i, 1] %in% col) {
            COLOR[i] <- "lightgreen"
        }
    }
    co <- layout.reingold.tilford(g, flip.y=TRUE)
    par(mar=c(0, 0, 0, 0) + .1)
    plot(
        g, layout=co,edge.arrow.size=1.5, vertex.shape="circle", vertex.size=26,
        vertex.color=COLOR, vertex.label.cex=0.8, vertex.label.font=2,
        vertex.label.color="black"
    )

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-13-1.png)

Section 3: Generation plot for all the data
===========================================

Loading the data after converting each file into csv
----------------------------------------------------

    df1 <- read.csv(file.path(path, "A3_1_Feb12 All Cells_Results.csv"))
    df2 <- read.csv(file.path(path, "A3_2_Feb12 All Cells_Results.csv"))
    df3 <- read.csv(file.path(path, "C10_2_Feb12 All Cells_Results.csv"))
    df <- rbind(df1, df2, df3)
    head(df)

    ##   ExperimentName   TiffFileName CellName isDivided isDaughter nImages Distance Displacement TrajectoryTime Directionality AverageSpeed
    ## 1          Feb12 A3_1_Feb12.tif       C1      TRUE      FALSE     100    353.7         50.6            990          0.143        0.357
    ## 2          Feb12 A3_1_Feb12.tif     C1.1      TRUE       TRUE     145    375.9        155.4           1440          0.413        0.261
    ## 3          Feb12 A3_1_Feb12.tif   C1.1.1     FALSE       TRUE     188    590.9        141.6           1870          0.240        0.316
    ## 4          Feb12 A3_1_Feb12.tif   C1.1.2     FALSE       TRUE     188    516.2         71.9           1870          0.139        0.276
    ## 5          Feb12 A3_1_Feb12.tif     C1.2      TRUE       TRUE     182    631.8         36.8           1810          0.058        0.349
    ## 6          Feb12 A3_1_Feb12.tif   C1.2.1     FALSE       TRUE     151    455.3        110.9           1500          0.243        0.304

    dim(df)

    ## [1] 648  11

    mothers <- c()
    first <- c()
    second <- c()
    third <- c()
    fourth <- c()
    for (i in 1:length(df[, 1])) {
        st <- strsplit(df[i, 3], regex("\\.", multiline=TRUE))
        L <- length(st[[1]]) - 1
        if (L == 0) mothers <- c(mothers, L)
        if (L == 1) first <- c(first, L)
        if (L == 2) second <- c(second, L)
        if (L == 3) third <- c(third, L)
        if (L == 4) fourth <- c(fourth, L)
    }
    generations <- c(length(third), length(second), length(first), length(mothers))
    barplot(
        generations, horiz=TRUE, col=c("bisque1","bisque2","bisque3","bisque4"),
        xlab="Number of cells", xlim=c(0, 275)
    )
    box()

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-14-1.png)

Section 4: Heterogeneity between daughter cells
===============================================

Loading the data after converting each file into csv
----------------------------------------------------

    df1 <- read.csv(file.path(path, "A3_1_Feb12 Dividing Daughter Cells.csv"))

twining the daughter cells in df1
---------------------------------

    implode <- function(..., sep='') paste(..., collapse=sep)
    newDF1 <- data.frame()
    for (i in 1:length(df1[, 1])) {
        w <- strsplit(df1[i, 3], "")
        ww <- w[[1]][length(w[[1]])]
        ww <- as.numeric(w[[1]][length(w[[1]])])
        if (ww == 1) {
            w[[1]][length(w[[1]])] <- 2
            se <- implode(w[[1]])
            wh <- which(df1[, 3] == paste0(se))
            if (length(wh) > 0){
                newDF1 <- rbind(newDF1, df1[i, ], df1[wh, ])
            }
        }
    }

twining the daughter cells in df2
---------------------------------

    df2 <-  read.csv(file.path(path, "A3_2_Feb12 Daughter Cells.csv"))
    implode <- function(..., sep='') {
        paste(..., collapse=sep)
    }
    newDF2 <- data.frame()
    for (i in 1:length(df2[, 1])) {
        w <- strsplit(df2[i, 3], "")
        ww <- w[[1]][length(w[[1]])]
        ww <- as.numeric(w[[1]][length(w[[1]])])
        if (ww == 1) {
            w[[1]][length(w[[1]])] <- 2
            se <- implode(w[[1]])
            wh <- which(df2[, 3] == paste0(se))
            if (length(wh) > 0) {
                newDF2 <- rbind(newDF2, df2[i, ], df2[wh, ])
            }
        }
    }

twining the daughter cells in df3
---------------------------------

    df3 <- read.csv(file.path(path, "C10_2_Feb12 Daughter Cells.csv"))
    newDF3 <- data.frame()
    for (i in 1:length(df3[, 1])) {
        w <- strsplit(df3[i, 3], "")
        ww <- w[[1]][length(w[[1]])]
        ww <- as.numeric(w[[1]][length(w[[1]])])
        if (ww == 1) {
            w[[1]][length(w[[1]])] <- 2
            se <- implode(w[[1]])
            wh <- which(df3[, 3] == paste0(se))
            if (length(wh) > 0) {
                newDF3 <- rbind(newDF3, df3[i, ], df3[wh, ])
            }
        }
    }
    dcells <- rbind(newDF1, newDF2, newDF3)
    head(dcells)

    ##   ExperimentName   TiffFileName CellName isDivided isDaughter nImages Distance Displacement TrajectoryTime Directionality AverageSpeed
    ## 1          Feb12 A3_1_Feb12.tif     C1.1      TRUE       TRUE     145    375.9        155.4           1440          0.413        0.261
    ## 2          Feb12 A3_1_Feb12.tif     C1.2      TRUE       TRUE     182    631.8         36.8           1810          0.058        0.349
    ## 3          Feb12 A3_1_Feb12.tif     C7.1      TRUE       TRUE     219    462.8          5.1           2180          0.011        0.212
    ## 4          Feb12 A3_1_Feb12.tif     C7.2      TRUE       TRUE     212    472.0         64.7           2110          0.137        0.224
    ## 5          Feb12 A3_1_Feb12.tif     C9.1      TRUE       TRUE     149    460.1         55.5           1480          0.121        0.311
    ## 6          Feb12 A3_1_Feb12.tif     C9.2      TRUE       TRUE     170    565.6        131.5           1690          0.232        0.335

    dim(dcells)

    ## [1] 446  11

    firstDC <- c() # selecting the first DCell
    num <- c(1:length(dcells[, 1]))
    for (k in num) {
        if(!(k %% 2) == 0) {
            firstDC <- c(firstDC, k)
        }
    }
    sdDiff <- 18 # no trajectory time difference larger than 3 hours between the two daughter cells
    minStep <- 60 # minimum trajectory time of 10 hours
    selectedrows <- c()
    for (i in firstDC) {
        condition1 <-abs(dcells[i, 6] - dcells[i + 1, 6]) <= sdDiff
        condition2 <- dcells[i, 6]>= minStep
        condition3 <- dcells[i + 1, 6]>= minStep
        if (condition1 & condition2 & condition3) {
            selectedrows <- c(selectedrows, i)
        }
    }
    Fselectedrows <- c(selectedrows, (selectedrows + 1)) # including the other cell
    Fselectedrows <- sort(Fselectedrows)
    Fdcells <- dcells[Fselectedrows, ]
    diffDC <- dcells[selectedrows, ]
    for (i in selectedrows) {
        diffDC[which(selectedrows %in% i), 5:11] <- abs(
            dcells[i, 5:11] - dcells[i + 1, 5:11]
        )
    }

Number of pairs of daughter cells included in the analysis
----------------------------------------------------------

    length(diffDC[, 1])

    ## [1] 98

    summary(diffDC[, 11] * 60)    ## speed difference

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.000   0.675   1.770   2.282   3.180   9.780

    summary(diffDC[, 7])          ## total distance difference

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.80   20.50   44.75   58.51   83.50  266.50

    summary(diffDC[, 10] * 100)   ## directionality difference (%)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.100   3.925   7.650  10.394  13.825  51.800

    summary(diffDC[, 8])          ## displacement difference

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.40   22.62   40.45   53.37   70.10  230.40

    par(mfrow=c(1,4))
    boxplot(
        diffDC[, 11] * 60, ylab="Average Speed difference (um/h)", cex.lab=1.2,
        cex.axis=1.2, col="yellow", ylim=c(0, 10)
    )
    boxplot(
        diffDC[, 10] * 100, ylab="Directionality difference (%)", cex.lab=1.2,
        cex.axis=1.2, col="lightgreen", ylim=c(0, 40)
    )
    boxplot(
        diffDC[, 7], ylab="Total Distance difference (um)", cex.lab=1.2,
        cex.axis=1.2, col="lightblue", ylim=c(0, 200)
    )
    boxplot(
        diffDC[,8], ylab="Displacement difference (um)", cex.lab=1.2, cex.axis=1.2,
        col="blue", ylim=c(0, 200)
    )

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-19-1.png)

Computing the Time Diffrence between divisions of BT549 daughter cells
----------------------------------------------------------------------

    TimeDifferences <- c()
    for (i in firstDC) {
        if (dcells[i, 4] == TRUE & dcells[i + 1, 4] == TRUE) {
            h <- abs(dcells[i, 9] - dcells[i + 1, 9])
            TimeDifferences <- c(TimeDifferences, h)
        }
    }
    length(TimeDifferences) # pairs of daughter cells included in the analysis

    ## [1] 71

    summary(TimeDifferences / 60)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##  0.1667  2.0000  3.6667  5.6761  8.1667 25.0000

    sd(TimeDifferences / 60)

    ## [1] 5.517065

Computing the mode
------------------

    getmode <- function(v) {
        uniqv <- unique(v)
        uniqv[which.max(tabulate(match(v, uniqv)))]
    }
    result <- getmode(TimeDifferences)
    print(result)

    ## [1] 120

Boxplot
-------

    boxplot(
        TimeDifferences / 60,
        ylab="Time difference between the division of daughter cells (h)",
        cex.lab=1.2, cex.axis=1.2, col="gray", ylim=c(0, 40), las=1
    )

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-22-1.png)

Violin plot
-----------

    TD <- TimeDifferences / 60
    Group <- c(rep(1, length(TD)))
    Da <- data.frame(TD, Group)
    data_summary <- function(x) {
        m <- mean(x)
        ymin <- m - sd(x)
        ymax <- m + sd(x)
        return(c(y=m, ymin=ymin, ymax=ymax))
    }
    p <- ggplot(Da, aes(x=Group, y=TD)) +
        geom_violin(trim=FALSE, fill="gray") + geom_point(size=2.5, color="black")
    p + stat_summary(fun.data=data_summary,geom ="pointrange", color="red", size=1)

![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/BT549_trajectory_analysis_files/figure-markdown_strict/unnamed-chunk-23-1.png)
