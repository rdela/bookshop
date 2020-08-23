var { Liquid, Tokenizer } = require('liquidjs');
var path = require('path');

//root here refers to the path im the browser, not on the fs.
const engine = new Liquid({
    root: '/',                   // root for layouts/includes lookup 
    extname: '.html'             // used for layouts/includes, defaults ""
});
engine.plugin(require('./plugins/bem-mods.js'));
engine.plugin(require('./plugins/jsonify.js'));
engine.plugin(require('./plugins/slugify-plugin.js'));

/**
 * Rewrite Jekyll includes to match LiquidJS syntax
 * @param  {Buffer} text File contents of a Jekyll include
 * @return {String}      File context of a LiquidJS include
 */
const rewriteIncludes = function(text) {
    text = text.toString();
    let tokenizer = new Tokenizer(text);
    let output = tokenizer.readTopLevelTokens();
  
    output.reverse().forEach(tag => {
      text = rewriteTag(tag, text);
    });

    return text;
};

const rewriteTag = function(token, src) {
  let raw = token.getText();
  let length = raw.length;

  if (token.kind === 16) return src; // html
  if (token.name && token.name.match(/^end/)) return src;

  if (token.name && token.name === 'include_cached') raw = raw.replace(/include_cached/, 'include');
  if (token.name && token.name.match(/^include/)) {
    raw = raw.replace(/=/g, ': ');
    raw = raw.replace(/include\s([^"'][^\s]+)/gi, 'include "$1"');
  }

  raw = raw.replace(/\binclude\./gi, '');
  
  return [
     src.substr(0, token.begin),
     raw,
     src.substr(token.end)
   ].join('');

}

module.exports = {
    jekyllEngine: engine,
    rewriteIncludes: rewriteIncludes
}