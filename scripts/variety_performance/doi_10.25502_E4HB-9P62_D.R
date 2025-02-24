
"
Title: N2Africa agronomy trials - Rwanda, 2010
  
Description: N2Africa is to contribute to increasing biological nitrogen fixation and productivity 
of grain legumes among African smallholder farmers which will contribute to enhancing soil fertility, 
improving household nutrition and increasing income levels of smallholder farmers. As a vision of success,
N2Africa will build sustainable, long-term partnerships to enable African smallholder farmers to benefit 
from symbiotic N2-fixation by grain legumes through effective production technologies including inoculants
and fertilizers adapted to local settings. A strong national expertise in grain legume production and 
N2-fixation research and development will be the legacy of the project. The project is implemented in 
five core countries (Ghana, Nigeria, Tanzania, Uganda and Ethiopia) and six other countries (DR Congo, 
Malawi, Rwanda, Mozambique, Kenya & Zimbabwe) as tier one countries.

"
carob_script <- function(path) {
  
  uri <- "doi:10.25502/E4HB-9P62/D"
  dataset_id <- agro::get_simple_URI(uri)
  group <- "variety_performance"
  
  ## data set level data 
  dset <- data.frame(
    dataset_id = dataset_id,
    group=group,
    uri=uri,
    publication="",
    data_citation = "Vanlauwe, B., Adjei-Nsiah, S., Woldemeskel, E., Ebanyat, P., Baijukya, F., Sanginga, J.-M.,
    Woomer, P., Chikowo, R., Phiphira, L., Kamai, N., Ampadu-Boakye, T., Ronner, E., Kanampiu, F., Giller,
    K., Baars, E., & Heerwaarden, J. van. (2020). N2Africa agronomy trials - Rwanda, 2010 [Data set]. 
    International Institute of Tropical Agriculture (IITA). https://doi.org/10.25502/E4HB-9P62/D",
    data_institutions = "IITA",
    carob_contributor="Rachel Mukami",
    experiment_type="variety_performance",
    has_weather=FALSE,
    has_management=FALSE
  )
  
  ## download and read data 
  
  ff  <- carobiner::get_data(uri, path, group)
  js <- carobiner::get_metadata(dataset_id, path, group, major=1, minor=0)
  dset$license <- carobiner::get_license(js)
  
  # reading the data.csv data
  f <- ff[basename(ff) == "data.csv"]
  d <- read.csv(f)
  
  d$trial_id <- d$experiment_id
  d$rep <- d$replication_no
  
  # Fertilizer rates: TSP and DAP will be applied using a uniform rate of 30 kg P per hectare; KCl at 30 kg K/ha 
  # and Urea split (50-50) applied at a rate of 60 kg N/ha
  
  d$treatments <- paste("main treatment: ",d$main_treatment," |","subtreatment inoculation : ",d$sub_treatment_inoc)
  d$treatment <- d$treatments
  d$planting_date <- as.Date(paste(d$planting_date_yyyy,d$planting_date_mm,d$planting_date_dd, sep = "-"))
  d$start_date <- d$planting_date
  
  d$fertilizer_type <- d$sub_treatment_inoc
  d$P_fertilizer <- ifelse(d$fertilizer_type == "DAP"|d$fertilizer_type == "TSP"|d$fertilizer_type == "TSP/KCL"|
                             d$fertilizer_type == "TSP/KCL+UREA"|d$fertilizer_type == "TSP/KCL +UREA"|d$fertilizer_type == "TSP/KCl"|
                             d$fertilizer_type == "TSP/KCl+UREA"|d$fertilizer_type == "TSP/KCL/UREA"|
                             d$fertilizer_type == "TSP/KCl/Urea"|d$fertilizer_type == "TSP/KCl+urea",30,NA)
  
  d$K_fertilizer <- ifelse(d$fertilizer_type == "TSP/KCL"|d$fertilizer_type == "TSP/KCL+UREA"|
                             d$fertilizer_type == "TSP/KCL +UREA"|d$fertilizer_type == "TSP/KCl"|
                             d$fertilizer_type == "TSP/KCl+UREA"|d$fertilizer_type == "TSP/KCL/UREA"|
                             d$fertilizer_type == "TSP/KCl/Urea"|d$fertilizer_type == "TSP/KCl+urea",30,NA)
  
  d$N_fertilizer <- ifelse(d$fertilizer_type == "PK6+Urea"|d$fertilizer_type == "PK6 +Urea"|d$fertilizer_type == "TSP/KCL+UREA"|
                             d$fertilizer_type == "TSP/KCL +UREA"|d$fertilizer_type == "TSP/KCl+UREA"|d$fertilizer_type == "TSP/KCL/UREA"|
                             d$fertilizer_type == "TSP/KCl/Urea"|d$fertilizer_type == "TSP/KCl+urea",60,NA)
  
  
  
  d$harvest_date <- as.Date(paste(d$date_harvest_yyyy,d$date_harvest_mm,d$date_harvest_dd, sep = "-"))
  d$end_date <-d$harvest_date
  d$grain_weight <- as.numeric(d$dry_weight_100_seeds)*10
  d$yield <- d$grain_yield_ha_calc
  d$residue_yield <- d$tot_stover_yield_haulm_husks_calc
  
  d[, c("above_ground_dry_biomass", "root_dry_weight_roots_no_nodules","nodule_dry_weight")] <- 
    lapply(d[, c("above_ground_dry_biomass", "root_dry_weight_roots_no_nodules","nodule_dry_weight")], as.numeric)
  
  d$biomass_total <- (d$above_ground_dry_biomass + d$root_dry_weight_roots_no_nodules+d$nodule_dry_weight)

  x <- d[,c("trial_id","rep","treatment","variety","start_date","end_date","grain_weight","yield","residue_yield",
            "biomass_total", "fertilizer_type","N_fertilizer","K_fertilizer","P_fertilizer")]
  
  # reading the general.csv data
  f <- ff[basename(ff) == "general.csv"]
  d1 <- read.csv(f)
  d1$trial_id <- d1$experiment_id
  d1$location <- d1$action_site
  d1$adm1 <- d1$mandate_area_name
  x1 <- d1[,c("trial_id","location","adm1","country","crop")]
  
  # reading the soil_properties.csv data
  f <- ff[basename(ff) == "soil_properties.csv"]
  d2 <- read.csv(f)
  d2$trial_id <- d2$experiment_id
  d2$soil_pH <- d2$ph
  d2$soil_sand <- d2$sand
  d2$soil_clay <- d2$clay
  d2$soil_N <- d2$tot_nitrogen
  d2$soil_K <- d2$k
  x2 <- d2[,c("trial_id","soil_pH","soil_sand","soil_clay","soil_N","soil_K")]
  
  
  # combining into 1 data set
  y <- merge(x,x1,by = "trial_id",all = TRUE)
  w <- merge(y,x2,by = "trial_id",all = TRUE)
  
  w$dataset_id <- dataset_id
  w$on_farm <- "yes"
  w$latitude <- -1.94028
  w$longitude <- 29.87389
  w$crop <- ifelse(w$crop %in% c("Bush Beans","Climbing Beans","Bush bean","Bush BEAN","Bush BEANS ","Bush BEANS",
                                  "Climbing BEANS ","Climbing bean"),"common bean",
                    ifelse(w$crop %in% c("Soybeans","SOY BEANS INPUT","SOYBEAN","Climbing bean","SOYBEAN "),"soybean","common bean")) # filled all NA values with common bean crop
  # all scripts must end like this
  carobiner::write_files(dset, w, path, dataset_id, group)
  TRUE
}

