# Get started with development

### Install all the dependencies
    $ npm install -g coffee-script; npm install

### Documentation
    $ npm install -g coffeedoc
    $ make docs

### Start the server
    $ ./start

# Using Shelf (CLI)

Shelf is a _micro_ CLI. The current version only allows you to generate a structure of files for components (collection + model + router + view)

Usage:
    
    $ ./wardrobe create [name:string] [view:boolean] [router:boolean] [collection:string <optional>]

Example Usage:

    $ ./wardrobe create episode true false episodes

The example would generate a model, view and a collection named episodes.

# Tests
All tests are to be written using mocha (tdd interface http://visionmedia.github.com/mocha/#tdd-interface) and CoffeeScript

    $ make test

# Technologies

+ Git Flow (https://github.com/nvie/gitflow)
+ Node (https://github.com/joyent/node)
+ Jade (https://github.com/visionmedia/jade)
+ Stylus (https://github.com/learnboost/stylus)
+ UglifyJS2 (https://github.com/mishoo/UglifyJS2)