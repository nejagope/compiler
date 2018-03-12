var parser = require("./parser").parser;
var fs = require("fs");

var codigo = fs.readFileSync("test.src", "utf8");
console.log(exec(codigo));

function exec (input) {
    return parser.parse(input);
}