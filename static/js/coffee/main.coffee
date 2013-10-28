jQuery ->

  class window.Movie extends Backbone.Model
    idAttribute: '_id'

    defaults:
      cast: 'not available'
      genres: 'not available'
      original_title: 'not available'
      overview: 'not available'
      poster_path: 'not available'
      release_date: 'not available'
      runtime: 'not available'
      vote_average: 'not available'

  class window.DecoratedMovie
    constructor: (@movie) ->
      @data = {}
      @deferred = @fetchDataFromTMDb()

    toJSON: ->
      json = _.clone @movie.attributes

      if @data
        $.extend json, @data
      else
        json

    fetchDataFromTMDb: ->
      _tmdb_id = @movie.get '_tmdb_id'
      that = @

      if _tmdb_id
        urls = [
          "http://api.themoviedb.org/3/configuration?api_key=b8c58e84a6add62d174b2aa7421365be"
          "http://api.themoviedb.org/3/movie/#{_tmdb_id}?api_key=b8c58e84a6add62d174b2aa7421365be"
          "http://api.themoviedb.org/3/movie/#{_tmdb_id}/casts?api_key=b8c58e84a6add62d174b2aa7421365be"
        ]

        deferreds = $.map urls, (url) ->
          $.get url, (data) ->
            $.extend that.data, data

        $.when.apply $, deferreds
      else
        deferred = new $.Deferred
        deferred.resolve()

    adjustData: ->
      @data.cast = @processArray @data.cast[0..9]
      @data.genres = @processArray @data.genres
      @data.release_date = @processDate @data.release_date

    processArray: (array) ->
      rv = []
      _.each array, (item) ->
        rv.push item.name
      rv.join ", "

    processDate: (date) ->
      options =
        year: 'numeric'
        month: 'long'
        day: 'numeric'

      [year, month, day] = date.split '-'

      rv = new Date year, month, day
      rv.toLocaleDateString 'en-US', options

  class window.Movies extends Backbone.Collection
    model: Movie
    url: '/api/movies'

  class window.MovieView extends Backbone.View
    tagName: 'tr'

    events:
      'click .remove': 'clear'

    initialize: ->
      @listenTo @model, 'change', @render
      @listenTo @model, 'destroy', @remove

      @template = _.template ($ '#movie-view-template').html()

    render: ->
      ($ @el).html(@template @model.toJSON())

      @

    # TODO: confirmation
    clear: ->
      @model.destroy()

  class window.MoviesView extends Backbone.View
    tagName: 'div'
    className: 'row'

    events:
      'keypress .submit': 'submit'

    initialize: ->
      @listenTo @collection, 'reset', @render
      @listenTo @collection, 'change', @render

      @template = _.template ($ '#movies-view-template').html()

    render: ->
      ($ @el).html(@template {})

      tbody = @$ 'tbody'

      @collection.each (movie) ->
        movieView = new MovieView
          model: movie

        tbody.append movieView.render().el

      @

    # TODO: validation
    submit: (e) ->
      input = @$ '.submit'

      if e.which isnt 13
        return

      rawDescription = input.val().trim()
      [all, _title, _year] = @parseRawDescription rawDescription

      @fetchTMDbId _year, _title

      input.val ''

    parseRawDescription: (rawDescription) ->
      pattern = ///
        ([^$]+)  # _title
        (\d{4})  # _year
      ///

      result = rawDescription.match pattern
      r.trim().replace /,/g, '' for r in result

    fetchTMDbId: (_year, _title) ->
      that = @
      url = "http://api.themoviedb.org/3/search/movie
?api_key=b8c58e84a6add62d174b2aa7421365be
&query=#{_title}
&include_adult=false
&year=#{_year}"

      $.get url, (data) ->
        that.createMovie data.results[0]?.id, _year, _title

    createMovie: (_tmdb_id, _year, _title) ->
      @collection.create
        _tmdb_id: _tmdb_id
        _year: _year
        _title: _title

  class window.MovieSingleView extends Backbone.View
    tagName: 'div'
    className: 'row'

    initialize: ->
      @template = _.template ($ '#movie-single-view-template').html()

    render: ->
      that = @

      @model.deferred.done ->
        if that.model.movie.get '_tmdb_id'
          that.model.adjustData()

        ($ that.el).html(that.template that.model.toJSON())

      @

  class window.Router extends Backbone.Router
    routes:
      '': 'index'
      'movies/:id': 'movieSingleView'

    initialize: ->
      @collection = new Movies()
      @deferred = @collection.fetch
        reset: true

    index: ->
      moviesView = new MoviesView
        collection: @collection

      ($ '#container')
        .empty()
        .append moviesView.render().el

    movieSingleView: (id) ->
      that = @

      # wait until collection is loaded before rendering
      @deferred.done ->
        movie = that.collection.get id
        decoratedMovie = new DecoratedMovie movie

        movieSingleView = new MovieSingleView
          model: decoratedMovie

        ($ '#container')
          .empty()
          .append movieSingleView.render().el

  $ ->
    window.app = new Router()

    Backbone.history.start
      pushstate: true
