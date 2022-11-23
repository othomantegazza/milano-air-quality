# Proof of Concept Dashboard with Quarto

A proof-of-concept dashboard made with [Quarto](https://quarto.org/), [GGiraph](https://davidgohel.github.io/ggiraph/index.html) and deployed through Github Actions.

I started making this project inspired by the [great tutorial on dashboarding in R](https://github.com/RamiKrispin/deploy-flex-actions) by Rami Krispin.

Developing the project, I've introduced several changes, to get rhis dashboard closer to the toolset that I'm used to work with in R.

This are the main changes that I've introduced:

- R packages are managed with [RENV](https://rstudio.github.io/renv/articles/renv.html),
- The visualization are made with [GGiraph](https://davidgohel.github.io/ggiraph/index.html), to avoid the commercial and governamental restrictions of highcharter, and to port ggplot's great API to the web.
- The layout, and the task to transform markdown code and R text into a webpage is managed by [Quarto](https://quarto.org/).
- The web page is deployed directly from  Github Action into Github Pages, without committing code back into the repo.

# Run

If you want to run this code locally:

1. Install [Quarto CLI](https://quarto.org/docs/get-started/) on your computer
2. Open [`air-quality.Rproj`](air-quality.Rproj) with Rstudio.
3. Run `renv::restore()` at the R console.
4. Run `quarto preview` at the command line terminal (shell).

# Data Source

This dashboard fetches daily the [Open Data on Air Pollution](https://dati.comune.milano.it/dataset/ds411-rilevazione-qualita-aria-2022) from the Open Data Portal of the City of Milano, I would like to thank them for providing well formatted and easy to reach Open Data.

On the other side, Air pollution is a huge issue in the area, and in my opinion, the initiatives on public transport and bicycle paths by the City of Milano, Regione Lombardia, and other the public administration entities are well below the level that would be needed to solve or even ease this issue.

# License

This work comes with no warranty and is [LICENSED](LICENSE) with under the CC4-BY-SA 4.0 license. Find the full text of the [license here](https://creativecommons.org/licenses/by-sa/4.0/legalcode).
