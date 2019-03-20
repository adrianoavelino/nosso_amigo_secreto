$(document).on 'turbolinks:load', ->
  $('#member_email, #member_name').keypress (e) ->
    if e.which == 13 && valid_email($( "#member_email" ).val()) && $( "#member_name" ).val() != ""
      $('.new_member').submit()

  up()

  $('#member_email, #member_name').bind 'blur', ->
    if valid_email($( "#member_email" ).val()) && $( "#member_name" ).val() != ""
      $('.new_member').submit()

  $('body').on 'click', 'a.remove_member', (e) ->
    $.ajax '/members/'+ e.currentTarget.id,
        type: 'DELETE'
        dataType: 'json',
        data: {}
        success: (data, text, jqXHR) ->
          Materialize.toast('Membro removido', 4000, 'green')
          # debugger
          # $('#member_' + e.currentTarget.id).remove()
          $('#member_update_' + e.currentTarget.id).remove()
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problema na remoção de membro', 4000, 'red')
    return false

  $('.new_member').on 'submit', (e) ->
    $.ajax e.target.action,
        type: 'POST'
        dataType: 'json',
        data: $(".new_member").serialize()
        success: (data, text, jqXHR) ->
          insert_member(data['id'], data['name'],  data['email'])
          $('#member_name, #member_email').val("")
          $('#member_name').focus()
          Materialize.toast('Membro adicionado', 4000, 'green')
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problema na hora de incluir membro', 4000, 'red')
    return false


valid_email = (email) ->
  /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(email)

insert_member = (id, name, email) ->
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
  fe = '#member_update_' + id + ' #email'
  fn = '#member_update_' + id + ' #name'
  console.log fe + ', '+ fn
  $('body').on 'blur', fe + ', '+ fn  , (e) ->
    console.log 'okkk' + valid_email($( fe ).val())
    console.log 'okkk' +  $( fn ).val() != ""
    if valid_email($( fe ).val()) && $( fn ).val() != ""
      console.log 'atualiza o campos'
      $('#member_update_' + id).on 'submit', (e) ->
        e.preventDefault()
        element = $(this).children().find('input')
        id = element[0].value
        name = element[1].value
        email = element[2].value
        $.ajax '/members/'+ id,
            type: 'PUT'
            dataType: 'json',
            data: {id: id, member: {id: id, name: name, email: email}}
            success: (data, text, jqXHR) ->
              Materialize.toast('Membro atualizado', 4000, 'green')
            error: (jqXHR, textStatus, errorThrown) ->
              Materialize.toast('Problema na atualização de membro', 4000, 'red')
        return false
      $('#member_update_' + id).each (mem) ->
        idForm = $(this).attr('id')
        $(this).keypress (e1) ->
          if e1.which == 13
            $(this).submit()




up = () ->
  $("[id^='member_update_']").each (mem) ->
    idForm = $(this).attr('id')
    $(this).keypress (e1) ->
      if e1.which == 13
        $(this).submit()



    #testar esse blur: $(".member_update input[type=text], .member_update input[type=email]")
    fe = '#' + idForm + ' #email'
    fn = '#' + idForm + ' #name'
    console.log fe + ', '+ fn
    $('body').on 'blur', '#' + idForm + '#name'  , (e) ->
      # console.log $(this).attr('value')
    # $(fe + ','+ fn).on 'blur', ->
      if valid_email($( fe ).val()) && $( fn ).val() != ""
        $(this).parent().parent().parent().parent().submit()

    $("#"+idForm).on 'submit', (e) ->
      e.preventDefault()
      element = $(this).children().find('input')
      id = element[0].value
      name = element[1].value
      email = element[2].value
      $.ajax '/members/'+ id,
          type: 'PUT'
          dataType: 'json',
          data: {id: id, member: {id: id, name: name, email: email}}
          success: (data, text, jqXHR) ->
            Materialize.toast('Membro atualizado', 4000, 'green')
          error: (jqXHR, textStatus, errorThrown) ->
            Materialize.toast('Problema na atualização de membro', 4000, 'red')
      return false
