# README

[Finejoke](https://finejoke.lol) is a free online game where players compose *fine* jokes. The finest and funniest ones get most points.

## Contribution

See active issues if you are willing to contribute to the code. You can also report a problem, or suggest an idea there.

I would not recommend working on any substantial PRs before tests and (more) proper documentation are written. Submit an issue if you are eager to contribute - this may speed up me preparing the repository for contributions.

### Localization and languages

English is the primary language of the game.

All locale files are stored in yaml files `app/config/locales` and its subdirectories, and marked by a relevant language code, e.g. `en.yml`.

Adding a locale not only translates the website, but also separates players, their jokes and their games from the rest of locales. Thus, locales should be as universal and as accessible as possible.

Localization should be carefully tested as some fields may have strict character limit, e.g. button translations or flash messages. Always take into account the length of relevant English translations.

### Moving forward

The following areas may (or may not) be worked on in the future, near or distant.

- Better AI suggestions
- Virtual Host interactivity
- Voicing jokes and Virtual Host's replies with the AI, and, possibly, streaming mode.
- A public catalogue or a small mini-game based on the best jokes created in the game.

## Technicalities

The website uses the Ruby on Rails framework for the backend and the Hotwire stack on the frontend with JS being delivered to the client via importmaps. Pages are server-rendered but Hotwire's Stimulus controllers allow for some client-side interactivity. Styles are written in single CSS & SCSS files, which are bundled together through the Rails' assets pipeline.

### Dependencies
- Ruby 3.3.1
- PostgreSQL

### Development Setup
#### First launch
- Install Ruby dependencies:
```sh
  bundle i
```

- Migrate the database:
```sh
  bundle exec rails db:migrate
```

- Seed the database:
```sh
  bundle exec rails db:seed
```

#### Launching dev server
```sh
  bundle exec rails s
```

#### Run tests
```sh
  bundle exec rails t
```
