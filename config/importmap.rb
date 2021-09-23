# Use direct uploads for Active Storage (remember to import "@rails/activestorage" in your application.js)
# pin "@rails/activestorage", to: "activestorage.esm.js"

# Use node modules from a JavaScript CDN by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.js"
pin "@hotwired/stimulus", to: "stimulus.js"
pin "@hotwired/stimulus-importmap-autoloader", to: "stimulus-importmap-autoloader.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
pin "@anycable/web", to: "https://ga.jspm.io/npm:@anycable/web@0.0.6/index.js"
pin "@anycable/core", to: "https://ga.jspm.io/npm:@anycable/core@0.0.5/index.js"
pin "nanoevents", to: "https://ga.jspm.io/npm:nanoevents@6.0.1/index.js"
