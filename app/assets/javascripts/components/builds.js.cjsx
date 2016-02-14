@BuildsCollection = React.createClass

  getInitialState: ->
    collection: []

  fetchRepos: ->
    $.get "#{@props.url}.json", ((result) ->
      if @isMounted()
        @setState
          collection: result.collection
      return
    ).bind(this)

  componentDidMount: ->
    @fetchRepos()

  render: ->

    return (

      <table style={{"width:100%;"}} className="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
        
        <thead>
          <tr>
            <th className="mdl-data-table__cell--non-numeric">
              Build
            </th>
            <th>Status</th>
            <th>Message</th>
            <th>Commit</th>
            <th>Duration</th>
            <th>Finished At</th>
          </tr>

        </thead>

        <tbody>
          {
            @state.collection.map (resource)->
              <BuildRow 
              key={resource.build.id} 
              repo={resource.repo} 
              build={resource.build}
              />
          }
        </tbody>

      </table>

    )

@BuildRow = React.createClass

  componentDidMount: ->
    $(ReactDOM.findDOMNode(this))
    .find("abbr.timeago").timeago();

  buildUrl: ->
    "/repos/#{@props.repo.name}/builds/#{@props.build.id}"

  render: ->

    return (
      <tr>
        
        <td className="mdl-data-table__cell--non-numeric">
          <a href={@buildUrl()}>
            <StatusIcon 
            build_status={@props.build.build_status} 
            status={@props.build.status}
            />
          </a>
        </td>

        <td className="mdl-data-table__cell--non-numeric">
          #{@props.build.id}
          { @props.build.build_status  }
        </td>

        <td className="mdl-data-table__cell--non-numeric">
          { @props.build.commit.message.split("\n")[0] if @props.build['commit']['message'] }
        </td>

        <td className="mdl-data-table__cell--non-numeric">
          { @props.build.sha[0..7] if @props.build.sha }
          
          {
            if @props.build.branch
              <strong>
                { "(#{@props.build.branch})" }
              </strong>
          }

        </td>

        <td className="mdl-data-table__cell--non-numeric">
          { @props.build.duration }
        </td>

        <td className="mdl-data-table__cell--non-numeric">
          <abbr className="timeago" title={ @props.build.build_time } >
            { @props.build.build_time }
          </abbr>
        </td>
        
      </tr>


    )


@BuildLog = React.createClass

  getInitialState: ->
    resource: {}

  initLogView: ->
    window.log_view = new LogView({el: "#log"})
    log_view.render()

  fetchRepos: ->
    $.get "#{@props.url}.json", ((result) ->
      if @isMounted()
        @setState
          resource: result.resource

      @initLogView()

      return
    ).bind(this)

  componentDidMount: ->
    @fetchRepos()

  render: ->
    return (
      <pre id="log" className="ansi">
        {@state.resource.build.response if @state.resource.build}
      </pre>
    )