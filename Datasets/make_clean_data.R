library(tidyverse)

chr_data<-read_csv("https://www.countyhealthrankings.org/sites/default/files/media/document/analytic_data2024.csv")

chr_data<-
  chr_data|>
  slice(-1)|>
  rename(fips_code=`5-digit FIPS Code`)|>
  filter(`County FIPS Code`!="000")|>
  select(-contains("CI low"),-contains("CI high"))

chr_data<-
  chr_data|>
  select(-`State FIPS Code`,-`County FIPS Code`,-`State Abbreviation`,-Name,-`Release Year`,-`County Clustered (Yes=1/No=0)`)

chr_data<-
  chr_data|>
  select(-contains(" flag"),
         -contains(" numerator"),
         -contains(" denominator"))

chr_data|>
  pivot_longer(-fips_code,names_to = "measure")|>
  mutate(value=as.numeric(value))|>
  mutate(measure=str_remove(measure," raw value$"))|>
  mutate(
    measure=str_replace(measure,"(AIAN)","American Indian & Alaska Native"),
    measure=str_replace(measure,"(NHOPI)","Native Hawaiian and Other Pacific Islander"),
    # measure=str_replace(measure,"(AIAN)","(American Indian & Alaska Native)"),
    # measure=str_replace(measure,"(AIAN)","(American Indian & Alaska Native)"),
    # measure=str_replace(measure,"(AIAN)","(American Indian & Alaska Native)"),
  )|>
  write_csv("Datasets/chr_county_metrics_2024.csv")


counties <- tigris::counties(cb=T,year=2021)|>
  filter(STATEFP<=56)|>
  tigris::shift_geometry()|>
  select(county_fips=GEOID)

counties2<-
  counties|>
  rmapshaper::ms_simplify(keep_shapes = T,keep = 0.01)

counties2|>
  sf::write_sf("Datasets/simply_counties.shp")
