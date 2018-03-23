var parser = require("./parser").parser;
var fs = require("fs");

var codigo = fs.readFileSync("test.src", "utf8");
exec(codigo);

function exec (input) {
    var res = parser.parse(input);
    console.log( JSON.stringify() );
}

function showJSON(json){
  console.log( JSON.stringify(json) );
}