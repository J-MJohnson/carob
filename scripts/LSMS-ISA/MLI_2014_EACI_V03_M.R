# R script for "carob"

## ISSUES
# ....


carob_script <- function(path) {

return( TRUE)


"
	https://microdata.worldbank.org/index.php/catalog/2583/download/47803
	Description:


"

	ht  <- httr::GET(url)

	uri <- "doi:______"
	dataset_id <- agro::get_simple_URI(uri)
	group <- ""
	## dataset level data 
	dset <- data.frame(
	   dataset_id = dataset_id,
	   group=group,
	   uri=uri,
	   publication="publication doi",
	   contributor="Your name",
	   experiment_type="___",
	   has_weather=FALSE,
	   has_management=FALSE
	)

## download and read data 

	ff  <- carobiner::get_data(uri, path, group)
	js <- carobiner::get_metadata(dataset_id, path, group, major=2, minor=1)
	dset$license <- carobiner::get_license(js)


	f <- ff[basename(ff) == "_____________"]

	d <- read.csv(f)
	d <- readxl::read_excel(f) |> as.data.frame()
	
	# process file(s)
	d <- carobiner::change_names(d, from, to)
	d$dataset_id <- dataset_id

# all scripts must end like this
	carobiner::write_files(dset, d, path, dataset_id, group)
	TRUE
}
