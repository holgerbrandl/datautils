
# requires
# devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.43/R/core_commons.R")

calc_ci = function(df, variable, ci_interval=0.95){
    variable <- enquo(variable)

    # http://dplyr.tidyverse.org/articles/programming.html
    mean_name <- paste0( quo_name(variable), "_mean")
    ci_name <- paste0(quo_name(variable), "_ci")
    # echo(glue::glue("varname is {ci_name}"))

    df %>% summarize(
    mean=mean(!!variable),
    sd=sd(!!variable),
    N = n(),
    se=sd/sqrt(N),
    !!ci_name := qt(ci_interval/2+0.5, N-1)*se,
    !!mean_name := mean
    ) %>% select(-c(mean, sd, N, se, mean))
}

iris %>% group_by(Species) %>% calc_ci(Sepal.Length)
iris %>% group_by(Species, Sepal.Width>3) %>% calc_ci(Sepal.Length)


#' now with plotting
plot_ci = function(grpData, variable, ci_interval=0.95){
    variable <- enquo(variable)

    # calculte ci intervals
    ciData = grpData %>% summarize(
        mean=mean(!!variable),
        sd=sd(!!variable),
        N = n(),
        se=sd/sqrt(N),
        ci = qt(ci_interval/2+0.5, N-1)*se,
    )


    #fail if there are more than one group attributes
    assert(length(groups(grpData)) < 3, "more than 2 groups are not supported")

    groupVar1 = groups(grpData)[[1]]

    gg = ggplot(grpData, aes(x= eval(rlang::UQE(groupVar1)), y= eval(rlang::UQE(variable)))) +
        geom_jitter(alpha=0.3, height=0) +
        geom_errorbar(aes(ymin= mean-ci, ymax= mean+ci, y=NULL), data=ciData, width=.2, size=0.9)

    # if 2 grouping variables are present add facetting on second grouping attribute
    if(length(groups(grpData)) ==2){
        # https://stackoverflow.com/questions/21588096/pass-string-to-facet-grid-ggplot2
        gg =  gg + facet_wrap(as.formula(paste("~",groups(grpData)[[2]])))
    }

    gg + xlab(groupVar1) + ylab()
}


########################################################################################################################
### DEV PLAYGROUND

if(F){

    # iris %>% ggplot(aes(Sepal.Width)) + geom_histogram()
    iris %>%
        group_by(Species) %>%
        plot_ci(Petal.Length)
    iris %>%
        group_by(Sepal.Width > 3, Species) %>%
        plot_ci(Petal.Length)
    iris %>%
        group_by(Sepal.Width > 3, Sepal.Width > 4, Species) %>%
        plot_ci(Petal.Length)



    ## see https://stackoverflow.com/questions/43405843/how-to-use-the-devel-version-of-dplyrs-enquo-and-quo-name-in-a-function-with-ti/43601059
    ## also see https://stackoverflow.com/questions/45279287/use-dplyr-se-with-ggplot2

    #' generic simple examples
    some_plot = function(data, var){
        variable <- enquo(var)
        tt = quo_name(variable)
        ggplot(data, aes_string(tt)) + geom_histogram()
    }
    some_plot(iris, Sepal.Length) -> works

    ## without using aes_string
    some_plot = function(data, var){
        variable <- enquo(var)
        # ggplot(data, aes(eval(rlang::UQE(variable))+eval(rlang::UQE(variable)))) + geom_histogram()
        ggplot(data, aes(eval(rlang::UQE(variable)))) + geom_histogram()
    }
    some_plot(iris, Petal.Length)

}

