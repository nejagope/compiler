var parser = require("./parser").parser;
var fs = require("fs");

var codigo = fs.readFileSync("test.src", "utf8");
exec(codigo);

function exec (input) {
    console.log( JSON.stringify(parser.parse(input)) );
}

function showJSON(json){
  console.log( JSON.stringify(json) );
}