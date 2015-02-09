class Sidebar
  selector: '#wikistack-sidebar'
  template: WikiStack.templates.sidebar
  blurbs: []
  constructor: ->
    $('body').append(@template())
    # grab data from localstorage to restore session?
    $('#content').on 'click', 'a', (e) =>
      e.preventDefault()
      @addBlurb(e.target.title)

    if sessionStorage.getItem("sessionID") == null
      sessionStorage.setItem("sessionID", Math.random().toString().slice(2,-1))
    else
      @blurbs = JSON.parse(localStorage[sessionStorage.getItem("sessionID")])
      @render()

  popBlurb: (title) ->
    for blurb, i in @blurbs
      if blurb.title == title
        @blurbs.splice(i, 1)
        return blurb
    return false

  addBlurb: (title) ->
    found = @popBlurb(title)
    if found
      @blurbs.unshift(found)
      @render()
    else
      blurb = new Blurb(title)
      blurb.loading.done =>
        @blurbs.unshift(blurb)
        @render()

  render: ->
    $(@selector).html @template({ blurbs: @blurbs })
    localStorage[sessionStorage.getItem("sessionID")] = JSON.stringify(@blurbs)

class Blurb
  template: WikiStack.templates.blurb
  endpoint: (title) ->
    "http://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro&exsentences=10&redirects=true&continue&titles=#{title}"

  constructor: (title) ->
    @loading = $.getJSON @endpoint(title), (data) =>
      results = data.query.pages
      for id, article of results
        @title = title
        @content = article.extract
        break

      @html = @render()
      @loading = null
      return @

  render: ->
    @template({
      title: @title
      content: @content
    })

sidebar = new Sidebar()