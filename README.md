# Which NHS trusts are most likely to miss the 4-hour A&E standard next winter?

An end-to-end analysis of NHS England's monthly A&E data, built to show where extra help is likely to matter most next winter. It is aimed at NHS managers and planners who need to decide which trusts to look at first.

## Headline findings

- **Winter matters.** Winter months raise the odds of a patient waiting over 4 hours by about 16% (odds ratio 1.16, quasi-binomial model).
- **National forecast.** An ARIMA forecast puts national 4-hour performance at about 57–59% next winter.
- **Scale.** Expected long waits (patients over 4 hours) come to about 1.72 million in the central case and about 2.06 million in a pessimistic case.
- **Concentration.** The top 10 trusts by expected long waits hold about 18% of the national total. Three trusts are high on both volume and breach rate, so they appear on both lenses.
- **Volume versus rate.** Ranking by breach rate alone and ranking by expected long waits give different lists. The highest-ranked trust by expected long waits is there mainly because of its size, not because it has the worst rate.

## Data

NHS England monthly A&E provider data, April 2019 to September 2026 (90 monthly CSV files). The data is public, so the repo does not include it. The script downloads it.

## Method

1. **Download** the monthly CSVs from NHS England's statistics pages (R, `rvest`).
2. **Clean and stack** the files into one table. This includes harmonising renamed columns, removing TOTAL rows and building a date column.
3. **Load into SQLite** and query with SQL (aggregation, window functions, a view that excludes unreported zeros).
4. **Model the winter effect** with a quasi-binomial GLM.
5. **Forecast** the national 4-hour series with ARIMA, backtested against a seasonal naive and an ETS model.
6. **Rank trusts** by expected long waits (attendances × breach rate × forecast adjustment), then group them into tiers and flag high volume and high rate.
7. **Excel workbook** (`outputs/ae_priority.xlsx`) with the ranking, each trust's share of the national total, a top-10 chart and notes, for managers who work in Excel.

**Tools:** R (tidyverse, rvest, DBI/RSQLite, forecast, openxlsx), SQL (SQLite), Excel, ggplot2.

## Outputs

- `outputs/ae_priority.xlsx`: ranked trust table, share of total, top-10 chart.
- `figures/`: national trend and charts.

## Limitations and known issues

- **Association, not causation.** The model describes patterns in past data. It does not show why trusts miss the standard.
- **Estimates, not predictions.** Rankings are expected values from a simple model and a short forecast series, not forecasts for individual trusts.
- **File problems.** One file labelled March 2020 carries a wrong period label, so March 2020 is missing and April 2026 is affected in the main table. The national series used for the forecast excludes the affected file.
- **Unreported zeros.** Some trusts report zero breaches in months where they clearly had attendances (for example field-test trusts). I excluded these with a rule, which is a judgement call.
- **Trusts are not equal.** Children's hospitals are included but are not comparable with general acute trusts. Reporting practices also differ between trusts, so a very low or high breach rate can reflect how a trust records, not only how it performs.
- **No reconciliation yet.** I have not reconciled my trust totals against NHS England's published national totals. This is the next improvement.
- **Database is in memory.** The SQLite database is rebuilt each time the script runs.

## How to run it

1. Install the R packages: `tidyverse`, `rvest`, `DBI`, `RSQLite`, `forecast`, `openxlsx`.
2. Open `A&E.Rproj` in RStudio.
3. Run `A&E.R` from top to bottom. The script downloads the data into `raw-data/`, which is not tracked in the repo.

## About

Built as a learning project on public NHS data. Feedback is welcome.