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

class Blurb
  template: WikiStack.templates.blurb
  endpoint: (title) ->
    "http://en.wikipedia.org/w/api.php?action=parse&prop=text&page=#{title}&format=json&redirects=1&section=0"

  constructor: (title) ->
    @loading = $.getJSON @endpoint(title), (data) =>
      @title = data.parse.title
      html = data.parse.text["*"]
      obj = $.parseHTML(html)
      console.log data

      for el in obj
        if el.nodeName == 'P'
          @content = '<p>' + el.innerHTML + '</p>'
          @html = @render()
          break

      @loading = null
      return @

  render: ->
    @template({
      title: @title
      content: @content
    })

sidebar = new Sidebar()