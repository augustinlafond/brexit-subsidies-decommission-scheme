make_grid_gfw <- function(df, def) {
  df_offset <-df %>% 
    mutate(lat=lat-def/2,
           lon=lon-def/2)
  bbox <- st_bbox(df_offset %>% 
                    st_as_sf(coords = c("lon", "lat"), crs = 4326))
  df_offset <- st_as_sf(st_make_grid(st_as_sfc(bbox),
                              what = "polygons", 
                              cellsize = def)) %>%
    st_join(df %>%
             st_as_sf(coords = c("lon", "lat"), crs = 4326))%>%## on écrit le fichier en WGS84 car c'est le SCR d'origine de GFW
    filter(!is.na(apparent_fishing_hours))
}

