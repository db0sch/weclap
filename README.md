# Holly

Save movies for later

## Heroku

We now have two Heroku instances running side by side : one for production and one for staging.
production : weclap.herokuapp.com
staging: weclap-staging.herokuapp.com

The staging instance is for testing purose. It has around 106K movies in it.
So testing can happen in real conditions (was made initially to test a new search config).
=> You can work on experimental features on this one.

You might need to add the remote git for this staging server.
Have a look at the Heroku documentation.

Here is how my `git remote -v` looks like :
```
heroku  https://git.heroku.com/weclap.git (fetch)
heroku  https://git.heroku.com/weclap.git (push)
heroku-staging  https://git.heroku.com/weclap-staging.git (fetch)
heroku-staging  https://git.heroku.com/weclap-staging.git (push)
origin  git@github.com:db0sch/weclap.git (fetch)
origin  git@github.com:db0sch/weclap.git (push)
```

`heroku` stands for 'production'
`heroku-staging` stands for 'staging'

## Search

Search has been made with pg_search (a ruby gem for PosgreSQL Full Text search feature).
In order to gain some performance, we created a ts_vector column in our Movie model (named `tsv`).
It indexes the 'lexemes' in order to optimize search.
We went from several seconds, to milliseconds... what a blast!

For more information on tsvector and lexemes, please check the pg_search gem doc, and the posgreSQL full text feature documentation.


Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates)
