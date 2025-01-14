

"Title: N2Africa farm monitoring - Malawi, 2011 - 2012

Description: N2Africa is to contribute to increasing biological nitrogen fixation and productivity
of grain legumes among African smallholder farmers which will contribute to enhancing soil fertility,
improving household nutrition and increasing income levels of smallholder farmers. As a vision of success,
N2Africa will build sustainable, long-term partnerships to enable African smallholder farmers to benefit
from symbiotic N2-fixation by grain legumes through effective production technologies including inoculants
and fertilizers adapted to local settings. A strong national expertise in grain legume production and
N2-fixation research and development will be the legacy of the project.The project is implemented in
five core countries (Ghana, Nigeria, Tanzania, Uganda and Ethiopia) and six other countries (DR Congo,
Malawi, Rwanda, Mozambique, Kenya & Zimbabwe) as tier one countries.
"
carob_script <- function(path) {
  
  uri <- "https://doi.org/10.25502/14m8-cs44/d"
  dataset_id <- agro::get_simple_URI(uri)
  group <- "variety_performance"
  
  ## data set level data
  dset <- data.frame(
    dataset_id = dataset_id,
    group=group,
    uri=uri,
    publication="",
    data_citation = "Vanlauwe, B., Adjei-Nsiah, S., Woldemeskel, E., Ebanyat, P., Baijukya, F., Sanginga, 
    J.-M., Woomer, P., Chikowo, R., Phiphira, L., Kamai, N., Ampadu-Boakye, T., Ronner, E., Kanampiu, F., 
    Giller, K., Baars, E., & Heerwaarden, J. van. (2020). N2Africa farm monitoring - Malawi, 2011 - 2012 [Data set]. 
    International Institute of Tropical Agriculture (IITA). https://doi.org/10.25502/14M8-CS44/D",
    data_institutions = "IITA",
    carob_contributor="Rachel Mukami",
    experiment_type="variety_performance",
    has_weather=TRUE,
    has_management=TRUE
  )
  
  ## download and read data
  
  ff  <- carobiner::get_data(uri, path, group)
  js <- carobiner::get_metadata(dataset_id, path, group, major=1, minor=0)
  dset$license <- carobiner::get_license(js)
  
  # reading the datasets
  f <- ff[basename(ff) == "a_general.csv"]
  d <- data.frame(read.csv(f))
  d$trial_id <- d$farm_id
  d$adm1 <- d$district
  d$adm2 <- d$sector_ward
  d$adm3 <- d$vilage
  d <- d[,c("trial_id","season","country","adm1","adm2","adm3")]
  
  f1 <- ff[basename(ff) == "c_use_of_package_2.csv"]
  d1 <- data.frame(read.csv(f1))
  d1$trial_id <- d1$farm_id
  d1$crop <- tolower(d1$crop_1)
  d1$crop[d1$crop =="bush bean"] <- "common bean"
  d1$crop[d1$crop == "sweet potato"] <- "sweetpotato"
  d1$variety <- d1$variety_1
  d1$inoculated <- ifelse(d1$inoculant_used == "Y","yes",
                          ifelse(d1$inoculant_used == "N","no",NA))
  d1$OM_used <- ifelse(d1$organic_fert_type %in% c("Animal dung","Animal manure","Compost","Compost manure",
                                                     "Farmyard","Farm yard","Compost, animal manure"),"yes",
                       ifelse(d1$organic_fert_amount > 0,"yes","no"))
  d1$OM_type <- ifelse(d1$organic_fert_type %in% c("Animal dung","Animal manure","Compost","Compost manure",
                                                   "Farmyard","Farm yard","Compost, animal manure"),d1$organic_fert_type,
                       ifelse(d1$organic_fert_amount > 0,d1$organic_fert_type,NA))
  d1$OM_applied <- as.numeric(d1$organic_fert_amount)*1000 # converting into g
  d1$fertilizer_type <- d1$mineral_fert_type
  d1$N_fertilizer <- ifelse(d1$fertilizer_type %in% c("NPK,UREA","UREA"),d1$mineral_fert_amount * 0.46,  # assumption is that mineral fert amount is in kg
                            ifelse(d1$fertilizer_type == "23:21:0+4S",d1$mineral_fert_amount * 0.23,
                                   ifelse(d1$fertilizer_type %in% c("D-Compound","D Compound","D Compmound","S-Compound"),
                                          d1$mineral_fert_amount * 0.08,
                                          ifelse(d1$fertilizer_type %in% c("Super D","Super d"),
                                                 d1$mineral_fert_amount * 0.01,NA))))
  
  d1$P_fertilizer <- ifelse(d1$fertilizer_type == "TSP",
                            d1$mineral_fert_amount * 0.46*((2*31)/(2*31+5*16)),
                            ifelse(d1$fertilizer_type %in% c("Sympal","sympal","SYMPAL"),
                                   d1$mineral_fert_amount * 0.23*((2*31)/(2*31+5*16)),
                                   ifelse(d1$fertilizer_type %in% c("NPK,UREA","23:21:0+4s","S-Compound"),
                                          d1$mineral_fert_amount * 0.21*((2*31)/(2*31+5*16)),
                                          ifelse(d1$fertilizer_type %in% c("D-Compound","D Compound","D Compmound"),
                                                 d1$mineral_fert_amount * 0.18*((2*31)/(2*31+5*16)),
                                                 ifelse(d1$fertilizer_type %in% c("Super D","Super d"),
                                                        d1$mineral_fert_amount * 0.24*((2*31)/(2*31+5*16)),
                                                        ifelse(d1$fertilizer_type %in% c("Single super phosphate",
                                                                                         "Single super phosphate "," Single Super phosphate","Super phosphate"),
                                                               d1$mineral_fert_amount * 0.145,NA)))))) # takes into account atomic weight of both P and O
  
  d1$K_fertilizer <- ifelse(d1$fertilizer_type %in% c("Sympal","sympal","SYMPAL","D-Compound","D Compound","D Compmound"),
                            d1$mineral_fert_amount * 0.15,
                            ifelse(d1$mineral_fert_type == "S-Compound",d1$mineral_fert_amount * 0.07,
                                   ifelse(d1$fertilizer_type %in% c("Super D","Super d"),d1$mineral_fert_amount * 0.20,NA)))
  d1 <- d1[,c("trial_id","crop","variety","inoculated","OM_used","OM_applied","OM_type","fertilizer_type","N_fertilizer","P_fertilizer","K_fertilizer")]
  
  
  f2 <- ff[basename(ff) == "c_use_of_package_4.csv"]
  d2 <- data.frame(read.csv(f2))
  d2$trial_id <- d2$farm_id
  d2$row_spacing <- d2$crop_1_spacing_row_to_row
  d2$plant_spacing <- d2$crop_1_spacing_plant_to_plant
  d2 <- d2[,c("trial_id","row_spacing","plant_spacing")] # assumption is spacing is in cm
  

  f3 <- ff[basename(ff) == "d_cropping_calendar.csv"]
  d3 <- data.frame(read.csv(f3))
  d3$trial_id <- d3$farm_id
  d3$start_date <- as.Date(paste(d3$date_planting_mm,d3$date_planting_dd,d3$date_planting_yyyy,sep = "/"),"%m/%d/%Y")
  d3 <- d3[,c("trial_id","start_date")]
  
  
  f4 <- ff[basename(ff) == "e_harvest.csv"]
  d4 <- data.frame(read.csv(f4))
  d4 <- d4[d4$crop_1_grain_unshelled == "Y",] # getting grain weights for only unshelled grains
  d4$trial_id <- d4$farm_id
  d4$grain_weight <- (as.numeric(d4$crop_1_area_harvested)*d4$crop_1_weight_grain *1000)/100 # standardizing to grain weight measured in g/100m2
  d4 <- d4[,c("trial_id","grain_weight")]
  
  f5 <- ff[basename(ff) == "g_farmer_assessment.csv"]  
  d5 <- data.frame(read.csv(f5))
  d5$trial_id <- d5$farm_id
  d5$yield <- 0 # yield is has no quantitative figures
  d5 <- d5[,c("trial_id","yield")] 
  
  # combining into one dataset
  z <- carobiner::bindr(d,d1,d2,d3,d4,d5)
  z$is_survey <- "yes"
  z$on_farm <- "no"
  z$longitude <- 34.30153
  z$latitude <- -13.25431
  z$dataset_id <- dataset_id
  z$country <- "Malawi"
  z$crop[is.na(z$crop)] <- "common bean" # filled NAs in crops with common bean
  
  z <- z[,c("dataset_id","trial_id","season","country","adm1","adm2","adm3","crop","variety",
            "start_date","inoculated","OM_used","OM_type","OM_applied","fertilizer_type",
            "N_fertilizer","P_fertilizer","K_fertilizer","grain_weight","yield","row_spacing","plant_spacing",
            "on_farm","is_survey","longitude","latitude")]
  
  # all scripts must end like this
  carobiner::write_files(dset, z, path, dataset_id, group)
  TRUE
}
