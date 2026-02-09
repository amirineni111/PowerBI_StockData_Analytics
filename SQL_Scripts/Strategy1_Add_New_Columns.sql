-- =====================================================
-- Strategy-1 View Updates: Add New Performance Columns
-- Purpose: Add actual_return, prediction_accuracy, 
--          direction_correct, model metadata columns
-- Run this when database is responsive
-- =====================================================

USE stockdata_db;
GO

-- =====================================================
-- 1. UPDATE: vw_strategy2_unified_ml_predictions
--    (This is actually Strategy-1 per corrected naming)
-- =====================================================

DROP VIEW IF EXISTS dbo.vw_strategy2_unified_ml_predictions;
GO

CREATE VIEW dbo.vw_strategy2_unified_ml_predictions AS
-- NSE ml_nse_trading_predictions
SELECT 
    'NSE' as market,
    ticker,
    company,
    trading_date as prediction_date,
    predicted_signal,
    confidence as ml_confidence,
    confidence_percentage,
    signal_strength as ml_signal_strength,
    close_price,
    rsi,
    rsi_category,
    buy_probability,
    sell_probability,
    CASE 
        WHEN predicted_signal = 'Buy' THEN 'LONG'
        WHEN predicted_signal = 'Sell' THEN 'SHORT'
        ELSE 'NEUTRAL'
    END as trade_direction,
    -- NEW COLUMNS --
    volume,
    hold_probability,
    model_name,
    model_version,
    sector,
    market_cap_category,
    medium_confidence,
    low_confidence,
    actual_return_1d,
    actual_return_5d,
    actual_return_10d,
    prediction_accuracy,
    direction_correct_1d,
    direction_correct_5d,
    updated_at
FROM dbo.ml_nse_trading_predictions

UNION ALL

-- NASDAQ ml_trading_predictions
SELECT 
    'NASDAQ' as market,
    ticker,
    company,
    trading_date as prediction_date,
    predicted_signal,
    confidence as ml_confidence,
    confidence_percentage,
    signal_strength as ml_signal_strength,
    close_price,
    RSI as rsi,
    rsi_category,
    buy_probability,
    sell_probability,
    CASE 
        WHEN predicted_signal LIKE '%Buy%' THEN 'LONG'
        WHEN predicted_signal LIKE '%Sell%' THEN 'SHORT'
        ELSE 'NEUTRAL'
    END as trade_direction,
    -- NEW COLUMNS (NULL where not available) --
    NULL as volume,
    NULL as hold_probability,
    NULL as model_name,
    NULL as model_version,
    NULL as sector,
    NULL as market_cap_category,
    NULL as medium_confidence,
    NULL as low_confidence,
    actual_return_1d,
    actual_return_5d,
    actual_return_10d,
    prediction_accuracy,
    direction_correct_1d,
    direction_correct_5d,
    updated_at
FROM dbo.ml_trading_predictions

UNION ALL

-- Forex forex_ml_predictions
SELECT 
    'Forex' as market,
    currency_pair as ticker,
    currency_pair as company,
    CAST(date_time as date) as prediction_date,
    predicted_signal,
    signal_confidence as ml_confidence,
    signal_confidence * 100 as confidence_percentage,
    CASE 
        WHEN signal_confidence >= 0.8 THEN 'High'
        WHEN signal_confidence >= 0.6 THEN 'Medium'
        ELSE 'Low'
    END as ml_signal_strength,
    close_price,
    NULL as rsi,
    NULL as rsi_category,
    prob_buy as buy_probability,
    prob_sell as sell_probability,
    CASE 
        WHEN predicted_signal = 'BUY' THEN 'LONG'
        WHEN predicted_signal = 'SELL' THEN 'SHORT'
        ELSE 'NEUTRAL'
    END as trade_direction,
    -- NEW COLUMNS --
    volume,
    NULL as hold_probability,
    model_name,
    model_version,
    NULL as sector,
    NULL as market_cap_category,
    NULL as medium_confidence,
    NULL as low_confidence,
    actual_return_1d,
    actual_return_5d,
    actual_return_10d,
    prediction_accuracy,
    direction_correct_1d,
    direction_correct_5d,
    updated_at
FROM dbo.forex_ml_predictions;
GO

PRINT 'View vw_strategy2_unified_ml_predictions updated successfully with new columns';
GO

-- =====================================================
-- 2. UPDATE: vw_strategy2_ml_tech_combined
--    Add new columns from unified predictions
-- =====================================================

DROP VIEW IF EXISTS dbo.vw_strategy2_ml_tech_combined;
GO

CREATE VIEW dbo.vw_strategy2_ml_tech_combined AS
SELECT 
    ml.market,
    ml.ticker,
    ml.company,
    ml.prediction_date,
    ml.predicted_signal as ml_signal,
    ml.ml_confidence,
    ml.confidence_percentage as ml_confidence_pct,
    ml.ml_signal_strength,
    ml.trade_direction as ml_direction,
    ml.close_price as ml_close_price,
    ml.rsi as ml_rsi,
    ml.rsi_category,
    ml.buy_probability,
    ml.sell_probability,
    -- NEW COLUMNS --
    ml.volume as ml_volume,
    ml.hold_probability,
    ml.model_name,
    ml.model_version,
    ml.sector,
    ml.market_cap_category,
    ml.medium_confidence,
    ml.low_confidence,
    ml.actual_return_1d,
    ml.actual_return_5d,
    ml.actual_return_10d,
    ml.prediction_accuracy,
    ml.direction_correct_1d,
    ml.direction_correct_5d,
    ml.updated_at as ml_updated_at,
    -- Technical signals --
    s.signal_id,
    s.signal_type as tech_signal,
    s.signal_strength as tech_signal_strength,
    s.signal_status,
    s.macd_signal as tech_macd,
    s.rsi_signal as tech_rsi,
    s.bb_signal as tech_bb,
    s.sma_signal as tech_sma,
    s.stoch_signal as tech_stoch,
    s.fib_signal as tech_fib,
    s.pattern_signal as tech_pattern,
    s.signal_price as tech_signal_price,
    s.target_date_7d,
    s.target_date_14d,
    s.target_date_30d,
    s.actual_price_7d,
    s.actual_change_7d,
    s.result_7d,
    s.actual_price_14d,
    s.actual_change_14d,
    s.result_14d,
    s.actual_price_30d,
    s.actual_change_30d,
    s.result_30d,
    -- Calculated fields --
    CASE 
        WHEN (ml.trade_direction = 'LONG' AND s.signal_type = 'BULLISH') 
          OR (ml.trade_direction = 'SHORT' AND s.signal_type = 'BEARISH') 
        THEN 1 
        ELSE 0 
    END as signals_aligned,
    CASE 
        WHEN ml.ml_confidence >= 0.8 AND s.signal_strength >= 3 THEN 'HIGH'
        WHEN ml.ml_confidence >= 0.7 AND s.signal_strength >= 2 THEN 'MEDIUM'
        ELSE 'LOW'
    END as combined_confidence
FROM dbo.vw_strategy2_unified_ml_predictions ml
LEFT JOIN dbo.signal_tracking_history s 
    ON ml.ticker = s.ticker 
    AND ml.prediction_date = s.signal_date;
GO

PRINT 'View vw_strategy2_ml_tech_combined updated successfully with new columns';
GO

-- =====================================================
-- 3. UPDATE: vw_strategy2_trade_opportunities
--    Add new columns for enhanced analysis
-- =====================================================

DROP VIEW IF EXISTS dbo.vw_strategy2_trade_opportunities;
GO

CREATE VIEW dbo.vw_strategy2_trade_opportunities AS
SELECT 
    c.market,
    c.ticker,
    c.company,
    c.prediction_date,
    c.ml_signal,
    c.ml_confidence,
    c.ml_confidence_pct,
    c.ml_signal_strength,
    c.ml_direction,
    c.ml_close_price,
    c.ml_rsi,
    c.rsi_category,
    c.buy_probability,
    c.sell_probability,
    -- NEW COLUMNS --
    c.ml_volume,
    c.hold_probability,
    c.model_name,
    c.model_version,
    c.sector,
    c.market_cap_category,
    c.actual_return_1d,
    c.actual_return_5d,
    c.actual_return_10d,
    c.prediction_accuracy,
    c.direction_correct_1d,
    c.direction_correct_5d,
    -- Technical signals --
    c.tech_signal,
    c.tech_signal_strength,
    c.tech_macd,
    c.tech_rsi,
    c.tech_bb,
    c.tech_sma,
    c.tech_stoch,
    c.tech_fib,
    c.tech_pattern,
    c.tech_signal_price,
    c.signals_aligned,
    c.combined_confidence,
    c.target_date_7d,
    c.target_date_14d,
    c.target_date_30d,
    -- Opportunity scoring --
    CASE 
        WHEN c.signals_aligned = 1 AND c.ml_direction = 'SHORT' AND c.tech_signal = 'BEARISH' 
             AND c.tech_signal_strength >= 3 AND c.ml_confidence >= 0.7 
        THEN 90 + (c.tech_signal_strength * 2) + (c.ml_confidence * 10)
        WHEN c.signals_aligned = 1 AND c.ml_direction = 'SHORT' AND c.tech_signal = 'BEARISH' 
             AND c.tech_signal_strength >= 2 AND c.ml_confidence >= 0.7 
        THEN 75 + (c.tech_signal_strength * 2) + (c.ml_confidence * 10)
        WHEN c.signals_aligned = 1 AND c.ml_direction = 'LONG' AND c.tech_signal = 'BULLISH' 
             AND c.tech_signal_strength >= 4 AND c.ml_confidence >= 0.8 
        THEN 70 + (c.tech_signal_strength * 2) + (c.ml_confidence * 10)
        WHEN c.signals_aligned = 1 AND c.ml_direction = 'LONG' AND c.tech_signal = 'BULLISH' 
             AND c.tech_signal_strength >= 3 AND c.ml_confidence >= 0.7 
        THEN 55 + (c.tech_signal_strength * 2) + (c.ml_confidence * 10)
        WHEN c.signals_aligned = 0 THEN 20
        ELSE 40
    END as opportunity_score,
    CASE 
        WHEN c.signals_aligned = 1 AND c.ml_direction = 'SHORT' AND c.tech_signal = 'BEARISH' 
             AND c.tech_signal_strength >= 3 
        THEN 'A - HIGH CONVICTION SHORT'
        WHEN c.signals_aligned = 1 AND c.ml_direction = 'SHORT' AND c.tech_signal = 'BEARISH' 
             AND c.tech_signal_strength >= 2 
        THEN 'B - GOOD SHORT'
        WHEN c.signals_aligned = 1 AND c.ml_direction = 'LONG' AND c.tech_signal = 'BULLISH' 
             AND c.tech_signal_strength >= 4 
        THEN 'B - STRONG LONG (Use Caution)'
        WHEN c.signals_aligned = 1 AND c.ml_direction = 'LONG' AND c.tech_signal = 'BULLISH' 
             AND c.tech_signal_strength >= 3 
        THEN 'C - MODERATE LONG'
        WHEN c.signals_aligned = 0 THEN 'D - CONFLICTING SIGNALS'
        ELSE 'C - WEAK SIGNAL'
    END as trade_grade,
    CASE 
        WHEN c.ml_direction = 'SHORT' THEN 'SELL / SHORT'
        WHEN c.ml_direction = 'LONG' THEN 'BUY / LONG'
        ELSE 'HOLD'
    END as recommended_action,
    CASE 
        WHEN c.rsi_category = 'Oversold' AND c.ml_direction = 'LONG' 
        THEN 'RSI Oversold - Good Entry'
        WHEN c.rsi_category = 'Overbought' AND c.ml_direction = 'SHORT' 
        THEN 'RSI Overbought - Good Entry'
        WHEN c.rsi_category = 'Oversold' AND c.ml_direction = 'SHORT' 
        THEN 'CAUTION: RSI Oversold against Short'
        WHEN c.rsi_category = 'Overbought' AND c.ml_direction = 'LONG' 
        THEN 'CAUTION: RSI Overbought against Long'
        ELSE 'RSI Neutral'
    END as rsi_assessment
FROM dbo.vw_strategy2_ml_tech_combined c
WHERE c.prediction_date >= DATEADD(day, -7, GETDATE());
GO

PRINT 'View vw_strategy2_trade_opportunities updated successfully with new columns';
GO

-- =====================================================
-- Verification Queries
-- =====================================================

PRINT '';
PRINT '===== VERIFICATION =====';
PRINT 'Run these queries to verify the new columns:';
PRINT '';
PRINT '-- Check unified predictions columns:';
PRINT 'SELECT TOP 3 market, ticker, prediction_date, model_name, sector, actual_return_1d, prediction_accuracy FROM dbo.vw_strategy2_unified_ml_predictions WHERE model_name IS NOT NULL;';
PRINT '';
PRINT '-- Check trade opportunities columns:';
PRINT 'SELECT TOP 3 market, ticker, model_name, sector, actual_return_5d, direction_correct_5d FROM dbo.vw_strategy2_trade_opportunities WHERE model_name IS NOT NULL;';
PRINT '';
PRINT '===== SCRIPT COMPLETED =====';
GO
