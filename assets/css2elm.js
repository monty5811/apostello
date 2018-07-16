const fs = require("fs");
const postcss = require("postcss");
const savePath = "./elm/Css.elm";
const loadPath = "../apostello/static/css/apostello.min.css"

const root = postcss.parse(fs.readFileSync(loadPath, "utf8"));
let classes = new Map();

root.walkRules(rule => {
    if (!rule.selector.startsWith(".")) {
        // keep only classes
        return;
    };

    let cls = rule.selector;

    let ignore = cls.indexOf(':after') != -1 || cls.indexOf(':before') != -1 || cls.indexOf('datepicker') != -1;
    if (ignore) {
        return;
    }
    if (cls)
    // remove the dot
    cls = cls.replace(/^(\.)/, '');
    // keep only up to a comma or a space
    cls = cls.split(/[ ,]/)[0];


    var elm = cls.split("\\:").join("__")
    elm = elm.replace(/-m([xytblr])/g, 'neg_m$1');
    elm = elm.replace(/^-/, 'neg_');
    elm = elm.replace(/-/g, '_');
    elm = elm.replace(/:/g, '_');
    elm = elm.replace(/\\\//g, '__');

    classes.set(cls, elmFunction(cls, elm));
});

function fixClass(cls) {
    cls = cls.replace(/([sm|md|lg|xl])\\:/g, '$1:');
    return cls.replace(/\\/g, '\\\\');
}

function elmFunction(cls, elm) {
    return `
${elm} : Html.Attribute msg
${elm} =
    A.class "${fixClass(cls)}"

`;
}

function elmBody(clases) {
    let body = '';
    for (var fn of classes.values()) {
        body = body + fn;
    }
    return body;
}

const elmHeader = `module Css exposing (..)

import Html
import Html.Attributes as A

`

const elmModule = elmHeader + elmBody(classes)

// writing to disk
fs.writeFile(savePath, elmModule, err => {
  if (err) {
    return console.log(err);
  }

  console.log(savePath, "was saved!");
});
