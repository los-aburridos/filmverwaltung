(function() {
  var TestObject, handleStarRating, provideButtons, testObject,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  jQuery(function() {
    var connectToParse, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
    window.Movie = (function(_super) {
      __extends(Movie, _super);

      function Movie() {
        _ref = Movie.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Movie.prototype.idAttribute = '_id';

      Movie.prototype.defaults = {
        cast: 'not available',
        genres: 'not available',
        original_title: 'not available',
        overview: 'not available',
        poster_path: 'not available',
        release_date: 'not available',
        runtime: 'not available',
        vote_average: 'not available'
      };

      return Movie;

    });
    window.DecoratedMovie = (function() {
      function DecoratedMovie(movie) {
        this.movie = movie;
        this.data = {};
        this.deferred = this.fetchDataFromTMDb();
      }

      DecoratedMovie.prototype.toJSON = function() {
        var json;
        json = _.clone(this.movie.attributes);
        if (this.data) {
          return $.extend(json, this.data);
        } else {
          return json;
        }
      };

      DecoratedMovie.prototype.fetchDataFromTMDb = function() {
        var deferred, deferreds, that, urls, _tmdb_id;
        that = this;
        _tmdb_id = this.movie.get('_tmdb_id');
        if (_tmdb_id) {
          urls = ["http://api.themoviedb.org/3/configuration?api_key=b8c58e84a6add62d174b2aa7421365be", "http://api.themoviedb.org/3/movie/" + _tmdb_id + "?api_key=b8c58e84a6add62d174b2aa7421365be", "http://api.themoviedb.org/3/movie/" + _tmdb_id + "/casts?api_key=b8c58e84a6add62d174b2aa7421365be"];
          deferreds = $.map(urls, function(url) {
            return $.get(url, function(data) {
              return $.extend(that.data, data);
            });
          });
          return $.when.apply($, deferreds);
        } else {
          deferred = new $.Deferred;
          return deferred.resolve();
        }
      };

      DecoratedMovie.prototype.adjustData = function() {
        this.data.cast = this.processArray(this.data.cast.slice(0, 10));
        this.data.genres = this.processArray(this.data.genres);
        return this.data.release_date = this.processDate(this.data.release_date);
      };

      DecoratedMovie.prototype.processArray = function(array) {
        var rv;
        rv = [];
        _.each(array, function(item) {
          return rv.push(item.name);
        });
        return rv.join(", ");
      };

      DecoratedMovie.prototype.processDate = function(date) {
        var day, month, options, rv, year, _ref1;
        options = {
          year: 'numeric',
          month: 'long',
          day: 'numeric'
        };
        _ref1 = date.split('-'), year = _ref1[0], month = _ref1[1], day = _ref1[2];
        rv = new Date(year, month, day);
        return rv.toLocaleDateString('en-US', options);
      };

      return DecoratedMovie;

    })();
    window.Movies = (function(_super) {
      __extends(Movies, _super);

      function Movies() {
        _ref1 = Movies.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      Movies.prototype.model = Movie;

      Movies.prototype.url = '/api/movies';

      Movies.prototype.sortAttribute = '_id';

      Movies.prototype.sortDirection = 1;

      Movies.prototype.comparator = function(a, b) {
        a = a.get(this.sortAttribute);
        b = b.get(this.sortAttribute);
        if (a === b) {
          return;
        }
        if (this.sortDirection === 1) {
          if (a > b) {
            return 1;
          } else {
            return -1;
          }
        } else {
          if (a < b) {
            return 1;
          } else {
            return -1;
          }
        }
      };

      Movies.prototype.sortByAttribute = function(attr) {
        this.sortAttribute = attr;
        return this.sort();
      };

      return Movies;

    });
    window.MovieView = (function(_super) {
      __extends(MovieView, _super);

      function MovieView() {
        _ref2 = MovieView.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      MovieView.prototype.tagName = 'tr';

      MovieView.prototype.events = {
        'click .remove': 'clear'
      };

      MovieView.prototype.initialize = function() {
        var that;
        that = this;
        this.listenTo(this.model, 'change', this.render);
        this.listenTo(this.model, 'destroy', this.remove);
        return this.template = _.template(($('#movie-view-template')).html());
      };

      MovieView.prototype.render = function() {
        ($(this.el)).html(this.template(this.model.toJSON()));
        return this;
      };

      MovieView.prototype.clear = function() {
        return this.model.destroy();
      };

      return MovieView;

    });
    window.MoviesView = (function(_super) {
      __extends(MoviesView, _super);

      function MoviesView() {
        _ref3 = MoviesView.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      MoviesView.prototype.tagName = 'div';

      MoviesView.prototype.className = 'row';

      MoviesView.prototype.events = {
        'click .sortable': 'sort',
        'keypress .submit': 'submit'
      };

      MoviesView.prototype.initialize = function() {
        this.listenTo(this.collection, 'change', this.render);
        this.listenTo(this.collection, 'reset', this.render);
        this.listenTo(this.collection, 'sort', this.render);
        return this.template = _.template(($('#movies-view-template')).html());
      };

      MoviesView.prototype.render = function() {
        var $tbody;
        ($(this.el)).html(this.template({}));
        $tbody = this.$('tbody');
        this.collection.each(function(movie) {
          var movieView;
          movieView = new MovieView({
            model: movie
          });
          return $tbody.append(movieView.render().el);
        });
        return this;
      };

      MoviesView.prototype.submit = function(e) {
        var $input, all, rawDescription, _ref4, _title, _year;
        $input = this.$('.submit');
        if (e.which !== 13) {
          return;
        }
        rawDescription = $input.val().trim();
        _ref4 = this.parseRawDescription(rawDescription), all = _ref4[0], _title = _ref4[1], _year = _ref4[2];
        this.fetchTMDbId(_year, _title);
        return $input.val('');
      };

      MoviesView.prototype.parseRawDescription = function(rawDescription) {
        var pattern, r, result, _i, _len, _results;
        pattern = /([^$]+)(\d{4})/;
        result = rawDescription.match(pattern);
        _results = [];
        for (_i = 0, _len = result.length; _i < _len; _i++) {
          r = result[_i];
          _results.push(r.trim().replace(/,/g, ''));
        }
        return _results;
      };

      MoviesView.prototype.fetchTMDbId = function(_year, _title) {
        var that, url;
        that = this;
        url = "http://api.themoviedb.org/3/search/movie?api_key=b8c58e84a6add62d174b2aa7421365be&query=" + _title + "&include_adult=false&year=" + _year;
        return $.get(url, function(data) {
          var _ref4;
          return that.createMovie((_ref4 = data.results[0]) != null ? _ref4.id : void 0, _year, _title);
        });
      };

      MoviesView.prototype.createMovie = function(_tmdb_id, _year, _title) {
        return this.collection.create({
          _tmdb_id: _tmdb_id,
          _year: _year,
          _title: _title
        });
      };

      MoviesView.prototype.sort = function(e) {
        var $el, attr;
        $el = $(e.currentTarget);
        attr = $el.data('val');
        if (attr === this.collection.sortAttribute) {
          this.collection.sortDirection *= -1;
        } else {
          this.collection.sortDirection = 1;
        }
        return this.collection.sortByAttribute(attr);
      };

      return MoviesView;

    });
    window.MovieSingleView = (function(_super) {
      __extends(MovieSingleView, _super);

      function MovieSingleView() {
        _ref4 = MovieSingleView.__super__.constructor.apply(this, arguments);
        return _ref4;
      }

      MovieSingleView.prototype.tagName = 'div';

      MovieSingleView.prototype.className = 'row';

      MovieSingleView.prototype.initialize = function() {
        return this.template = _.template(($('#movie-single-view-template')).html());
      };

      MovieSingleView.prototype.render = function() {
        var that;
        that = this;
        this.model.deferred.done(function() {
          if (that.model.movie.get('_tmdb_id')) {
            that.model.adjustData();
          }
          return ($(that.el)).html(that.template(that.model.toJSON()));
        });
        return this;
      };

      return MovieSingleView;

    });
    window.Router = (function(_super) {
      __extends(Router, _super);

      function Router() {
        _ref5 = Router.__super__.constructor.apply(this, arguments);
        return _ref5;
      }

      Router.prototype.routes = {
        '': 'index',
        'movies/:id': 'movieSingleView'
      };

      Router.prototype.initialize = function() {
        this.collection = new Movies();
        return this.deferred = this.collection.fetch({
          reset: true
        });
      };

      Router.prototype.index = function() {
        var moviesView;
        moviesView = new MoviesView({
          collection: this.collection
        });
        return ($('#container')).empty().append(moviesView.render().el);
      };

      Router.prototype.movieSingleView = function(id) {
        var that;
        that = this;
        return this.deferred.done(function() {
          var decoratedMovie, movie, movieSingleView;
          movie = that.collection.get(id);
          decoratedMovie = new DecoratedMovie(movie);
          movieSingleView = new MovieSingleView({
            model: decoratedMovie
          });
          return ($('#container')).empty().append(movieSingleView.render().el);
        });
      };

      return Router;

    });
      connectToParse();
      handleStarRating();
      return provideButtons();
    });
    return connectToParse = function() {};
  });

  Parse.initialize('v9oyjDoQ8pSauSj0PlSy7DvoR2VlHfxBHm0fJLBK', '29KiuVrfWBhUnwRrXrs6L2aoHmYi9E13rxEUFdyX');

  TestObject = Parse.Object.extend("TestObject");

  console.log("Start: Parse");

  testObject = new TestObject();

  testObject.save({
    foo: "bar"
  });

  ({
    success: function(object) {
      return alert("yay! it worked");
    }
  });

  console.log("Ende: Parse");

  handleStarRating = function() {
    var blClicked, iLastId;
    iLastId = 0;
    blClicked = false;
    $(document).on("mouseenter", ".rs", function() {
      iLastId = $(this).attr("id");
      blClicked = false;
      return $(".own").addClass("rt_" + iLastId);
    });
    $(document).on("click", ".rs", function() {
      return blClicked = true;
    });
    return $(document).on("mouseleave", ".rs", function() {
      if (blClicked) {

      } else {
        return $(".own").removeClass("rt_" + iLastId);
      }
    });
  };

  provideButtons = function() {};

  $(document).on('click', '#ja_home_btn', function() {
    return window.location.href = '/';
  });
