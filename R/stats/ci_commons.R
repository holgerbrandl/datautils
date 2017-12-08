
# requires
# devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.45/R/core_commons.R")

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

    # browser()

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
        geom_jitter(alpha=0.3, height=0,width=0.2) +
        geom_errorbar(aes(ymin= mean-ci, ymax= mean+ci, y=NULL), data=ciData, width=.2, size=0.9)

    gg = gg + xlab(groupVar1) + ylab(quo_name(variable))

    # if 2 grouping variables are present add facetting on second grouping attribute
    if(length(groups(grpData)) ==2){
        # https://stackoverflow.com/questions/21588096/pass-string-to-facet-grid-ggplot2
        gg =  gg + facet_wrap(as.formula(paste("~",groups(grpData)[[2]])))
    }

    gg
}


## todo support model formula instead of group data
interaction_plot = function(grpData, variable, ci_interval=0.95){
    variable <- enquo(variable)

    #fail if there are more not 2 group attributes
    assert(length(groups(grpData)) == 2, "only dfs with 2 grouping vars are supported")

    # calculte ci intervals
    ciData = grpData %>% summarize(
        mean=mean(!!variable),
        sd=sd(!!variable),
        N = n(),
        se=sd/sqrt(N),
        ci = qt(ci_interval/2+0.5, N-1)*se,
    )


    groupVar1 = groups(grpData)[[1]]
    groupVar2 = groups(grpData)[[2]]
    dodge_with=0.2

    gg = ggplot(grpData, aes(x = eval(rlang::UQE(groupVar1)), y = eval(rlang::UQE(variable)), color = eval(rlang::UQE(groupVar2)))) +
        geom_jitter(position = position_jitterdodge(jitter.width = 0.1, dodge.width = dodge_with), alpha = 0.3) +
        geom_errorbar(aes(ymin = mean - ci, ymax = mean + ci, y = NULL), data = ciData, width = .2, size = 0.9, position = position_dodge(width = dodge_with)) +
        geom_line(aes(y = mean, group = eval(rlang::UQE(groupVar2))), position = position_dodge(width = dodge_with), data = ciData) +
        xlab(groupVar1) +
        ylab(quo_name(variable))

    gg
}


two_way_interaction = function(grpData, variable){
    ## invert the grouping
    grpData = ToothGrowth %>% group_by(supp, as.factor(dose))
    groupVar1 = groups(grpData)[[1]]
    groupVar2 = groups(grpData)[[2]]

    regrouped = grpData %>% group_by(eval(rlang::UQE(groupVar2)), eval(rlang::UQE(groupVar1)))

    multiplot(
    interaction_plot(grpData, !!enquo(variable)),
    interaction_plot(regrouped, !!enquo(variable))
    )
}



########################################################################################################################
### DEV PLAYGROUND


## DEBUG-START
if(F){
    devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.43/R/ggplot_commons.R")

    lmModel = lm(len ~ supp*dose, data = ToothGrowth)
    varNames = attr(attr(lmModel$terms, "factors"), "dimnames")[[1]]

    grpData = lmModel$model %>%  group_by_at(vars(one_of(varNames[2], varNames[3])))


    two_way_interaction(grpData, eval(parse(text=varNames[1])))

    ToothGrowth %>% group_by(supp, as.factor(dose)) %>% plot_confint(len)
    ToothGrowth %>% group_by(supp, dose) %>% plot_ci(len)
    # ToothGrowth %>% mutate_inplace(dose, as.factor()) %>% group_by(supp, dose) %>% plot_ci(len)

    # .plot_confint = function(grpData, variable, ci_interval=0.95) plot_confint(grpData, quo_name(variable), ci_interval)

    model_interaction = function(model, variable){
        lmModel %>% str
        lmModel$model
    }



    ToothGrowth %>% group_by(supp, as.factor(dose))  %>% interaction_plot2(len)

}
## DEBUG-END


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



    foo = function(){


    }
}

