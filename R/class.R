################################################################################
##
##   phreda: Phenological event simulation, courtesy of Wenjie Wang's reda
##   package.
##   Copyright (C) 2018 Luke Zachmann.
##
##   This program incorporates a modified version of the R package reda.
##   Copyright (C) 2015-2018 Wenjie Wang, Haoda Fu, and Jun Yan.
##
##   These R packages are free software: You can redistribute them and/or
##   modify them under the terms of the GNU General Public License as published
##   by the Free Software Foundation, either version 3 of the License, or
##   any later version (at your option). See the GNU General Public License
##   at <http://www.gnu.org/licenses/> for details.
##
##   These R packages are distributed in the hope that they will be useful,
##   but WITHOUT ANY WARRANTY without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
##
################################################################################


##' An S4 Class Representing Formula Response
##'
##' The class \code{Survr} is an S4 that represents a formula response for
##' recurrent event data model.  The function \code{\link{Survr}} produces
##' objects of this class.  See ``Slots'' for details.
##'
##' @aliases Survr-class
##'
##' @slot .Data A numeric matrix object.
##' @slot ID A charactrer vector for original subject identificator.
##' @slot check A logical value indicating whether to performance data checking.
##' @slot ord An integer vector for increasingly ordering data by \code{ID},
##'     \code{time}, and \code{1 - event}.
##'
##' @seealso \code{\link{Survr}}
##' @export
setClass(
    "Survr",
    contains = "matrix",
    slots = c(
        ID = "factor",
        check = "logical",
        ord = "integer"
    )
)


##' An S4 Class Representing a Fitted Model
##'
##' The class \code{rateReg} is an S4 class that represents a fitted model.  The
##' function \code{\link{rateReg}} produces objects of this class.  See
##' ``Slots'' for details.
##'
##' @aliases rateReg-class
##'
##' @slot call Function call.
##' @slot formula Formula.
##' @slot nObs A positive integer
##' @slot spline A list.
##' @slot estimates A list.
##' @slot control A list.
##' @slot start A list.
##' @slot na.action A character vector (of length one).
##' @slot xlevels A list.
##' @slot contrasts A list.
##' @slot convergCode A nonnegative integer.
##' @slot logL A numeric value.
##' @slot fisher A numeric matrix.
##'
##' @seealso \code{\link{rateReg}}
##' @export
setClass(
    Class = "rateReg",
    slots = c(
        call = "call",
        formula = "formula",
        nObs = "integer",
        spline = "list",
        estimates = "list",
        control = "list",
        start = "list",
        na.action = "character",
        xlevels = "list",
        contrasts = "list",
        convergCode = "integer",
        logL = "numeric",
        fisher = "matrix"
    ),
    validity = function(object) {
        ## check on nObs
        if (object@nObs <= 0)
            return("Number of observations must be a positive integer.")
        ## check on knots
        knots <- object@spline$knots
        Boundary.knots <- object@spline$Boundary.knots
        if (length(knots)) { # if there exists internal knots
            if (min(knots) < min(Boundary.knots) ||
                max(knots) > max(Boundary.knots))
                return(paste("Internal knots must all lie in the",
                             "coverage of boundary knots."))
        }
        ## check on degree
        degree <- object@spline$degre
        if (degree < 0)
            return("Degree of spline bases must be a nonnegative integer.")
        ## check on df
        dfVec <- do.call("c", object@spline$df)
        dfValid <- is.integer(dfVec) && all(dfVec >= 0)
        if (! dfValid)
            return("Degree of freedom must be nonnegative integers.")
        ## else return
        TRUE
    }
)


##' An S4 Class Representing Summary of a Fitted Model
##'
##' The class \code{summary.rateReg} is an S4 class with selective slots of
##' \code{rateReg} object.  See ``Slots'' for details.  The function
##' \code{\link{summary,rateReg-method}} produces objects of this class.
##'
##' @aliases summary.rateReg-class
##'
##' @slot call Function call.
##' @slot spline A character.
##' @slot knots A numeric vector.
##' @slot Boundary.knots A numeric vector.
##' @slot covarCoef A numeric matrix.
##' @slot frailtyPar A numeric matrix.
##' @slot degree A nonnegative integer.
##' @slot baseRateCoef A numeric matrix.
##' @slot logL A numeric value.
##'
##' @seealso \code{\link{summary,rateReg-method}}
##' @export
setClass(
    Class = "summary.rateReg",
    slots = c(
        call = "call",
        spline = "character",
        knots = "numeric",
        Boundary.knots = "numeric",
        covarCoef = "matrix",
        frailtyPar = "matrix",
        degree = "integer",
        baseRateCoef = "matrix",
        logL = "numeric"
    ),
    validity = function(object) {
        ## check on knots
        if (length(object@knots)) { # if there exists internal knots
            if (min(object@knots) < min(object@Boundary.knots) ||
                max(object@knots) > max(object@Boundary.knots))
                return(paste("Internal knots must all lie in the",
                             "coverage of boundary knots."))
        }
        ## check on degree
        if (object@degree < 0)
            return("Degree of spline bases must be a nonnegative integer.")
        ## else return
        TRUE
    }
)


##' An S4 Class Representing Sample MCF
##'
##' An S4 class that represents sample mean cumulative function (MCF) from data.
##' The function \code{\link{mcf}} produces objects of this class.
##'
##' @aliases mcf.formula-class
##'
##' @slot formula Formula.
##' @slot data A data frame.
##' @slot MCF A data frame.
##' @slot origin A named numeric vector.
##' @slot multiGroup A logical value.
##' @slot variance A character vector.
##' @slot logConfInt A logical value.
##' @slot level A numeric value.
##'
##' @seealso \code{\link{mcf,formula-method}}.
##' @export
setClass(
    Class = "mcf.formula",
    slots = c(
        formula = "formula",
        data = "data.frame",
        MCF = "data.frame",
        origin = "numeric",
        multiGroup = "logical",
        variance = "character",
        logConfInt = "logical",
        level = "numeric"
    )
)


##' An S4 Class Respresenting Estimated MCF from a Fitted Model
##'
##' An S4 class that represents estimated mean cumulative function (MCF) from
##' Models. The function \code{\link{mcf}} produces objects of this class.
##'
##' @aliases mcf.rateReg-class
##'
##' @slot call Function call.
##' @slot formula Formula.
##' @slot spline A character.
##' @slot knots A numeric vector.
##' @slot degree A nonnegative integer.
##' @slot Boundary.knots A numeric vector.
##' @slot newdata A numeric matrix.
##' @slot MCF A data frame.
##' @slot level A numeric value between 0 and 1.
##' @slot na.action A length-one character vector.
##' @slot control A list.
##' @slot multiGroup A logical value.
##'
##' @seealso \code{\link{mcf,rateReg-method}}
##' @export
setClass(
    Class = "mcf.rateReg",
    slots = c(
        call = "call",
        formula = "formula",
        spline = "character",
        knots = "numeric",
        degree = "integer",
        Boundary.knots = "numeric",
        newdata = "matrix",
        MCF = "data.frame",
        level = "numeric",
        na.action = "character",
        control = "list",
        multiGroup = "logical"
    ),
    validity = function(object) {
        ## check on knots
        if (length(object@knots)) { # if there exists internal knots
            if (min(object@knots) < min(object@Boundary.knots) ||
                max(object@knots) > max(object@Boundary.knots)) {
                return(wrapMessages(
                    "Internal knots must all lie in the",
                    "coverage of boundary knots."
                ))
            }
        }
        ## check on degree
        if (object@degree < 0)
            return("Degree of spline bases must be a nonnegative integer.")
        ## check on level
        if (object@level <= 0 || object@level >= 1)
            return("Confidence level mush be between 0 and 1.")
        ## else return
        TRUE
    }
)


##' An S4 Class Representing Estimated Baseline Rate Function
##'
##' An S4 class that represents the estimated baseline rate function from model.
##' The function \code{\link{baseRate}} produces objects of this class.
##'
##' @aliases baseRate.rateReg-class
##'
##' @slot baseRate A data frame.
##' @slot level A numeric value.
##'
##' @seealso \code{\link{baseRate,rateReg-method}}
##' @export
setClass(
    Class = "baseRate.rateReg",
    slots = c(
        baseRate = "data.frame",
        level = "numeric"
    )
)


##' An S4 Class for Simulated Recurrent Event or Survival Times
##'
##' An S4 class that represents the simulated recurrent event or survival time
##' from one stochastic process. The function \code{\link{simEvent}} produces
##' objects of this class.
##'
##' @aliases simEvent-class
##'
##' @slot .Data A numerical vector of possibly length zero.
##' @slot call A function call.
##' @slot z A list.
##' @slot zCoef A list.
##' @slot rho A list.
##' @slot rhoCoef A numerical vector.
##' @slot frailty A list.
##' @slot origin A list.
##' @slot endTime A list.
##' @slot censoring A list.
##' @slot recurrent A logical vector.
##' @slot interarrival A list.
##' @slot relativeRisk A list.
##' @slot method A character vector.
##'
##' @seealso \code{\link{simEvent}}
##' @export
setClass(
    Class = "simEvent",
    contains = "numeric",
    slots = c(
        call = "call",
        z = "list",
        zCoef = "list",
        rho = "list",
        rhoCoef = "numeric",
        frailty = "list",
        origin = "list",
        endTime = "list",
        censoring = "list",
        recurrent = "logical",
        interarrival = "list",
        relativeRisk = "list",
        method = "character"
    )
)


##' An S4 Class Representing the Two-Sample Pseudo-Score Test Results
##'
##' An S4 class that represents the results of the two-sample pseudo-score tests
##' between two sample mean cumulative functions.  The function
##' \code{\link{mcfDiff.test}} produces objects of this class.
##'
##' @aliases mcfDiff.test-class
##'
##' @slot .Data A numeric matrix.
##' @slot testVariance A character vector.
##'
##' @seealso \code{\link{mcfDiff.test}}
##' @export
setClass(
    Class = "mcfDiff.test",
    contains = "matrix",
    slots = c(
        testVariance = "character"
    ),
    prototype = {
        mat <- matrix(NA_real_, nrow = 2L, ncol = 5L)
        row.names(mat) <- c("Constant Weight", "Linear Weight")
        colnames(mat) <- c("Statistic", "Variance", "Chisq",
                           "DF", "Pr(>Chisq)")
        attr(mat, "testVariance") <- "none"
        mat
    }
)


##' An S4 Class Representing Sample MCF Difference
##'
##' An S4 class that represents the difference between two sample mean
##' cumulative functions from data.  The function \code{\link{mcfDiff}}
##' produces objects of this class.
##'
##' @aliases mcfDiff-class
##'
##' @slot call A function call.
##' @slot MCF A data frame.
##' @slot origin A named numeric vector.
##' @slot variance A character vector.
##' @slot logConfInt A logical value.
##' @slot level A numeric value.
##' @slot test A \code{mcfDiff.test} class object.
##'
##' @seealso \code{\link{mcfDiff}}
##' @export
setClass(
    Class = "mcfDiff",
    slots = c(
        call = "call",
        MCF = "data.frame",
        origin = "numeric",
        variance = "character",
        logConfInt = "logical",
        level = "numeric",
        test = "mcfDiff.test"
    )
)
