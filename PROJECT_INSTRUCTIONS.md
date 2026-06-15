# EIP Ranking Dashboard — Project Instructions & Handoff

> Yeh file isliye hai taaki agli baar kaam turant aur sahi tareeke se shuru ho sake.
> Chat hamesha **Hinglish** mein. Deliverable/website ka content **English** mein.

## What this project is
Ek SEO **keyword Google-ranking tracker** ko ek **interactive web dashboard** mein convert kiya gaya hai,
upper management ko dikhane aur sabke saath share karne ke liye (Vercel par host karke).
Deliverable: ek **single self-contained HTML file** (saara data andar embedded, koi server/DB/login nahi).
- `index.html` → ready-to-deploy (Vercel par drag-drop).
- `Ranking_UpDown_Tracker.html` → same content (backup).
- `ranking_data.json` → **MASTER data store** (history yahin rehti hai; future files isme append hote hain).
Teeno har update par refresh hote hain.

## DATA WORKFLOW (NEW — date-wise files) ⭐ most important
User ab har ranking date ka **alag Excel file** dega (date-wise). Pehle ek manually-compiled master tha;
ab har file = ek date ka snapshot.

### Each date-wise file format (single sheet "Sheet1")
Columns: `Keyword | # of Searches | Trend | Rank | Difference | URL Found | SERP Features | Organic Traffic | Tags`
**Sirf yeh 5 fields use karne hain:** Keyword, # of Searches, Rank, URL Found, **Tags**.
- **Tags = GROUP** (person ya report-type). Yahi ab grouping ka source hai (purane "1 Apr - Distribute" ki jagah).
- **Rank**: number (1–30) YA **"Not in top 30"** → treat as `'-'` (not ranked). Tool sirf top 30 track karta hai.
- **# of Searches**: number ya "N/A" (→ null).
- **URL Found**: ranking URL (sirf jab top 30 mein ho; warna blank).
- **Date** = filename se (e.g. `11-June-2026 - EMR Ranking.xlsx` → "Jun 11").

### Groups (Tags) — 4 people + 10 types
People: Harsh, Dubey, Gagan, Saurabh.
Types: Topical Mapping, Manufacturing Plant Project, Pipeline Analysis, Epidemiology Forecast,
Patent Landscape, Price Trend, Procurement Intelligence, Supply and Demand Analysis, Technology Scouting, Market Report (EMR+HC).
(~14,389 keywords; har keyword exactly ek group mein.)

### Value meaning in master store (`ranking_data.json`)
Per keyword `r[]` = rank per date. Value = number (rank), `'-'` (not in top 30 / not ranked), or `null` (us date track hi nahi hua / keyword tab tak nahi tha).
`searches` aur `url` = **latest snapshot** (newest file se). Old (pre-date-wise) history ke liye yeh null hain.

### NEW keywords handling
Future file mein naye keywords aa sakte hain (user ne abhi website par naye report daale ho).
Merge logic: jo keyword pehle nahi tha → naya entry, uski pichhli dates `null`, latest date par rank.
(11 June file mein koi naya keyword nahi tha — set master se exactly match hua.)

## History seed (one-time, already done) — IMPORTANT date gotcha
- Master `1 April Ranking Sheet-1628a2e5.xlsx`, tab "Keywords Ranking", cols **18..26** (9 columns).
- **WARNING: us sheet ke column header dates GALAT hain.** Actual (user-confirmed) dates for cols 18..26:
  `01 Apr, 07 Apr, 13 Apr, 23 Apr, 05 May, 13 May, 18 May, 05 Jun, 09 Jun`
  (Header "Apr 04" actually = 07 Apr; header "Jun 11" actually = **09 Jun**.) Hardcoded as SEED_LABELS in build_master.py.
- Phir alag **11 June** date-wise file (`11-June-2026 - EMR Ranking-*.xlsx`) se **11 Jun** add hua (#searches/url ke saath).
- Total 10 dates: 01 Apr → 11 Jun.
- **Date format = day-first** ("01 Apr", "11 Jun"), month baad mein.

## Dashboard features (current)
**Tab 1 — Summary (Up/Down):** date dropdown; Person + Report-type tables (Top 3, Top 10 with ▲/▼ vs previous date,
Not yet live, Newly live; row green/red); **Ranking Bands Trend** line chart (1–3, 4–10, 11–30) with scope selector.
**Tab 2 — Keyword Drill-down:** Single-keyword graph (type karo → rank graph 1 Apr→latest, Y reversed);
Full history table — left columns **Keyword/Owner/Searches/URL/first-date FROZEN (sticky)**, baaki dates horizontal-scroll; with **# Searches** + **URL (clickable ↗)** + every date's rank (colour-coded 1-3/4-10/11-30) + Change;
Semrush-style filters: search, owner multi-select (checkboxes), movement, position band (Top 3/10/20/30/50, 51-100, not ranked),
position range, **Min searches**, change-size, sort (incl. **Highest/Lowest search volume**, gainers/losers), Reset, Show All;
**Download CSV** + **Download Excel (.xlsx)** (current filtered view; includes searches+url).

## Build pipeline (files in scratchpad/outputs)
- `build_master.py` → seed master from old sheet + `add_datefile()` for each date-wise file → writes `ranking_data.json` + `data4.json`.
- `template6.html` → has `__DATA__` placeholder; replace with `data4.json` → `dashboard6.html`.
- `xlsxgen.js` → dependency-free .xlsx writer (embedded in template). Only allowed CDN = Chart.js.
- Validate: node (JSON.parse + JS parse), openpyxl (xlsx export opens).

## How to update when a NEW date-wise file arrives (the routine)
1. `ranking_data.json` load karo (master). Naye xlsx ka path + date (filename se) lo.
2. `add_datefile(master, path, 'Mon DD')` → naya date append, ranks/searches/url update, naye keywords add.
3. Master JSON save; dashboard dataset (`data4.json`) regenerate.
4. `template6.html` + JSON → `dashboard6.html`. Validate.
5. Folder mein `index.html` + `Ranking_UpDown_Tracker.html` + `ranking_data.json` overwrite; artifact `ranking-updown-tracker` update.
6. Vercel hosted copy manually redeploy karni padti hai (data file mein embedded hai, auto nahi).

## Deploy / share (Vercel)
Static HTML → vercel.com → Add New Project → `index.html` upload → public URL. Sabko same data. Download buttons hosted site par chalte hain.

## User preferences
- Chat **Hinglish**, content English. Concise + direct.
- **Naya kuch banane se pehle saare clarifying questions ek saath puch lo** (user ne explicitly kaha).
- Simplicity > complexity (pehla complex "Power BI" version reject hua). Speed/clean rakho.

## Enquiries data (separate source)
- Source: `All Enquiries.xlsx` (columns **Date, Keywords**; one row per enquiry, ~2022-2026).
- Aggregated to `enquiries_data.json` (per matched keyword: list of enquiry dates; plus byOwner totals, range, total).
- ~15,779 enquiries matched to ~4,989 tracker keywords (matched by keyword text).
- Powers the **Enquiries tab**: KPI cards, per-keyword monthly trend graph + exact dates + latest rank, sortable table (total enquiries + latest rank), and insights (Enquiries by Owner, Opportunities = high enquiries but rank outside Top 10).
- When a new enquiries file arrives, re-aggregate to `enquiries_data.json` (same script logic), then run derive.

## URL data (separate source)
- `Keyword + URLs.xlsx` (Keyword, URL Found) gives the canonical URL per keyword. Applied to `ranking_data.json` (url field). 14,388/14,389 have URLs.

## Pipeline files (in folder for reference)
- `ranking_data.json` = master (ranks+searches+urls), updated incrementally. **Do NOT rebuild from scratch** or you lose the URL-sheet URLs.
- `enquiries_data.json` = aggregated enquiries.
- `derive.py` = reads ranking_data.json (+ enquiries_data.json) -> `data4.json` (the dashboard dataset). Use this to regenerate, NOT a full reseed.
- `build_master.py` = seed/add date-wise files into ranking_data.json (its add_datefile now keeps an existing URL if a new file's URL is blank).
- Build dashboard: `data4.json` into `template8.html` (__DATA__) -> `dashboard8.html` -> copy to index.html + Ranking_UpDown_Tracker.html; update artifact `ranking-updown-tracker`.

## Routine: new date-wise ranking file
1. `python build_master.py`-style add_datefile into ranking_data.json (date from filename). 2. `python derive.py`. 3. rebuild dashboard from template8 + data4.json. 4. copy index.html + tracker; update artifact.
