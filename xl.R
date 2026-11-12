install.packages("openxlsx")
library(openxlsx)
dir.create("C:/Users/ASHWIN/Desktop/A&E/outputs", showWarnings = FALSE)
saveRDS(ranking, "C:/Users/ASHWIN/Desktop/A&E/outputs/ranking.rds")
write_csv(ranking, "C:/Users/ASHWIN/Desktop/A&E/outputs/ranking.csv")
library(openxlsx)

out <- ranking |> select(org_name,att,breaches,breach_rate,expected,rank,tier,priority
                         )
names(out)
nrow(out)
head(out)

wb <- createWorkbook()
addWorksheet(wb,"Ranking")
writeData(wb,"Ranking",ranking)
saveWorkbook(wb,"C:/Users/ASHWIN/Desktop/A&E/outputs/ae_priority.xlsx",overwrite = TRUE)
