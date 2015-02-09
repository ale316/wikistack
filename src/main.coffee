console.log "I'm here moterfucka", WikiStack

temp = WikiStack.templates.sidebar()
$('body').append(temp)

$(document).on 'click', 'a', (e) ->
  e.preventDefault()
  query = e.target.title
  $.getJSON "http://en.wikipedia.org/w/api.php?action=query&titles=#{query}" +
  "&format=json&prop=extracts&exintro&exsentences=10&redirects=true&continue", (data) ->
    results = data.query.pages
    console.log results
    for id, article of results
      $('#wikistack-sidebar').prepend(article.extract)


