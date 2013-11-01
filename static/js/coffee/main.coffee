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
      that = @

      _tmdb_id = @movie.get '_tmdb_id'

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

    sortAttribute: '_id'
    sortDirection: 1

    comparator: (a, b) ->
      a = a.get @sortAttribute
      b = b.get @sortAttribute

      if a is b
        return

      if @sortDirection is 1
        if a > b then 1 else -1
      else
        if a < b then 1 else -1

    sortByAttribute: (attr) ->
      @sortAttribute = attr
      @sort()

  class window.MovieView extends Backbone.View
    tagName: 'tr'

    events:
      'click .remove': 'clear'

    initialize: ->
      that = @

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
      'click .sortable': 'sort'
      'keypress .submit': 'submit'

    initialize: ->
      @listenTo @collection, 'change', @render
      @listenTo @collection, 'reset', @render
      @listenTo @collection, 'sort', @render

      @template = _.template ($ '#movies-view-template').html()

    render: ->
      ($ @el).html(@template {})

      $tbody = @$ 'tbody'

      @collection.each (movie) ->
        movieView = new MovieView
          model: movie

        $tbody.append movieView.render().el

      @

    # TODO: validation
    submit: (e) ->
      $input = @$ '.submit'

      if e.which isnt 13
        return

      rawDescription = $input.val().trim()
      [all, _title, _year] = @parseRawDescription rawDescription

      @fetchTMDbId _year, _title

      $input.val ''

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

    sort: (e) ->
      $el = $ e.currentTarget
      attr = $el.data 'val'

      if attr is @collection.sortAttribute
        @collection.sortDirection *= -1
      else
        @collection.sortDirection = 1

      @collection.sortByAttribute attr

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
      
    # Parse initialisieren
    connectToParse()
    
    # Bewertungs-Feature
    handleStarRating()
    
    # Buttons (Handler + Templates)
    provideButtons()
    
    # Autostart-Ende
    
  connectToParse = ->	
	#Parse.initialize('sNPHcU6shFITOpT3GnW1KlHGgfjT3YYmpnLQSlPZ','KGqWWTnBuRXDwrHW2KIecQYel0ZqR6J00jF7wZjY'); #EB
	Parse.initialize('v9oyjDoQ8pSauSj0PlSy7DvoR2VlHfxBHm0fJLBK','29KiuVrfWBhUnwRrXrs6L2aoHmYi9E13rxEUFdyX'); #JA
	TestObject = Parse.Object.extend("TestObject");
	console.log("Start: Parse")
	testObject = new TestObject();
	testObject.save
      foo: "bar",
	  success: (object) ->
	    alert "yay! it worked"
		console.log("Ende: Parse")
	    
  handleStarRating = ->
    iLastId = 0
    blClicked = false;
    
    $(document).on "mouseenter", ".rs", ->
      iLastId = $(this).attr("id")
      blClicked = false;
      $(".own").addClass "rt_" + iLastId
      
    $(document).on "click", ".rs", ->
      blClicked = true
  
    $(document).on "mouseleave", ".rs", ->
      if blClicked
        #alert "Jetzt wird gespeichert:" + iLastId
      else
        $(".own").removeClass "rt_" + iLastId
        
  provideButtons = ->
	# Nach Hause navigieren
	$(document).on 'click','#ja_home_btn', ->
	  window.location.href='/'
	