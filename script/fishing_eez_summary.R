# A function for calculating the proportion of time spent fishing in the various exclusive economic zones, based on vessel trajectories. This function is used after the 
# trajectory_with_events_gfw function, which associates a fishing event with each AIS point on a trajectory. 

#data is the dataframe output from the trajectory_with_events_gfw function. It contains AIS trajectories with a column "event" indicating for each 
# AIS data point if a fishing was occuring or not based on Gloibal fishing watch events

# eez is economic exclusive zones polygons in sf format

fishing_eez_summary <- function(data, eez, start_date, end_date){
  
  sf_use_s2(FALSE)
  
  eez_name <- eez %>%
    st_drop_geometry() %>%
    mutate(geoname = str_replace(str_replace_all(tolower(geoname), " ", "_"), "exclusive_economic_zone", "eez")) %>%
    pull(geoname)
  
  
  intersection <- st_intersects(data %>%
                                  st_as_sf (coords = c("lon", "lat"), crs = 4326),
                                eez, sparse = FALSE) %>%
    as_tibble ()
  
  colnames(intersection) <- eez_name
  
  data <- data %>% 
    bind_cols(intersection)
  
  #calculate time spent fishing in each eez
  
  data <- data %>%
    filter(timestamp >= ymd(start_date) & timestamp <= ymd(end_date)) %>%
    #for fishing time to be counted, two consecutive points must be associated with a fishing event and these two points must be associated with the same event.
    with_groups(vessel_mmsi, mutate, diff_time = ifelse(event == "fishing" & lead(event) == "fishing" & lead(event_id) == event_id, diff_time, NA)) %>%
    mutate(other_eez = if_else(rowSums(select(., ends_with("eez")) == TRUE) == 0, TRUE, FALSE)) %>%
    pivot_longer(cols = select(., ends_with("eez")) %>% colnames (), names_to = "eez_name", values_to = "eez_value") %>%
    filter(event == "fishing" & eez_value == TRUE) %>%
    mutate(year = year(timestamp)) %>%
    with_groups(c("vessel_mmsi", "vessel_name", "year", "eez_name"), summarise, effort = sum(diff_time, na.rm = T)/1440) %>% # effort expressed in days
    pivot_wider (names_from = eez_name, values_from = effort) %>%
    mutate(effort_all = rowSums(select(., ends_with("eez")), na.rm = TRUE)) %>%
    mutate_at(vars(matches("eez")), ~round((.*100)/effort_all,1))
  
  # we replace all na value by 0
  
  data[is.na(data)] <- 0
  
  return(data)
}

