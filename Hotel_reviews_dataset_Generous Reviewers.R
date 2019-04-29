suppressWarnings(library(ggplot2))
library(readr)
library(dplyr)
library(treemap)
require(GGally)
library(ggrepel)
reviews.raw.df <- read.csv('C:/Karthi/Semester/Sem 4/ISDS 577/Project Phase 2/Hotel_Reviews.csv')

## Lets do some analysis to see how the year and nationality of the reviewer impact the ratings
reviews.df <- reviews.raw.df %>%
  mutate(Review_year = substr(as.character(Review_Date),
                              nchar(as.character(Review_Date))-3,
                              nchar(as.character(Review_Date))))

reviews.by.nationality <- reviews.df %>%
  filter(Reviewer_Nationality != " ") %>%
  select(Review_year,
         Reviewer_Nationality,
         Reviewer_Score,
         Average_Score,
         Total_Number_of_Reviews_Reviewer_Has_Given,
         Total_Number_of_Reviews
  ) %>%
  mutate(Reviewer_Nationality = as.character(Reviewer_Nationality)) %>%
  group_by(Reviewer_Nationality,Review_year) %>%
  summarise(
    Averager_Score = mean(Average_Score),
    Reviewer_Score = mean(Reviewer_Score),
    Total_Number_of_Reviews_Reviewer_Has_Given = sum(Total_Number_of_Reviews_Reviewer_Has_Given),
    Total_Number_of_Reviews = n()
  ) %>%
  arrange(Reviewer_Nationality,Review_year)

head(reviews.by.nationality)

g <- ggplot(reviews.by.nationality, aes(Averager_Score)) + scale_fill_brewer(palette = "Spectral")
g + geom_histogram(aes(fill=Review_year), 
                   binwidth = .1, 
                   col="black", 
                   size=.1) + labs(title="Histogram - Year wise distribution of Average_Score")

g <- ggplot(reviews.by.nationality, aes(Reviewer_Score)) + scale_fill_brewer(palette = "Accent")
g + geom_histogram(aes(fill=Review_year), 
                   binwidth = .1, 
                   col="black", 
                   size=.1) + labs(title="Histogram - Year wise distribution of Reviewer_Score")

## histograms show that distribution of average scores and Reviewer scores are nearly the same.
## Let's use cut() function to give meaningful levels to the ratings than just continous values.

levels <- c(-Inf, 1, 5, 8, 9, Inf)
labels <- c("Really Bad", "Poor", "fair", "very good", "excellent")
reviews.by.nationality <- reviews.by.nationality %>% mutate(Review_Level = cut(Reviewer_Score, levels, labels, right = FALSE)) %>%  mutate(Review_Level = as.character(Review_Level))
head(reviews.by.nationality)

## COnsidering the population factor of these countries will yield a better insight
## Let's use an external csv file for population data.

country.population <- read.csv("C:/Karthi/Semester/Sem 4/ISDS 577/Project Phase 2/population.csv")
country.population.2010 <- country.population %>% select(Country, X2010) %>% rename(Population = X2010) %>%
  mutate(Population = as.numeric(as.character(Population))) %>% filter(complete.cases(.))
## Removed any rows with NAs to have clean data

country.population.2010 <- country.population.2010 %>%
  rename(Reviewer_Nationality = Country) %>% 
  mutate(Reviewer_Nationality = as.character(Reviewer_Nationality)) %>% 
  arrange(Reviewer_Nationality)  %>% 
  filter(Population >0 )

## Merging the nationality and population files to get an accurate picture of which country is the most generous.
reviews.by.nationality.merged <- merge(x = reviews.by.nationality, y = country.population.2010)
head(reviews.by.nationality.merged,5)
## Normalize the Total Reviews/ country by the population figures to get the scale.
reviews.by.nationality.merged <- reviews.by.nationality.merged %>%
mutate(scaling.for.population = Total_Number_of_Reviews/( Population)) %>% 
filter(Review_Level=="excellent")

## Now, let's plot the ratings and check for the most generous reviewers

## For the Year 2016

baseplot = ggplot(reviews.by.nationality.merged[which(reviews.by.nationality.merged$Review_year=="2016"),], 
                  aes(scaling.for.population,Averager_Score,color = Review_Level))
baseplot + geom_label_repel(
  aes(scaling.for.population,Averager_Score, fill = factor(Review_Level), label = Reviewer_Nationality),
  size = 3,fontface = 'bold', color = 'white',
  box.padding = unit(0.35, "lines"),
  point.padding = unit(0.5, "lines"),
  segment.color = 'grey50'
)  +
  geom_point(aes(scaling.for.population,Averager_Score), size = 5, color = 'grey') +
  ggtitle(" 2016 Countries with the most generous reviewers")


## For the year 2017
baseplot = ggplot(reviews.by.nationality.merged[which(reviews.by.nationality.merged$Review_year=="2017"),], 
                  aes(scaling.for.population,Averager_Score,color = Review_Level))
baseplot + geom_label_repel(
  aes(scaling.for.population,Averager_Score, fill = factor(Review_Level), label = Reviewer_Nationality),
  size = 3,fontface = 'bold', color = 'white',
  box.padding = unit(0.35, "lines"),
  point.padding = unit(0.5, "lines"),
  segment.color = 'grey50'
)  +
  geom_point(aes(scaling.for.population,Averager_Score), size = 5, color = 'grey') +
  ggtitle(" 2017 Countries with the most generous reviewers")

## Countries that gave top ratings in the year 2016 and 2017
reviews.by.nationality.merged[which(reviews.by.nationality.merged$Review_year=="2016"),]

reviews.by.nationality.merged[which(reviews.by.nationality.merged$Review_year=="2017"),]

## We can do this for other years as well.
## It appears that not many countries are consistently among the most generous reviewers. YoY.
