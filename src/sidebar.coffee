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

      sessionList = localStorage.getItem("sessionList")
      sessionList = if sessionList then JSON.parse(sessionList) else []

      for session in sessionList
        if not session.saved
          localStorage.removeItem(session._id)

      sessionList.push({_id : sessionStorage.getItem("sessionID"), saved : false})

      localStorage.setItem("sessionList", JSON.stringify(sessionList))

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