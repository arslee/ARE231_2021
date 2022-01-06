# Crash Course on Applied Economics Research using R

This repository contains codes, slides, and other documents that I have
used as a guest lecturer for ARE231 Agricultural Demand and Supply at UC Davis in 2021
Fall, a 2nd-year PhD course. ARE231 is taught jointly by Timothy Beatty and Aaron Smith. I held two sessions, each of
which took around one and half hours.

In the first session, I covered coding mindset, useful features of
Rstudio, short-cuts, snippets and project setup. Before the session, I
have asked students to do a mini empirical research project using R
(please see at the end of this document). I walked through my workflow
and codes for the mini project.

In the second session, I taught how to use R for spatial data analysis.
I spent about an hour about how to use R as a GIS tool. In the last half
hour, I went through how to construct cropland-weighted county-level
temperature data using gridded weather data from the PRISM Climate Group and landcover data
from the National Land Cover Database (NLCD).

<center>
————mini research project—————
</center>

We are going to run the following panel regression of crop yields for
corn and soybeans in Iowa, Illinois and Indiana over the period
1981-2019:

![ log(y\_{cit})=\\beta\_{c1}prec\_{it}+\\beta\_{c2}prec\_{it}^2+\\beta\_{c3}gdd\_{it}+\\beta\_{c4}hdd\_{it}+ \\alpha_i+f_i(t)+\\epsilon\_{cit},](https://latex.codecogs.com/png.latex?%20log%28y_%7Bcit%7D%29%3D%5Cbeta_%7Bc1%7Dprec_%7Bit%7D%2B%5Cbeta_%7Bc2%7Dprec_%7Bit%7D%5E2%2B%5Cbeta_%7Bc3%7Dgdd_%7Bit%7D%2B%5Cbeta_%7Bc4%7Dhdd_%7Bit%7D%2B%20%5Calpha_i%2Bf_i%28t%29%2B%5Cepsilon_%7Bcit%7D%2C " log(y_{cit})=\beta_{c1}prec_{it}+\beta_{c2}prec_{it}^2+\beta_{c3}gdd_{it}+\beta_{c4}hdd_{it}+ \alpha_i+f_i(t)+\epsilon_{cit},")

where
![y\_{cit}](https://latex.codecogs.com/png.latex?y_%7Bcit%7D "y_{cit}")
denotes the yield for crop
![c](https://latex.codecogs.com/png.latex?c "c") in county
![i](https://latex.codecogs.com/png.latex?i "i") in year
![t](https://latex.codecogs.com/png.latex?t "t").
![prec](https://latex.codecogs.com/png.latex?prec "prec") denotes
precipitation, and
![gdd](https://latex.codecogs.com/png.latex?gdd "gdd") represents
beneficial heat exposure (Growing Degree Days: degree days between 10C
and 30C) and ![hdd](https://latex.codecogs.com/png.latex?hdd "hdd")
represents harmful heat exposure (Heating Degree Days: degree days above
30C). We include county fixed effects
![\\alpha\_{i}](https://latex.codecogs.com/png.latex?%5Calpha_%7Bi%7D "\alpha_{i}")
and county-specific time trend
![f\_{i}(t)](https://latex.codecogs.com/png.latex?f_%7Bi%7D%28t%29 "f_{i}(t)").
The growing season for corn and soybeans in the three I states is
approximately from April to September.

This crop yield model has become popular in the literature since the
seminar work by [Schlenker and Roberts
(2009)](https://www.pnas.org/content/106/37/15594.short). You will learn
more about the methodology and other related ones later in the course in
more detail.

**I do encourage you to spend some time trying to implement the
following steps**, although I will walk through them in the session.

It is totally ok even if you do not make much progress. But, I would
like you to at least try each step so that you can make most out of my
session.

1.  Download annual county-level yield and acreage data for corn (for
    grain) and soybeans for all counties in the I states from the USDA
    NASS quickstats for the period 1981-2019. (Note: There are multiple
    ways of doing this. I would like your workflow to be reproducible
    and automated, meaning that executing your script downloads all data
    you need at once. Please feel free to refer to [Accessing Ag Data
    Using R](https://asmith.ucdavis.edu/data/meta))

2.  Download weather data by clicking `Download All Monthly Data` from
    [US County Weather](https://asmith.ucdavis.edu/data/weather) once
    the app is fully loaded. (In a few weeks later, we are going to
    learn how to construct this data using the gridded daily temperature
    data from the PRISM Climate Group, county boundaries, and crop
    frequency map)

3.  Using the data you downloaded, create a crop-county-year level panel
    dataset that contains columns of yield and weather variables
    necessary for your regressions. This will involve some data
    cleaning. (Tip: You can construct annual
    ![gdd](https://latex.codecogs.com/png.latex?gdd "gdd") or
    ![hdd](https://latex.codecogs.com/png.latex?hdd "hdd") by summing
    monthly degree days over the growing season (April to September))

4.  Before running regressions, do some data exploration to check your
    data. You can compare your data with [US
    Crops](https://asmith.ucdavis.edu/data/us-crops).

5.  Run regressions for the following combinations.

    -   crop : 1) corn, 2) soybeans

    -   period : 1) full (1981-2019), 2) pre 2000 (1981-2000), 3) post
        2000 (2001-2019),

    -   regression weights : 1) no weight, 2) acreage

    -   cluster standard errors by: 1) year, 2) state

    -   time trend : 1) county-specific linear, 2) state-specific
        linear, 3) county-specific quadratic, 4) state-specific
        quadratic

    -   weather variables : 1) (with precipitation)
        ![prec](https://latex.codecogs.com/png.latex?prec "prec"),
        ![prec^2](https://latex.codecogs.com/png.latex?prec%5E2 "prec^2"),
        ![gdd](https://latex.codecogs.com/png.latex?gdd "gdd") and
        ![hdd](https://latex.codecogs.com/png.latex?hdd "hdd"), 2)
        (without precipitation)
        ![gdd](https://latex.codecogs.com/png.latex?gdd "gdd") and
        ![hdd](https://latex.codecogs.com/png.latex?hdd "hdd")

That is, you have
![2\\times 3\\times 2 \\times 2\\times 4\\times 2 = 192](https://latex.codecogs.com/png.latex?2%5Ctimes%203%5Ctimes%202%20%5Ctimes%202%5Ctimes%204%5Ctimes%202%20%3D%20192 "2\times 3\times 2 \times 2\times 4\times 2 = 192")
regression results.

6.  Let’s focus on
    ![\\beta_4](https://latex.codecogs.com/png.latex?%5Cbeta_4 "\beta_4").

    -   Obtain
        ![\\hat{\\beta}\_4](https://latex.codecogs.com/png.latex?%5Chat%7B%5Cbeta%7D_4 "\hat{\beta}_4")s
        and calculate their confidence intervals.
    -   Compare
        ![\\hat{\\beta}\_4](https://latex.codecogs.com/png.latex?%5Chat%7B%5Cbeta%7D_4 "\hat{\beta}_4")s
        and their confidence intervals by changing one dimension at a
        time. (i.e., compare
        ![\\hat{\\beta}\_4](https://latex.codecogs.com/png.latex?%5Chat%7B%5Cbeta%7D_4 "\hat{\beta}_4")s
        for different crops 1) corn and 2) soybeans while keeping 1) for
        all the other dimensions).
    -   Do you find any systematic differences between models in any
        dimensions? If so, what are they? Are they consistent with your
        intuition?
