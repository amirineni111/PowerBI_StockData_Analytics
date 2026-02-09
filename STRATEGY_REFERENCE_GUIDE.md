# Strategy Reference Guide

## Quick Reference: What's What After Renaming

### Strategy-1 (ML-Based Trading Signals)
**Data Source:** `ml_*` tables (ml_nse_trading_predictions, ml_trading_predictions, forex_ml_predictions)
**Power BI Pages:**
- Strategy-1: ML Overview
- Strategy-1: Historical Performance  
- Strategy-1: Trade Opportunities

**Key Features:**
- Real-time ML predictions from multiple models
- Technical indicator alignment scoring
- Trade opportunity grading (A, B, C, D)
- Performance tracking with actual returns
- Sector and market cap classifications (NSE only)

**Database Views:**
- vw_strategy2_unified_ml_predictions
- vw_strategy2_ml_tech_combined
- vw_strategy2_trade_opportunities
- vw_strategy2_historical_performance
- vw_strategy2_outcome_tracking
- vw_strategy2_powerbi_dashboard

**DAX Measures:** All measures starting with "S2 *" in "Strategy-1" folder

---

### Strategy-2 (AI Prediction History)
**Data Source:** `ai_prediction_history` table
**Power BI Pages:**
- Strategy-2: AI Predictions Overview
- Strategy-2: AI Prediction Accuracy

**Key Features:**
- Historical AI predictions with multiple time horizons (1d, 7d, 10d)
- Multiple model ensemble predictions
- Actual vs predicted performance tracking
- Model confidence and accuracy metrics
- TIER-based opportunity classification

**Database Views:**
- vw_PowerBI_Opportunities
- vw_PowerBI_AI_Technical_Combos
- vw_PowerBI_HistoricalTrend
- vw_PowerBI_DataFreshness
- vw_PowerBI_TopTickers

**DAX Measures:** All measures starting with "S1 *" in "Strategy-2" folder

---

## Key Differences

| Feature | Strategy-1 (ml_*) | Strategy-2 (ai_prediction_history) |
|---------|-------------------|-------------------------------------|
| **Update Frequency** | Real-time daily | Historical tracking |
| **Prediction Horizon** | Current trading day | 1d, 7d, 10d ahead |
| **Model Approach** | Latest ML model predictions | Multi-model ensemble |
| **Technical Integration** | Deep integration with signal_tracking_history | Light integration |
| **Grading System** | A/B/C/D trade grades | TIER 1/2/3 classification |
| **Best For** | Intraday and short-term trades | Medium-term position analysis |
| **Markets** | NSE, NASDAQ, Forex | NSE, NASDAQ, Forex |

---

## When to Use Each Strategy

### Use Strategy-1 When:
- You want TODAY's trading opportunities
- You need trade grades based on ML + Technical alignment
- You want sector/market cap filtering (NSE)
- You're making short-term trading decisions
- You want to see the latest ML model performance

### Use Strategy-2 When:
- You want historical prediction accuracy analysis
- You need to understand multi-model consensus
- You're evaluating prediction performance over time
- You want to see TIER-based opportunity rankings
- You're analyzing model drift and accuracy trends

---

## Common Confusion Points

⚠️ **View Names Don't Match Strategy Names**
- Database views named `vw_strategy2_*` actually serve Strategy-1
- Database views named `vw_PowerBI_*` actually serve Strategy-2
- This is intentional to avoid breaking Power BI table references

⚠️ **Measure Prefixes vs Folder Names**
- Measures prefixed "S2 *" are in "Strategy-1" folder (use ml_* data)
- Measures prefixed "S1 *" are in "Strategy-2" folder (use ai_prediction_history)
- The prefix reflects the old naming; the folder reflects correct naming

⚠️ **Data Freshness**
- Strategy-1: As current as your ML prediction process
- Strategy-2: Requires actual price updates for accuracy calculation
- Both strategies depend on signal_tracking_history for technical signals

---

## Data Flow

### Strategy-1 Flow:
```
ML Prediction Tables (ml_*)
    ↓
vw_strategy2_unified_ml_predictions (combines NSE/NASDAQ/Forex)
    ↓
vw_strategy2_ml_tech_combined (joins with signal_tracking_history)
    ↓
vw_strategy2_trade_opportunities (adds scoring and grading)
    ↓
Power BI Strategy-1 Reports
```

### Strategy-2 Flow:
```
ai_prediction_history (multiple models, multiple horizons)
    ↓
vw_PowerBI_Opportunities (combines AI + Technical signals)
    ↓
vw_PowerBI_AI_Technical_Combos (TIER classification)
    ↓
vw_PowerBI_HistoricalTrend (performance over time)
    ↓
Power BI Strategy-2 Reports
```

---

## Upcoming Enhancements

After running `Strategy1_Add_New_Columns.sql`, Strategy-1 will have:
- ✅ Actual return tracking (1d, 5d, 10d)
- ✅ Prediction accuracy classification
- ✅ Direction correctness flags
- ✅ Model name and version tracking
- ✅ Sector and market cap data (NSE)
- ✅ Trading volume data

This will enable new analyses like:
- Model performance comparison
- Sector-based filtering
- Accuracy trending
- Volume-weighted signals
