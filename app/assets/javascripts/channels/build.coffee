@App.build = App.cable.subscriptions.create {channel: "BuildChannel"},
  connected: ->
    console.log("Connected!")
    #$("p").trigger("refresh")
    # Called when the subscription is ready for use on the server

  disconnected: ->
    console.log("disconnected!")

    # Called when the subscription has been terminated by the server

  received: (d) ->
    console.log("Received!")
    console.log(d)
    $(".repo-#{d.repo.id}").trigger("refresh", d);

    # Called when there's incoming data on the websocket for this channel

  notify: ->
    @perform 'notify'
