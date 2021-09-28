# Global Rails with Anycable

This is a sample Rails 7 app with [Anycable](https://anycable.io/) setup for deployment on [Fly.io](https://fly.io). It can be deployed globally with a handful of commands, staying performant, by taking avantage of a few key features of the Fly platform.

Fly can deploy app close to your users around the world. This leads to low latency response times and a noticeable boost in overall app performance in distant regions.

A single Fly app may deploy multiple services in tandem, all of which may receive traffic the internet. This overcomes
limitations on platforms like Heroku which only allow exposing a single process. This allows us to run Anycable, which needs a Ruby RPC process for each websocket handler process.

Finally, the app instances share a private IPv6 network. This feature is the key to this demo: we'll be running
a [multimaster KeyDB cluster](https://github.com/fly-apps/keydb) behind Anycable. KeyDB is a Redis fork offering some unique features like multimaster mode. Each region where our app deploys gets its own instance, and all instances replicate from each other over the Fly private network. Most importantly, *pub/sub messages are broadcast to all KeyDB peers*. Actioncable/Anycable uses pub/sub!

Not that this approach should work equally well for standard ActionCable. AnyCable is just awesome, and uses a lot less memory, so we went that route here.
## Developement

The usual `bundle install`.

Install [Hivemind](https://github.com/DarthSim/hivemind/releases) for running the Rails, Anycable RPC and Anycable Go processes via `Procfile`. On a Mac, just run `brew install hivemind`.

Run `bin/start`.
## Deployment on Fly

First, get [flyctl](https://fly.io/docs/getting-started/installing-flyctl/) and a [Fly account](https://fly.io/docs/getting-started/login-to-fly/).

Then go ahead and setup a [KeyDB cluster based on our example](https://github.com/fly-apps/keydb). Take note
of the regions you have decided to deploy it in. We want to deploy in the same regions so we have a fast local KeyDB
instance for each.

Finally, clone this repo and run `fly launch`, but don't deploy yet. we need to do some more setup.

Let's set the regions where we'd like to deploy.

```
fly regions set ord ams
fly regions backup ord ams
```

Now, scale each process type up to the number of desired regions. `max-per-region=2` ensures that processes will be evenly distributed across both regions.

```
fly scale count anycable_go=2 anycable_rpc=2 rails=2 --max-per-region=2
```

Finally, deploy.

`bin/deploy`

When it's done, `fly open` should get your chat interface up. Try it from different regions!