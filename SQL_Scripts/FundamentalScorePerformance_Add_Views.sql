/*
Creates a reusable performance snapshot for fundamental score reports.

Each row represents a stock score on a fundamentals fetch date, ranked within
market and score type. The final view keeps the top 10 per market, per score
type, per snapshot date and compares the selected-date price with the latest
available close price.
*/

USE [stockdata_db];
GO

CREATE OR ALTER VIEW dbo.vw_PowerBI_FundamentalScorePerformance AS
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
scored AS (
    SELECT
        market,
        ticker,
        company_name,
        snapshot_date,
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
        payout_ratio,
        (
            CASE
                WHEN trailing_pe IS NULL OR trailing_pe <= 0 THEN 0
                WHEN trailing_pe < 10 THEN 25
                WHEN trailing_pe < 15 THEN 20
                WHEN trailing_pe < 20 THEN 15
                WHEN trailing_pe < 30 THEN 5
                ELSE 0
            END
            + CASE
                WHEN price_to_book IS NULL OR price_to_book <= 0 THEN 0
                WHEN price_to_book < 1 THEN 25
                WHEN price_to_book < 1.5 THEN 20
                WHEN price_to_book < 2 THEN 15
                WHEN price_to_book < 3 THEN 5
                ELSE 0
            END
            + CASE
                WHEN price_to_sales IS NULL OR price_to_sales <= 0 THEN 0
                WHEN price_to_sales < 1 THEN 20
                WHEN price_to_sales < 2 THEN 15
                WHEN price_to_sales < 3 THEN 10
                WHEN price_to_sales < 5 THEN 5
                ELSE 0
            END
            + CASE
                WHEN peg_ratio IS NULL OR peg_ratio <= 0 THEN 0
                WHEN peg_ratio < 0.5 THEN 15
                WHEN peg_ratio < 1 THEN 12
                WHEN peg_ratio < 1.5 THEN 8
                WHEN peg_ratio < 2 THEN 4
                ELSE 0
            END
            + CASE
                WHEN return_on_equity IS NULL THEN 0
                WHEN return_on_equity > 0.25 THEN 15
                WHEN return_on_equity > 0.20 THEN 12
                WHEN return_on_equity > 0.15 THEN 8
                WHEN return_on_equity > 0.10 THEN 4
                ELSE 0
            END
        ) AS value_score,
        (
            CASE
                WHEN return_on_equity IS NULL THEN 0
                WHEN return_on_equity > 0.30 THEN 25
                WHEN return_on_equity > 0.20 THEN 20
                WHEN return_on_equity > 0.15 THEN 15
                WHEN return_on_equity > 0.10 THEN 8
                ELSE 0
            END
            + CASE
                WHEN return_on_assets IS NULL THEN 0
                WHEN return_on_assets > 0.15 THEN 15
                WHEN return_on_assets > 0.10 THEN 12
                WHEN return_on_assets > 0.05 THEN 8
                ELSE 0
            END
            + CASE
                WHEN profit_margin IS NULL THEN 0
                WHEN profit_margin > 0.25 THEN 20
                WHEN profit_margin > 0.15 THEN 15
                WHEN profit_margin > 0.10 THEN 10
                WHEN profit_margin > 0.05 THEN 5
                ELSE 0
            END
            + CASE
                WHEN debt_to_equity IS NULL THEN 10
                WHEN debt_to_equity < 0.3 THEN 20
                WHEN debt_to_equity < 0.5 THEN 15
                WHEN debt_to_equity < 1 THEN 10
                WHEN debt_to_equity < 1.5 THEN 5
                ELSE 0
            END
            + CASE
                WHEN free_cashflow IS NULL OR free_cashflow <= 0 THEN 0
                ELSE 20
            END
        ) AS quality_score,
        (
            CASE
                WHEN revenue_growth IS NULL THEN 0
                WHEN revenue_growth > 0.50 THEN 30
                WHEN revenue_growth > 0.30 THEN 25
                WHEN revenue_growth > 0.15 THEN 20
                WHEN revenue_growth > 0.10 THEN 10
                WHEN revenue_growth > 0 THEN 5
                ELSE 0
            END
            + CASE
                WHEN earnings_growth IS NULL THEN 0
                WHEN earnings_growth > 0.50 THEN 30
                WHEN earnings_growth > 0.30 THEN 25
                WHEN earnings_growth > 0.15 THEN 20
                WHEN earnings_growth > 0.10 THEN 10
                WHEN earnings_growth > 0 THEN 5
                ELSE 0
            END
            + CASE
                WHEN peg_ratio IS NULL OR peg_ratio <= 0 THEN 0
                WHEN peg_ratio < 1 THEN 20
                WHEN peg_ratio < 1.5 THEN 15
                WHEN peg_ratio < 2 THEN 10
                WHEN peg_ratio < 3 THEN 5
                ELSE 0
            END
            + CASE
                WHEN return_on_equity IS NULL THEN 0
                WHEN return_on_equity > 0.20 THEN 20
                WHEN return_on_equity > 0.15 THEN 15
                WHEN return_on_equity > 0.10 THEN 10
                ELSE 0
            END
        ) AS growth_score,
        (
            CASE
                WHEN dividend_yield IS NULL OR dividend_yield <= 0 THEN 0
                WHEN dividend_yield > 0.05 THEN 35
                WHEN dividend_yield > 0.03 THEN 30
                WHEN dividend_yield > 0.02 THEN 20
                WHEN dividend_yield > 0.01 THEN 10
                ELSE 5
            END
            + CASE
                WHEN payout_ratio IS NULL THEN 15
                WHEN payout_ratio > 0 AND payout_ratio < 0.30 THEN 25
                WHEN payout_ratio < 0.50 THEN 20
                WHEN payout_ratio < 0.75 THEN 15
                WHEN payout_ratio < 1 THEN 5
                ELSE 0
            END
            + CASE
                WHEN free_cashflow IS NULL OR free_cashflow <= 0 THEN 0
                ELSE 20
            END
            + CASE
                WHEN debt_to_equity IS NULL THEN 10
                WHEN debt_to_equity < 0.5 THEN 20
                WHEN debt_to_equity < 1 THEN 15
                WHEN debt_to_equity < 1.5 THEN 10
                ELSE 0
            END
        ) AS dividend_score
    FROM fundamentals
),
score_rows AS (
    SELECT
        s.market,
        s.ticker,
        s.company_name,
        s.snapshot_date,
        s.market_cap,
        v.score_type,
        v.score,
        s.value_score,
        s.quality_score,
        s.growth_score,
        s.dividend_score,
        s.trailing_pe,
        s.price_to_book,
        s.peg_ratio,
        s.return_on_equity,
        s.revenue_growth,
        s.earnings_growth
    FROM scored s
    CROSS APPLY (VALUES
        ('Value', s.value_score),
        ('Quality', s.quality_score),
        ('Growth', s.growth_score),
        ('Master', s.value_score + s.quality_score + s.growth_score + s.dividend_score)
    ) v(score_type, score)
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY market, score_type, snapshot_date
            ORDER BY score DESC, market_cap DESC, ticker
        ) AS score_rank
    FROM score_rows
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
)
SELECT
    r.market,
    r.score_type,
    r.snapshot_date,
    r.score_rank,
    r.ticker,
    r.company_name,
    r.score,
    r.value_score,
    r.quality_score,
    r.growth_score,
    r.dividend_score,
    r.market_cap,
    r.trailing_pe,
    r.price_to_book,
    r.peg_ratio,
    r.return_on_equity,
    r.revenue_growth,
    r.earnings_growth,
    start_price.trading_date AS selected_trading_date,
    start_price.close_price AS selected_close_price,
    current_price.trading_date AS current_trading_date,
    current_price.close_price AS current_close_price,
    current_price.close_price - start_price.close_price AS price_change,
    CASE
        WHEN start_price.close_price IS NULL OR start_price.close_price = 0 THEN NULL
        ELSE (current_price.close_price - start_price.close_price) / start_price.close_price
    END AS return_pct
FROM ranked r
OUTER APPLY (
    SELECT TOP (1) ph.trading_date, ph.close_price
    FROM price_history ph
    WHERE ph.market = r.market
      AND ph.ticker = r.ticker
      AND ph.trading_date >= r.snapshot_date
    ORDER BY ph.trading_date ASC
) start_price
OUTER APPLY (
    SELECT TOP (1) ph.trading_date, ph.close_price
    FROM price_history ph
    WHERE ph.market = r.market
      AND ph.ticker = r.ticker
    ORDER BY ph.trading_date DESC
) current_price
WHERE r.score_rank <= 10;
GO

PRINT 'View dbo.vw_PowerBI_FundamentalScorePerformance created or updated.';
PRINT 'Power BI imports this view four times, filtered by score_type: Value, Quality, Growth, and Master.';
GO
