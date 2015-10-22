---
# main script
---

"use strict"
$ = document.querySelector.bind(document)
$$ = document.querySelectorAll.bind(document)
LS = window.localStorage
map = Array::map
if typeof LS == 'undefined'
  document.getElementById('container').className = 'not-supported'
  throw new Error('Html5 Local Storage not supported!')
ST =
  lvl: $('#lvl>td>input[type="number"]')
  el: $$('tbody>tr:nth-child(n+2)>td>input[type="number"]')
  rn: $$('tbody>tr:nth-child(n+2)>td>input[type="range"]')
  points: $('#points>td:nth-of-type(2)')
  spent: $('#spent>td:nth-of-type(2)')
  remaining: $('#remaining>td:nth-of-type(2)')
  stat_p: [ 0, 48 ]
  arc: [ 0, 1, 2, 2, 2, 2, 2, 2, 2 ]
i = 2
while 256 > i
  ST.stat_p[i] = ST.stat_p[i - 1] + Math.floor((i - 2) / 4) + 4
  i++
w = 9
while 101 > w
  ST.arc[w] = Math.floor((w - 2) / 10) + 2
  w++

ST.load = ->
  if typeof LS.el == 'undefined' or typeof LS.lvl == 'undefined'
    ST.lvl.value = parseInt(1)
    map.call ST.el, (e) ->
      e.value = parseInt(1)
      return
  else
    ST.lvl.value = parseInt(LS.lvl)
    ls_el = LS.el.split(',')
    k = 0
    u = 0
    ls_el.map (e) ->
      ST.el[k].value = parseInt(e)
      k++
      return
    ls_el.map (e) ->
      ST.rn[u].value = parseInt(e)
      u++
      return
  return

ST.calc = (p) ->
  if p
    if p.target.type == 'range' and parseInt(p.target.max) == 99
      p.target.parentNode.parentNode.children[2].children[0].value = parseInt(p.target.value)
    else if p.target.type == 'number' and parseInt(p.target.max) == 99
      p.target.parentNode.parentNode.children[1].children[0].value = parseInt(p.target.value)
  spent = 0
  LS.el = map.call(ST.el, (e) ->
    parseInt e.value
  )
  LS.lvl = parseInt(ST.lvl.value)
  ST.points.innerHTML = ST.stat_p[LS.lvl]
  map.call ST.el, (e) ->
    y = 1
    while parseInt(e.value) > y
      spent += ST.arc[y + 1]
      y++
    e.parentNode.parentNode.children[3].innerHTML = "+" + ST.arc[parseInt(e.value)+1]
    return
  remaining = ST.stat_p[LS.lvl] - spent
  ST.spent.innerHTML = spent
  ST.remaining.innerHTML = remaining
  ST.remaining.className = ""
  if (remaining < 0)
    ST.remaining.className =  "err"
  return

ST.copy = (b) ->
  str = ""
  map.call(ST.el, (p) ->
    str += p.parentNode.parentNode.children[0].innerHTML + ": " + p.value
    if (p != ST.el[ST.el.length - 1])
      str += ", "
  )
  $("#copy").innerHTML = str
  selection = window.getSelection()
  range = document.createRange()
  range.selectNodeContents($("#copy"))
  selection.removeAllRanges()
  selection.addRange(range)
  document.execCommand("copy", false, null)
  return

ST.reset = ->
  map.call(ST.el, (p) ->
    p.value = parseInt(1)
  )
  map.call(ST.rn, (p) ->
    p.value = parseInt(1)
  )
  ST.lvl.value = parseInt(1)
  ST.calc()
  return

ST.load()
map.call $$('tbody input'), (e) ->
  e.addEventListener 'input', ST.calc
  return
$('tfoot>#buttons>td>button:first-of-type').addEventListener 'click', ST.copy
$('tfoot>#buttons>td>button:last-of-type').addEventListener 'click', ST.reset
ST.calc()
