class Sidebar
  selector: '#wikistack-sidebar'
  template: WikiStack.templates.sidebar
  blurbs: []
  canOpenLink: false
  constructor: ->
    $('body').append(@template())
    # grab data from localstorage to restore session?
    $('#content').on 'click', 'a', (e) =>
      if @canOpenLink
        e.preventDefault()
        @addBlurb(e.target.title, e.target.href, @render)
    $(document).on 'keydown', (e) =>
      if e.which == 90
        @canOpenLink = true
    $(document).on 'keyup', (e) =>
      if e.which == 90
        @canOpenLink = false
    $(@selector).on 'click', '.swap', (e) =>
      e.preventDefault()
      url = window.location.href.split('wikipedia.org')
      blurb = @popBlurb(e.target.title)
      @addBlurb($('#firstHeading').text(), url[1], =>
        @save()
        window.location.href = "#{e.target.href}")

    if sessionStorage.getItem("sessionID") == null
      sessionStorage.setItem("sessionID", Math.random().toString().slice(2,-1))

      sessionList = localStorage.getItem("sessionList")
      sessionList = if sessionList and sessionList != "" then JSON.parse(sessionList) else []

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

  # This should probably always return a promise instead of implementing
  # callbacks wrongly
  addBlurb: (title, link, cb) ->
    found = @popBlurb(title)
    if found
      @blurbs.unshift(found)
      cb() if cb?
    else
      blurb = new Blurb(title, link)
      blurb.loading.done =>
        @blurbs.unshift(blurb)
        cb() if cb?

  save: =>
    localStorage[sessionStorage.getItem("sessionID")] = JSON.stringify(@blurbs)

  render: =>
    $(@selector).html @template({ blurbs: @blurbs })
    @save()