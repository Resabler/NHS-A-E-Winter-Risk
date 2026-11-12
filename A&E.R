library(tidyverse)
library(rvest)

page_url <- "https://www.england.nhs.uk/statistics/statistical-work-areas/ae-waiting-times-and-activity/ae-attendances-and-emergency-admissions-"
page <- read_html(page_url)
class(page)


links %>% filter(str_detect(href,"csv"))

#vector of year strings for the function
years<-c("2019-20","2020-21","2021-22","2022-23","2023-24","2024-25","2025-26","2026-27")
get_monthly_links <- function (url){
  page <- read_html(url)  
  links <- tibble(
    text= page |> html_elements("a") |>html_text2(),
    href= page|> html_elements("a") |> html_attr("href")
    
  )
  links %>% filter(str_detect(href,"csv"))
} 

get_monthly_links("https://www.england.nhs.uk/statistics/statistical-work-areas/ae-waiting-times-and-activity/ae-attendances-and-emergency-admissions-2019-20/")

urls <- paste0(page_url,years,"/")
urls
all_links <- map(urls,get_monthly_links)
all_links <- bind_rows(all_links)
n_distinct(all_links$href)
n_distinct(all_links$text)
length(urls)

# download all the files in the file folder 
u <- all_links$href[1]
d <- paste0("C:/Users/ASHWIN/Desktop/A&E/raw-data/", basename(u))

ul <- all_links$href
dests  <- paste0("C:/Users/ASHWIN/Desktop/A&E/raw-data/", basename(ul))
walk2(ul[1:3],dests[1:3],download_one)
download_one <- function(u,d)
{
  if (file.exists(d))
    return(invisible(NULL))
  download.file(u, d, mode = "wb")
  Sys.sleep(1)
}
map2(ul,dests,download_one)
length(list.files("C:/Users/ASHWIN/Desktop/A&E/raw-data"))
n_distinct(basename(ul))
length(list.files("C:/Users/ASHWIN/Desktop/A&E/raw-data"))

raw <- read_csv("June-2026-CSV-Wfg38l.csv")
dim(raw)
view(raw)
tail(raw)

april_2020 <- read_csv("April-2020-revised-260421-abc123.csv",n_max = 0)
april_2022 <- read_csv("April-2022-revised-130624-F4scP.csv",n_max = 0)
april_2026 <- read_csv("April-2026-CSV-QD21vf.csv",n_max = 0)
names(april_2020)
names(april_2022)
names(april_2026)


# to find the number of cols in everyfile 
files <- list.files("C:/Users/ASHWIN/Desktop/A&E/raw-data/",full.names = TRUE)
length(files)

header_read <- function(f){
  read_90files <- read_csv(f,n_max = 0)
  read_90files
}
hd<-map(files,header_read)
hd
a<-map_int(hd,ncol)
a
table(a)

#data frame with file name and col count 
df <- data.frame(file=basename(files),ncols=a)
df
ed <-  df |> filter(ncols==16)
ed1 <- df |> filter(ncols==22)
ed
ed1
# now i have 15 tables with 16 cols, 74 tables with 22 cols , 1 table with 28 cols

#which months files have 28 cols
# which months have 16 cols
 which(df$ncols==16)[1]
which(df$ncols==22)[1]
which(df$ncols==28)[1]
df$file[c(1,2,74)]
    
setdiff(names(hd[[2]]), names(hd[[1]]))
setdiff(names(hd[[1]]), names(hd[[2]]))
setdiff(names(hd[[74]]), names(hd[[2]]))
setdiff(names(hd[[2]]), names(hd[[74]]))
all_names <- unique(unlist(map(hd, names)))
all_names

read_one <- function(f){
 rd <- read_csv(f, col_types = cols(.default = col_character()), show_col_types = FALSE) |>
 rename(any_of(c(
   "A&E attendances Type 1" =	"Number of A&E attendances Type 1",
   "A&E attendances Type 2"=	"Number of A&E attendances Type 2",
   "A&E attendances Other A&E Department"=	"Number of A&E attendances Other A&E Department",
   "Attendances over 4hrs Type 1" =	"Number of attendances over 4hrs Type 1",
   "Attendances over 4hrs Type 2" =	"Number of attendances over 4hrs Type 2",
   "Attendances over 4hrs Other Department" =	"Number of attendances over 4hrs Other A&E Department"
 ))) |>
   select(-starts_with("..."), -any_of("a")) |>
   mutate(source_file=basename(f))

}
mp <- map(files,read_one)
 pm <- bind_rows(mp)
 head(pm)
 
 dim(pm)
sum(is.na(pm$`A&E attendances Type 1`))
pm |> count(source_file)
unique(pm$Period)
pm |> filter(is.na(Period))
pm |> filter(str_detect(Period,regex("total",ignore_case = TRUE)))

pm <- pm |> 
  mutate(is_total =
           replace_na(str_detect(Period, regex("total", ignore_case = TRUE)), FALSE) |
           replace_na(str_detect(`Org name`, regex("total", ignore_case = TRUE)), FALSE))
pm_totals <- pm|> filter(is_total)
pm_trusts <- pm |> filter(!is_total)

pm_trusts <- pm_trusts |>
  mutate(date = my(str_remove(Period, "^MSitAE-")))

n_distinct(pm_trusts$date)
range(pm_trusts$date)
sum(is.na(pm_trusts$date))

ae <- pm_trusts |>
  rename(
    org_code = `Org Code`, parent_org = `Parent Org`, org_name = `Org name`,
    att_t1 = `A&E attendances Type 1`,
    att_t2 = `A&E attendances Type 2`,
    att_oth = `A&E attendances Other A&E Department`,
    over_t1 = `Attendances over 4hrs Type 1`,
    over_t2 = `Attendances over 4hrs Type 2`,
    over_oth = `Attendances over 4hrs Other Department`,
    dta_4_12 = `Patients who have waited 4-12 hs from DTA to admission`,
    dta_12plus = `Patients who have waited 12+ hrs from DTA to admission`,
    adm_t1 = `Emergency admissions via A&E - Type 1`,
    adm_t2 = `Emergency admissions via A&E - Type 2`,
    adm_oth = `Emergency admissions via A&E - Other A&E department`,
    adm_other = `Other emergency admissions`,
    att_bk_t1 = `A&E attendances Booked Appointments Type 1`,
    att_bk_t2 = `A&E attendances Booked Appointments Type 2`,
    att_bk_oth = `A&E attendances Booked Appointments Other Department`,
    over_bk_t1 = `Attendances over 4hrs Booked Appointments Type 1`,
    over_bk_t2 = `Attendances over 4hrs Booked Appointments Type 2`,
    over_bk_oth = `Attendances over 4hrs Booked Appointments Other Department`
  )
names(ae)

ae <- ae |>
  mutate(across(
    -c(Period, org_code, parent_org, org_name, source_file, date, is_total),
    parse_number
  ))
dir.create("C:/Users/ASHWIN/Desktop/A&E/data/processed", recursive = TRUE, showWarnings = FALSE)
saveRDS(ae, "C:/Users/ASHWIN/Desktop/A&E/data/processed/ae_clean.rds")
write_csv(ae, "C:/Users/ASHWIN/Desktop/A&E/data/processed/ae_clean.csv")
glimpse(ae)
colSums(is.na(ae))

sum(is.na(ae$date))
n_distinct(ae$date)
range(ae$date)
nrow(pm_totals)

ae |> distinct(source_file,date) |> count(date) |> filter(n>1)
ae_db <- ae |> mutate(date=as.character(date)) |> select(-is_total)
library(DBI)
con <- dbConnect(RSQLite::SQLite(), ":memory:")
dbWriteTable(con,"ae",ae_db,overwrite=TRUE)
dbListTables(con)
dbGetQuery(con,"select count(*) from ae")

dbGetQuery(con,"select sum(att_t1),sum(att_t2),period from ae group by period")
dbGetQuery(con,"select count(distinct org_code) from ae")
# worst NHS trust over last 12 months
dbGetQuery(con,"select org_name from ae
           where
           date >= '2025-10-01'
           group by org_name
           having
           avg(att_t1) >= 2000
           ")

# worst NHS trust over this month 
dbGetQuery(con,"
           select org_name ,
           avg(att_t1) AS avg_att,
           avg(over_t1) AS avg_over ,
           (100.0 * (sum(att_t1)-sum(over_t1))/ sum(att_t1)) as 
           pct_within_4hrs
           from ae
           where date >= '2023-01-01'
           group by org_name
           having avg(att_t1) >= 2000
           order by pct_within_4hrs ASC 
           limit 20")

dbExecute(con,
           "
           create view v_known 
           as
           select * from ae 
           where
           not (att_t1>=1000  and over_t1=0 )")

national <- dbGetQuery(con,
           "
           select 
           avg(att_t1) as Attendances
           ,
           avg(over_t1) as Breaches,
           (100 * (sum(att_t1)-sum(over_t1))/sum(att_t1))
           as
           pct_within_4hrs,date
            from v_known
           group by date
           order by date
           ")
national

ae |> filter(date == as.Date("2026-04-01")) |> distinct(source_file, Period)
ae <- ae |>
  mutate(date = if_else(
    source_file == "Monthly-AE-March-2020-revised-220720-ce435.csv",
    as.Date("2020-03-01"),
    date))
n_distinct(ae$date)


# making the date real again
national <- national |> mutate(date=as.Date(date))
ggplot(
  national,
  aes(x=date,y=pct_within_4hrs) )+
    geom_line() +
    geom_hline(yintercept = 95,linetype = "dashed") +
  labs(x="DATE",y="% OF PATIENTS SEEN WITHIN 4 HOURS",
           caption = "National Performance since 2019") +
  theme_minimal() + 
  scale_y_continuous(limits = c(40,100))
ggsave("C:/Users/ASHWIN/Desktop/A&E/figures/national_trend.png", width = 9, height = 5, dpi = 300)

# winter effect 
# is winter that much worse?
# we group or summarise the entire 7 years with the monthly section and check the december
library(lubridate)
national <- national %>% mutate(m=month(date,label = TRUE))
by_month <- by_month %>% mutate(winter=m %in% c("Dec","Jan","Feb") )

by_month <- national |> group_by(m) |> summarise(avg_pct = mean(pct_within_4hrs))
by_month
ggplot(by_month,aes(x=m,y=avg_pct,fill = winter))+ geom_col()+
  labs(x="Months",y="Mean percentage of patients attended within 4 hours",caption = "Monthly Performance Chart") +
theme_minimal() + scale_y_continuous(limits = c(0,80)) 

national <- national %>% mutate(within4=Attendances-Breaches)
national <- national %>% mutate(winter=m%in%c("Dec","Jan","Feb"))
m1 <- glm(cbind(Breaches,within4)~winter,family=quasibinomial,data=national)
coef(m1)
exp(coef(m1))
summary(m1)

# exclude the lockdown time period and apply the model again
m3 <- glm(cbind(Breaches,within4)~winter,family=quasibinomial,data=national  |> filter(date < "2020-03-01" | date > "2021-03-31"))
exp(coef(m3))
summary(m3)
exp(confint.default(m3))


national2 <- dbGetQuery(con, "
  SELECT date, SUM(att_t1) AS Attendances, SUM(over_t1) AS Breaches,
         100.0 * (SUM(att_t1) - SUM(over_t1)) / SUM(att_t1) AS pct_within_4hrs
  FROM v_known
  WHERE source_file <> 'Monthly-AE-March-2020-revised-220720-ce435.csv'
    AND date >= '2021-04-01'
  GROUP BY date ORDER BY date") |>
  mutate(date = as.Date(date))
nrow(national2)

library(forecast)
y <- ts(national2$pct_within_4hrs, start = c(2021, 4), frequency = 12)
autoplot(y)

train <- window(y, end = c(2025, 9))                       # Apr 2021 to Sep 2025
test  <- window(y, start = c(2025, 12), end = c(2026, 2))  # Dec 2025 to Feb 2026
f1 <- snaive(train, h = 5)                  # same as last year
f2 <- forecast(ets(train), h = 5)           # exponential smoothing
f3 <- forecast(auto.arima(train), h = 5)
mean(abs(test - f1$mean[3:5]))
mean(abs(test - f2$mean[3:5]))
mean(abs(test - f3$mean[3:5]))
fit <- auto.arima(y)
fit
fc <- forecast(fit,h=5)
fc
autoplot(fc)
fc$mean[3:5]
fc$lower[3:5,]
fc$upper[3:5,]

#trust ranking 

trust_winter <- dbGetQuery(con,"select org_name,SUM(att_t1) AS att, SUM(over_t1) AS breaches FROM v_known WHERE date IN ('2025-12-01','2026-01-01','2026-02-01') group by org_name HAVING AVG(att_t1) >= 2000")
trust_winter
head(trust_winter)
trust_winter <- trust_winter %>% mutate(breach_rate=breaches/att)
head(trust_winter)
range(trust_winter$breach_rate)
trust_winter |> arrange(breach_rate) |> head(5)
trust_winter |> arrange(desc(breach_rate)) |> head(5)

fc_rate   <- 1 - mean(fc$mean[3:5]) / 100
last_rate <- sum(trust_winter$breaches) / sum(trust_winter$att)
adj       <- fc_rate / last_rate

ranking <- trust_winter |>
  mutate(expected = att * breach_rate * adj) |>
  arrange(desc(expected)) |>
  mutate(rank = row_number(),
         tier = case_when(rank <= 10 ~ "Tier 1", rank <= 30 ~ "Tier 2", TRUE ~ "Tier 3"))
head(ranking, 10)

ranking <- ranking |>
  mutate(rate_rank = rank(desc(breach_rate), ties.method = "first"),
         priority = case_when(
           rank <= 20 & rate_rank <= 20 ~ "High volume AND high rate",
           rank <= 20                   ~ "High volume",
           rate_rank <= 20              ~ "High rate",
           TRUE                         ~ "Other"))
ranking |> filter(priority != "Other") |> arrange(priority) |> select(org_name, att, breach_rate, expected, rank, rate_rank, priority)
bad_rate <- 1 - mean(fc$lower[3:5, "95%"]) / 100
adj_bad  <- bad_rate / last_rate
sum(ranking$expected)               # central total
sum(ranking$breach_rate * ranking$att * adj_bad)   # pessimistic total



