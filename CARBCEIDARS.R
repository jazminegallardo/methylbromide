#summarize the data 

setwd("~/Dropbox/MeBr/Data/CARB CEIDARS")

library(dplyr)
library(readr)
library(stringr)

# Set your folder path where the files are located
folder_path <- "~/Dropbox/MeBr/Data/CARB CEIDARS"

# List all CSVs matching the pattern
csv_files <- list.files(folder_path, pattern = "^[0-9]{4} CARB CEIDARS MeBr CA\\.csv$", full.names = TRUE)

# Initialize a list to store data
all_data <- list()

# Loop through each file
for (file in csv_files) {
  # Extract the year from the filename
  year <- str_extract(basename(file), "^[0-9]{4}")
  
  # Read CSV and add year column
  df <- read_csv(file, col_types = cols(.default = "c")) %>%
    mutate(year = year)
  
  all_data[[year]] <- df
}

# Combine all into one dataframe
CARBCEIDARS <- bind_rows(all_data)


#CO to  county 


library(dplyr)
library(readr)

# Create a lookup table for county codes and names
county_lookup <- tibble::tribble(
  ~CO, ~county,
  "1", "ALAMEDA",
  "2", "ALPINE",
  "3", "AMADOR",
  "4", "BUTTE",
  "5", "CALAVERAS",
  "6", "COLUSA",
  "7", "CONTRA COSTA",
  "8", "DEL NORTE",
  "09", "EL DORADO",
  "10", "FRESNO",
  "11", "GLENN",
  "12", "HUMBOLDT",
  "13", "IMPERIAL",
  "14", "INYO",
  "15", "KERN",
  "16", "KINGS",
  "17", "LAKE",
  "18", "LASSEN",
  "19", "LOS ANGELES",
  "20", "MADERA",
  "21", "MARIN",
  "22", "MARIPOSA",
  "23", "MENDOCINO",
  "24", "MERCED",
  "25", "MODOC",
  "26", "MONO",
  "27", "MONTEREY",
  "28", "NAPA",
  "29", "NEVADA",
  "30", "ORANGE",
  "31", "PLACER",
  "32", "PLUMAS",
  "33", "RIVERSIDE",
  "34", "SACRAMENTO",
  "35", "SAN BENITO",
  "36", "SAN BERNARDINO",
  "37", "SAN DIEGO",
  "38", "SAN FRANCISCO",
  "39", "SAN JOAQUIN",
  "40", "SAN LUIS OBISPO",
  "41", "SAN MATEO",
  "42", "SANTA BARBARA",
  "43", "SANTA CLARA",
  "44", "SANTA CRUZ",
  "45", "SHASTA",
  "46", "SIERRA",
  "47", "SISKIYOU",
  "48", "SOLANO",
  "49", "SONOMA",
  "50", "STANISLAUS",
  "51", "SUTTER",
  "52", "TEHAMA",
  "53", "TRINITY",
  "54", "TULARE",
  "55", "TUOLUMNE",
  "56", "VENTURA",
  "57", "YOLO",
  "58", "YUBA"
)


# Join the county names into your data
CARBCEIDARSV2 <- CARBCEIDARS %>%
  left_join(county_lookup, by = "CO")

CARBCEIDARSV2 %>%
  #filter(DISN == "SOUTH COAST AQMD" | DISN == "ANTELOPE VALLEY AQMD" ) %>%
  summarise(unique_facilities = n_distinct(FACID))

CARBCEIDARSV2 %>%
  filter(DISN == "SOUTH COAST AQMD" | DISN == "ANTELOPE VALLEY AQMD" ) %>%
  summarise(unique_facilities = n_distinct(FACID))

CARBCEIDARSV2 %>%
  filter(county == "LOS ANGELES") %>%
  summarise(unique_facilities = n_distinct(FACID))





### Geocoding ####

library(dplyr)
library(ggmap)
register_google(key = "https://console.cloud.google.com/google/maps-apis/credentials?inv=1&invt=Ab48GA&project=ej-reparations-jpb")


# Step 1: Create full address
CARBCEIDARSV2 <- CARBCEIDARSV2 %>%
  mutate(
    full_address = paste(FSTREET, FCITY, county, "CA", sep = ", ")
  )

# Remove missing/blank addresses, then keep only unique ones
CARBCEIDARSV2_clean <- CARBCEIDARSV2 %>%
  filter(!is.na(full_address) & full_address != "") %>%
  distinct(full_address, .keep_all = TRUE)

#geocode address
geocoded_google <- geocode(
  location = CARBCEIDARSV2_clean$full_address,
  output = "more",
  source = "google"
)

#merge back to unique only dataset
CARBCEIDARSV2_geocoded <- bind_cols(
  CARBCEIDARSV2_clean,
  geocoded_google %>% select(lat, lon)
) %>%
  rename(latitude = lat, longitude = lon)

#mannually fix FACID ==1
CARBCEIDARSV2_geocoded <- CARBCEIDARSV2_geocoded %>%
  mutate(
    latitude = ifelse(FACID == 1, 38.67277892152629, latitude),
    longitude = ifelse(FACID == 1, -121.21185919013638, longitude)
  )


write_csv(CARBCEIDARSV2_geocoded, "CARBCEIDARSV2_geocoded.csv")

## Map ####

library(sf)
library(tigris)
library(ggplot2)

ca_counties <- counties(state = "CA", cb = TRUE, class = "sf")

facilities_sf <- CARBCEIDARSV2_geocoded %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

ggplot() +
  geom_sf(data = ca_counties, fill = NA, color = "black", size = 0.3) +
  geom_sf(data = facilities_sf, color = "red", size = 2, alpha = 0.7) +
  theme_minimal() +
  labs(
    title = "Geocoded Facilities in California",
    caption = "Red dots = facility locations"
  )

# Normalize both to lowercase
south_coast_counties <- CARBCEIDARSV2_geocoded %>%
  filter(DISN == "SOUTH COAST AQMD") %>%
  mutate(county = tolower(trimws(county))) %>%
  distinct(county) %>%
  pull(county)

ca_counties <- ca_counties %>%
  mutate(NAME_lower = tolower(trimws(NAME)))

# Now filter by normalized name
south_coast_sf <- ca_counties %>%
  filter(NAME_lower %in% south_coast_counties)

n_distinct(facilities_sf$FACID)

ggplot() +
  geom_sf(data = ca_counties, fill = NA, color = "gray", size = 0.3) +
  geom_sf(data = south_coast_sf, fill = NA, color = "purple", size = 1.5) +
  geom_sf(data = facilities_sf, color = "red", size = 2, alpha = 0.7) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()  
  ) +
  labs(
    title = "Fumigation Facilities in California \n
    Permitted 2016-2023 \n
    Total = 212* (202)",
    caption = "Purple = South Coast AQMD"
  )

#ONLY SCAQMD
south_coast_facilities_sf <- CARBCEIDARSV2_geocoded %>%
  mutate(county = tolower(trimws(county))) %>%
  filter(DISN == "SOUTH COAST AQMD") %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

nrow(south_coast_facilities_sf)
n_distinct(south_coast_facilities_sf$FACID)

ggplot() +
  #geom_sf(data = ca_counties, fill = NA, color = "gray", size = 0.3) +
  geom_sf(data = south_coast_sf, fill = NA, color = "purple", size = 1.5) +
  geom_sf(data = south_coast_facilities_sf, color = "red", size = 2, alpha = 0.7) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()  
  )  +
  labs(
    title = "Fumigation Facilities in SCAQMD \n
    Permitted 2016-2023 \n
    Total = 39* (2 =ANTELOPE VALLEY AQMD)",
    caption = "Purple = South Coast AQMD"
  )



#NOWWWW Just LA County 

library(sf)

# Only mainland part of LA County (filter by area)
la_mainland <- la_county_sf %>%
  st_cast("MULTIPOLYGON") %>%    # Split into individual parts
  st_cast("POLYGON") %>%         # Handle nested geometry
  mutate(area = st_area(.)) %>%
  arrange(desc(area)) %>%
  slice(1)                       # Keep the largest polygon = mainland

# Reproject to match maptiles
la_mainland_proj <- st_transform(la_mainland, 3857)

la_facilities_sf <- CARBCEIDARSV2_geocoded %>%
  filter(
    tolower(trimws(county)) == "los angeles",
    DISN == "SOUTH COAST AQMD",
    !is.na(latitude) & !is.na(longitude)
  ) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)


la_facilities_proj <- st_transform(la_facilities_sf, 3857)

n_distinct(la_facilities_sf$FACID)


# Get the basemap only for mainland LA
library(maptiles)

bg <- get_tiles(la_mainland_proj, provider = "CartoDB.Positron", crop = TRUE, zoom = 11)

library(ggplot2)
library(ggspatial)


ggplot() +
  layer_spatial(bg) +
  geom_sf(data = la_mainland_proj, fill = NA, color = "black", linewidth = 1) +
  geom_sf(data = la_facilities_proj, color = "red", size = 2, alpha = 0.7) +
  coord_sf() +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank()
  ) +
  labs(
    title = "Fumigation Facilities in Los Angeles County \n
    Total= 20* (2 ANTELOPE VALLEY AQMD)",
    caption = "Basemap: CartoDB.Positron via maptiles"
  )




#SUMMARY OF FACILITIES IN LOS ANGELES COUNTY
library(dplyr)

# Count unique facilities in Los Angeles County
la_facilities <- CARBCEIDARSV2 %>%
  group_by(county, year) %>%
 #filter(county == "LOS ANGELES") %>%
  #filter(year == "2023") %>%
  summarise(
    #unique_facilities = n_distinct(FACID),
    total_ems_lbs = sum(as.numeric(EMS), na.rm = TRUE)
  )

print(la_facilities)






library(dplyr)
library(ggplot2)

# Summarize total EMS by county and year
ems_by_county_year <- CARBCEIDARSV2 %>%
  #filter(county %in% c("LOS ANGELES", "SAN JOAQUIN", "ALAMEDA", "VENTURA", "TEHAMA", "KERN", "MADERA")) %>%
  #filter(county %in% c("SISKIYOU")) %>%
  mutate(EMS = as.numeric(EMS)) %>%
  group_by(county, year) %>%
  summarise(total_ems = sum(EMS, na.rm = TRUE), .groups = "drop")






# Plot: EMS over time by county
ggplot(ems_by_county_year, aes(x = as.integer(year), y = total_ems, color = county)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Total EMS by County and Year",
    x = "Year",
    y = "Total EMS (lbs)",
    color = "County"
  ) +
  theme_minimal()


### 

library(readr)
pur <- read_csv("pur_county_year_lbs.csv")

library(dplyr)
library(tidyr)


# Make sure both have "County" and "Year" columns
ems_long <- ems_by_county_year %>%
  rename(County = county, Year = year, Lbs = total_ems) %>%
  mutate(
    Year = as.integer(Year),
    Source = "CARB"
  )

pur_long <- pur %>%
  pivot_longer(
    cols = -County,
    names_to = "Year",
    values_to = "Lbs"
  ) %>%
  mutate(
    Year = as.integer(Year),
    Source = "PUR"
  )

combined_data <- bind_rows(ems_long, pur_long)



#Plot 
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

# Step 1: Create complete grid of all County, Year, Source combinations
all_combos <- expand_grid(
  County = unique(combined_data$County),
  Year = sort(unique(as.integer(combined_data$Year))),
  Source = unique(combined_data$Source)
)

# Step 2: Left join to preserve all bars, fill in Lbs = 0 where missing
expanded_data <- all_combos %>%
  left_join(combined_data %>% mutate(Year = as.integer(Year)), 
            by = c("County", "Year", "Source")) %>%
  mutate(
    Lbs = replace_na(Lbs, 0),
    Year = factor(Year)
  )

# Step 3: Filter out Lbs == 0 only when plotting (not before!)
ggplot(expanded_data %>% filter(Lbs > 1), aes(x = Year, y = Lbs, fill = Source)) +
  geom_col(position = "dodge", width = 0.6) +
  scale_y_log10(
    breaks = trans_breaks("log10", function(x) 10^x),
    labels = label_number()
  ) +
  facet_wrap(~ County, scales = "fixed") +
  labs(
    title = "MeBr  County, Year and Data Source",
    x = "Year",
    y = "Lbs (log scale)",
    fill = "Data Source"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


#Table Supplement 
library(dplyr)
library(tidyr)

ems_wide <- CARBCEIDARSV2 %>%
  mutate(EMS = as.numeric(EMS)) %>%
  group_by(county, year) %>%
  summarise(total_ems = sum(EMS, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(
    names_from = year,
    values_from = total_ems
  ) %>%
  mutate(across(where(is.numeric), ~ ifelse(. == 0, NA, .)))


write.csv(ems_wide, "ems_by_county_wide.csv", row.names = FALSE)


### differences ####
library(dplyr)


change_data <- bind_rows(ems_long, pur_long) %>%
  select(County, Year, Source, Lbs) %>%
  filter(Year != 2023) %>%                         # Exclude 2023
  pivot_wider(
    names_from = Source,
    values_from = Lbs,
    values_fill = list(Lbs = 0)                    # Replace NA with 0
  ) %>%
  mutate(Change_Lbs = PUR - CARB)

library(ggplot2)
library(dplyr)
library(scales)

# Step 1: Order counties by absolute total change
ordered_counties <- change_data %>%
  group_by(County) %>%
  summarise(total_abs_change = sum(abs(Change_Lbs), na.rm = TRUE)) %>%
  arrange(desc(total_abs_change)) %>%
  pull(County)

# Step 2: Prepare data with ordered counties
change_data <- change_data %>%
  mutate(
    County = factor(County, levels = ordered_counties),
    Year = factor(Year)
  )

# Step 3: Heat map plot
ggplot(change_data, aes(x = Year, y = County, fill = Change_Lbs)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(
    low = "green", mid = "white", high = "purple", midpoint = 0,
    name = "Diff in Lbs",
    labels = label_comma(),
    guide = guide_colorbar(
      title.position = "top",
      barwidth = unit(10, "lines"),
      barheight = unit(0.5, "lines"),
      title.hjust = 0.5,
      ticks = TRUE
    )
  ) +
  labs(
    title = "Difference in pounds reported by County \n PUR applications vs CARB emissions",
    x = "Year",
    y = "County"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    panel.grid = element_blank()
  )


library(ggplot2)
library(dplyr)
library(scales)
library(cowplot)

# Dummy legend data with centered text
legend_labels <- tibble(
  Label = c("PUR > CARB", "CARB > PUR"),
  Color = c("purple", "green"),
  x = c(1, 2),
  y = 1
)

# Main heatmap
heatmap <- ggplot(change_data, aes(x = factor(Year), y = County, fill = Change_Lbs)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(
    low = "green", mid = "white", high = "purple", midpoint = 0,
    name = "Diff in Lbs",
    labels = label_comma(),
    guide = guide_colorbar(
      title.position = "top",
      barwidth = unit(10, "lines"),
      barheight = unit(0.5, "lines"),
      title.hjust = 0.5,
      ticks = TRUE
    )
  ) +
  labs(
    title = "Difference in pounds reported by County \n PUR applications vs CARB emissions",
    x = "Year",
    y = "County"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    panel.grid = element_blank()
  )

# Custom legend (centered text inside boxes)
legend_patch <- ggplot(legend_labels, aes(x = x, y = y, fill = Label)) +
  geom_tile(width = 0.6, height = 0.6, color = "black") +
  geom_text(aes(label = Label), color = "white", size = 3.5, fontface = "bold") +
  scale_fill_manual(values = c("PUR > CARB" = "purple", "CARB > PUR" = "green")) +
  theme_void() +
  theme(legend.position = "none") +
  xlim(0.5, 2.5)

# Combine heatmap and custom legend
final_plot <- plot_grid(
  heatmap,
  legend_patch,
  ncol = 1,
  rel_heights = c(1, 0.12)
)

# Display it
final_plot


