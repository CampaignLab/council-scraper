# README

Scrapes from UK Council websites running the ModernGov software. Uses Sidekiq to fan out, but then concurrency control in sidekiq.yml to not hammer the websites. Just run `ScrapeCouncilsWorker.perform_async` to get started.

Largely it upserts over existing data, so it can be run periodically over a recent time period. (Meetings appear and then are later updated with more documents).

The initial dataset of council URLs was scraped from Google with Puppeteer.

TODO
- Support the other 20% of councils who seem to be on different software
