

# strip rownames from a data frame
# not exported from broom so had to replicate here
unrowname <- function(x) {
  rownames(x) <- NULL
  x
}


#' Coerce a data frame to a tibble, preserving rownames
#'
#' A thin wrapper around [tibble::as_tibble()], except checks for
#' rownames and adds them to a new column `.rownames` if they are
#' interesting (i.e. more than `1, 2, 3, ...`).
#'
#' Replacement for `fix_data_frame()`.
#'
#' @param data A [data.frame()] or [tibble::tibble()].
#'
#' @return A `tibble` potentially with a `.rownames` column
#' @noRd
#'
as_broom_tibble <- function(data) {

  # TODO: error when there aren't column names?

  tryCatch(
    df <- tibble::as_tibble(data),

    error = function(cnd)
      stop("Could not coerce data to `tibble`. Try explicitly passing a",
           "dataset to either the `data` or `newdata` argument.",
           call. = FALSE)
  )

  if (has_rownames(data))
    df <- tibble::add_column(df, .rownames = rownames(data), .before = TRUE)
  df
}

# copied from modeltests. re-export if at some we Import modeltests rather
# than suggest it
has_rownames <- function(df) {
  if (tibble::is_tibble(df))
    return(FALSE)
  any(rownames(df) != as.character(1:nrow(df)))
}


#' @export

tidy.crr <- function(x, exponentiate = FALSE, conf.int = TRUE,
                       conf.level = .95, ...) {
  # backward compatibility (in previous version, conf.int was used instead of conf.level)
  if (is.numeric(conf.int)) {
    conf.level <- conf.int
    conf.int <- TRUE
  }

  if (conf.int) {
    s <- summary(x, conf.int = conf.level)
  } else {
    s <- summary(x, conf.int = FALSE)
  }
  co <- s$coef
  nn <- c("term", "estimate", "std.error", "statistic", "p.value")
  ret <- as_broom_tibble(co[, -2, drop = FALSE])
  colnames(ret) <- nn

  if (exponentiate) {
    ret$estimate <- exp(ret$estimate)
  }
  if (!is.null(s$conf.int)) {
    CI <- as.matrix(unrowname(s$conf.int[, 3:4, drop = FALSE]))
    colnames(CI) <- c("conf.low", "conf.high")
    if (!exponentiate) {
      CI <- log(CI)
    }
    ret <- cbind(ret, CI)
  }

  tibble::as_tibble(ret)
}

#' @export
#' @seealso [glance()], [cmprsk::crr()]
#' @family crr tidiers
glance.crr <- function(x, ...) {
  s <- summary(x)
  # there's not much to work with in standard cmprsk::crr summary.
  # I've pulled what we can... should we augment?
  # hashed statistics are what are included in glance.coxph.
  # There are currently no methods for AIC, BIC.
  ret <- list(

    #nevent = s$nevent,# no event in summary for the crr
    statistic.log = s$logtest[1],
    #p.value.log = s$logtest[3],# there's no p value for the crr logtest??
    #r.squared = s$rsq[1],
    #r.squared.max = s$rsq[2],
   # concordance = s$concordance[1],
    #std.error.concordance = s$concordance[2],
    logLik = as.numeric(s$loglik),
    #AIC = stats::AIC(x),
    #BIC = stats::BIC(x),
    nobs = s$n
  )
  ret <- as_tibble(purrr::compact(ret))
  ret
}

#' @templateVar class crr
#' @inherit tidy.crr params examples
#'
#' @export
#' @seealso [augment()], [cmprsk::crr()]
#' @family crr tidiers
augment.coxph <- function(x, data = NULL, newdata = NULL,
                          #type.predict = "lp",
                          ...) {
  if (is.null(data) && is.null(newdata)) {
    stop("Must specify either `data` or `newdata` argument.", call. = FALSE)
  }

  augment_columns(x, data, newdata,
                  #type.predict = type.predict,
                  #type.residuals = type.residuals
  )
}
