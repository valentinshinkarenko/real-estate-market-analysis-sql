# Real Estate Market Analysis (SQL / PostgreSQL)

Ad hoc SQL analysis of a real estate agency's listings database, covering Saint Petersburg and Leningrad Oblast. Written in PostgreSQL against a normalized schema (`flats`, `advertisement`, `city`, `type`), using CTEs, window/percentile functions, and outlier filtering to turn raw listing data into segmented, business-ready findings.

## Business questions

- Which market segments (by region, price, size) have the shortest or longest time-to-sell?
- Which property characteristics — area, price per sqm, rooms, balconies, floor — drive listing duration, and how does that differ between Saint Petersburg and Leningrad Oblast?
- Which months see the most listing publications vs. removals (sales), and does that timing line up?
- How do price per sqm and average apartment size shift seasonally?
- Which Leningrad Oblast settlements have the most active, highest-turnover markets — and where do properties sell fastest/slowest?

## Data

PostgreSQL schema `real_estate` with four tables: `flats` (property attributes), `advertisement` (listing price, publication/removal dates), `city` (region/settlement), `type` (listing type). Not included in this repo — the queries are written against the schema and are directly runnable if you have access to an equivalent database.

## Methodology

1. **Outlier filtering** — 1st/99th percentile caps on total area, rooms, balconies, and ceiling height (`PERCENTILE_DISC`), applied per query via a `limits` CTE.
2. **Segmentation** — listings bucketed into activity-duration segments (up to 1 month, up to 3 months, up to 6 months, 6+ months) and by region (Saint Petersburg vs. Leningrad Oblast).
3. **Seasonality** — publication and removal dates extracted by month, aggregated and compared side by side via a `FULL OUTER JOIN`.
4. **Settlement ranking** — Leningrad Oblast settlements filtered to those with 50+ listings (for statistical reliability), ranked by sale-completion ratio and volume.

Full queries: [`final_project.sql`](final_project.sql). Full written findings and business recommendations: [`ANALYSIS.md`](ANALYSIS.md).

## Key findings

- Time-to-sell correlates with price and size: cheap, small apartments move fastest; expensive, spacious ones — especially in Saint Petersburg — stay listed longest.
- Publication and sale (removal) peaks don't coincide (Feb. publication peak vs. Apr. removal peak), pointing to a lag between listing and closing.
- Leningrad Oblast sales activity is concentrated in three settlements — Murino, Kudrovo, Shushary — which combine high listing volume with a 92%+ removal rate.
- Price per sqm and apartment size both show seasonal patterns, useful for timing marketing campaigns.

## Why this project

Same analytical muscle used in fraud/risk work, applied to a different domain: forming hypotheses, filtering outliers before drawing conclusions, segmenting a population to find where deviations concentrate, and translating query output into concrete, prioritized business recommendations.

## Stack

PostgreSQL · CTEs · window & percentile functions · aggregate queries

## Author

Valentin Shinkarenko
