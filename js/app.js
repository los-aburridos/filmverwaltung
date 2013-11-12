'use strict';

var App = Ember.Application.create({});

// data store
App.Store = DS.Store.extend({
  adapter: DS.LSAdapter
  // revision: 11,
  // adapter: ParseAdapter.create({
  //   applicationId: 'g8SN66cXKu0j6yyHxkgHVfdS4AWlrJAhrglDpdYA',
  //   restApiId: '3lIyphYqUeYRVUO0GiNxiRowgJv1rDXE6J0ZGBCP',
  //   javascriptId: 'qWqXSIRY8K9OoNGzxCRTJIHVe70mwRrTqs5arKUA'
  // })
});

// models
App.Movie = DS.Model.extend({
// App.Movie = ParseModel.extend({
  rating: DS.attr('number'),
  title: DS.attr('string'),
  watched: DS.attr('boolean'),
  year: DS.attr('string'),

  config: null,
  details: null,
  casts: null,

  default: 'not available',

  imagePath: function() {
    if(this.get('config') && this.get('details')) {
      return this.get('config').images.base_url
        + 'original'
        + this.get('details').poster_path;
    };

    return 'img/default.png';
  }.property('config', 'details'),

  originalTitle: function() {
    if(this.get('details')) {
      return this.get('details').original_title
        + ' (original title)';
    };

    return this.get('default');
  }.property('details'),

  runtime: function() {
    if(this.get('details')) {
      return this.get('details').runtime
        + ' min';
    };

    return this.get('default');
  }.property('details'),

  genres: function() {
    if(this.get('details')) {
      var rv   = [],
        genres = this.get('details').genres;

      genres.forEach(function(genre) {
        rv.push(genre.name);
      });

      return rv.join(', ');
    };

    return this.get('default');
  }.property('details'),

  releaseDate: function() {
    if(this.get('details')) {
      var date   = this.get('details').release_date,
        partials = date.split('-'),
        rv       = new Date(partials[0], partials[1], partials[2]),
        options  = {
          year:  'numeric',
          month: 'long',
          day:   'numeric'
        };

      return rv.toLocaleString('en-US', options);
    };

    return this.get('default');
  }.property('details'),

  overview: function() {
    if(this.get('details')) {
      return this.get('details').overview;
    };

    return this.get('default');
  }.property('details'),

  actors: function() {
    if(this.get('casts')) {
      var rv   = [],
        actors = this.get('casts').cast;

      if (actors.length > 10) {
        for (var i = 0; i < 10; i++) {
          rv.push(actors[i].name);
        };
      } else {
        actors.forEach(function(actor) {
          rv.push(actor.name);
        });
      };

      return rv.join(', ');
    };

    return this.get('default');
  }.property('casts'),

  voteAverage: function() {
    if(this.get('details')) {
      return this.get('details').vote_average
        + '/10';
    };

    return this.get('default');
  }.property('details')
});

// router
App.Router = Ember.Router.extend({
  location: 'hash'
});

App.Router.map(function() {
  this.route('index', {path: '/'});
  this.resource('movies', {path: '/movies'}, function() {
    this.route('watched');
    this.route('remaining');
  });
  this.route('movie', {path: '/movie/:movie_id'});
  this.route('about', {path: '/about'});
});

// routes
App.IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('movies');
  }
});

App.MoviesIndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('movie');
  }
});

App.MoviesWatchedRoute = Ember.Route.extend({
  model: function() {
    return this.store.filter('movie', function(movie) {
      return movie.get('watched');
    });
  },
  renderTemplate: function(controller) {
    this.render('movies/index', {controller: controller});
  }
});

App.MoviesRemainingRoute = Ember.Route.extend({
  model: function() {
    return this.store.filter('movie', function(movie) {
      return !movie.get('watched');
    });
  },
  renderTemplate: function(controller) {
    this.render('movies/index', {controller: controller});
  }
});

App.MovieRoute = Ember.Route.extend({
  model: function(movie) {
    return this.store.find('movie', movie.movie_id);
  }
});

// controllers
App.MoviesIndexController = Ember.ArrayController.extend({
  hasError: false,
  helpText: null,

  sortProperties: null,
  sortAscending: null,

  actions: {
    createMovie: function() {
      var content      = this.get('content'),
        rawDescription = this.get('rawDescription'),
        rv             = this.parseRawDescription(rawDescription),
        title          = rv[1],
        year           = rv[2],
        unique         = true;

      content.forEach(function(movie) {
        if (title === movie.get('title') && year === movie.get('year')) {
          unique = false;
        };
      });

      if (rv.length > 0) {
        if (unique) {
          var newMovie = this.store.createRecord('movie');

          newMovie.set('rating', Math.floor(Math.random()*5));
          newMovie.set('title', title);
          newMovie.set('watched', false);
          newMovie.set('year', year);
          newMovie.save();

          this.set('rawDescription', null);
          this.set('hasError', false);
          this.set('helpText', null);
        } else {
          this.set('hasError', true);
          this.set('helpText', 'Oh, no! This movie already exists.');
        };
      } else {
        this.set('hasError', true);
        this.set('helpText', 'Oh, no! Please include the movie\'s title and year.');
      };
    },

    doDeleteMovie: function(movie) {
      this.set('movieForDeletion', movie);
      Ember.$('#confirmDeleteMovieDialog').modal('show');
    },

    doCancelDelete: function() {
      this.set('movieForDeletion', null);
      Ember.$('#confirmDeleteMovieDialog').modal('hide');
    },

    doConfirmDelete: function() {
      var selectedMovie = this.get('movieForDeletion');

      this.set('movieForDeletion', null);

      if (selectedMovie) {
        this.store.deleteRecord(selectedMovie);
        selectedMovie.save();
      };

      Ember.$('#confirmDeleteMovieDialog').modal('hide');
    },

    toggleWatched: function(movie) {
      // movie.toggleProperty('watched');
      movie.set('watched', !movie.get('watched'));
      movie.save();
    },

    sortByAttribute: function(attr) {
      if (this.get('sortProperties')) {
        if (this.get('sortProperties')[0] === attr) {
          // this.toggleProperty('sortAscending');
          this.set('sortAscending', !this.get('sortAscending'));
        } else {
          this.set('sortProperties', [attr]);
        }
      } else {
        this.set('sortProperties', [attr]);
        this.set('sortAscending', true);
      }
    }
  },

  parseRawDescription: function(rawDescription) {
    var rv    = [],
      pattern = /([^$]+)(\d{4})/,
      result  = rawDescription.match(pattern);

    if (result) {
      result.forEach(function(item) {
        item = item.trim().replace(/,/g, '');
        rv.push(item);
      });
    };

    return rv;
  }
});

App.MovieController = Ember.ObjectController.extend({
  contentObserver: function() {
    if (this.get('content')) {
      var content = this.get('content'),
        apiKey    = 'b8c58e84a6add62d174b2aa7421365be',
        configUrl = 'http://api.themoviedb.org/3/configuration',
        searchUrl = 'http://api.themoviedb.org/3/search/movie',
        movieUrl  = 'http://api.themoviedb.org/3/movie',
        params    = {
          api_key: apiKey,
          query:   content.get('title'),
          year:    content.get('year')
        };

      params = Ember.$.param(params);

      Ember.$.get(searchUrl + '?' + params).then(function(data) {
        return data;
      }).then(function(data) {
        if (data.results.length > 0) {
          var tmdbId = data.results[0].id,
            params   = {
              api_key: apiKey
            },
            promises;

          params = Ember.$.param(params);

          promises = {
            config:  Ember.$.get(configUrl + '?' + params),
            details: Ember.$.get(movieUrl  + '/' + tmdbId + '?' + params),
            casts:   Ember.$.get(movieUrl  + '/' + tmdbId + '/casts?' + params)
          };

          Ember.RSVP.hash(promises).then(function(results) {
            content.set('config',  results.config);
            content.set('details', results.details);
            content.set('casts',   results.casts);
          });
        }
      });
    };
  }.observes('content')
});

// components
App.StarRatingComponent = Ember.Component.extend({
  tagName: 'span',
  classNames: ['rating'],
  rating: 0,
  stars: [],

  actions: {
    setRating: function(value) {
      this.set('rating', value);
    }
  },

  didInsertElement: function() {
    var stars = [];

    for (var i = 5; i > 0; i--) {
      if (i === this.get('rating')) {
        stars.push(Ember.Object.create({
          active: true,
          value: i
        }));
      } else {
        stars.push(Ember.Object.create({
          active: false,
          value: i
        }));
      }
    };

    this.set('stars', stars);
  }
});
