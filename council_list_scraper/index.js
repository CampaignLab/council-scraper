'use strict';

if (process.env.NODE_ENV !== 'production') require('dotenv').config()

const puppeteer = require('puppeteer');
const winston = require('winston');
const Papa = require('papaparse');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

const fs = require('fs');

const cookiesFilePath = 'cookies.json';

async function saveCookies(page) {
    const cookies = await page.cookies();
    fs.writeFileSync(cookiesFilePath, JSON.stringify(cookies, null, 2));
    console.log('Cookies saved');
}

async function loadCookies(page) {
    if (fs.existsSync(cookiesFilePath)) {
        const cookies = JSON.parse(fs.readFileSync(cookiesFilePath));
        if (cookies.length !== 0) {
            for (let cookie of cookies) {
                await page.setCookie(cookie);
            }
            console.log('Cookies loaded');
        }
    }
}

let browser = null;
let page = null;
let shouldClose = false;
let isClosing = false;

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.printf(info => `${info.timestamp} ${info.level}: ${info.message}`),
  ),
  transports: [
    new winston.transports.Console()
  ]
});

const devSettings = {
  headless: false,
  dumpio: true,
  executablePath: '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome',
  args: [ // Various settings required to run on Heroku
    '--disable-gesture-requirement-for-media-playback',
    '--no-sandbox',
    '--disable-setuid-sandbox',
    "--disable-dev-shm-usage",
    "--disable-gpu",
    "--window-size=1920x1080",
    "--disable-features=VizDisplayCompositor",
    "--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko)",
  ]
}

const prodSettings = {
  headless: true,
  dumpio: true,
  executablePath: '/app/.apt/usr/bin/google-chrome', // this is where heroku/heroku-buildpack-google-chrome puts it
  args: [ // Various settings required to run on Heroku
    //'--disable-gesture-requirement-for-media-playback',
    '--no-sandbox',
    //'--disable-setuid-sandbox',
    "--disable-dev-shm-usage",
    //"--disable-gpu",
    //"--window-size=1920x1080",
    //"--disable-features=VizDisplayCompositor",
  ]
}

async function main({ port }) {
  logger.debug('Launching browser...');
  browser = await puppeteer.launch(process.env.NODE_ENV === 'development' ? devSettings : prodSettings);
  logger.info('Launched browser.');
  if (shouldClose) {
    await close();
    return;
  }

  logger.debug('Opening new page...');
  page = await browser.newPage();
  page.on('console', message => console.log(`${message.type().substr(0, 3).toUpperCase()} ${message.text()}`))
    .on('pageerror', ({ message }) => console.log(message))
    .on('response', response => console.log(`${response.status()} ${response.url()}`))
    .on('requestfailed', request => console.log(`${request.failure().errorText} ${request.url()}`))

  await page.setDefaultNavigationTimeout(0)

  logger.info('Opened new page.');
  if (shouldClose) {
    await close();
    return;
  }

  await loadCookies(page);

  logger.debug('Registering callback(s)...');
  await Promise.all([
    page.exposeFunction('debug', message => { logger.debug(message); }),
    page.exposeFunction('error', message => { logger.error(message); }),
    page.exposeFunction('info', message => { logger.info(message); })
  ]);
  logger.info('Registered callback(s).');

  const csvPath = 'source_data/opencouncildata_councils.csv'
  const outputPath = 'data/council_urls.csv'

  const csvWriter = createCsvWriter({
      path: outputPath,
      header: [
          {id: 'id', title: 'id'},
          {id: 'council', title: 'name'},
          {id: 'url', title: 'url'},
      ],
  });


  fs.readFile(csvPath, 'utf8', async function(err, data) {
    if (err) {
        console.error('Error reading the file:', err);
        return;
    }

    let i = 0
      Papa.parse(data, {
        complete: async function(results) {
            for (const row of results.data) {
              // if (parseInt(row[0]) <= 53) {
              //   continue // skip the first row
              // }

                const council = row[1];
                const url = `https://www.google.com/search?q=${council} council "mgCalendarMonthView"`;
                await page.goto(url);

                if (i === 0) {
                  try {
                    await page.waitForSelector('input[value="Accept all"][type="submit"]', { timeout: 2000 });
                    await page.click('input[value="Accept all"][type="submit"]');
                  } catch (error) {
                      // Handle the error or simply ignore if the button is not found
                  }
                }

                await page.waitForTimeout(2000);

                // Check for CAPTCHA element or the word 'Captcha' on the page
                while (await page.$('#captcha') !== null || await page.evaluate(() => document.body.textContent.includes('Our systems have detected'))) {
                  console.log('CAPTCHA detected. Please solve it.');
                  await page.waitForTimeout(10000);  // wait for 10 seconds before checking again
                }

                const href = await page.evaluate(() => {
                  const firstH3Link = document.querySelector('a h3');
                  return firstH3Link && firstH3Link.closest('a').href.includes('mgCalendarMonthView') ? firstH3Link.closest('a').href : null;
              });
              

                if (href) {
                  const link = new URL(href);
                  const params = new URLSearchParams(link.search);
                  const url = params.get('q').split('?')[0];
                    console.log(`Found ${council} at ${url}`)
                    await csvWriter.writeRecords([{ id: row[0], council, url }]);
                }
                i++;
            }
        }
    });
  })

  while (true) {
    await page.waitForTimeout(1000)
    if (shouldClose) {
      await saveCookies(page);
      await close();
      return;
    }
  }
}

async function close(error) {
  if (isClosing) {
    return;
  }
  isClosing = true;

  if (error) {
    logger.error(`\n\n${indent(error.stack)}\n`);
  }

  if (page) {
    await page.evaluate('close()');
  }

  if (browser) {
    logger.debug('Closing browser...');
    await browser.close();
    logger.info('Closed browser.');
  }

  if (error) {
    process.exit(1);
    return;
  }
  process.exit();
}

function indent(str, n) {
  return (str || '').split('\n').map(line => `  ${line}`).join('\n');
}

[
  'SIGUSR2',
  'SIGINT'
].forEach(signal => {
  process.on(signal, () => {
    logger.debug(`Received ${signal}.`);
    shouldClose = true;
    close();
  });
});

const configuration = {
  port: 3001
};

main(configuration).catch(error => {
  shouldClose = true;
  close(error);
});
