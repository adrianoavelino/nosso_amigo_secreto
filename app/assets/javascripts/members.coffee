$(document).on 'turbolinks:load', ->
  $('#member_email, #member_name').keypress (e) ->
    if e.which == 13 && valid_email($( "#member_email" ).val()) && $( "#member_name" ).val() != ""
      $('.new_member').submit()

  $('#member_email, #member_name').bind 'blur', ->
    if valid_email($( "#member_email" ).val()) && $( "#member_name" ).val() != ""
      $('.new_member').submit()

  $('.new_member').on 'submit', (e) ->
    $.ajax e.target.action,
        type: 'POST'
        dataType: 'json',
        data: $(".new_member").serialize()
        success: (data, text, jqXHR) ->
          append_member(data['id'], data['name'],  data['email'])
          $('#member_name, #member_email').val("")
          $('#member_name').focus()
          Materialize.toast('Membro adicionado', 4000, 'green')
          $("#member_update_"+data['id']).on 'submit', (e) ->
            e.preventDefault()
            update_member.call(this)
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problema na hora de incluir membro', 4000, 'red')
    return false

  $('body').on 'keypress', '[id^=member_update_] input[type=text], [id^=member_update_] input[type=email]', (e) ->
    form = $(this).parent().parent().parent()
    name = form.find('input[type=text]').val()
    email = form.find('input[type=email]').val()
    if e.which == 13  && name != "" && valid_email(email)
      form.submit()

  $('body').on 'blur', '[id^=member_update_] input[type=text], [id^=member_update_] input[type=email]', (e) ->
    form = $(this).parent().parent().parent()
    name = form.find('input[type=text]').val()
    email = form.find('input[type=email]').val()
    if name != "" && valid_email(email)
      form.submit()

  $("[id^='member_update_']").each (mem) ->
    $(this).on 'submit', (e) ->
      e.preventDefault()
      update_member.call(this)

  $('body').on 'click', 'a.remove_member', (e) ->
    $.ajax '/members/'+ e.currentTarget.id,
        type: 'DELETE'
        dataType: 'json',
        data: {}
        success: (data, text, jqXHR) ->
          Materialize.toast('Membro removido', 4000, 'green')
          $('#member_update_' + e.currentTarget.id).remove()
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problema na remoção de membro', 4000, 'red')
    return false

valid_email = (email) ->
  /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(email)

append_member = (id, name, email) ->
  $('.member_list').append(
    '<form class="member" id="member_update_' + id + '">' +
      '<div class="row">' +
        '<input id="id" type="hidden" value="' + id + '">' +
        '<div class="col s12 m5 input-field">' +
          '<input id="name" name="name" type="text" class="validate" value="' + name + '">' +
          '<label for="name" class="active">Nome</label>' +
        '</div>' +
        '<div class="col s12 m5 input-field">' +
          '<input id="email" name="email" type="email" class="validate" value="' + email + '">' +
          '<label for="email" class="active" data-error="Formato incorreto">Email</label>' +
        '</div>' +
        '<div class="col s3 offset-s3 m1 input-field">' +
          '<i class="material-icons icon">visibility</i>' +
        '</div>' +
        '<div class="col s3 m1 input-field">' +
          '<a href="#" class="remove_member" id="' + id + '">' +
            '<i class="material-icons icon">delete</i>' +
          '</a>' +
        '</div>' +
      '</div>' +
    '</form>')

update_member = () ->
  inputs = $(this).children().find('input')
  id = inputs[0].value
  name = inputs[1].value
  email = inputs[2].value
  $.ajax '/members/'+ id,
      type: 'PUT'
      dataType: 'json',
      data: {id: id, member: {id: id, name: name, email: email}}
      success: (data, text, jqXHR) ->
        Materialize.toast('Membro atualizado', 4000, 'green')
      error: (jqXHR, textStatus, errorThrown) ->
        Materialize.toast('Problema na atualização de membro', 4000, 'red')
  return false
