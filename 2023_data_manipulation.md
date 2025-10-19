MeBr 2023 Data
================

``` r
library(tidyverse)
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ## ✔ forcats   1.0.1     ✔ stringr   1.5.2
    ## ✔ ggplot2   4.0.0     ✔ tibble    3.3.0
    ## ✔ lubridate 1.9.4     ✔ tidyr     1.3.1
    ## ✔ purrr     1.1.0     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

Load in 2023 CARB data

``` r
twentythree_data <- read_csv("./data/2023_carb_ceidars_mebr_ca.csv")
```

    ## Rows: 185 Columns: 18
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (9): AB, DIS, FNAME, FSTREET, FCITY, COID, DISN, CHAPIS, CERR_CODE
    ## dbl (9): CO, FACID, FZIP, FSIC, TS, HRA, CHINDEX, AHINDEX, EMS
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
twentythree_data <- janitor::clean_names(twentythree_data)
```

``` r
skimr::skim(twentythree_data)
```

|                                                  |                  |
|:-------------------------------------------------|:-----------------|
| Name                                             | twentythree_data |
| Number of rows                                   | 185              |
| Number of columns                                | 18               |
| \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_   |                  |
| Column type frequency:                           |                  |
| character                                        | 9                |
| numeric                                          | 9                |
| \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ |                  |
| Group variables                                  | None             |

Data summary

**Variable type: character**

| skim_variable | n_missing | complete_rate | min | max | empty | n_unique | whitespace |
|:--------------|----------:|--------------:|----:|----:|------:|---------:|-----------:|
| ab            |         0 |          1.00 |   2 |   3 |     0 |       11 |          0 |
| dis           |         0 |          1.00 |   2 |   3 |     0 |       19 |          0 |
| fname         |         0 |          1.00 |   9 |  57 |     0 |      171 |          0 |
| fstreet       |         0 |          1.00 |   8 |  36 |     0 |      183 |          0 |
| fcity         |         1 |          0.99 |   4 |  16 |     0 |      111 |          0 |
| coid          |         0 |          1.00 |   2 |   3 |     0 |       30 |          0 |
| disn          |         0 |          1.00 |  13 |  35 |     0 |       19 |          0 |
| chapis        |       181 |          0.02 |   1 |   1 |     0 |        1 |          0 |
| cerr_code     |       184 |          0.01 |   1 |   1 |     0 |        1 |          0 |

**Variable type: numeric**

| skim_variable | n_missing | complete_rate | mean | sd | p0 | p25 | p50 | p75 | p100 | hist |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|
| co | 0 | 1.00 | 30.96 | 15.67 | 1 | 19.00 | 33.00 | 39.00 | 58.00 | ▅▇▅▇▇ |
| facid | 0 | 1.00 | 2200379.37 | 20834540.66 | 1 | 973.00 | 3338.00 | 15041.00 | 201201212\.00 | ▇▁▁▁▁ |
| fzip | 2 | 0.99 | 93690.47 | 1482.50 | 90023 | 92694.00 | 93610.00 | 95236.00 | 96097.00 | ▁▃▇▂▆ |
| fsic | 0 | 1.00 | 2980.41 | 2445.79 | 172 | 723.00 | 2869.00 | 4911.00 | 9999.00 | ▇▃▃▁▁ |
| ts | 141 | 0.24 | 833.04 | 3392.56 | 0 | 0.16 | 3.64 | 11.75 | 18223.58 | ▇▁▁▁▁ |
| hra | 169 | 0.09 | 5.65 | 3.12 | 0 | 3.62 | 7.15 | 8.00 | 9.10 | ▅▁▃▂▇ |
| chindex | 168 | 0.09 | 0.20 | 0.28 | 0 | 0.02 | 0.04 | 0.30 | 0.80 | ▇▁▁▁▂ |
| ahindex | 173 | 0.06 | 0.50 | 0.67 | 0 | 0.07 | 0.30 | 0.72 | 2.41 | ▇▃▁▁▁ |
| ems | 0 | 1.00 | 717.03 | 2536.21 | 0 | 0.00 | 0.20 | 51.43 | 16812.33 | ▇▁▁▁▁ |

Isolate Los Angeles City data

``` r
filter(twentythree_data, fcity == "LOS ANGELES")
```

    ## # A tibble: 2 × 18
    ##      co ab     facid dis   fname     fstreet fcity  fzip  fsic coid     ts   hra
    ##   <dbl> <chr>  <dbl> <chr> <chr>     <chr>   <chr> <dbl> <dbl> <chr> <dbl> <dbl>
    ## 1    19 SC    107655 SC    CALMAT CO 2715 E… LOS … 90023  2951 LA       NA    NA
    ## 2    19 SC    116480 SC    LA CITY,… 2474-8… LOS … 90023  8711 LA       NA    NA
    ## # ℹ 6 more variables: chindex <dbl>, ahindex <dbl>, disn <chr>, chapis <chr>,
    ## #   cerr_code <chr>, ems <dbl>

Isolate Los Angeles County data

``` r
la_twentythree <- filter(twentythree_data, coid == "LA")
```

``` r
la_twentythree_sort <- arrange(la_twentythree, ems)
```

``` r
relocate(la_twentythree, ems)
```

    ## # A tibble: 19 × 18
    ##         ems    co ab     facid dis   fname fstreet fcity  fzip  fsic coid     ts
    ##       <dbl> <dbl> <chr>  <dbl> <chr> <chr> <chr>   <chr> <dbl> <dbl> <chr> <dbl>
    ##  1  1.68e+4    19 SC    106897 SC    AG-F… 2200 M… SAN … 90731  7342 LA    NA   
    ##  2  2.99e+0    19 SC    148236 SC    AIR … 324 W … EL S… 90245  8099 LA    NA   
    ##  3  6.01e-1    19 SC    114264 SC    ALL … 13646 … IRWI… 91706  1611 LA    NA   
    ##  4  4.62e-1    19 SC    132954 SC    ALL … 11549 … SAN … 91340  1771 LA    NA   
    ##  5  5.47e-2    19 SC     20421 SC    BLUE… 441 W … INGL… 90302  1611 LA    NA   
    ##  6  4.78e-1    19 SC    107654 SC    CALM… 16005 … IRWI… 91706  3273 LA    NA   
    ##  7  5.90e-2    19 SC    107655 SC    CALM… 2715 E… LOS … 90023  2951 LA    NA   
    ##  8  2.03e-1    19 SC    107656 SC    CALM… 11447 … SUN … 91352  2951 LA    NA   
    ##  9  5.91e+1    19 SC      8547 SC    ECOB… 720 S … CITY… 91746  1541 LA    NA   
    ## 10  4.46e-2    19 MD      3728 AV    GRAN… 34809 … LLANO 93544  1442 LA     0.17
    ## 11  1.66e+4    19 SC    100145 SC    HARB… 2200 M… SAN … 90731  7342 LA    NA   
    ## 12  9.08e-1    19 SC    184576 SC    HEXP… 491 WI… CITY… 91744  3069 LA    NA   
    ## 13  1.76e-1    19 SC    116480 SC    LA C… 2474-8… LOS … 90023  8711 LA    NA   
    ## 14  4.54e+0    19 SC     94009 SC    LAS … 3700  … CALA… 91302  4941 LA    NA   
    ## 15  2.93e-1    19 SC    105277 SC    SULL… 2600 B… IRWI… 91706  3273 LA    NA   
    ## 16  3.30e-1    19 SC      4988 SC    SULL… 5625 S… SOUT… 90280  1611 LA    NA   
    ## 17  1.97e-1    19 SC     19390 SC    SULL… 11462 … SUN … 91352  1611 LA    NA   
    ## 18  5.14e+1    19 SC    181667 SC    TORR… 3700 W… TORR… 90504  2911 LA    NA   
    ## 19  4.31e-2    19 MD      1759 AV    VULC… 7107 E… LITT… 93543  2951 LA     1.75
    ## # ℹ 6 more variables: hra <dbl>, chindex <dbl>, ahindex <dbl>, disn <chr>,
    ## #   chapis <chr>, cerr_code <chr>

How many unique LA county facilities?

``` r
la_facs <- twentythree_data %>%
filter(coid == "LA") %>%
summarise(unique_facilities = n_distinct(facid))
print(la_facs)
```

    ## # A tibble: 1 × 1
    ##   unique_facilities
    ##               <int>
    ## 1                19
