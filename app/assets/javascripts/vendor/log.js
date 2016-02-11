minispade.register('log', "(function() {(function() {\n\n  this.Log = function() {\n    this.autoCloseFold = true;\n    this.listeners = [];\n    this.renderer = new Log.Renderer;\n    this.children = new Log.Nodes(this);\n    this.parts = {};\n    this.folds = new Log.Folds(this);\n    this.times = new Log.Times(this);\n    return this;\n  };\n\n  Log.extend = function(one, other) {\n    var name;\n    for (name in other) {\n      one[name] = other[name];\n    }\n    return one;\n  };\n\n  Log.extend(Log, {\n    DEBUG: true,\n    SLICE: 500,\n    TIMEOUT: 25,\n    FOLD: /fold:(start|end):([\\w_\\-\\.]+)/,\n    TIME: /time:(start|end):([\\w_\\-\\.]+):?([\\w_\\-\\.\\=\\,]*)/,\n    create: function(options) {\n      var listener, log, _i, _len, _ref;\n      options || (options = {});\n      log = new Log();\n      if (options.limit) {\n        log.listeners.push(log.limit = new Log.Limit(options.limit));\n      }\n      _ref = options.listeners || [];\n      for (_i = 0, _len = _ref.length; _i < _len; _i++) {\n        listener = _ref[_i];\n        log.listeners.push(listener);\n      }\n      return log;\n    }\n  });\nminispade.require('log/nodes');\n\n  Log.prototype = Log.extend(new Log.Node, {\n    set: function(num, string) {\n      if (this.parts[num]) {  } else {\n        this.parts[num] = true;\n        return Log.Part.create(this, num, string);\n      }\n    },\n    insert: function(data, pos) {\n      this.trigger('insert', data, pos);\n      return this.renderer.insert(data, pos);\n    },\n    remove: function(node) {\n      this.trigger('remove', node);\n      return this.renderer.remove(node);\n    },\n    hide: function(node) {\n      this.trigger('hide', node);\n      return this.renderer.hide(node);\n    },\n    trigger: function() {\n      var args, ix, listener, _i, _len, _ref, _results;\n      args = [this].concat(Array.prototype.slice.apply(arguments));\n      _ref = this.listeners;\n      _results = [];\n      for (ix = _i = 0, _len = _ref.length; _i < _len; ix = ++_i) {\n        listener = _ref[ix];\n        _results.push(listener.notify.apply(listener, args));\n      }\n      return _results;\n    }\n  });\n\n  Log.Listener = function() {};\n\n  Log.extend(Log.Listener.prototype, {\n    notify: function(log, event) {\n      if (this[event]) {\n        return this[event].apply(this, [log].concat(Array.prototype.slice.call(arguments, 2)));\n      }\n    }\n  });\nminispade.require('log/folds');\nminispade.require('log/times');\nminispade.require('log/deansi');\nminispade.require('log/limit');\nminispade.require('log/renderer');\n\n}).call(this);\n\n})();\n//@ sourceURL=log");minispade.register('log/deansi', "(function() {(function() {\n\n  Log.Deansi = {\n    CLEAR_ANSI: /(?:\\033)(?:\\[0?c|\\[[0356]n|\\[7[lh]|\\[\\?25[lh]|\\(B|H|\\[(?:\\d+(;\\d+){,2})?G|\\[(?:[12])?[JK]|[DM]|\\[0K)/gm,\n    apply: function(string) {\n      var nodes,\n        _this = this;\n      if (!string) {\n        return [];\n      }\n      string = string.replace(this.CLEAR_ANSI, '');\n      nodes = ansiparse(string).map(function(part) {\n        return _this.node(part);\n      });\n      return nodes;\n    },\n    node: function(part) {\n      var classes, node;\n      node = {\n        type: 'span',\n        text: part.text\n      };\n      if (classes = this.classes(part)) {\n        node[\"class\"] = classes.join(' ');\n      }\n      return node;\n    },\n    classes: function(part) {\n      var result;\n      result = [];\n      result = result.concat(this.colors(part));\n      if (result.length > 0) {\n        return result;\n      }\n    },\n    colors: function(part) {\n      var colors;\n      colors = [];\n      if (part.foreground) {\n        colors.push(part.foreground);\n      }\n      if (part.background) {\n        colors.push(\"bg-\" + part.background);\n      }\n      if (part.bold) {\n        colors.push('bold');\n      }\n      if (part.italic) {\n        colors.push('italic');\n      }\n      if (part.underline) {\n        colors.push('underline');\n      }\n      return colors;\n    },\n    hidden: function(part) {\n      if (part.text.match(/\\r/)) {\n        part.text = part.text.replace(/^.*\\r/gm, '');\n        return true;\n      }\n    }\n  };\n\n}).call(this);\n\n})();\n//@ sourceURL=log/deansi");minispade.register('log/folds', "(function() {(function() {\n\n  Log.Folds = function(log) {\n    this.log = log;\n    this.folds = {};\n    return this;\n  };\n\n  Log.extend(Log.Folds.prototype, {\n    add: function(data) {\n      var fold, _base, _name;\n      fold = (_base = this.folds)[_name = data.name] || (_base[_name] = new Log.Folds.Fold);\n      fold.receive(data, {\n        autoCloseFold: this.log.autoCloseFold\n      });\n      return fold.active;\n    }\n  });\n\n  Log.Folds.Fold = function() {\n    return this;\n  };\n\n  Log.extend(Log.Folds.Fold.prototype, {\n    receive: function(data, options) {\n      this[data.event] = data.id;\n      if (this.start && this.end && !this.active) {\n        return this.activate(options);\n      }\n    },\n    activate: function(options) {\n      var fragment, nextSibling, node, parentNode, toRemove, _i, _len, _ref;\n      options || (options = {});\n      if (Log.DEBUG) {\n        console.log(\"F.n - activate \" + this.start);\n      }\n      toRemove = this.fold.parentNode;\n      parentNode = toRemove.parentNode;\n      nextSibling = toRemove.nextSibling;\n      parentNode.removeChild(toRemove);\n      fragment = document.createDocumentFragment();\n      _ref = this.nodes;\n      for (_i = 0, _len = _ref.length; _i < _len; _i++) {\n        node = _ref[_i];\n        fragment.appendChild(node);\n      }\n      this.fold.appendChild(fragment);\n      parentNode.insertBefore(toRemove, nextSibling);\n      this.fold.setAttribute('class', this.classes(options['autoCloseFold']));\n      return this.active = true;\n    },\n    classes: function(autoCloseFold) {\n      var classes;\n      classes = this.fold.getAttribute('class').split(' ');\n      classes.push('fold');\n      if (!autoCloseFold) {\n        classes.push('open');\n      }\n      if (this.fold.childNodes.length > 2) {\n        classes.push('active');\n      }\n      return classes.join(' ');\n    }\n  });\n\n  Object.defineProperty(Log.Folds.Fold.prototype, 'fold', {\n    get: function() {\n      return this._fold || (this._fold = document.getElementById(this.start));\n    }\n  });\n\n  Object.defineProperty(Log.Folds.Fold.prototype, 'nodes', {\n    get: function() {\n      var node, nodes;\n      node = this.fold;\n      nodes = [];\n      while ((node = node.nextSibling) && node.id !== this.end) {\n        nodes.push(node);\n      }\n      return nodes;\n    }\n  });\n\n}).call(this);\n\n})();\n//@ sourceURL=log/folds");minispade.register('log/limit', "(function() {(function() {\n\n  Log.Limit = function(max_lines) {\n    this.max_lines = max_lines || 1000;\n    return this;\n  };\n\n  Log.Limit.prototype = Log.extend(new Log.Listener, {\n    count: 0,\n    insert: function(log, node, pos) {\n      if (node.type === 'paragraph' && !node.hidden) {\n        return this.count += 1;\n      }\n    }\n  });\n\n  Object.defineProperty(Log.Limit.prototype, 'limited', {\n    get: function() {\n      return this.count >= this.max_lines;\n    }\n  });\n\n}).call(this);\n\n})();\n//@ sourceURL=log/limit");minispade.register('log/nodes', "(function() {(function() {\n  var newLineAtTheEndRegexp, newLineRegexp, rRegexp, removeCarriageReturns;\n\n  Log.Node = function(id, num) {\n    this.id = id;\n    this.num = num;\n    this.key = Log.Node.key(this.id);\n    this.children = new Log.Nodes(this);\n    return this;\n  };\n\n  Log.extend(Log.Node, {\n    key: function(id) {\n      if (id) {\n        return id.split('-').map(function(i) {\n          return '000000'.concat(i).slice(-6);\n        }).join('');\n      }\n    }\n  });\n\n  Log.extend(Log.Node.prototype, {\n    addChild: function(node) {\n      return this.children.add(node);\n    },\n    remove: function() {\n      this.log.remove(this.element);\n      return this.parent.children.remove(this);\n    }\n  });\n\n  Object.defineProperty(Log.Node.prototype, 'log', {\n    get: function() {\n      var _ref;\n      return this._log || (this._log = ((_ref = this.parent) != null ? _ref.log : void 0) || this.parent);\n    }\n  });\n\n  Object.defineProperty(Log.Node.prototype, 'firstChild', {\n    get: function() {\n      return this.children.first;\n    }\n  });\n\n  Object.defineProperty(Log.Node.prototype, 'lastChild', {\n    get: function() {\n      return this.children.last;\n    }\n  });\n\n  Log.Nodes = function(parent) {\n    if (parent) {\n      this.parent = parent;\n    }\n    this.items = [];\n    this.index = {};\n    return this;\n  };\n\n  Log.extend(Log.Nodes.prototype, {\n    add: function(item) {\n      var ix, next, prev, _ref, _ref1;\n      ix = this.position(item) || 0;\n      this.items.splice(ix, 0, item);\n      if (this.parent) {\n        item.parent = this.parent;\n      }\n      prev = function(item) {\n        while (item && !item.children.last) {\n          item = item.prev;\n        }\n        return item != null ? item.children.last : void 0;\n      };\n      next = function(item) {\n        while (item && !item.children.first) {\n          item = item.next;\n        }\n        return item != null ? item.children.first : void 0;\n      };\n      if (item.prev = this.items[ix - 1] || prev((_ref = this.parent) != null ? _ref.prev : void 0)) {\n        item.prev.next = item;\n      }\n      if (item.next = this.items[ix + 1] || next((_ref1 = this.parent) != null ? _ref1.next : void 0)) {\n        item.next.prev = item;\n      }\n      return item;\n    },\n    remove: function(item) {\n      this.items.splice(this.items.indexOf(item), 1);\n      if (item.next) {\n        item.next.prev = item.prev;\n      }\n      if (item.prev) {\n        item.prev.next = item.next;\n      }\n      if (this.items.length === 0) {\n        return this.parent.remove();\n      }\n    },\n    position: function(item) {\n      var ix, _i, _ref;\n      for (ix = _i = _ref = this.items.length - 1; _i >= 0; ix = _i += -1) {\n        if (this.items[ix].key < item.key) {\n          return ix + 1;\n        }\n      }\n    },\n    indexOf: function() {\n      return this.items.indexOf.apply(this.items, arguments);\n    },\n    slice: function() {\n      return this.items.slice.apply(this.items, arguments);\n    },\n    each: function(func) {\n      return this.items.slice().forEach(func);\n    },\n    map: function(func) {\n      return this.items.map(func);\n    }\n  });\n\n  Object.defineProperty(Log.Nodes.prototype, 'first', {\n    get: function() {\n      return this.items[0];\n    }\n  });\n\n  Object.defineProperty(Log.Nodes.prototype, 'last', {\n    get: function() {\n      return this.items[this.length - 1];\n    }\n  });\n\n  Object.defineProperty(Log.Nodes.prototype, 'length', {\n    get: function() {\n      return this.items.length;\n    }\n  });\n\n  Log.Part = function(id, num, string) {\n    Log.Node.apply(this, arguments);\n    this.string = string || '';\n    this.string = this.string.replace(/\\033\\[1000D/gm, '\\r');\n    this.string = this.string.replace(/\\r+\\n/gm, '\\n');\n    this.strings = this.string.split(/^/gm) || [];\n    this.slices = ((function() {\n      var _results;\n      _results = [];\n      while (this.strings.length > 0) {\n        _results.push(this.strings.splice(0, Log.SLICE));\n      }\n      return _results;\n    }).call(this));\n    return this;\n  };\n\n  Log.extend(Log.Part, {\n    create: function(log, num, string) {\n      var part;\n      part = new Log.Part(num.toString(), num, string);\n      log.addChild(part);\n      return part.process(0, -1);\n    }\n  });\n\n  Log.Part.prototype = Log.extend(new Log.Node, {\n    remove: function() {},\n    process: function(slice, num) {\n      var node, span, spans, string, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4,\n        _this = this;\n      _ref = this.slices[slice] || [];\n      for (_i = 0, _len = _ref.length; _i < _len; _i++) {\n        string = _ref[_i];\n        if ((_ref1 = this.log.limit) != null ? _ref1.limited : void 0) {\n          return;\n        }\n        spans = [];\n        _ref2 = Log.Deansi.apply(string);\n        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {\n          node = _ref2[_j];\n          span = Log.Span.create(this, \"\" + this.id + \"-\" + (num += 1), num, node.text, node[\"class\"]);\n          span.render();\n          spans.push(span);\n        }\n        if ((_ref3 = spans[0]) != null ? (_ref4 = _ref3.line) != null ? _ref4.cr : void 0 : void 0) {\n          spans[0].line.clear();\n        }\n      }\n      if (!(slice >= this.slices.length - 1)) {\n        return setTimeout((function() {\n          return _this.process(slice + 1, num);\n        }), Log.TIMEOUT);\n      }\n    }\n  });\n\n  newLineAtTheEndRegexp = new RegExp(\"\\n$\");\n\n  newLineRegexp = new RegExp(\"\\n\");\n\n  rRegexp = new RegExp(\"\\r\");\n\n  removeCarriageReturns = function(string) {\n    var index;\n    index = string.lastIndexOf(\"\\r\");\n    if (index === -1) {\n      return string;\n    }\n    return string.substr(index + 1);\n  };\n\n  Log.Span = function(id, num, text, classes) {\n    var fold, time, _ref;\n    Log.Node.apply(this, arguments);\n    if (fold = text.match(Log.FOLD)) {\n      this.fold = true;\n      this.event = fold[1];\n      this.text = this.name = fold[2];\n    } else if (time = text.match(Log.TIME)) {\n      this.time = true;\n      this.event = time[1];\n      this.name = time[2];\n      this.stats = time[3];\n    } else {\n      this.text = text;\n      this.text = removeCarriageReturns(this.text);\n      this.text = this.text.replace(newLineAtTheEndRegexp, '');\n      this.nl = !!((_ref = text[text.length - 1]) != null ? _ref.match(newLineRegexp) : void 0);\n      this.cr = !!text.match(rRegexp);\n      this[\"class\"] = this.cr && ['clears'] || classes;\n    }\n    return this;\n  };\n\n  Log.extend(Log.Span, {\n    create: function(parent, id, num, text, classes) {\n      var span;\n      span = new Log.Span(id, num, text, classes);\n      parent.addChild(span);\n      return span;\n    },\n    render: function(parent, id, num, text, classes) {\n      var span;\n      span = this.create(parent, id, num, text, classes);\n      return span.render();\n    }\n  });\n\n  Log.Span.prototype = Log.extend(new Log.Node, {\n    render: function() {\n      var tail;\n      if (this.time && this.event === 'end' && this.prev) {\n        if (Log.DEBUG) {\n          console.log(\"S.0 insert \" + this.id + \" after prev \" + this.prev.id);\n        }\n        this.nl = this.prev.nl;\n        this.log.insert(this.data, {\n          after: this.prev.element\n        });\n        this.line = this.prev.line;\n      } else if (!this.fold && this.prev && !this.prev.fold && !this.prev.nl) {\n        if (Log.DEBUG) {\n          console.log(\"S.1 insert \" + this.id + \" after prev \" + this.prev.id);\n        }\n        this.log.insert(this.data, {\n          after: this.prev.element\n        });\n        this.line = this.prev.line;\n      } else if (!this.fold && this.next && !this.next.fold && !this.next.time) {\n        if (Log.DEBUG) {\n          console.log(\"S.2 insert \" + this.id + \" before next \" + this.next.id);\n        }\n        this.log.insert(this.data, {\n          before: this.next.element\n        });\n        this.line = this.next.line;\n      } else {\n        this.line = Log.Line.create(this.log, [this]);\n        this.line.render();\n      }\n      if (this.nl && (tail = this.tail).length > 0) {\n        this.split(tail);\n      }\n      if (this.time) {\n        return this.log.times.add(this);\n      }\n    },\n    remove: function() {\n      Log.Node.prototype.remove.apply(this);\n      if (this.line) {\n        return this.line.remove(this);\n      }\n    },\n    split: function(spans) {\n      var line, span, _i, _len;\n      if (Log.DEBUG) {\n        console.log(\"S.4 split [\" + (spans.map(function(span) {\n          return span.id;\n        }).join(', ')) + \"]\");\n      }\n      for (_i = 0, _len = spans.length; _i < _len; _i++) {\n        span = spans[_i];\n        this.log.remove(span.element);\n      }\n      line = Log.Line.create(this.log, spans);\n      line.render();\n      if (line.cr) {\n        return line.clear();\n      }\n    },\n    clear: function() {\n      if (this.prev && this.isSibling(this.prev) && this.isSequence(this.prev)) {\n        this.prev.clear();\n        return this.prev.remove();\n      }\n    },\n    isSequence: function(other) {\n      return this.parent.num - other.parent.num === this.log.children.indexOf(this.parent) - this.log.children.indexOf(other.parent);\n    },\n    isSibling: function(other) {\n      var _ref, _ref1;\n      return ((_ref = this.element) != null ? _ref.parentNode : void 0) === ((_ref1 = other.element) != null ? _ref1.parentNode : void 0);\n    },\n    siblings: function(type) {\n      var siblings, span;\n      siblings = [];\n      while ((span = (span || this)[type]) && this.isSibling(span)) {\n        siblings.push(span);\n      }\n      return siblings;\n    }\n  });\n\n  Object.defineProperty(Log.Span.prototype, 'data', {\n    get: function() {\n      return {\n        id: this.id,\n        type: 'span',\n        text: this.text,\n        \"class\": this[\"class\"],\n        time: this.time\n      };\n    }\n  });\n\n  Object.defineProperty(Log.Span.prototype, 'line', {\n    get: function() {\n      return this._line;\n    },\n    set: function(line) {\n      if (this.line) {\n        this.line.remove(this);\n      }\n      this._line = line;\n      if (this.line) {\n        return this.line.add(this);\n      }\n    }\n  });\n\n  Object.defineProperty(Log.Span.prototype, 'element', {\n    get: function() {\n      return document.getElementById(this.id);\n    }\n  });\n\n  Object.defineProperty(Log.Span.prototype, 'head', {\n    get: function() {\n      return this.siblings('prev').reverse();\n    }\n  });\n\n  Object.defineProperty(Log.Span.prototype, 'tail', {\n    get: function() {\n      return this.siblings('next');\n    }\n  });\n\n  Log.Line = function(log) {\n    this.log = log;\n    this.spans = [];\n    return this;\n  };\n\n  Log.extend(Log.Line, {\n    create: function(log, spans) {\n      var line, span, _i, _len;\n      if ((span = spans[0]) && span.fold) {\n        line = new Log.Fold(log, span.event, span.name);\n      } else {\n        line = new Log.Line(log);\n      }\n      for (_i = 0, _len = spans.length; _i < _len; _i++) {\n        span = spans[_i];\n        span.line = line;\n      }\n      return line;\n    }\n  });\n\n  Log.extend(Log.Line.prototype, {\n    add: function(span) {\n      var ix;\n      if (span.cr) {\n        this.cr = true;\n      }\n      if (this.spans.indexOf(span) > -1) {\n\n      } else if ((ix = this.spans.indexOf(span.prev)) > -1) {\n        return this.spans.splice(ix + 1, 0, span);\n      } else if ((ix = this.spans.indexOf(span.next)) > -1) {\n        return this.spans.splice(ix, 0, span);\n      } else {\n        return this.spans.push(span);\n      }\n    },\n    remove: function(span) {\n      var ix;\n      if ((ix = this.spans.indexOf(span)) > -1) {\n        return this.spans.splice(ix, 1);\n      }\n    },\n    render: function() {\n      var fold;\n      if ((fold = this.prev) && fold.event === 'start' && fold.active) {\n        if (this.next && !this.next.fold) {\n          if (Log.DEBUG) {\n            console.log(\"L.0 insert \" + this.id + \" before next \" + this.next.id);\n          }\n          return this.element = this.log.insert(this.data, {\n            before: this.next.element\n          });\n        } else {\n          if (Log.DEBUG) {\n            console.log(\"L.0 insert \" + this.id + \" into fold \" + fold.id);\n          }\n          fold = this.log.folds.folds[fold.name].fold;\n          return this.element = this.log.insert(this.data, {\n            into: fold\n          });\n        }\n      } else if (this.prev) {\n        if (Log.DEBUG) {\n          console.log(\"L.1 insert \" + this.spans[0].id + \" after prev \" + this.prev.id);\n        }\n        return this.element = this.log.insert(this.data, {\n          after: this.prev.element\n        });\n      } else if (this.next) {\n        if (Log.DEBUG) {\n          console.log(\"L.2 insert \" + this.spans[0].id + \" before next \" + this.next.id);\n        }\n        return this.element = this.log.insert(this.data, {\n          before: this.next.element\n        });\n      } else {\n        if (Log.DEBUG) {\n          console.log(\"L.3 insert \" + this.spans[0].id + \" into #log\");\n        }\n        return this.element = this.log.insert(this.data);\n      }\n    },\n    clear: function() {\n      var cr, _i, _len, _ref, _results;\n      _ref = this.crs;\n      _results = [];\n      for (_i = 0, _len = _ref.length; _i < _len; _i++) {\n        cr = _ref[_i];\n        _results.push(cr.clear());\n      }\n      return _results;\n    }\n  });\n\n  Object.defineProperty(Log.Line.prototype, 'id', {\n    get: function() {\n      var _ref;\n      return (_ref = this.spans[0]) != null ? _ref.id : void 0;\n    }\n  });\n\n  Object.defineProperty(Log.Line.prototype, 'data', {\n    get: function() {\n      return {\n        type: 'paragraph',\n        nodes: this.nodes\n      };\n    }\n  });\n\n  Object.defineProperty(Log.Line.prototype, 'nodes', {\n    get: function() {\n      return this.spans.map(function(span) {\n        return span.data;\n      });\n    }\n  });\n\n  Object.defineProperty(Log.Line.prototype, 'prev', {\n    get: function() {\n      var _ref;\n      return (_ref = this.spans[0].prev) != null ? _ref.line : void 0;\n    }\n  });\n\n  Object.defineProperty(Log.Line.prototype, 'next', {\n    get: function() {\n      var _ref;\n      return (_ref = this.spans[this.spans.length - 1].next) != null ? _ref.line : void 0;\n    }\n  });\n\n  Object.defineProperty(Log.Line.prototype, 'crs', {\n    get: function() {\n      return this.spans.filter(function(span) {\n        return span.cr;\n      });\n    }\n  });\n\n  Log.Fold = function(log, event, name) {\n    Log.Line.apply(this, arguments);\n    this.fold = true;\n    this.event = event;\n    this.name = name;\n    return this;\n  };\n\n  Log.Fold.prototype = Log.extend(new Log.Line, {\n    render: function() {\n      var element, _ref;\n      if (this.prev && this.prev.element) {\n        if (Log.DEBUG) {\n          console.log(\"F.1 insert \" + this.id + \" after prev \" + this.prev.id);\n        }\n        element = this.prev.element;\n        this.element = this.log.insert(this.data, {\n          after: element\n        });\n      } else if (this.next) {\n        if (Log.DEBUG) {\n          console.log(\"F.2 insert \" + this.id + \" before next \" + this.next.id);\n        }\n        element = this.next.element || this.next.element.parentNode;\n        this.element = this.log.insert(this.data, {\n          before: element\n        });\n      } else {\n        if (Log.DEBUG) {\n          console.log(\"F.3 insert \" + this.id);\n        }\n        this.element = this.log.insert(this.data);\n      }\n      if (this.span.next && ((_ref = this.span.prev) != null ? _ref.isSibling(this.span.next) : void 0)) {\n        this.span.prev.split([this.span.next].concat(this.span.next.tail));\n      }\n      return this.active = this.log.folds.add(this.data);\n    }\n  });\n\n  Object.defineProperty(Log.Fold.prototype, 'id', {\n    get: function() {\n      return \"fold-\" + this.event + \"-\" + this.name;\n    }\n  });\n\n  Object.defineProperty(Log.Fold.prototype, 'span', {\n    get: function() {\n      return this.spans[0];\n    }\n  });\n\n  Object.defineProperty(Log.Fold.prototype, 'data', {\n    get: function() {\n      return {\n        type: 'fold',\n        id: this.id,\n        event: this.event,\n        name: this.name\n      };\n    }\n  });\n\n}).call(this);\n\n})();\n//@ sourceURL=log/nodes");minispade.register('log/renderer', "(function() {(function() {\n\n  Log.Renderer = function() {\n    this.frag = document.createDocumentFragment();\n    this.para = this.createParagraph();\n    this.span = this.createSpan();\n    this.text = document.createTextNode('');\n    this.fold = this.createFold();\n    return this;\n  };\n\n  Log.extend(Log.Renderer.prototype, {\n    insert: function(data, pos) {\n      var after, before, into, node;\n      node = this.render(data);\n      if (into = pos != null ? pos.into : void 0) {\n        if (typeof into === 'String') {\n          into = document.getElementById(pos != null ? pos.into : void 0);\n        }\n        if (pos != null ? pos.prepend : void 0) {\n          this.prependTo(node, into);\n        } else {\n          this.appendTo(node, into);\n        }\n      } else if (after = pos != null ? pos.after : void 0) {\n        if (typeof after === 'String') {\n          after = document.getElementById(pos);\n        }\n        this.insertAfter(node, after);\n      } else if (before = pos != null ? pos.before : void 0) {\n        if (typeof before === 'String') {\n          before = document.getElementById(pos != null ? pos.before : void 0);\n        }\n        this.insertBefore(node, before);\n      } else {\n        this.insertBefore(node);\n      }\n      return node;\n    },\n    hide: function(node) {\n      node.setAttribute('class', this.addClass(node.getAttribute('class'), 'hidden'));\n      return node;\n    },\n    remove: function(node) {\n      if (node) {\n        node.parentNode.removeChild(node);\n      }\n      return node;\n    },\n    render: function(data) {\n      var frag, node, type, _i, _len;\n      if (data instanceof Array) {\n        frag = this.frag.cloneNode(true);\n        for (_i = 0, _len = data.length; _i < _len; _i++) {\n          node = data[_i];\n          node = this.render(node);\n          if (node) {\n            frag.appendChild(node);\n          }\n        }\n        return frag;\n      } else {\n        data.type || (data.type = 'paragraph');\n        type = data.type[0].toUpperCase() + data.type.slice(1);\n        return this[\"render\" + type](data);\n      }\n    },\n    renderParagraph: function(data) {\n      var node, para, type, _i, _len, _ref;\n      para = this.para.cloneNode(true);\n      if (data.id) {\n        para.setAttribute('id', data.id);\n      }\n      if (data.hidden) {\n        para.setAttribute('style', 'display: none;');\n      }\n      _ref = data.nodes || [];\n      for (_i = 0, _len = _ref.length; _i < _len; _i++) {\n        node = _ref[_i];\n        type = node.type[0].toUpperCase() + node.type.slice(1);\n        node = this[\"render\" + type](node);\n        para.appendChild(node);\n      }\n      return para;\n    },\n    renderFold: function(data) {\n      var fold;\n      fold = this.fold.cloneNode(true);\n      fold.setAttribute('id', data.id || (\"fold-\" + data.event + \"-\" + data.name));\n      fold.setAttribute('class', \"fold-\" + data.event);\n      if (data.event === 'start') {\n        fold.lastChild.lastChild.nodeValue = data.name;\n      } else {\n        fold.removeChild(fold.lastChild);\n      }\n      return fold;\n    },\n    renderSpan: function(data) {\n      var span;\n      span = this.span.cloneNode(true);\n      if (data.id) {\n        span.setAttribute('id', data.id);\n      }\n      if (data[\"class\"]) {\n        span.setAttribute('class', data[\"class\"]);\n      }\n      span.lastChild.nodeValue = data.text || '';\n      return span;\n    },\n    renderText: function(data) {\n      var text;\n      text = this.text.cloneNode(true);\n      text.nodeValue = data.text;\n      return text;\n    },\n    createParagraph: function() {\n      var para;\n      para = document.createElement('p');\n      para.appendChild(document.createElement('a'));\n      return para;\n    },\n    createFold: function() {\n      var fold;\n      fold = document.createElement('div');\n      fold.appendChild(this.createSpan());\n      fold.lastChild.setAttribute('class', 'fold-name');\n      return fold;\n    },\n    createSpan: function() {\n      var span;\n      span = document.createElement('span');\n      span.appendChild(document.createTextNode(' '));\n      return span;\n    },\n    insertBefore: function(node, other) {\n      var log;\n      if (other) {\n        return other.parentNode.insertBefore(node, other);\n      } else {\n        log = document.getElementById('log');\n        return log.insertBefore(node, log.firstChild);\n      }\n    },\n    insertAfter: function(node, other) {\n      if (other.nextSibling) {\n        return this.insertBefore(node, other.nextSibling);\n      } else {\n        return this.appendTo(node, other.parentNode);\n      }\n    },\n    prependTo: function(node, other) {\n      if (other.firstChild) {\n        return other.insertBefore(node, other.firstChild);\n      } else {\n        return appendTo(node, other);\n      }\n    },\n    appendTo: function(node, other) {\n      return other.appendChild(node);\n    },\n    addClass: function(classes, string) {\n      if (classes != null ? classes.indexOf(string) : void 0) {\n        return;\n      }\n      if (classes) {\n        return \"\" + classes + \" \" + string;\n      } else {\n        return string;\n      }\n    }\n  });\n\n}).call(this);\n\n})();\n//@ sourceURL=log/renderer");minispade.register('log/times', "(function() {(function() {\n\n  Log.Times = function(log) {\n    this.log = log;\n    this.times = {};\n    return this;\n  };\n\n  Log.extend(Log.Times.prototype, {\n    add: function(node) {\n      var time, _base, _name;\n      time = (_base = this.times)[_name = node.name] || (_base[_name] = new Log.Times.Time);\n      return time.receive(node);\n    },\n    duration: function(name) {\n      if (this.times[name]) {\n        return this.times[name].duration;\n      }\n    }\n  });\n\n  Log.Times.Time = function() {\n    return this;\n  };\n\n  Log.extend(Log.Times.Time.prototype, {\n    receive: function(node) {\n      this[node.event] = node;\n      if (Log.DEBUG) {\n        console.log(\"T.0 - \" + node.event + \" \" + node.name);\n      }\n      if (this.start && this.end) {\n        return this.finish();\n      }\n    },\n    finish: function() {\n      var element;\n      if (Log.DEBUG) {\n        console.log(\"T.1 - finish \" + this.start.name);\n      }\n      element = document.getElementById(this.start.id);\n      if (element) {\n        return this.update(element);\n      }\n    },\n    update: function(element) {\n      element.setAttribute('class', 'duration');\n      element.setAttribute('title', \"This command finished after \" + this.duration + \" seconds.\");\n      return element.lastChild.nodeValue = \"\" + this.duration + \"s\";\n    }\n  });\n\n  Object.defineProperty(Log.Times.Time.prototype, 'duration', {\n    get: function() {\n      var duration;\n      duration = this.stats.duration / 1000 / 1000 / 1000;\n      return duration.toFixed(2);\n    }\n  });\n\n  Object.defineProperty(Log.Times.Time.prototype, 'stats', {\n    get: function() {\n      var stat, stats, _i, _len, _ref;\n      if (!(this.end && this.end.stats)) {\n        return {};\n      }\n      stats = {};\n      _ref = this.end.stats.split(',');\n      for (_i = 0, _len = _ref.length; _i < _len; _i++) {\n        stat = _ref[_i];\n        stat = stat.split('=');\n        stats[stat[0]] = stat[1];\n      }\n      return stats;\n    }\n  });\n\n}).call(this);\n\n})();\n//@ sourceURL=log/times");
