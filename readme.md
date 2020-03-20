A simple Sinatra app using Airtable as the back-end for an anthology of poems.

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
