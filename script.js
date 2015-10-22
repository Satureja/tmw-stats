(function(){
    "use strict";
    var $  = document.querySelector.bind(document), // shorthand
        $$ = document.querySelectorAll.bind(document),
        LS = localStorage,
        map = Array.prototype.map;

    if(!window.hasOwnProperty("localStorage")) {
        document.getElementById("container").className="not-supported";
        throw new Error("Html5 Local Storage not supported!");
    }

    var ST = {
        lvl: $("#lvl>td>input"),
        el: $$("tbody>tr:nth-child(n+2)>td>input"),
        points: $("#points>td:nth-of-type(2)"),
        spent: $("#spent>td:nth-of-type(2)"),
        remaining: $("#remaining>td:nth-of-type(2)"),
        stat_p: [0,48],
        arc: [0,1,2,2,2,2,2,2,2,2,2,2,3,3,3,3]
    };

    // generate stats_by_level
    for(var i = 2; 255 > i; i++) ST.stat_p[i] = ST.stat_p[i - 1] + Math.floor((i - 2) / 4) + 4;
    for(var w = 9; 99 > w; w++)  ST.arc[w] = Math.floor((w - 2) / 10) + 2;

    ST.load = function(){
        if (typeof LS.el === "undefined" || typeof LS.lvl === "undefined")
        {
            ST.lvl.value = parseInt(1);
            map.call(ST.el, function(e){e.value=parseInt(1)});
        }
        else {
            ST.lvl.value = parseInt(LS.lvl);
            var ls_el = LS.el.split(","), k = 0;
            ls_el.map(function(e){ST.el[k].value=parseInt(e);k++});
        }
    };

    ST.calc = function(){
        var spent = 0;
        LS.el = map.call(ST.el, function(e){return parseInt(e.value)}); // save
        LS.lvl = parseInt(ST.lvl.value);
        ST.points.innerHTML = ST.stat_p[LS.lvl];
        map.call(ST.el, function(e){
            var val = parseInt(e.value);
            for(var y = 1; val > y; y++) spent += ST.arc[y+1]
        });
        ST.spent.innerHTML = spent;
        ST.remaining.innerHTML = ST.stat_p[LS.lvl] - spent;
    };

    // main payload below
    ST.load(); // load from LS
    ST.onLVLChange = ST.lvl.addEventListener("change", ST.calc);
    map.call(ST.el, function(e){e.addEventListener("change", ST.calc)});
    ST.calc(); // calc stats
})();
