/* ; */
function comment() {
  // This is a one line JavaScript comment
   /* This comment spans multiple lines.
                            Notice
     that we don
  't need to end the comment until
                  we're done. */
  console.log("Hello!");
}
comment();

// Class declaration
class A {
  a = 1;
  [b] = 2;
}

const c = new A(); // Variable declaration (may also be `let` or `var`)
console.log(c.a, c[b]);
let d = 2 ** 3;
function fn() {} // Function declaration
const obj = { key: "value" }; // Object keys
lbl: console.log(1); // Label

let regex = /hello/;
regex = /\d+/g;
regex = /[a-zA-Z]+/i;
regex = /[\w.-]+@[a-zA-Z]+\.[a-zA-Z]{2,}/;

const longString =
  "This is a \"very\" long \ string which needs \
  to wrap across multiple lines because" +
  'otherwise \'my\' code is unreadable.' +
  `string \`text\`` +
  `string text ${expression} string text`;

do {
  var e = 1e-3 + 0E3;
  e = 012;
  e = 0b11;
  e = 0O12;
  e = 0xFF;
  e = 0x123456789ABCDEFn;
} while (condition) /* ; */
