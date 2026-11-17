# Weekly Pipeline Review

Paste your CRM export or spreadsheet rows into the conversation and ask for a weekly pipeline review. Include the review date, reporting period, and currency. Supply your own stage and forecast mappings where needed. Preserve your source stage labels.

Map columns to deal, owner, stage, amount, currency, close date, forecast category, and next step. Include buyer evidence and prior close date when available. Leave unknown values blank. Use ISO dates, plain decimal amounts, and one currency per total. If using an export with duplicate rows, include a stable deal ID or deduplicate before adding amounts.

For this fictional review, the as-of date is 17 November 2026, the period ends 30 November, and all four rows are open AUD opportunities. Closed won and target were not supplied. Commit and upside are source categories. An empty forecast category remains unclassified and contributes only to the open total.

**Prompt.** Use the weekly pipeline review in `pipeline-management` and the [sample CSV](sample.csv). Produce the view for my role. Identify missing values and slippage. Show the amounts behind your totals and explain where rep judgement differs from buyer evidence.

## Sales Rep

Harbour Health slipped from 13 to 27 November. It is marked commit, but the buyer has confirmed only the problem and the next call. Ask on Thursday who can approve the purchase and whether budget is available. For Wattle Systems, turn the request for a pilot outline into a discussion of success criteria.

**Draft follow-up for Harbour Health.** Thanks for confirming Thursday. Could we use the call to agree who needs to approve the purchase, whether there’s funding available, and what decision date is realistic?

## Sales Manager

| Deal | Coaching priority | Owner and checkpoint |
| --- | --- | --- |
| Harbour Health | Challenge the slipped commit using buyer evidence. | Mia to confirm funding and signer Thursday. |
| Cedar Freight | Convert the checklist into agreed milestones. | Sam to confirm dates with procurement before the next review. |
| Banksia Retail | Resolve the missing forecast category. | Sam to confirm the decision process and update the category after the next buyer conversation. |

## Head of Sales

Open commit is AUD 70,000. Harbour Health accounts for AUD 40,000 of that amount and merits a separate risk discussion after Thursday’s call. Upside is AUD 25,000. Banksia Retail’s AUD 15,000 stays unclassified. A total revenue forecast and gap to target are unavailable without closed-won revenue and the period target.

## Sales Reporting

| Metric | AUD |
| --- | ---: |
| Open commit | 70000 |
| Open upside | 25000 |
| Open unclassified | 15000 |
| Open pipeline | 110000 |

Open pipeline reconciles to commit plus upside plus unclassified. The report excludes closed revenue because the export only contains open deals. Harbour Health is the one evidenced slip. Rows without a prior close date have unknown slip status.

Run `ruby scripts/check_pipeline_review.rb` from the repo root to reconcile the worked totals and check the sample and regression cases.
