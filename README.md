# shrift project page

## Adding One-Liners

Fork this repo and edit this branch (```gh-pages```), add your one-liner to
```_data/oneliners.yaml``` and submit a PR. Before submitting, please review
the following criteria for an acceptable one-liner.

### Criteria for one-liners

There's a lot of bash-trickery and crazy one-liners out there. The following
guidelines are intended to present succinct, grokable test commands for others
to generally consume.

1. Should be simple/easy to understand (think junior admin)
2. Should pass on a most modern (maybe ~5 years) *nix operating systems
3. Should only include one line (exceptions for variations)
4. Should include a human readable description of the test
4. Should include a working example

## Developing

    # install depedencies
    bundle install

    # run in watch mode
    guard
    # or run standalone
    jekyll serve

Browse to [http://localhost:4000](http://localhost:4000) to see the site.

### Less

Compile less files with the following:

    npm install -g less
    lessc public/less/default/styles.less public/css/styles.css
