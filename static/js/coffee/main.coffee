jQuery ->

  class window.Movie extends Backbone.Model

  class window.Movies extends Backbone.Collection
    model: Movie
    url: '/api/movies'

  window.movies = new Movies()

  class window.MovieView extends Backbone.View
    tagName: 'tr'

    events:
      'click .remove': 'clear',

    initialize: ->
      @listenTo @model, 'change', @render
      @listenTo @model, 'destroy', @remove

      @template = _.template ($ '#movie-template').html()

    render: =>
      ($ @el).html(@template @model.toJSON())

      @

    clear: ->
      @model.destroy()

  class window.MoviesView extends Backbone.View
    tagName: 'div'
    className: 'row'

    events:
      'keypress #newMovie': 'createOnEnter',

    initialize: ->
      @listenTo @collection, 'reset', @render
      @listenTo @collection, 'change', @render

      @template = _.template ($ '#movies-template').html()

    render: =>
      ($ @el).html(@template {})

      collection = @collection
      $tbody = @$ 'tbody'

      collection.each (movie) ->
        view = new MovieView {
          model: movie
          collection: collection
        }
        $tbody.append view.render().el

      @

    createOnEnter: (e) ->
      $input = @$ '#newMovie'

      if e.which isnt 13 or not $input.val().trim()
        return

      rawDescription = $input.val().trim()
      [all, title, year] = @parseRawDescription rawDescription

      window.movies.create {
        year: year
        title: title
      }

      $input.val ''

    parseRawDescription: (rawDescription) ->
      pattern = ///
        ([^$]+)  # Title
        (\d{4})  # Year
      ///
      result = rawDescription.match pattern
      r.trim().replace /,/g, '' for r in result

  class window.MovieAdministration extends Backbone.Router
    routes:
      '': 'index'

    initialize: ->
      @moviesView = new MoviesView {
        collection: window.movies
      }

    index: ->
      $container = $ '#container'
      $container.empty()
      $container.append @moviesView.render().el


  $ ->
    window.App = new MovieAdministration()
    Backbone.history.start {pushState: true}

    window.movies.fetch {reset: true}
