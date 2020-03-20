A simple Sinatra app using Airtable as the back-end for an anthology of poems.

It's essentially a nicer public front-end to an Airtable, which gives you some extra features:

- Public-shareable nicely-formatted site, with a small group of contributors that can be easily managed via Airtable.
- Caches in memory so that the Airtable API is only pinged on server startup, or when you hit the `/refresh` endpoint. Yes, it's possible to hit the rate limit by "DDOS"ing this endpoint, in which case you'd not be able to see new updates to the Airtable.
- Searchability with regex, including custom search by (in this case) Author or Submitter.
- Automatic RSS feed, so that people can subscribe in [proper internet newsreaders](https://github.com/newsboat/newsboat).
- Permalinks per row (per poem in this case).

My version is deployed to <https://quarantine-poem-anthology.herokuapp.com/>.

# Setup and Deployment
You will need an Airtable with a table that has the following fields:
- `Title`
- `Author`
- `Text`
- `Image` - an "upload" field
- `Submitted By`

On your deployment server, make sure to set the following environment variables:

- `TITLE` - Title of the app
- `API_KEY` - Airtable API key
- `APP_KEY` - Airtable app ey
- `TABLE` - Airtable table name
- `SITE_URL` - Base URL where the site will be published, for permalinks in RSS.
