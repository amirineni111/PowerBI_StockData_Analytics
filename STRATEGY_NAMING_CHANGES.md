# Strategy Naming Standardization - Summary

## Date: February 1, 2026

## Problem Identified
The strategy naming was backwards:
- **Strategy-1** was using `ai_prediction_history` (should use `ml_*` tables)
- **Strategy-2** was using `ml_*` tables (should use `ai_prediction_history`)

## Solution Implemented
**Renamed the strategies in Power BI** to match the correct naming standard WITHOUT changing the underlying database views/data sources.

---

## Changes Made to Power BI Project

### 1. Report Page Display Names Updated

| Old Display Name | New Display Name | Data Source |
|------------------|------------------|-------------|
| "AI Predictions Overview" | "Strategy-2: AI Predictions Overview" | `ai_prediction_history` ✓ |
| "AI Prediction Accuracy Analysis" | "Strategy-2: AI Prediction Accuracy" | `ai_prediction_history` ✓ |
| "Strategy-2 Overview" | "Strategy-1: ML Overview" | `ml_*` tables ✓ |
| "Strategy-2 Historical Performance" | "Strategy-1: Historical Performance" | `ml_*` tables ✓ |
| "Strategy-2 Trade Opportunities" | "Strategy-1: Trade Opportunities" | `ml_*` tables ✓ |

**Files Modified:**
- `ai_overview_page01/page.json`
- `ai_accuracy_page02/page.json`
- `strategy2_overview/page.json`
- `strategy2_performance/page.json`
- `strategy2_opportunities/page.json`

### 2. DAX Measure Display Folders Swapped

**In `_Measures.tmdl`:**
- All measures in folder "Strategy-1" → moved to "Strategy-2"
- All measures in folder "Strategy-2" → moved to "Strategy-1"

This ensures:
- **Strategy-1 measures** (prefixed `S2 *`) now appear under "Strategy-1" folder (uses `ml_*` tables)
- **Strategy-2 measures** (prefixed `S1 *`) now appear under "Strategy-2" folder (uses `ai_prediction_history`)

---

## Database Views - NO CHANGES YET

### Current Database View Names (NOT Changed)
These view names remain as-is because renaming would break existing Power BI table references:

| View Name | Data Source | Actually Represents |
|-----------|-------------|---------------------|
| `vw_PowerBI_Opportunities` | `ai_prediction_history` | Strategy-2 |
| `vw_PowerBI_AI_Technical_Combos` | `ai_prediction_history` | Strategy-2 |
| `vw_PowerBI_HistoricalTrend` | `ai_prediction_history` | Strategy-2 |
| `vw_strategy2_unified_ml_predictions` | `ml_*` tables | Strategy-1 |
| `vw_strategy2_ml_tech_combined` | `ml_*` tables | Strategy-1 |
| `vw_strategy2_trade_opportunities` | `ml_*` tables | Strategy-1 |
| `vw_strategy2_historical_performance` | `ml_*` tables | Strategy-1 |
| `vw_strategy2_outcome_tracking` | `ml_*` tables | Strategy-1 |
| `vw_strategy2_powerbi_dashboard` | `ml_*` tables | Strategy-1 |

**Note:** The view names contain "strategy2" but they actually represent Strategy-1 data. This is a known inconsistency but changing them would require updating all Power BI TMDL table definitions.

---

## SQL Script Created: Add New Columns to Strategy-1 Views

**File:** `SQL_Scripts/Strategy1_Add_New_Columns.sql`

### New Columns Being Added

#### From `ml_nse_trading_predictions` (NSE):
- `volume` - Trading volume
- `hold_probability` - Third probability option
- `model_name`, `model_version` - Model metadata
- `sector`, `market_cap_category` - Fundamental classifications
- `medium_confidence`, `low_confidence` - Confidence breakdowns
- `actual_return_1d`, `actual_return_5d`, `actual_return_10d` - Actual returns
- `prediction_accuracy` - Accuracy classification
- `direction_correct_1d`, `direction_correct_5d` - Direction flags
- `updated_at` - Last update timestamp

#### From `ml_trading_predictions` (NASDAQ):
- `actual_return_1d`, `actual_return_5d`, `actual_return_10d`
- `prediction_accuracy`
- `direction_correct_1d`, `direction_correct_5d`
- `updated_at`

#### From `forex_ml_predictions` (Forex):
- `volume`
- `model_name`, `model_version`
- `features_used`
- `actual_return_1d`, `actual_return_5d`, `actual_return_10d`
- `prediction_accuracy`
- `direction_correct_1d`, `direction_correct_5d`
- `updated_at`

### Views Being Updated
1. **`vw_strategy2_unified_ml_predictions`** - Adds all new columns from source tables
2. **`vw_strategy2_ml_tech_combined`** - Passes through new columns from unified view
3. **`vw_strategy2_trade_opportunities`** - Adds new columns for reporting

### When to Run
Run the SQL script (`Strategy1_Add_New_Columns.sql`) when the database is responsive. It will:
- Drop and recreate the three views with new columns
- Include verification queries to test the changes

---

## Next Steps

### 1. Run SQL Script (When Database is Responsive)
```sql
-- Execute this file:
c:\Users\sreea\OneDrive\Desktop\PowerBI_StockData_Analytics_202601\SQL_Scripts\Strategy1_Add_New_Columns.sql
```

### 2. Update Power BI Table Definitions (After SQL Script)
Once the SQL views are updated, you'll need to:
- Open Power BI Desktop
- Refresh the data model
- Check if new columns appear automatically, or
- Update the `.tmdl` files to include new column definitions

### 3. Create New DAX Measures (Optional)
With the new columns available, you could create measures like:
- Prediction accuracy by model
- Actual vs predicted return comparison
- Direction correctness rates
- Performance by sector (NSE only)
- Model performance comparison

---

## Testing Checklist

After running the SQL script and refreshing Power BI:

- [ ] Verify Strategy-1 pages show correct names ("Strategy-1: ML Overview", etc.)
- [ ] Verify Strategy-2 pages show correct names ("Strategy-2: AI Predictions Overview", etc.)
- [ ] Verify all measures still calculate correctly
- [ ] Verify all visuals render without errors
- [ ] Check that new columns appear in Strategy-1 tables
- [ ] Run verification queries from SQL script

---

## Summary

✅ **Completed:**
- Renamed all strategy labels in Power BI to match correct naming standard
- Created SQL script to add new performance tracking columns to Strategy-1 views

⏳ **Pending (Manual Action Required):**
- Run SQL script when database is responsive
- Refresh Power BI data model
- Optionally add new DAX measures leveraging new columns

---

## Files Modified

**Power BI Report Pages:**
- `PBI_ProjectFolder/StockData_Analysis_v1.Report/definition/pages/ai_overview_page01/page.json`
- `PBI_ProjectFolder/StockData_Analysis_v1.Report/definition/pages/ai_accuracy_page02/page.json`
- `PBI_ProjectFolder/StockData_Analysis_v1.Report/definition/pages/strategy2_overview/page.json`
- `PBI_ProjectFolder/StockData_Analysis_v1.Report/definition/pages/strategy2_performance/page.json`
- `PBI_ProjectFolder/StockData_Analysis_v1.Report/definition/pages/strategy2_opportunities/page.json`

**Power BI Measures:**
- `PBI_ProjectFolder/StockData_Analysis_v1.SemanticModel/definition/tables/_Measures.tmdl`

**SQL Script Created:**
- `SQL_Scripts/Strategy1_Add_New_Columns.sql`
