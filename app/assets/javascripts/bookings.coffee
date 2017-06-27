# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  $('#default_tab').removeClass('active')
  $('a[href="'+window.location.pathname+window.location.search+'"]').parent().addClass('active')
  if $('ul>li').hasClass('active')
  else
    $('#default_tab').addClass('active')


