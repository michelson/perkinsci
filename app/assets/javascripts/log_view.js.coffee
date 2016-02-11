class window.LogView

  constructor: (options={})->
    @el = $(options.el)
    @text = @el.text()
    #console.log @text
    @options = options
    @reset()

  render: ()->
    parts = @split(@text)
    #@log.set(ix, line)
    @receive(part[0], part[1]) for part in parts
    #console.log(@el)
    #@log.set(0,"dfs")

  receive: (ix, line) ->
    @log.set(ix, line) #if @get('running')

  split: (string) ->
    string = string.replace(/\r\n/gm, "\n") # it seems split(/^/) would remove the newline, but not the \r here?
    lines = string.split(/^/m)
    parts = ([i, line] for line, i in lines)
    #console.log(JSON.stringify(parts))
    parts = @slice(parts)     if @options.slice
    parts = @randomize(parts) if @options.randomize
    # parts = @partition(parts) if @options.partition
    parts

  reset: ->
    @clear()
    @log = new Log
    #log = new Log
    #log.listeners.push(new Log) if @options.log
    #log.listeners.push(new Log[@options.renderer])
    #log.listeners.push(new Log.Folds) if @options.folds
    #log.listeners.push(new Log.Instrumenter)
    #log.listeners.push(new App.MetricsRenderer(@controller))
    #@log = @options.buffer && new Log.Buffer(log) || log

  slice: (array) ->
    array.slice(0, @options.slice)

  partition: (parts) ->
    step = @rand(10)

    # randomly split some of the parts into more parts
    for _, i in Array::slice.apply(parts) by step
      if @rand(10) > 7.5
        split = @splitRand(parts[i][1], 5).map((chunk) -> [0, chunk])
        parts.splice.apply(parts, [i, 1].concat(split))

    # randomly join some of the parts into multi-line ones
    for _, i in Array::slice.apply(parts) by step
      if @rand(10) > 7.5
        count  = @rand(10)
        joined = ''
        joined += part[1] for part in parts.slice(i, count)
        parts.splice(i, count, joined)

    @renumber(parts)

  renumber: (parts) ->
    num = 0
    parts[i][0] = num += 1 for _, i in parts
    parts

  randomize: (array, step) ->
    @shuffle(array, i, step || 10) for _, i in array by step || 10
    array

  splitRand: (string, count) ->
    size  = (string.length / count) * 1.5
    split = []
    while string.length > 0
      count = @rand(size) + 1
      split.push(string.slice(0, count))
      string = string.slice(count)
    split

  rand: (num) ->
    Math.floor(Math.random() * num)

  shuffle: (array, start, count) ->
    for _, i in array.slice(start, start + count)
      j = start + @rand(i + 1)
      i = start + i
      tmp = array[i]
      array[i] = array[j]
      array[j] = tmp

  clear: ->
    $('#log').empty()
    #$('#events').empty()
