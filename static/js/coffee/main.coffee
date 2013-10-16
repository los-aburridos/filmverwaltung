# https://github.com/CodeSeven/toastr
# http://tablesorter.com/docs/


jQuery ->

  class window.Movie extends Backbone.Model

  class window.Movies extends Backbone.Collection
    model: Movie
    url: '/movies'

  window.movies = new Movies()

  class window.MovieView extends Backbone.View
    tagName: 'tr'

    initialize: ->
      @model.bind 'change', @render
      @template = _.template ($ '#movie-template').html()

    render: =>
      ($ @el).html(@template @model.toJSON())

      @

  class window.MoviesView extends Backbone.View
    tagName: 'div'
    className: 'row'

    initialize: ->
      @collection.bind 'reset', @render
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

  class window.MovieAdministration extends Backbone.Router
    routes: {
      '': 'index'
    }

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
