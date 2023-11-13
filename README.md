# README

Scrapes from UK Council websites running the ModernGov software. Uses Sidekiq to fan out, but then concurrency control in sidekiq.yml to not hammer the websites. Just run `ScrapeCouncilsWorker.perform_async` to get started.

It upserts over existing data, so it can be run periodically over a recent time period. (Meetings appear and then are later updated with more documents).

## Install
You'll need Ruby 3.2, Redis + Postgres setup locally

```
bundle
rails db:setup
foreman start -f Procfile.dev
```

To kick off the scraping process run `ScrapeCouncilsWorker.perform_async` in `rails c`

## Council list scraper

The initial dataset of council URLs was scraped from Google with Puppeteer. This is included under `council_list_scraper/`

```
yarn
NODE_ENV=development yarn start
```

TODO
- How do we get the correct day (for late minutes)
- Try pulling structured attendees
- Find a way to stop pulling dupe docs (e.g. when there is a 'pack' of all the docs, and then individual versions)
- Scrape attendees directly from ModernGov data instead of parsing PDFs?
- Support the other 20% of councils who seem to be on different software

## Useful resources:
http://opencouncildata.co.uk/council.php?c=298&y=0
https://democracy.cambridge.gov.uk/mgWhatsNew.aspx?CID=0&WID=0&CT=0&DR=26%2f09%2f2023-03%2f10%2f2023
