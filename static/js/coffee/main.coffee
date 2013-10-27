jQuery ->

  window.api_url = 'http://api.themoviedb.org/3'
  window.api_key = 'b8c58e84a6add62d174b2aa7421365be'


  do window.getConfig = ->
    $.get "#{api_url}/configuration?api_key=#{api_key}", (data) ->
      window.base_url = data.images.base_url

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

  class window.DecoratedMovie
    constructor: (@movie) ->
      @movie.set 'base_url', window.base_url
      @data = {}
      @deferred = @fetchDataFromTMDb()

    toJSON: ->
      json = _.clone @movie.attributes

      if @data
        $.extend json, @data
      else
        json

    fetchDataFromTMDb: ->
      that = @
      _tmdb_id = @movie.get '_tmdb_id'

      if _tmdb_id
        $.get "#{api_url}/movie/#{_tmdb_id}?api_key=#{api_key}", (data) ->
          $.extend that.data, data

          # post processing
          that.data.genres = that.processArray that.data.genres
          that.data.release_date = that.processDate that.data.release_date

        $.get "#{api_url}/movie/#{_tmdb_id}/casts?api_key=#{api_key}", (data) ->
          $.extend that.data, data

          # post processing
          that.data.cast = that.processArray that.data.cast[0..9]
      else
        deferred = new $.Deferred
        deferred.resolve()

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

  window.movies = new Movies()

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

      $.get "#{api_url}/search/movie?api_key=#{api_key}&query=#{_title}&include_adult=false&year=#{_year}", (data) ->
        that.createMovie data.results[0]?.id, _year, _title

    createMovie: (_tmdb_id, _year, _title) ->
      window.movies.create
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
        ($ that.el).html(that.template that.model.toJSON())

      @

  class window.Router extends Backbone.Router
    routes:
      '': 'index'
      'movies/:id': 'movieSingleView'

    index: ->
      moviesView = new MoviesView
        collection: window.movies

      ($ '#container')
        .empty()
        .append moviesView.render().el

    movieSingleView: (id) ->
      movie = window.movies.get id
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

    window.movies.fetch
      reset: true
