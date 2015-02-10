class Blurb
  template: WikiStack.templates.blurb
  endpoint: (title) ->
    "http://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro&exsentences=10&redirects=true&continue&titles=#{title}"

  constructor: (title) ->
    @loading = $.getJSON @endpoint(title), (data) =>


      results = data.query.pages
      for id, article of results
        @title = title
        text = article.extract
        @content = if text.split(".").length < 2 then "Summary Unavailible, click to view" else text
        break

      @html = @render()
      @loading = null
      return @

  render: ->
    @template({
      title: @title
      content: @content
    })