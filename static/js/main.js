// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  jQuery(function() {
    var _ref, _ref1, _ref2, _ref3, _ref4;
    window.Movie = (function(_super) {
      __extends(Movie, _super);

      function Movie() {
        _ref = Movie.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      return Movie;

    })(Backbone.Model);
    window.Movies = (function(_super) {
      __extends(Movies, _super);

      function Movies() {
        _ref1 = Movies.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      Movies.prototype.model = Movie;

      Movies.prototype.url = '/api/movies';

      return Movies;

    })(Backbone.Collection);
    window.movies = new Movies();
    window.MovieView = (function(_super) {
      __extends(MovieView, _super);

      function MovieView() {
        this.render = __bind(this.render, this);
        _ref2 = MovieView.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      MovieView.prototype.tagName = 'tr';

      MovieView.prototype.events = {
        'click .remove': 'clear'
      };

      MovieView.prototype.initialize = function() {
        this.listenTo(this.model, 'change', this.render);
        this.listenTo(this.model, 'destroy', this.remove);
        return this.template = _.template(($('#movie-template')).html());
      };

      MovieView.prototype.render = function() {
        ($(this.el)).html(this.template(this.model.toJSON()));
        return this;
      };

      MovieView.prototype.clear = function() {
        return this.model.destroy();
      };

      return MovieView;

    })(Backbone.View);
    window.MoviesView = (function(_super) {
      __extends(MoviesView, _super);

      function MoviesView() {
        this.render = __bind(this.render, this);
        _ref3 = MoviesView.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      MoviesView.prototype.tagName = 'div';

      MoviesView.prototype.className = 'row';

      MoviesView.prototype.events = {
        'keypress #newMovie': 'createOnEnter'
      };

      MoviesView.prototype.initialize = function() {
        this.listenTo(this.collection, 'reset', this.render);
        this.listenTo(this.collection, 'change', this.render);
        return this.template = _.template(($('#movies-template')).html());
      };

      MoviesView.prototype.render = function() {
        var $tbody, collection;
        ($(this.el)).html(this.template({}));
        collection = this.collection;
        $tbody = this.$('tbody');
        collection.each(function(movie) {
          var view;
          view = new MovieView({
            model: movie,
            collection: collection
          });
          return $tbody.append(view.render().el);
        });
        return this;
      };

      MoviesView.prototype.createOnEnter = function(e) {
        var $input;
        $input = this.$('#newMovie');
        if (e.which !== 13 || !$input.val().trim()) {
          return;
        }
        window.movies.create({
          title: $input.val().trim()
        });
        return $input.val('');
      };

      return MoviesView;

    })(Backbone.View);
    window.MovieAdministration = (function(_super) {
      __extends(MovieAdministration, _super);

      function MovieAdministration() {
        _ref4 = MovieAdministration.__super__.constructor.apply(this, arguments);
        return _ref4;
      }

      MovieAdministration.prototype.routes = {
        '': 'index'
      };

      MovieAdministration.prototype.initialize = function() {
        return this.moviesView = new MoviesView({
          collection: window.movies
        });
      };

      MovieAdministration.prototype.index = function() {
        var $container;
        $container = $('#container');
        $container.empty();
        return $container.append(this.moviesView.render().el);
      };

      return MovieAdministration;

    })(Backbone.Router);
    return $(function() {
      window.App = new MovieAdministration();
      Backbone.history.start({
        pushState: true
      });
      return window.movies.fetch({
        reset: true
      });
    });
  });

}).call(this);
