class Blurb
  template: WikiStack.templates.blurb
  endpoint: (title) ->
    "http://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro&exsentences=10&redirects=true&continue&titles=#{title}"

  constructor: (title, link) ->
    @loading = $.getJSON @endpoint(title), (data) =>
      results = data.query.pages
      for id, article of results
        @title = title
        @content = article.extract
        @link = link
        break

      @html = @render()
      @loading = null
      return @

  render: ->
    @template({
      link: @link
      title: @title
      content: @content
    })