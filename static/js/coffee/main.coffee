jQuery ->

  class window.Movie extends Backbone.Model

  class window.Movies extends Backbone.Collection
    model: Movie
    url: '/movies'


$ ->
  console.log 'Ready to start!'
