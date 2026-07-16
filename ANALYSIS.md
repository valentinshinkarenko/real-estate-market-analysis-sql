# Real Estate Market Analysis — Saint Petersburg & Leningrad Oblast

**Author:** Valentin Shinkarenko
**Date:** December 18, 2024

Ad hoc SQL analysis for a real estate agency, built on top of a PostgreSQL database (`real_estate` schema: `flats`, `advertisement`, `city`, `type`). Full queries: [`final_project.sql`](final_project.sql).

---

## Task 1. Listing activity duration

To plan an effective business strategy, the client needs to know — based on how long listings stay active — which real estate segments in Saint Petersburg and Leningrad Oblast towns are most attractive to work with.

**1. Which segments have the shortest or longest listing activity durations?**

Shortest activity (up to 1 month):
- In Saint Petersburg: smaller apartments (avg. 52.97 sqm), avg. price per sqm of 108,927 RUB.
- In Leningrad Oblast: even smaller apartments (avg. 47.23 sqm), lower price per sqm — 74,281 RUB.

Longest activity (more than 6 months):
- In Saint Petersburg: larger apartments (65.69 sqm), higher price per sqm (118,886 RUB).
- In Leningrad Oblast: apartments of 52.85 sqm, lower price per sqm — 67,101 RUB.

**Conclusion:** shorter activity periods are associated with cheaper, smaller apartments, while longer periods are associated with more expensive, larger properties. Saint Petersburg's overall price level is significantly higher, which also affects time-to-sell.

**2. Which characteristics affect listing activity duration, and how do relationships vary by region?**

- *Average price per sqm* — significantly higher in Saint Petersburg across all activity segments (108,927–118,886 RUB) vs. Leningrad Oblast (67,101–74,281 RUB). Relationship: the higher the price per sqm, the longer the apartment stays on the market.
- *Average area* — in Saint Petersburg, larger apartments (up to 65.69 sqm) sell more slowly (6+ month segment); in Leningrad Oblast, smaller apartments (47.23 sqm) sell faster (within 1 month). Larger, pricier properties take longer to sell.
- *Number of rooms* — median is 2 rooms across all segments in Saint Petersburg (stable demand for 2-room apartments); in Leningrad Oblast, 1–2 room apartments sell faster, especially within the 1-month segment. Fewer rooms → faster sale.
- *Number of balconies* — median is 1 balcony across all segments and regions; no meaningful effect on activity duration.
- *Floor* — median floor is higher in Saint Petersburg (5th floor, consistent with dense mid/high-rise housing) vs. Leningrad Oblast (4th floor, consistent with low-rise/suburban housing). In Saint Petersburg, higher floors are associated with longer time-to-sell.

**Summary:** in Saint Petersburg, high price per sqm and large area are the main drivers of longer listing duration — expensive, spacious apartments sell slower. In Leningrad Oblast, smaller and cheaper listings close faster, especially in the under-1-month segment. Across both regions, balcony count has no significant effect, and 1–2 room apartments are the most in demand.

**3. Are there differences between Saint Petersburg and Leningrad Oblast?**

- Price: Saint Petersburg is significantly more expensive.
- Apartment size: larger on average in Saint Petersburg.
- Floor count: buildings are taller in Saint Petersburg.
- Time-to-sell: expensive apartments take longer to sell in Saint Petersburg; small, cheap apartments sell faster in Leningrad Oblast.

The two markets differ meaningfully in price, size, and demand characteristics.

---

## Task 2. Listing seasonality

The client needs to understand seasonal trends across the whole Saint Petersburg + Leningrad Oblast region, to identify periods of higher seller/buyer activity and plan marketing campaigns and market-entry timing accordingly.

**1. Which months show the highest publication and removal activity?**

Highest publication activity:
- February — 2,280 listings published (yearly maximum)
- November — 2,153 listings (second highest)

Highest removal activity:
- April — 2,128 listings removed (yearly maximum)
- January — 1,883 listings (second highest)

**2. Do publication and removal (sales) peaks coincide?**

Only partially:
- January: high removal activity (1,883) with average publication volume (1,282).
- February: publication peak (2,280), but removals are lower (1,670).
- April: removal peak (2,128), but fewer publications (1,519).

**Conclusion:** publication and removal peaks don't always align, pointing to a time lag between listing and sale.

**3. How do seasonal fluctuations affect average price per sqm and average area?**

Average price per sqm:
- Highest in September (100,243.94 RUB/sqm) and April (99,102.61 RUB/sqm).
- Lowest in March (96,661.31 RUB/sqm) and February (96,900.21 RUB/sqm).

Average apartment area:
- Largest in May (60.53 sqm) and December (60.40 sqm).
- Smallest in March (57.44 sqm) and October (57.14 sqm).

**Conclusion:** price per sqm tends to be higher in autumn and spring, while apartment area sold peaks in May and December — possibly reflecting shifting demand toward larger properties in those months.

---

## Task 3. Leningrad Oblast market analysis

The client wants to know which Leningrad Oblast settlements have the most active property sales, and what kind of property, to prioritize where to focus business efforts.

**1. Which settlements publish listings most actively?**

Murino (590 listings), Kudrovo (472 listings), and Shushary (440 listings) lead in publication volume.

**2. Which settlements have the highest share of removed listings** (a proxy for completed sales)?

Kudrovo (93.43%), Murino (93.39%), and Shushary (92.73%) — suggesting high sales activity in these three settlements.

**3. Average price per sqm and average area, and how much do they vary?**

- Price per sqm ranges from 46,784.12 RUB (Kingisepp) to 101,757.62 RUB (Sestroretsk).
- Average area ranges from 44.10 sqm (Murino) to 63.37 sqm (Sestroretsk).
- Significant variation: larger, pricier apartments in Sestroretsk and Kudrovo; the cheapest properties are in Kingisepp.

**4. Which settlements stand out by time-to-sell?**

- Fastest sales: Kingisepp (129.05 days) and Kolpino (143.60 days).
- Slowest sales: Sestroretsk (209.31 days) and Peterhof (204.66 days).

**Note on methodology:** only settlements with at least 50 listings were included, to ensure sample representativeness, avoid distortion from small samples, and keep the analysis focused on settlements with an actively traded market.

---

## Overall conclusions and recommendations

**Saint Petersburg**
- High price per sqm slows down sales of large, expensive apartments.
- Recommendation: prioritize marketing for smaller apartments, particularly in the fast-moving (under 1 month) segment.

**Leningrad Oblast**
- Active markets with high sales share: Murino, Kudrovo, Shushary.
- Recommendation: increase marketing focus in these settlements, as well as in fast-selling towns (Kingisepp, Kolpino).

**Seasonality**
- Publication peaks in February and November; sales activity peaks in January and April.
- Marketing campaigns should be planned around this time lag between publication and sale.

**Bottom line:** focus on smaller apartments in high-activity locations, optimize sales timing around seasonality, and strengthen positioning in the most promising Leningrad Oblast markets.
