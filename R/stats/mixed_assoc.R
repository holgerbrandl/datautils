require(tidyverse)
pacman::p_load(rcompanion)


# Calculate a pairwise association between all variables in a data-frame. In particular nominal vs nominal with Chi-square, numeric vs numeric with Pearson correlation, and nominal vs numeric with ANOVA.
# Adopted from https://stackoverflow.com/a/52557631/590437
mixed_assoc = function(df, cor_method="spearman", adjust_cramersv_bias=TRUE){
    df_comb = expand.grid(names(df), names(df),  stringsAsFactors = F) %>% purrr::set_names("X1", "X2")

    is_nominal = function(x) class(x) %in% c("factor", "character")
    # https://community.rstudio.com/t/why-is-purr-is-numeric-deprecated/3559
    # https://github.com/r-lib/rlang/issues/781
    is_numeric <- function(x) { is.integer(x) || is_double(x)}

    f = function(xName,yName) {
        x =  pull(df, xName)
        y =  pull(df, yName)

        result = if(is_nominal(x) && is_nominal(y)){
            # use bias corrected cramersV as described in https://rdrr.io/cran/rcompanion/man/cramerV.html
            cv = cramerV(as.character(x), as.character(y), bias.correct = adjust_cramersv_bias)
            data.frame(xName, yName, assoc=cv, type="cramersV")

        }else if(is_numeric(x) && is_numeric(y)){
            correlation = cor(x, y, method=cor_method, use="complete.obs")
            data.frame(xName, yName, assoc=correlation, type="correlation")

        }else if(is_numeric(x) && is_nominal(y)){
            # from https://stats.stackexchange.com/questions/119835/correlation-between-a-nominal-iv-and-a-continuous-dv-variable/124618#124618
            r_squared = summary(lm(x ~ y))$r.squared
            data.frame(xName, yName, assoc=sqrt(r_squared), type="anova")

        }else if(is_nominal(x) && is_numeric(y)){
            r_squared = summary(lm(y ~x))$r.squared
            data.frame(xName, yName, assoc=sqrt(r_squared), type="anova")

        }else {
            warning(paste("unmatched column type combination: ", class(x), class(y)))
        }

        # finally add complete obs number and ratio to table
        result %>% mutate(complete_obs_pairs=sum(!is.na(x) & !is.na(y)), complete_obs_ratio=complete_obs_pairs/length(x)) %>% rename(x=xName, y=yName)
    }

    # apply function to each variable combination
    map2_df(df_comb$X1, df_comb$X2, f)
}


if(F){
    mixed_assoc(iris)

    require(corrr)

    msleep %>%
        select(- name) %>%
        mixed_assoc() %>%
        select(x, y, assoc) %>%
        spread(y, assoc) %>%
        column_to_rownames("x") %>%
        as.matrix %>%
        as_cordf %>%
        network_plot()
}