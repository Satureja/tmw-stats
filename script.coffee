---
# main script
---

"use strict"
$ = document.querySelector.bind document
$$ = document.querySelectorAll.bind document
LS = window.localStorage
map = Array::map
if typeof LS == 'undefined'
    document.getElementById('container').className = 'not-supported'
    throw new Error 'Html5 Local Storage not supported!'
ST =
    lvl: $ '#lvl>td>input[type="number"]'
    el: $$ 'tbody>tr:nth-child(n+2)>td>input[type="number"]'
    rn: $$ 'tbody>tr:nth-child(n+2)>td>input[type="range"]'
    points: $ '#points>td:nth-of-type(2)'
    spent: $ '#spent>td:nth-of-type(2)'
    remaining: $ '#remaining>td:nth-of-type(2)'
    stat_p: [ 0, 48 ]
    arc: [ 0, 1, 2, 2, 2, 2, 2, 2, 2 ]

ST.stat_p[i] = ST.stat_p[i - 1] + (i - 2) // 4 + 4 for i in [2..255]
ST.arc[i] = (i - 2) // 10 + 2 for i in [9..100]

ST.load = ->
    unless LS.el? and LS.lvl?
        ST.lvl.value = parseInt 1
        map.call ST.el, (e) ->
            e.value = parseInt 1
            return
    else
        ST.lvl.value = parseInt LS.lvl
        ls_el = LS.el.split ','
        k = 0
        u = 0
        ls_el.map (e) ->
            ST.el[k].value = parseInt e
            k++
            return
        ls_el.map (e) ->
            ST.rn[u].value = parseInt e
            u++
            return
    return

ST.calc = (p) ->
    if p
        if p.target.type == 'range' and parseInt(p.target.max) == 99
            p.target.parentNode.parentNode.children[2].children[0].value = parseInt p.target.value
        else if p.target.type == 'number' and parseInt(p.target.max) == 99
            p.target.parentNode.parentNode.children[1].children[0].value = parseInt p.target.value
    spent = 0
    LS.el = map.call ST.el, (e) ->
        parseInt e.value
    LS.lvl = if parseInt(ST.lvl.value) > 0 then parseInt ST.lvl.value else 1
    ST.points.innerHTML = ST.stat_p[LS.lvl]
    map.call ST.el, (e) ->
        val = if parseInt(e.value) > 0 then parseInt e.value else 1
        spent += ST.arc[y+1] for y in [1...val]
        e.parentNode.parentNode.children[3].innerHTML = "+#{ST.arc[val+1]}"
        return
    remaining = ST.stat_p[LS.lvl] - spent
    ST.spent.innerHTML = spent
    ST.remaining.innerHTML = remaining
    ST.remaining.className = if remaining < 0 then 'err' else ''
    return

ST.copy = (b) ->
    str = ''
    map.call ST.el, (p) ->
        str += "#{p.parentNode.parentNode.children[0].innerHTML}: #{value}"
        str += ', ' if p != ST.el[ST.el.length - 1]
    $('#copy').className = 'v'
    $('#copy').innerHTML = str
    selection = window.getSelection()
    range = document.createRange()
    range.selectNodeContents $ '#copy'
    selection.removeAllRanges()
    selection.addRange range
    document.execCommand 'copy', false, null
    return

ST.reset = ->
    map.call ST.el, (p) ->
        p.value = parseInt 1
    map.call ST.rn, (p) ->
        p.value = parseInt 1
    ST.lvl.value = parseInt 1
    ST.calc()
    return

ST.load()
map.call $$('tbody input'), (e) ->
    e.addEventListener 'input', ST.calc
    return
$('tfoot>#buttons>td>button:first-of-type').addEventListener 'click', ST.copy
$('#copy').addEventListener 'click', ST.copy
$('tfoot>#buttons>td>button:last-of-type').addEventListener 'click', ST.reset
ST.calc()
