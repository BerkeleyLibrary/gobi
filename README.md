# GOBI Processor
A command-line tool for processing GOBI order marc files (.ord). Input files can be mounted anywhere on the filesystem, but by default the program looks at `./data/incoming/*.ord`. Output files are written to `./data/gobi_processed`. original input file are moved to `./data/incoming/processed` after being processed.

## Building the app

```sh
docker-compose build
```

## Running it

View the CLI tool help/description:

```sh
docker-compose run --rm gobi help
```

Adds test data to the default watch directory:

```sh
docker-compose run --rm gobi seed
```

Deletes seed data and output files:

```sh
docker-compose run --rm gobi clear
```

Deletes seed data and output files and reseeds with new data:

```sh
docker-compose run --rm gobi refresh 
```

Run the app in the background. It will continue running, monitoring for .ord files to process every 10s.

```sh
docker-compose up -d
docker-compose logs -f # view processing logs in real time
```

Process a specific file:

```sh
docker-compose run --rm gobi process /abs/path/to/myfile.ord # absolute path
docker-compose run --rm gobi process data/incoming/somefile.ord # relative path
```
