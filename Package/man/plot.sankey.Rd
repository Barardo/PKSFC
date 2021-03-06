% Generated by roxygen2 (4.0.2): do not edit by hand
\name{plot.sankey}
\alias{plot.sankey}
\title{Plot sfc objects as a Sankey, using a specific time simulation}
\usage{
plot.sankey(dataset, filename)

plot.sankey(dataset, filename, outputfile, period)
}
\arguments{

\item{dataset}{a matrix containing the results of an SFC simulation where the column names corresponds to the variables of the model}
\item{filename}{A csv file containing a Flow Matrix in symbolic form, using the same name of variables than the dataset}
\item{outputfile}{The name of the file to generate containing the plot}
\item{period}{The period to use for the values in the Sankey}


}
\description{
Plots the sankey of a specific dataset.
}
\examples{

}
\author{
Antoine Godin
}

