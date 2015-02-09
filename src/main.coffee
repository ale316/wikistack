class Sidebar
  selector: '#wikistack-sidebar'
  template: WikiStack.templates.sidebar
  blurbs: []
  constructor: ->
    $('body').append(@template())
    # grab data from localstorage to restore session?
    $('#content').on 'click', 'a', (e) =>
      e.preventDefault()
      blurb = new Blurb(e.target.title)
      blurb.loading.done =>
        @addBlurb(blurb)

  addBlurb: (blurb) ->
    $(@selector).prepend blurb.render()

class Blurb
  template: WikiStack.templates.blurb
  endpoint: "http://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro&exsentences=10&redirects=true&continue&titles="
  constructor: (title) ->
    @loading = $.getJSON @endpoint+title, (data) =>
      results = data.query.pages
      for id, article of results
        @title = article.title
        @content = article.extract
        break
      @loading = null
    return @

  render: ->
    @template({
      title: @title
      content: @content
    })

sidebar = new Sidebar()