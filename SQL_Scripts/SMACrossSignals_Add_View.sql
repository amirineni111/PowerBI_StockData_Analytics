CREATE OR ALTER VIEW dbo.vw_PowerBI_SMACrossSignals
AS
WITH cross_events AS (
    SELECT
        CAST('NSE' AS varchar(10)) AS market,
        s.ticker,
        COALESCE(n.company_name, s.ticker) AS company_name,
        CAST(s.trading_date AS date) AS trading_date,
        CAST(s.trading_date AS date) AS cross_date,
        s.sma_trade_signal AS cross_type,
        s.close_price AS cross_close_price,
        s.SMA_20 AS sma_20,
        s.SMA_50 AS sma_50,
        s.SMA_20 - s.SMA_50 AS sma_spread,
        s.Trend_Status AS trend_status,
        s.SMA_Cross_Status AS cross_status,
        current_price.trading_date AS current_trading_date,
        current_price.close_price AS current_close_price
    FROM dbo.nse_500_sma_signals s
    LEFT JOIN dbo.nse_500 n
        ON n.ticker = s.ticker
    OUTER APPLY (
        SELECT TOP (1)
            CAST(h.trading_date AS date) AS trading_date,
            h.close_price
        FROM dbo.nse_500_hist_data h
        WHERE h.ticker = s.ticker
        ORDER BY h.trading_date DESC
    ) current_price
    WHERE s.sma_trade_signal IN ('Golden Cross', 'Death Cross')

    UNION ALL

    SELECT
        CAST('NASDAQ' AS varchar(10)) AS market,
        s.ticker,
        COALESCE(n.company_name, s.ticker) AS company_name,
        CAST(s.trading_date AS date) AS trading_date,
        CAST(s.trading_date AS date) AS cross_date,
        s.sma_trade_signal AS cross_type,
        s.close_price AS cross_close_price,
        s.SMA_20 AS sma_20,
        s.SMA_50 AS sma_50,
        s.SMA_20 - s.SMA_50 AS sma_spread,
        s.Trend_Status AS trend_status,
        s.SMA_Cross_Status AS cross_status,
        current_price.trading_date AS current_trading_date,
        current_price.close_price AS current_close_price
    FROM dbo.nasdaq_100_sma_signals s
    LEFT JOIN dbo.nasdaq_top100 n
        ON n.ticker = s.ticker
    OUTER APPLY (
        SELECT TOP (1)
            CAST(h.trading_date AS date) AS trading_date,
            h.close_price
        FROM dbo.nasdaq_100_hist_data h
        WHERE h.ticker = s.ticker
        ORDER BY h.trading_date DESC
    ) current_price
    WHERE s.sma_trade_signal IN ('Golden Cross', 'Death Cross')
)
SELECT
    market,
    ticker,
    company_name,
    trading_date,
    cross_date,
    cross_type,
    cross_close_price,
    current_trading_date,
    current_close_price,
    current_close_price - cross_close_price AS price_change_since_cross,
    CASE
        WHEN cross_close_price IS NULL OR cross_close_price = 0 THEN NULL
        ELSE (current_close_price - cross_close_price) / cross_close_price
    END AS return_pct_since_cross,
    sma_20,
    sma_50,
    sma_spread,
    trend_status,
    cross_status
FROM cross_events;
GO
