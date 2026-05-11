/*
Creates a week-over-week Master score trend scanner for Power BI.

The view compares every fundamentals fetch date with the immediately previous
available fetch date per market and returns all stocks whose Master score
changed by at least 25 points in either direction.
*/

USE [stockdata_db];
GO

CREATE OR ALTER VIEW dbo.vw_PowerBI_MasterScoreTrendWoW AS
WITH fundamentals AS (
    SELECT
        'NSE' AS market,
        ticker,
        company_name,
        CAST(fetch_date AS date) AS snapshot_date,
        market_cap,
        trailing_pe,
        price_to_book,
        price_to_sales,
        peg_ratio,
        return_on_equity,
        return_on_assets,
        profit_margin,
        debt_to_equity,
        free_cashflow,
        revenue_growth,
        earnings_growth,
        dividend_yield,
        payout_ratio
    FROM dbo.nse_500_fundamentals

    UNION ALL

    SELECT
        'NASDAQ' AS market,
        ticker,
        company_name,
        CAST(fetch_date AS date) AS snapshot_date,
        market_cap,
        trailing_pe,
        price_to_book,
        price_to_sales,
        peg_ratio,
        return_on_equity,
        return_on_assets,
        profit_margin,
        debt_to_equity,
        free_cashflow,
        revenue_growth,
        earnings_growth,
        dividend_yield,
        payout_ratio
    FROM dbo.nasdaq_100_fundamentals
),
date_pairs AS (
    SELECT
        dates.market,
        dates.current_fetch_date,
        (
            SELECT MAX(f2.snapshot_date)
            FROM fundamentals f2
            WHERE f2.market = dates.market
              AND f2.snapshot_date < dates.current_fetch_date
        ) AS previous_fetch_date
    FROM (
        SELECT DISTINCT market, snapshot_date AS current_fetch_date
        FROM fundamentals
    ) dates
),
scored AS (
    SELECT
        f.market,
        f.ticker,
        f.company_name,
        f.snapshot_date,
        f.market_cap,
        (
            CASE
                WHEN f.trailing_pe IS NULL OR f.trailing_pe <= 0 THEN 0
                WHEN f.trailing_pe < 10 THEN 25
                WHEN f.trailing_pe < 15 THEN 20
                WHEN f.trailing_pe < 20 THEN 15
                WHEN f.trailing_pe < 30 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.price_to_book IS NULL OR f.price_to_book <= 0 THEN 0
                WHEN f.price_to_book < 1 THEN 25
                WHEN f.price_to_book < 1.5 THEN 20
                WHEN f.price_to_book < 2 THEN 15
                WHEN f.price_to_book < 3 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.price_to_sales IS NULL OR f.price_to_sales <= 0 THEN 0
                WHEN f.price_to_sales < 1 THEN 20
                WHEN f.price_to_sales < 2 THEN 15
                WHEN f.price_to_sales < 3 THEN 10
                WHEN f.price_to_sales < 5 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.peg_ratio IS NULL OR f.peg_ratio <= 0 THEN 0
                WHEN f.peg_ratio < 0.5 THEN 15
                WHEN f.peg_ratio < 1 THEN 12
                WHEN f.peg_ratio < 1.5 THEN 8
                WHEN f.peg_ratio < 2 THEN 4
                ELSE 0
            END
            + CASE
                WHEN f.return_on_equity IS NULL THEN 0
                WHEN f.return_on_equity > 0.25 THEN 15
                WHEN f.return_on_equity > 0.20 THEN 12
                WHEN f.return_on_equity > 0.15 THEN 8
                WHEN f.return_on_equity > 0.10 THEN 4
                ELSE 0
            END
            + CASE
                WHEN f.return_on_equity IS NULL THEN 0
                WHEN f.return_on_equity > 0.30 THEN 25
                WHEN f.return_on_equity > 0.20 THEN 20
                WHEN f.return_on_equity > 0.15 THEN 15
                WHEN f.return_on_equity > 0.10 THEN 8
                ELSE 0
            END
            + CASE
                WHEN f.return_on_assets IS NULL THEN 0
                WHEN f.return_on_assets > 0.15 THEN 15
                WHEN f.return_on_assets > 0.10 THEN 12
                WHEN f.return_on_assets > 0.05 THEN 8
                ELSE 0
            END
            + CASE
                WHEN f.profit_margin IS NULL THEN 0
                WHEN f.profit_margin > 0.25 THEN 20
                WHEN f.profit_margin > 0.15 THEN 15
                WHEN f.profit_margin > 0.10 THEN 10
                WHEN f.profit_margin > 0.05 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.debt_to_equity IS NULL THEN 10
                WHEN f.debt_to_equity < 0.3 THEN 20
                WHEN f.debt_to_equity < 0.5 THEN 15
                WHEN f.debt_to_equity < 1 THEN 10
                WHEN f.debt_to_equity < 1.5 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.free_cashflow IS NULL OR f.free_cashflow <= 0 THEN 0
                ELSE 20
            END
            + CASE
                WHEN f.revenue_growth IS NULL THEN 0
                WHEN f.revenue_growth > 0.50 THEN 30
                WHEN f.revenue_growth > 0.30 THEN 25
                WHEN f.revenue_growth > 0.15 THEN 20
                WHEN f.revenue_growth > 0.10 THEN 10
                WHEN f.revenue_growth > 0 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.earnings_growth IS NULL THEN 0
                WHEN f.earnings_growth > 0.50 THEN 30
                WHEN f.earnings_growth > 0.30 THEN 25
                WHEN f.earnings_growth > 0.15 THEN 20
                WHEN f.earnings_growth > 0.10 THEN 10
                WHEN f.earnings_growth > 0 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.peg_ratio IS NULL OR f.peg_ratio <= 0 THEN 0
                WHEN f.peg_ratio < 1 THEN 20
                WHEN f.peg_ratio < 1.5 THEN 15
                WHEN f.peg_ratio < 2 THEN 10
                WHEN f.peg_ratio < 3 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.return_on_equity IS NULL THEN 0
                WHEN f.return_on_equity > 0.20 THEN 20
                WHEN f.return_on_equity > 0.15 THEN 15
                WHEN f.return_on_equity > 0.10 THEN 10
                ELSE 0
            END
            + CASE
                WHEN f.dividend_yield IS NULL OR f.dividend_yield <= 0 THEN 0
                WHEN f.dividend_yield > 0.05 THEN 35
                WHEN f.dividend_yield > 0.03 THEN 30
                WHEN f.dividend_yield > 0.02 THEN 20
                WHEN f.dividend_yield > 0.01 THEN 10
                ELSE 5
            END
            + CASE
                WHEN f.payout_ratio IS NULL THEN 15
                WHEN f.payout_ratio > 0 AND f.payout_ratio < 0.30 THEN 25
                WHEN f.payout_ratio < 0.50 THEN 20
                WHEN f.payout_ratio < 0.75 THEN 15
                WHEN f.payout_ratio < 1 THEN 5
                ELSE 0
            END
            + CASE
                WHEN f.free_cashflow IS NULL OR f.free_cashflow <= 0 THEN 0
                ELSE 20
            END
            + CASE
                WHEN f.debt_to_equity IS NULL THEN 10
                WHEN f.debt_to_equity < 0.5 THEN 20
                WHEN f.debt_to_equity < 1 THEN 15
                WHEN f.debt_to_equity < 1.5 THEN 10
                ELSE 0
            END
        ) AS master_score
    FROM fundamentals f
),
price_history AS (
    SELECT
        'NSE' AS market,
        ticker,
        CAST(trading_date AS date) AS trading_date,
        TRY_CONVERT(decimal(19, 4), close_price) AS close_price
    FROM dbo.nse_500_hist_data

    UNION ALL

    SELECT
        'NASDAQ' AS market,
        ticker,
        CAST(trading_date AS date) AS trading_date,
        TRY_CONVERT(decimal(19, 4), close_price) AS close_price
    FROM dbo.nasdaq_100_hist_data
),
changes AS (
    SELECT
        curr.market,
        curr.ticker,
        curr.company_name,
        dp.previous_fetch_date,
        dp.current_fetch_date,
        prev.master_score AS previous_master_score,
        curr.master_score AS current_master_score,
        curr.master_score - prev.master_score AS score_delta,
        ABS(curr.master_score - prev.master_score) AS abs_score_delta
    FROM date_pairs dp
    INNER JOIN scored curr
        ON curr.market = dp.market
       AND curr.snapshot_date = dp.current_fetch_date
    INNER JOIN scored prev
        ON prev.market = curr.market
       AND prev.ticker = curr.ticker
       AND prev.snapshot_date = dp.previous_fetch_date
    WHERE ABS(curr.master_score - prev.master_score) >= 25
)
SELECT
    c.market,
    c.ticker,
    c.company_name,
    c.previous_fetch_date,
    c.current_fetch_date,
    c.previous_master_score,
    c.current_master_score,
    c.score_delta,
    c.abs_score_delta,
    CASE WHEN c.score_delta >= 25 THEN 'Up' ELSE 'Down' END AS trend_direction,
    trend_price.trading_date AS trend_price_date,
    trend_price.close_price AS trend_close_price,
    current_price.trading_date AS current_trading_date,
    current_price.close_price AS current_close_price,
    current_price.close_price - trend_price.close_price AS price_change_since_trend,
    CASE
        WHEN trend_price.close_price IS NULL OR trend_price.close_price = 0 THEN NULL
        ELSE (current_price.close_price - trend_price.close_price) / trend_price.close_price
    END AS return_pct_since_trend
FROM changes c
OUTER APPLY (
    SELECT TOP (1) ph.trading_date, ph.close_price
    FROM price_history ph
    WHERE ph.market = c.market
      AND ph.ticker = c.ticker
      AND ph.close_price IS NOT NULL
    ORDER BY
        CASE WHEN ph.trading_date >= c.current_fetch_date THEN 0 ELSE 1 END,
        CASE
            WHEN ph.trading_date >= c.current_fetch_date
                THEN DATEDIFF(day, c.current_fetch_date, ph.trading_date)
            ELSE DATEDIFF(day, ph.trading_date, c.current_fetch_date)
        END ASC
) trend_price
OUTER APPLY (
    SELECT TOP (1) ph.trading_date, ph.close_price
    FROM price_history ph
    WHERE ph.market = c.market
      AND ph.ticker = c.ticker
      AND ph.close_price IS NOT NULL
    ORDER BY ph.trading_date DESC
) current_price;
GO

PRINT 'View dbo.vw_PowerBI_MasterScoreTrendWoW created or updated.';
PRINT 'Power BI imports this view for the Master Score Trend Week Over Week page.';
GO
