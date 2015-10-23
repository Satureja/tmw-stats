---
# main script
---

"use strict"
if document.location.pathname == '/tmw-stats/'
    document.location.href = 'http://stats.meko.moe'

$ = document.querySelector.bind document
$$ = document.querySelectorAll.bind document
LS = window.localStorage
nz = (x) => if x? and parseInt(x) > 0 then parseInt x else 1
map = Array::map
if typeof LS == 'undefined'
    $('#container').className = 'not-supported'
    throw new Error 'Html5 Local Storage not supported!'
ST =
    lvl: $ '#lvl>td>input[type="number"]'
    el: $$ 'tbody>tr:nth-child(n+2)>td>input[type="number"]'
    rn: $$ 'tbody>tr:nth-child(n+2)>td>input[type="range"]'
    points: $ '#points>td:nth-of-type(2)'
    spent: $ '#spent>td:nth-of-type(2)'
    remaining: $ '#remaining>td:nth-of-type(2)'
    t: $ '#profile'
    ptable: $ '#container>table:first-of-type'
    stat_p: [ 0, 48 ]
    arc: [ 0, 1, 2, 2, 2, 2, 2, 2, 2 ]
    profile: 0
    profiles: []
    names: ['Default']

ST.stat_p[i] = ST.stat_p[i - 1] + (i - 2) // 4 + 4 for i in [2..255]
ST.arc[i] = (i - 2) // 10 + 2 for i in [9..100]

ST.load = ->
    ST.profiles = if LS.profiles? then JSON.parse LS.profiles else []
    if ST.profiles[ST.profile]?
        p = ST.profiles[ST.profile]
        ST.lvl.value = parseInt p[0]
        ST.rn[k-1].value = ST.el[k-1].value = parseInt p[k] for k in [1...p.length]
    return

ST.calc = (p) ->
    if p
        if p.target.type == 'range' and parseInt(p.target.max) == 99
            p.target.parentNode.parentNode.children[2].children[0].value = nz p.target.value
        else if p.target.type == 'number' and parseInt(p.target.max) == 99
            p.target.parentNode.parentNode.children[1].children[0].value = nz p.target.value
    spent = 0
    str = ''
    ST.profiles[ST.profile] = [nz ST.lvl.value]
    ST.points.textContent = ST.stat_p[nz ST.lvl.value]
    map.call ST.el, (e) ->
        val = nz e.value
        spent += ST.arc[y+1] for y in [1...val]
        ST.profiles[ST.profile].push parseInt e.value
        e.parentNode.parentNode.children[3].textContent = "+#{ST.arc[val+1]}"
        str += "#{e.parentNode.parentNode.children[0].textContent}: #{e.value}"
        str += ', ' if e != ST.el[ST.el.length - 1]
        return
    $('#copy').textContent = str
    remaining = ST.stat_p[nz ST.lvl.value] - spent
    ST.spent.textContent = spent
    ST.remaining.textContent = remaining
    ST.remaining.className = if remaining < 0 then 'err' else ''
    LS.profiles = JSON.stringify ST.profiles
    #
    #prepare profiles
    #
    map.call $$('table:first-of-type tr'), (g) ->
        do g.remove
    map.call ST.profiles, (e,n) =>
        s = ST.t.content.querySelector('td:nth-child(1)')
        ST.t.content.querySelector('th').textContent = e[0]
        ST.t.content.querySelector('td:nth-child(2)').textContent = ST.names[n]
        s.textContent = e[1]
        s.textContent += ' ' + e[v] for v in [2...e.length]
        ST.ptable.appendChild document.importNode ST.t.content, true
    return

ST.copy = (b) ->
    $('#copy').className = 'v'
    selection = do window.getSelection
    range = do document.createRange
    range.selectNodeContents $ '#copy'
    do selection.removeAllRanges
    selection.addRange range
    document.execCommand 'copy', false, null
    return

ST.reset = ->
    map.call ST.el, (p) ->
        p.value = parseInt 1
    map.call ST.rn, (p) ->
        p.value = parseInt 1
    ST.lvl.value = parseInt 1
    do ST.calc
    return

do ST.load
map.call $$('tbody input'), (e) ->
    e.addEventListener 'input', ST.calc
    return
$('tfoot>#buttons>td>button:nth-of-type(1)').addEventListener 'click', (e) =>
    if document.location.hash == '#dev'
        $('#copy').className = ''
        $('#container').className = 'profiles'
    else
        window.alert 'Sorry, feature not ready yet'
        e.target.style.opacity = 0
$('tfoot>#buttons>td>button:nth-of-type(2)').addEventListener 'click', ST.copy
$('#copy').addEventListener 'click', ST.copy
$('tfoot>#buttons>td>button:nth-of-type(3)').addEventListener 'click', ST.reset
do ST.calc
