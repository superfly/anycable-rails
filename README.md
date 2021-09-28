# Global Rails with Anycable

This is a sample Rails 7 app for running Anycable and Rails in a geographically distributed deployment.

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