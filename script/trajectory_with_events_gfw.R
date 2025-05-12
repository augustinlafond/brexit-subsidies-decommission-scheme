#Author : Augustin Lafond
#Date : 11/10/2024

# A function to read GFW trajectories data and to join each AIS data point with fishing events downloaded from the GFW API. 
# AIS trajectories have to be manually downloaded on the Global Fishing Watch platform
# Then store the data in your R project folder
# token_gfw is your API access token to get access to GFW data
# start_date and end_date are date in "%Y-%m-%d" format. It allows to filter data to the corresponding date interval. 

#path is a character vector containing the path of each trajectory data file. It can be a vector of length one (if there is only one trajectory) or a vector of length > 1 if you are working on several trajectories

trajectory_with_events_gfw <- function(path, start_date, end_date, token_gfw){
  
  trajectories_gfw <- lapply(path, read.csv) 
  
  for (i in 1:length(trajectories_gfw)){
    
    trajectories_gfw[[i]] <- cbind(trajectories_gfw[[i]], vessel_name = str_extract(path[i], "^(.+/)([A-Z].+)([:blank:][:punct:].+)", group = 2))
  
    }
  
  trajectories_gfw <- do.call("rbind", trajectories_gfw) 
  
  #clean data
  trajectories_gfw <- trajectories_gfw %>%
    mutate(timestamp = ymd_hms(timestamp),
           diff_time = as.numeric(difftime(lead(timestamp), timestamp, units = "mins")), # calculate the delay between, two AIS signals in minutes
           vessel_mmsi = str_extract(seg_id, "(^[0-9]{9})([:punct:].+$)", group = 1),
           vessel_name = str_trim(str_remove(vessel_name, "F_V|FV|FV_|F_V\\.|V_F"), side = "both"), 
           vessel_name = str_remove(vessel_name, "_|\\.")) %>% 
    with_groups(c("vessel_name", "vessel_mmsi"), slice, -n()) %>%
    filter(timestamp >= ymd(start_date) & timestamp <= ymd(end_date))
  

#create a vector with vessel mmsi  
  vessel_id <- trajectories_gfw %>%
    distinct(vessel_mmsi) %>%
    mutate(gfw_id = NA)
  
  #download GFW vessel ids
  
  for (i in 1:nrow(vessel_id)) {
    id <- get_vessel_info(
      query = vessel_id[i, 1],
      search_type = "search",
      key = token_gfw)
    
    if (!is.null(id)) {
      vessel_id [i, 2] <- paste(id$selfReportedInfo %>% 
                                  select(id = vesselId, mmsi = ssvid, shipname) %>%
                                  filter (mmsi == vessel_id %>% slice(i) %>% pull(vessel_mmsi) & !is.na(shipname)) %>% # in some cases the mmsi found is different from the one indicated in the search
                                  pull (id), collapse = ",")
    }
    else if (is.null(id)) {
      vessel_id [i, 2] <- NA
    }
  }
  
#download gfw fishing events

vessel_id <- unlist(strsplit(vessel_id %>% filter(!is.na(gfw_id)) %>% pull(gfw_id), ","))

fishing_events <- foreach(i=1:length(vessel_id)) %do% 
  get_event(event_type = 'FISHING',
            vessels = vessel_id[i],
            start_date = start_date,
            end_date = end_date,
            key = token_gfw)

fishing_events <- fishing_events %>%
  bind_rows() %>%
  mutate(id = 1 : n()) %>%
  with_groups(id, mutate, vessel_mmsi =  unlist(map(vessel, 3))[1])

#we join together fishing events and trajectories to evaluate vessel activity for each AIS point of the trajectory

trajectories_gfw <- trajectories_gfw %>%
  left_join(fishing_events %>%
              arrange(vessel_mmsi, start) %>%
              mutate(event_interval = interval (start, end)) %>%
              dplyr::select(event_interval, vessel_mmsi) %>%
              with_groups(vessel_mmsi, summarise, fishing_intervals = list(event_interval)), by = "vessel_mmsi") %>%
  rowwise () %>%
  mutate(event_count = length(fishing_intervals)) %>% # we remove vessels with no fishing event associated with
  ungroup() %>%
  filter(event_count > 0) %>%
  select(-event_count) %>%
  rowwise () %>%
  mutate(event = ifelse(any(timestamp %within% fishing_intervals), "fishing", NA)) %>%
  mutate(event_id = ifelse(event == "fishing", which(timestamp %within% fishing_intervals == TRUE), NA)) %>%
  select(-fishing_intervals) %>%
  ungroup ()

}

