/*
html5slider - a JS implementation of <input type=range> for Firefox 4 and up
https://github.com/fryn/html5slider

Copyright (c) 2010-2011 Frank Yan, <http://frankyan.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

(function() {

// test for native support
var test = document.createElement('input');
try {
  test.type = 'range';
  if (test.type == 'range')
    return;
} catch (e) {
  return;
}

// test for required property support
if (!document.mozSetImageElement || !('MozAppearance' in test.style))
  return;

var scale;
var isMac = navigator.platform == 'MacIntel';
var thumb = {
  radius: isMac ? 9 : 6,
  width: isMac ? 22 : 12,
  height: isMac ? 16 : 20
};
var track = '-moz-linear-gradient(top, transparent ' + (isMac ?
  '6px, #999 6px, #999 7px, #ccc 9px, #bbb 11px, #bbb 12px, transparent 12px' :
  '9px, #999 9px, #bbb 10px, #fff 11px, transparent 11px') +
  ', transparent)';
var styles = {
  'min-width': thumb.width + 'px',
  'min-height': thumb.height + 'px',
  'max-height': thumb.height + 'px',
  padding: 0,
  border: 0,
  'border-radius': 0,
  cursor: 'default',
  'text-indent': '-999999px' // -moz-user-select: none; breaks mouse capture
};
var onChange = document.createEvent('HTMLEvents');
onChange.initEvent('change', true, false);

if (document.readyState == 'loading')
  document.addEventListener('DOMContentLoaded', initialize, true);
else
  initialize();

function initialize() {
  // create initial sliders
  Array.forEach(document.querySelectorAll('input[type=range]'), transform);
  // create sliders on-the-fly
  document.addEventListener('DOMNodeInserted', onNodeInserted, true);
}

function onNodeInserted(e) {
  check(e.target);
  if (e.target.querySelectorAll)
    Array.forEach(e.target.querySelectorAll('input'), check);
}

function check(input, async) {
  if (input.localName != 'input' || input.type == 'range');
  else if (input.getAttribute('type') == 'range')
    transform(input);
  else if (!async)
    setTimeout(check, 0, input, true);
}

function transform(slider) {

  var isValueSet, areAttrsSet, isChanged, isClick, prevValue, rawValue, prevX;
  var min, max, step, range, value = slider.value;

  // lazily create shared slider affordance
  if (!scale) {
    scale = document.body.appendChild(document.createElement('hr'));
    style(scale, {
      '-moz-appearance': isMac ? 'scale-horizontal' : 'scalethumb-horizontal',
      display: 'block',
      visibility: 'visible',
      opacity: 1,
      position: 'fixed',
      top: '-999999px'
    });
    document.mozSetImageElement('__sliderthumb__', scale);
  }

  // reimplement value and type properties
  var getValue = function() { return '' + value; };
  var setValue = function setValue(val) {
    value = '' + val;
    isValueSet = true;
    draw();
    delete slider.value;
    slider.value = value;
    slider.__defineGetter__('value', getValue);
    slider.__defineSetter__('value', setValue);
  };
  slider.__defineGetter__('value', getValue);
  slider.__defineSetter__('value', setValue);
  slider.__defineGetter__('type', function() { return 'range'; });

  // sync properties with attributes
  ['min', 'max', 'step'].forEach(function(prop) {
    if (slider.hasAttribute(prop))
      areAttrsSet = true;
    slider.__defineGetter__(prop, function() {
      return this.hasAttribute(prop) ? this.getAttribute(prop) : '';
    });
    slider.__defineSetter__(prop, function(val) {
      val === null ? this.removeAttribute(prop) : this.setAttribute(prop, val);
    });
  });

  // initialize slider
  slider.readOnly = true;
  style(slider, styles);
  update();

  slider.addEventListener('DOMAttrModified', function(e) {
    // note that value attribute only sets initial value
    if (e.attrName == 'value' && !isValueSet) {
      value = e.newValue;
      draw();
    }
    else if (~['min', 'max', 'step'].indexOf(e.attrName)) {
      update();
      areAttrsSet = true;
    }
  }, true);

  slider.addEventListener('mousedown', onDragStart, true);
  slider.addEventListener('keydown', onKeyDown, true);
  slider.addEventListener('focus', onFocus, true);
  slider.addEventListener('blur', onBlur, true);

  function onDragStart(e) {
    isClick = true;
    setTimeout(function() { isClick = false; }, 0);
    if (e.button || !range)
      return;
    var width = parseFloat(getComputedStyle(this, 0).width);
    var multiplier = (width - thumb.width) / range;
    if (!multiplier)
      return;
    // distance between click and center of thumb
    var dev = e.clientX - this.getBoundingClientRect().left - thumb.width / 2 -
              (value - min) * multiplier;
    // if click was not on thumb, move thumb to click location
    if (Math.abs(dev) > thumb.radius) {
      isChanged = true;
      this.value -= -dev / multiplier;
    }
    rawValue = value;
    prevX = e.clientX;
    this.addEventListener('mousemove', onDrag, true);
    this.addEventListener('mouseup', onDragEnd, true);
  }

  function onDrag(e) {
    var width = parseFloat(getComputedStyle(this, 0).width);
    var multiplier = (width - thumb.width) / range;
    if (!multiplier)
      return;
    rawValue += (e.clientX - prevX) / multiplier;
    prevX = e.clientX;
    isChanged = true;
    this.value = rawValue;
  }

  function onDragEnd() {
    this.removeEventListener('mousemove', onDrag, true);
    this.removeEventListener('mouseup', onDragEnd, true);
  }

  function onKeyDown(e) {
    if (e.keyCode > 36 && e.keyCode < 41) { // 37-40: left, up, right, down
      onFocus.call(this);
      isChanged = true;
      this.value = value + (e.keyCode == 38 || e.keyCode == 39 ? step : -step);
    }
  }

  function onFocus() {
    if (!isClick)
      this.style.boxShadow = !isMac ? '0 0 0 2px #fb0' :
        '0 0 2px 1px -moz-mac-focusring, inset 0 0 1px -moz-mac-focusring';
  }

  function onBlur() {
    this.style.boxShadow = '';
  }

  // determines whether value is valid number in attribute form
  function isAttrNum(value) {
    return !isNaN(value) && +value == parseFloat(value);
  }

  // validates min, max, and step attributes and redraws
  function update() {
    min = isAttrNum(slider.min) ? +slider.min : 0;
    max = isAttrNum(slider.max) ? +slider.max : 100;
    if (max < min)
      max = min > 100 ? min : 100;
    step = isAttrNum(slider.step) && slider.step > 0 ? +slider.step : 1;
    range = max - min;
    draw(true);
  }

  // recalculates value property
  function calc() {
    if (!isValueSet && !areAttrsSet)
      value = slider.getAttribute('value');
    if (!isAttrNum(value))
      value = (min + max) / 2;;
    // snap to step intervals (WebKit sometimes does not - bug?)
    value = Math.round((value - min) / step) * step + min;
    if (value < min)
      value = min;
    else if (value > max)
      value = min + ~~(range / step) * step;
  }

  // renders slider using CSS background ;)
  function draw(attrsModified) {
    calc();
    if (isChanged && value != prevValue)
      slider.dispatchEvent(onChange);
    isChanged = false;
    if (!attrsModified && value == prevValue)
      return;
    prevValue = value;
    var position = range ? (value - min) / range * 100 : 0;
    var bg = '-moz-element(#__sliderthumb__) ' + position + '% no-repeat, ';
    style(slider, { background: bg + track });
  }

}

function style(element, styles) {
  for (var prop in styles)
    element.style.setProperty(prop, styles[prop], 'important');
}

})();

var generateName, generatePage;

generateName = function() {
  var adjective, animal, pick;
  pick = function(list) {
    var n;
    n = list.split(',');
    return n[Math.floor(n.length * Math.random())];
  };
  adjective = 'flaming,aberrant,agressive,warty,hoary,breezy,dapper,edgy,feisty,gutsy,hardy,intrepid,jaunty,karmic,lucid,gastric,maverick,natty,oneric,precise,quantal,quizzical,curious,derisive,bodacious,nefarious,nuclear,nonchalant,marvelous,greedy,omnipotent,loquacious,rabid,redundant,dazzling,jolly,autoerotic,gloomy,valiant,pedantic,demented,prolific,scientific,pedagogical,robotic,sluggish,lethargic,bioluminescent,stationary,quirky,spunky,stochastic,bipolar,brownian,relativistic,defiant,rebellious,rhetorical,irradiated,electric,tethered,polemic,nostalgic,ninja,wistful,wintry,narcissistic,foreign,deistic,eclectic,discordant,cacophonous,drunk,racist,secular';
  animal = 'monkey,axolotl,warthog,hedgehog,badger,drake,fawn,gibbon,heron,ibex,jackalope,koala,lynx,meerkat,narwhal,ocelot,penguin,quetzal,kodiak,cheetah,puma,jaguar,panther,tiger,leopard,lion,neanderthal,walrus,mushroom,dolphin,giraffe,gnat,fox,possum,otter,owl,osprey,oyster,rhinoceros,quail,gerbil,jellyfish,porcupine,anglerfish,unicorn,seal,macaw,kakapo,squirrel,squid,rabbit,raccoon,turtle,tortoise,iguana,gecko,werewolf,traut';
  return pick(adjective) + " " + pick(animal);
};

generatePage = function() {
  var noun, people, pick, verb;
  pick = function(list) {
    var n;
    n = list.split(',');
    return n[Math.floor(n.length * Math.random())];
  };
  people = 'kirk,picard,feynman,einstein,erdos,huxley,robot,ben,batman,panda,pinkman,superhero,celebrity,traitor,alien,lemon,police,whale,astronaut,chicken,kitten,cats,shakespeare,dali,cherenkov,stallman,sherlock,sagan,irving,copernicus,kepler,astronomer,colbert';
  verb = 'on,enveloping,eating,drinking,in,near,sleeping,destroying,arresting,cloning,around,jumping,scrambling,painting,stalking,vomiting,defrauding,rappelling,searching,voting,faking';
  noun = 'mountain,drugs,house,asylum,elevator,scandal,planet,school,brick,rock,pebble,lamp,water,paper,friend,toilet,airplane,cow,pony,egg,chicken,meat,book,wikipedia,turd,rhinoceros,paris,sunscreen,canteen,earwax,printer,staple,endorphins,trampoline,helicopter,feather,cloud,skeleton,uranus,neptune,earth,venus,mars,mercury,pluto,moon,jupiter,saturn,electorate,facade,tree,plant,pants';
  return pick(people) + "-" + pick(verb) + "-" + pick(noun);
};

if (typeof exports !== "undefined" && exports !== null) {
  exports.generatePage = generatePage;
}

if (typeof exports !== "undefined" && exports !== null) {
  exports.generateName = generateName;
}

removeDiacritics = (function(){
var defaultDiacriticsRemovalMap = [
    {'base':'A', 'letters':/[\u0041\u24B6\uFF21\u00C0\u00C1\u00C2\u1EA6\u1EA4\u1EAA\u1EA8\u00C3\u0100\u0102\u1EB0\u1EAE\u1EB4\u1EB2\u0226\u01E0\u00C4\u01DE\u1EA2\u00C5\u01FA\u01CD\u0200\u0202\u1EA0\u1EAC\u1EB6\u1E00\u0104\u023A\u2C6F]/g},
    {'base':'AA','letters':/[\uA732]/g},
    {'base':'AE','letters':/[\u00C6\u01FC\u01E2]/g},
    {'base':'AO','letters':/[\uA734]/g},
    {'base':'AU','letters':/[\uA736]/g},
    {'base':'AV','letters':/[\uA738\uA73A]/g},
    {'base':'AY','letters':/[\uA73C]/g},
    {'base':'B', 'letters':/[\u0042\u24B7\uFF22\u1E02\u1E04\u1E06\u0243\u0182\u0181]/g},
    {'base':'C', 'letters':/[\u0043\u24B8\uFF23\u0106\u0108\u010A\u010C\u00C7\u1E08\u0187\u023B\uA73E]/g},
    {'base':'D', 'letters':/[\u0044\u24B9\uFF24\u1E0A\u010E\u1E0C\u1E10\u1E12\u1E0E\u0110\u018B\u018A\u0189\uA779]/g},
    {'base':'DZ','letters':/[\u01F1\u01C4]/g},
    {'base':'Dz','letters':/[\u01F2\u01C5]/g},
    {'base':'E', 'letters':/[\u0045\u24BA\uFF25\u00C8\u00C9\u00CA\u1EC0\u1EBE\u1EC4\u1EC2\u1EBC\u0112\u1E14\u1E16\u0114\u0116\u00CB\u1EBA\u011A\u0204\u0206\u1EB8\u1EC6\u0228\u1E1C\u0118\u1E18\u1E1A\u0190\u018E]/g},
    {'base':'F', 'letters':/[\u0046\u24BB\uFF26\u1E1E\u0191\uA77B]/g},
    {'base':'G', 'letters':/[\u0047\u24BC\uFF27\u01F4\u011C\u1E20\u011E\u0120\u01E6\u0122\u01E4\u0193\uA7A0\uA77D\uA77E]/g},
    {'base':'H', 'letters':/[\u0048\u24BD\uFF28\u0124\u1E22\u1E26\u021E\u1E24\u1E28\u1E2A\u0126\u2C67\u2C75\uA78D]/g},
    {'base':'I', 'letters':/[\u0049\u24BE\uFF29\u00CC\u00CD\u00CE\u0128\u012A\u012C\u0130\u00CF\u1E2E\u1EC8\u01CF\u0208\u020A\u1ECA\u012E\u1E2C\u0197]/g},
    {'base':'J', 'letters':/[\u004A\u24BF\uFF2A\u0134\u0248]/g},
    {'base':'K', 'letters':/[\u004B\u24C0\uFF2B\u1E30\u01E8\u1E32\u0136\u1E34\u0198\u2C69\uA740\uA742\uA744\uA7A2]/g},
    {'base':'L', 'letters':/[\u004C\u24C1\uFF2C\u013F\u0139\u013D\u1E36\u1E38\u013B\u1E3C\u1E3A\u0141\u023D\u2C62\u2C60\uA748\uA746\uA780]/g},
    {'base':'LJ','letters':/[\u01C7]/g},
    {'base':'Lj','letters':/[\u01C8]/g},
    {'base':'M', 'letters':/[\u004D\u24C2\uFF2D\u1E3E\u1E40\u1E42\u2C6E\u019C]/g},
    {'base':'N', 'letters':/[\u004E\u24C3\uFF2E\u01F8\u0143\u00D1\u1E44\u0147\u1E46\u0145\u1E4A\u1E48\u0220\u019D\uA790\uA7A4]/g},
    {'base':'NJ','letters':/[\u01CA]/g},
    {'base':'Nj','letters':/[\u01CB]/g},
    {'base':'O', 'letters':/[\u004F\u24C4\uFF2F\u00D2\u00D3\u00D4\u1ED2\u1ED0\u1ED6\u1ED4\u00D5\u1E4C\u022C\u1E4E\u014C\u1E50\u1E52\u014E\u022E\u0230\u00D6\u022A\u1ECE\u0150\u01D1\u020C\u020E\u01A0\u1EDC\u1EDA\u1EE0\u1EDE\u1EE2\u1ECC\u1ED8\u01EA\u01EC\u00D8\u01FE\u0186\u019F\uA74A\uA74C]/g},
    {'base':'OI','letters':/[\u01A2]/g},
    {'base':'OO','letters':/[\uA74E]/g},
    {'base':'OU','letters':/[\u0222]/g},
    {'base':'P', 'letters':/[\u0050\u24C5\uFF30\u1E54\u1E56\u01A4\u2C63\uA750\uA752\uA754]/g},
    {'base':'Q', 'letters':/[\u0051\u24C6\uFF31\uA756\uA758\u024A]/g},
    {'base':'R', 'letters':/[\u0052\u24C7\uFF32\u0154\u1E58\u0158\u0210\u0212\u1E5A\u1E5C\u0156\u1E5E\u024C\u2C64\uA75A\uA7A6\uA782]/g},
    {'base':'S', 'letters':/[\u0053\u24C8\uFF33\u1E9E\u015A\u1E64\u015C\u1E60\u0160\u1E66\u1E62\u1E68\u0218\u015E\u2C7E\uA7A8\uA784]/g},
    {'base':'T', 'letters':/[\u0054\u24C9\uFF34\u1E6A\u0164\u1E6C\u021A\u0162\u1E70\u1E6E\u0166\u01AC\u01AE\u023E\uA786]/g},
    {'base':'TZ','letters':/[\uA728]/g},
    {'base':'U', 'letters':/[\u0055\u24CA\uFF35\u00D9\u00DA\u00DB\u0168\u1E78\u016A\u1E7A\u016C\u00DC\u01DB\u01D7\u01D5\u01D9\u1EE6\u016E\u0170\u01D3\u0214\u0216\u01AF\u1EEA\u1EE8\u1EEE\u1EEC\u1EF0\u1EE4\u1E72\u0172\u1E76\u1E74\u0244]/g},
    {'base':'V', 'letters':/[\u0056\u24CB\uFF36\u1E7C\u1E7E\u01B2\uA75E\u0245]/g},
    {'base':'VY','letters':/[\uA760]/g},
    {'base':'W', 'letters':/[\u0057\u24CC\uFF37\u1E80\u1E82\u0174\u1E86\u1E84\u1E88\u2C72]/g},
    {'base':'X', 'letters':/[\u0058\u24CD\uFF38\u1E8A\u1E8C]/g},
    {'base':'Y', 'letters':/[\u0059\u24CE\uFF39\u1EF2\u00DD\u0176\u1EF8\u0232\u1E8E\u0178\u1EF6\u1EF4\u01B3\u024E\u1EFE]/g},
    {'base':'Z', 'letters':/[\u005A\u24CF\uFF3A\u0179\u1E90\u017B\u017D\u1E92\u1E94\u01B5\u0224\u2C7F\u2C6B\uA762]/g},
    {'base':'a', 'letters':/[\u0061\u24D0\uFF41\u1E9A\u00E0\u00E1\u00E2\u1EA7\u1EA5\u1EAB\u1EA9\u00E3\u0101\u0103\u1EB1\u1EAF\u1EB5\u1EB3\u0227\u01E1\u00E4\u01DF\u1EA3\u00E5\u01FB\u01CE\u0201\u0203\u1EA1\u1EAD\u1EB7\u1E01\u0105\u2C65\u0250]/g},
    {'base':'aa','letters':/[\uA733]/g},
    {'base':'ae','letters':/[\u00E6\u01FD\u01E3]/g},
    {'base':'ao','letters':/[\uA735]/g},
    {'base':'au','letters':/[\uA737]/g},
    {'base':'av','letters':/[\uA739\uA73B]/g},
    {'base':'ay','letters':/[\uA73D]/g},
    {'base':'b', 'letters':/[\u0062\u24D1\uFF42\u1E03\u1E05\u1E07\u0180\u0183\u0253]/g},
    {'base':'c', 'letters':/[\u0063\u24D2\uFF43\u0107\u0109\u010B\u010D\u00E7\u1E09\u0188\u023C\uA73F\u2184]/g},
    {'base':'d', 'letters':/[\u0064\u24D3\uFF44\u1E0B\u010F\u1E0D\u1E11\u1E13\u1E0F\u0111\u018C\u0256\u0257\uA77A]/g},
    {'base':'dz','letters':/[\u01F3\u01C6]/g},
    {'base':'e', 'letters':/[\u0065\u24D4\uFF45\u00E8\u00E9\u00EA\u1EC1\u1EBF\u1EC5\u1EC3\u1EBD\u0113\u1E15\u1E17\u0115\u0117\u00EB\u1EBB\u011B\u0205\u0207\u1EB9\u1EC7\u0229\u1E1D\u0119\u1E19\u1E1B\u0247\u025B\u01DD]/g},
    {'base':'f', 'letters':/[\u0066\u24D5\uFF46\u1E1F\u0192\uA77C]/g},
    {'base':'g', 'letters':/[\u0067\u24D6\uFF47\u01F5\u011D\u1E21\u011F\u0121\u01E7\u0123\u01E5\u0260\uA7A1\u1D79\uA77F]/g},
    {'base':'h', 'letters':/[\u0068\u24D7\uFF48\u0125\u1E23\u1E27\u021F\u1E25\u1E29\u1E2B\u1E96\u0127\u2C68\u2C76\u0265]/g},
    {'base':'hv','letters':/[\u0195]/g},
    {'base':'i', 'letters':/[\u0069\u24D8\uFF49\u00EC\u00ED\u00EE\u0129\u012B\u012D\u00EF\u1E2F\u1EC9\u01D0\u0209\u020B\u1ECB\u012F\u1E2D\u0268\u0131]/g},
    {'base':'j', 'letters':/[\u006A\u24D9\uFF4A\u0135\u01F0\u0249]/g},
    {'base':'k', 'letters':/[\u006B\u24DA\uFF4B\u1E31\u01E9\u1E33\u0137\u1E35\u0199\u2C6A\uA741\uA743\uA745\uA7A3]/g},
    {'base':'l', 'letters':/[\u006C\u24DB\uFF4C\u0140\u013A\u013E\u1E37\u1E39\u013C\u1E3D\u1E3B\u017F\u0142\u019A\u026B\u2C61\uA749\uA781\uA747]/g},
    {'base':'lj','letters':/[\u01C9]/g},
    {'base':'m', 'letters':/[\u006D\u24DC\uFF4D\u1E3F\u1E41\u1E43\u0271\u026F]/g},
    {'base':'n', 'letters':/[\u006E\u24DD\uFF4E\u01F9\u0144\u00F1\u1E45\u0148\u1E47\u0146\u1E4B\u1E49\u019E\u0272\u0149\uA791\uA7A5]/g},
    {'base':'nj','letters':/[\u01CC]/g},
    {'base':'o', 'letters':/[\u006F\u24DE\uFF4F\u00F2\u00F3\u00F4\u1ED3\u1ED1\u1ED7\u1ED5\u00F5\u1E4D\u022D\u1E4F\u014D\u1E51\u1E53\u014F\u022F\u0231\u00F6\u022B\u1ECF\u0151\u01D2\u020D\u020F\u01A1\u1EDD\u1EDB\u1EE1\u1EDF\u1EE3\u1ECD\u1ED9\u01EB\u01ED\u00F8\u01FF\u0254\uA74B\uA74D\u0275]/g},
    {'base':'oi','letters':/[\u01A3]/g},
    {'base':'ou','letters':/[\u0223]/g},
    {'base':'oo','letters':/[\uA74F]/g},
    {'base':'p','letters':/[\u0070\u24DF\uFF50\u1E55\u1E57\u01A5\u1D7D\uA751\uA753\uA755]/g},
    {'base':'q','letters':/[\u0071\u24E0\uFF51\u024B\uA757\uA759]/g},
    {'base':'r','letters':/[\u0072\u24E1\uFF52\u0155\u1E59\u0159\u0211\u0213\u1E5B\u1E5D\u0157\u1E5F\u024D\u027D\uA75B\uA7A7\uA783]/g},
    {'base':'s','letters':/[\u0073\u24E2\uFF53\u00DF\u015B\u1E65\u015D\u1E61\u0161\u1E67\u1E63\u1E69\u0219\u015F\u023F\uA7A9\uA785\u1E9B]/g},
    {'base':'t','letters':/[\u0074\u24E3\uFF54\u1E6B\u1E97\u0165\u1E6D\u021B\u0163\u1E71\u1E6F\u0167\u01AD\u0288\u2C66\uA787]/g},
    {'base':'tz','letters':/[\uA729]/g},
    {'base':'u','letters':/[\u0075\u24E4\uFF55\u00F9\u00FA\u00FB\u0169\u1E79\u016B\u1E7B\u016D\u00FC\u01DC\u01D8\u01D6\u01DA\u1EE7\u016F\u0171\u01D4\u0215\u0217\u01B0\u1EEB\u1EE9\u1EEF\u1EED\u1EF1\u1EE5\u1E73\u0173\u1E77\u1E75\u0289]/g},
    {'base':'v','letters':/[\u0076\u24E5\uFF56\u1E7D\u1E7F\u028B\uA75F\u028C]/g},
    {'base':'vy','letters':/[\uA761]/g},
    {'base':'w','letters':/[\u0077\u24E6\uFF57\u1E81\u1E83\u0175\u1E87\u1E85\u1E98\u1E89\u2C73]/g},
    {'base':'x','letters':/[\u0078\u24E7\uFF58\u1E8B\u1E8D]/g},
    {'base':'y','letters':/[\u0079\u24E8\uFF59\u1EF3\u00FD\u0177\u1EF9\u0233\u1E8F\u00FF\u1EF7\u1E99\u1EF5\u01B4\u024F\u1EFF]/g},
    {'base':'z','letters':/[\u007A\u24E9\uFF5A\u017A\u1E91\u017C\u017E\u1E93\u1E95\u01B6\u0225\u0240\u2C6C\uA763]/g}
];
var changes;
function removeDiacritics (str) {
    if(!changes) {
        changes = defaultDiacriticsRemovalMap;
    }
    for(var i=0; i<changes.length; i++) {
        str = str.replace(changes[i].letters, changes[i].base);
    }
    return str;
}

return removeDiacritics;
})()

if(typeof exports !== "undefined"){
    exports.removeDiacritics = removeDiacritics    
}

function levenshtein( a, b )
{
	var i;
	var j;
	var cost;
	var d = new Array();
 
	if ( a.length == 0 )
	{
		return b.length;
	}
 
	if ( b.length == 0 )
	{
		return a.length;
	}
 
	for ( i = 0; i <= a.length; i++ )
	{
		d[ i ] = new Array();
		d[ i ][ 0 ] = i;
	}
 
	for ( j = 0; j <= b.length; j++ )
	{
		d[ 0 ][ j ] = j;
	}
 
	for ( i = 1; i <= a.length; i++ )
	{
		for ( j = 1; j <= b.length; j++ )
		{
			if ( a.charAt( i - 1 ) == b.charAt( j - 1 ) )
			{
				cost = 0;
			}
			else
			{
				cost = 1;
			}
 
			d[ i ][ j ] = Math.min( d[ i - 1 ][ j ] + 1, d[ i ][ j - 1 ] + 1, d[ i - 1 ][ j - 1 ] + cost );
			
			if(
         i > 1 && 
         j > 1 &&  
         a.charAt(i - 1) == b.charAt(j-2) && 
         a.charAt(i-2) == b.charAt(j-1)
         ){
          d[i][j] = Math.min(
            d[i][j],
            d[i - 2][j - 2] + cost
          )
         
			}
		}
	}
 
	return d[ a.length ][ b.length ];
}

if(typeof exports !== "undefined"){
    exports.levenshtein = levenshtein    
}
// Porter stemmer in Javascript. Few comments, but it's easy to follow against the rules in the original
// paper, in
//
//  Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
//  no. 3, pp 130-137,
//
// see also http://www.tartarus.org/~martin/PorterStemmer

// Release 1
// Derived from (http://tartarus.org/~martin/PorterStemmer/js.txt) - cjm (iizuu) Aug 24, 2009

PorterStemmer = (function(){
	var step2list = {
			"ational" : "ate",
			"tional" : "tion",
			"enci" : "ence",
			"anci" : "ance",
			"izer" : "ize",
			"bli" : "ble",
			"alli" : "al",
			"entli" : "ent",
			"eli" : "e",
			"ousli" : "ous",
			"ization" : "ize",
			"ation" : "ate",
			"ator" : "ate",
			"alism" : "al",
			"iveness" : "ive",
			"fulness" : "ful",
			"ousness" : "ous",
			"aliti" : "al",
			"iviti" : "ive",
			"biliti" : "ble",
			"logi" : "log"
		},

		step3list = {
			"icate" : "ic",
			"ative" : "",
			"alize" : "al",
			"iciti" : "ic",
			"ical" : "ic",
			"ful" : "",
			"ness" : ""
		},

		c = "[^aeiou]",          // consonant
		v = "[aeiouy]",          // vowel
		C = c + "[^aeiouy]*",    // consonant sequence
		V = v + "[aeiou]*",      // vowel sequence

		mgr0 = "^(" + C + ")?" + V + C,               // [C]VC... is m>0
		meq1 = "^(" + C + ")?" + V + C + "(" + V + ")?$",  // [C]VC[V] is m=1
		mgr1 = "^(" + C + ")?" + V + C + V + C,       // [C]VCVC... is m>1
		s_v = "^(" + C + ")?" + v;                   // vowel in stem

	return function (w) {
		var 	stem,
			suffix,
			firstch,
			re,
			re2,
			re3,
			re4,
			origword = w;

		if (w.length < 3) { return w; }

		firstch = w.substr(0,1);
		if (firstch == "y") {
			w = firstch.toUpperCase() + w.substr(1);
		}

		// Step 1a
		re = /^(.+?)(ss|i)es$/;
		re2 = /^(.+?)([^s])s$/;

		if (re.test(w)) { w = w.replace(re,"$1$2"); }
		else if (re2.test(w)) {	w = w.replace(re2,"$1$2"); }

		// Step 1b
		re = /^(.+?)eed$/;
		re2 = /^(.+?)(ed|ing)$/;
		if (re.test(w)) {
			var fp = re.exec(w);
			re = new RegExp(mgr0);
			if (re.test(fp[1])) {
				re = /.$/;
				w = w.replace(re,"");
			}
		} else if (re2.test(w)) {
			var fp = re2.exec(w);
			stem = fp[1];
			re2 = new RegExp(s_v);
			if (re2.test(stem)) {
				w = stem;
				re2 = /(at|bl|iz)$/;
				re3 = new RegExp("([^aeiouylsz])\\1$");
				re4 = new RegExp("^" + C + v + "[^aeiouwxy]$");
				if (re2.test(w)) { w = w + "e"; }
				else if (re3.test(w)) { re = /.$/; w = w.replace(re,""); }
				else if (re4.test(w)) { w = w + "e"; }
			}
		}

		// Step 1c
	        re = new RegExp("^(.+" + c + ")y$");
		    if (re.test(w)) {
			var fp = re.exec(w);
			stem = fp[1];
		    w = stem + "i";
		}

		// Step 2
		re = /^(.+?)(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$/;
		if (re.test(w)) {
			var fp = re.exec(w);
			stem = fp[1];
			suffix = fp[2];
			re = new RegExp(mgr0);
			if (re.test(stem)) {
				w = stem + step2list[suffix];
			}
		}

		// Step 3
		re = /^(.+?)(icate|ative|alize|iciti|ical|ful|ness)$/;
		if (re.test(w)) {
			var fp = re.exec(w);
			stem = fp[1];
			suffix = fp[2];
			re = new RegExp(mgr0);
			if (re.test(stem)) {
				w = stem + step3list[suffix];
			}
		}

		// Step 4
		re = /^(.+?)(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$/;
		re2 = /^(.+?)(s|t)(ion)$/;
		if (re.test(w)) {
			var fp = re.exec(w);
			stem = fp[1];
			re = new RegExp(mgr1);
			if (re.test(stem)) {
				w = stem;
			}
		} else if (re2.test(w)) {
			var fp = re2.exec(w);
			stem = fp[1] + fp[2];
			re2 = new RegExp(mgr1);
			if (re2.test(stem)) {
				w = stem;
			}
		}

		// Step 5
		re = /^(.+?)e$/;
		if (re.test(w)) {
			var fp = re.exec(w);
			stem = fp[1];
			re = new RegExp(mgr1);
			re2 = new RegExp(meq1);
			re3 = new RegExp("^" + C + v + "[^aeiouwxy]$");
			if (re.test(stem) || (re2.test(stem) && !(re3.test(stem)))) {
				w = stem;
			}
		}

		re = /ll$/;
		re2 = new RegExp(mgr1);
		if (re.test(w) && re2.test(w)) {
			re = /.$/;
			w = w.replace(re,"");
		}

		// and turn initial Y back to y

		if (firstch == "y") {
			w = firstch.toLowerCase() + w.substr(1);
		}

	    // See http://snowball.tartarus.org/algorithms/english/stemmer.html
	    // "Exceptional forms in general"
	    var specialWords = {
	    	"skis" : "ski",
	    	"skies" : "sky",
	    	"dying" : "die",
	    	"lying" : "lie",
	    	"tying" : "tie",
	    	"idly" : "idl",
	    	"gently" : "gentl",
	    	"ugly" : "ugli",
	    	"early": "earli",
	    	"only": "onli",
	    	"singly": "singl"
	    };

	    if(specialWords[origword]){
	    	w = specialWords[origword];
	    }

	    if( "sky news howe atlas cosmos bias \
	    	 andes inning outing canning herring \
	    	 earring proceed exceed succeed".indexOf(origword) !== -1 ){
	    	w = origword;
	    }

	    // Address words overstemmed as gener-
	    re = /.*generate?s?d?(ing)?$/;
	    if( re.test(origword) ){
		w = w + 'at';
	    }
	    re = /.*general(ly)?$/;
	    if( re.test(origword) ){
		w = w + 'al';
	    }
	    re = /.*generic(ally)?$/;
	    if( re.test(origword) ){
		w = w + 'ic';
	    }
	    re = /.*generous(ly)?$/;
	    if( re.test(origword) ){
		w = w + 'ous';
	    }
	    // Address words overstemmed as commun-
	    re = /.*communit(ies)?y?/;
	    if( re.test(origword) ){
		w = w + 'iti';
	    }

	    return w;
	}
})();

if(typeof exports !== "undefined"){
    exports.stemmer = PorterStemmer
}

var SyllableCounter;

SyllableCounter = function(word) {
  var add, addSyllables, count, fix, part, prefixSuffix, problemWords, sub, subSyllables, tmp, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref;
  word = word.toLowerCase().replace(/[^a-z]/g, '');
  problemWords = {
    simile: 3,
    forever: 3,
    shoreline: 2
  };
  if (word in problemWords) {
    return problemWords[word];
  }
  prefixSuffix = [/^un/, /^fore/, /ly$/, /less$/, /ful$/, /ers?$/, /ings?$/];
  count = 0;
  for (_i = 0, _len = prefixSuffix.length; _i < _len; _i++) {
    fix = prefixSuffix[_i];
    tmp = word.replace(fix, '');
    if (tmp !== word) {
      count++;
    }
    word = tmp;
  }
  subSyllables = [/cial/, /tia/, /cius/, /cious/, /giu/, /ion/, /iou/, /sia$/, /[^aeiuoyt]{2,}ed$/, /.ely$/, /[cg]h?e[rsd]?$/, /rved?$/, /[aeiouy][dt]es?$/, /[aeiouy][^aeiouydt]e[rsd]?$/, /^[dr]e[aeiou][^aeiou]+$/, /[aeiouy]rse$/];
  addSyllables = [/ia/, /riet/, /dien/, /iu/, /io/, /ii/, /[aeiouym]bl$/, /[aeiou]{3}/, /^mc/, /ism$/, /([^aeiouy])\1l$/, /[^l]lien/, /^coa[dglx]./, /[^gq]ua[^auieo]/, /dnt$/, /uity$/, /ie(r|st)$/];
  _ref = word.split(/[^aeiouy]+/);
  for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
    part = _ref[_j];
    if (part !== '') {
      count++;
    }
  }
  for (_k = 0, _len2 = subSyllables.length; _k < _len2; _k++) {
    sub = subSyllables[_k];
    count -= word.split(sub).length - 1;
  }
  for (_l = 0, _len3 = addSyllables.length; _l < _len3; _l++) {
    add = addSyllables[_l];
    count += word.split(add).length - 1;
  }
  return Math.max(1, count);
};

if (typeof exports !== "undefined" && exports !== null) {
  exports.syllables = SyllableCounter;
}

var __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(function() {
  var advancedCompare, checkAnswer, checkWord, isPerson, levens, log, parseAnswer, rawCompare, reduceAlphabet, reduceLetter, replaceNumber, safeCheckAnswer, splitWords, stem, stopnames, stopwords;
  stopwords = "derp rofl lmao lawl lole lol the prompt on of is a in on that have for at so it do or de y by accept any and".split(' ');
  stopnames = "ivan james john robert michael william david richard charles joseph thomas christopher daniel paul mark donald george steven edward brian ronald anthony kevin jason benjamin mary patricia linda barbara elizabeth jennifer maria susan margaret dorothy lisa karen henry harold luke matthew";
  log = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (exports.log) {
      return exports.log.apply(exports, args);
    }
  };
  parseAnswer = function(answer) {
    var clean, comp, neg, part, pos, _i, _len;
    answer = answer.replace(/[\[\]\<\>\{\}][\w\-]+?[\[\]\<\>\{\}]/g, '');
    clean = (function() {
      var _i, _len, _ref, _results;
      _ref = answer.split(/[^\w]or[^\w]|\[|\]|\{|\}|\;|\,|\<|\>|\(|\)/g);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        part = _ref[_i];
        _results.push(part.trim());
      }
      return _results;
    })();
    clean = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = clean.length; _i < _len; _i++) {
        part = clean[_i];
        if (part !== '') {
          _results.push(part);
        }
      }
      return _results;
    })();
    pos = [];
    neg = [];
    for (_i = 0, _len = clean.length; _i < _len; _i++) {
      part = clean[_i];
      part = removeDiacritics(part);
      part = part.replace(/\"|\'|\“|\”|\.|’|\:/g, '');
      part = part.replace(/-/g, ' ');
      if (/equivalent|word form|other wrong/.test(part)) {

      } else if (/do not|dont/.test(part)) {
        neg.push(part);
      } else if (/accept/.test(part)) {
        comp = part.split(/before|until/);
        if (comp.length > 1) {
          neg.push(comp[1]);
        }
        pos.push(comp[0]);
      } else {
        pos.push(part);
      }
    }
    return [pos, neg];
  };
  replaceNumber = function(word) {
    if (/\d+nd/.test(word) || /\d+st/.test(word)) {
      return parseInt(word, 10);
    }
    if (word === 'zero' || word === 'zeroeth' || word === 'zeroth') {
      return 0;
    }
    if (word === 'one' || word === 'first' || word === 'i') {
      return 1;
    }
    if (word === 'two' || word === 'second' || word === 'twoth' || word === 'ii') {
      return 2;
    }
    if (word === 'three' || word === 'third' || word === 'turd' || word === 'iii' || word === 'iiv') {
      return 3;
    }
    if (word === 'forth' || word === 'fourth' || word === 'four' || word === 'iiii' || word === 'iv') {
      return 4;
    }
    if (word === 'fifth' || word === 'five' || word === 'v') {
      return 5;
    }
    if (word === 'sixth' || word === 'six' || word === 'vi' || word === 'emacs') {
      return 6;
    }
    if (word === 'seventh' || word === 'seven' || word === 'vii') {
      return 7;
    }
    if (word === 'eight' || word === 'eighth' || word === 'viii' || word === 'iix') {
      return 8;
    }
    if (word === 'nine' || word === 'nein' || word === 'ninth' || word === 'ix' || word === 'viiii') {
      return 9;
    }
    if (word === 'tenth' || word === 'ten' || word === 'x') {
      return 10;
    }
    if (word === 'eleventh' || word === 'eleven' || word === 'xi') {
      return 11;
    }
    if (word === 'twelfth' || word === 'twelveth' || word === 'twelve' || word === 'xii') {
      return 12;
    }
    if (word === 'thirteenth' || word === 'thirteen' || word === 'xiii' || word === 'iixv') {
      return 13;
    }
    if (word === 'fourteenth' || word === 'fourteen' || word === 'ixv' || word === 'xiiii') {
      return 14;
    }
    return word;
  };
  stem = function(word) {
    return PorterStemmer(word.replace(/ez$/g, 'es').replace(/[^\w]/g, ''));
  };
  splitWords = function(text) {
    var arr, word, words;
    arr = (function() {
      var _i, _len, _ref, _results;
      _ref = text.toLowerCase().split(/\s+/);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        word = _ref[_i];
        _results.push(word.trim());
      }
      return _results;
    })();
    words = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arr.length; _i < _len; _i++) {
        word = arr[_i];
        if (__indexOf.call(stopwords, word) < 0 && word !== '') {
          _results.push(stem(word));
        }
      }
      return _results;
    })();
    return words;
  };
  isPerson = function(answer) {
    var canon, caps, name;
    canon = (function() {
      var _i, _len, _ref, _results;
      _ref = answer.split(/\s+/);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        if (name.length > 3) {
          _results.push(name);
        }
      }
      return _results;
    })();
    caps = (function() {
      var _i, _len, _ref, _results;
      _results = [];
      for (_i = 0, _len = canon.length; _i < _len; _i++) {
        name = canon[_i];
        if (("A" <= (_ref = name[0]) && _ref <= "Z")) {
          _results.push(name);
        }
      }
      return _results;
    })();
    return caps.length === canon.length;
  };
  reduceLetter = function(letter) {
    if (letter === 'z' || letter === 's' || letter === 'k' || letter === 'c') {
      return 's';
    }
    if (letter === 'e' || letter === 'a' || letter === 'o' || letter === 'u' || letter === 'y' || letter === 'i') {
      return 'e';
    }
    return letter;
  };
  reduceAlphabet = function(word) {
    var letter, letters;
    letters = (function() {
      var _i, _len, _ref, _results;
      _ref = word.split('');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        letter = _ref[_i];
        _results.push(reduceLetter(letter));
      }
      return _results;
    })();
    return letters.join('');
  };
  levens = function(a, b) {
    return damlev(reduceAlphabet(a), reduceAlphabet(b));
  };
  checkWord = function(word, list) {
    var frac, len, real, score, scores, valid, _ref;
    scores = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        valid = list[_i];
        score = levens(valid, word);
        _results.push([score, valid.length - score, valid.length, valid]);
      }
      return _results;
    })();
    if (scores.length === 0) {
      return '';
    }
    scores = scores.sort(function(a, b) {
      return a[0] - b[0];
    });
    _ref = scores[0], score = _ref[0], real = _ref[1], len = _ref[2], valid = _ref[3];
    frac = real / len;
    log(word, valid, list, len, score, frac);
    if (len > 4) {
      if (frac >= 0.65) {
        return valid;
      }
    } else {
      if (frac >= 0.60) {
        return valid;
      }
    }
    return '';
  };
  advancedCompare = function(inputText, p, questionWords) {
    var invalid_count, is_person, list, result, valid_count, value, word, _i, _len;
    is_person = isPerson(p.trim());
    list = (function() {
      var _i, _len, _ref, _results;
      _ref = splitWords(p);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        word = _ref[_i];
        if (__indexOf.call(questionWords, word) < 0) {
          _results.push(word);
        }
      }
      return _results;
    })();
    valid_count = 0;
    invalid_count = 0;
    for (_i = 0, _len = inputText.length; _i < _len; _i++) {
      word = inputText[_i];
      value = 1;
      result = checkWord(word, list);
      if (is_person && __indexOf.call(stopnames, result) >= 0 && __indexOf.call(list, 'gospel') < 0) {
        value = 0.5;
      }
      if (result) {
        valid_count += value;
      } else {
        invalid_count += value;
      }
    }
    log("ADVANCED", valid_count, invalid_count, inputText.length);
    return valid_count - invalid_count >= 1;
  };
  rawCompare = function(compare, p) {
    var accuracy, diff, minlen;
    compare = compare.toLowerCase().replace(/[^\w]/g, '');
    p = p.toLowerCase().replace(/[^\w]/g, '');
    minlen = Math.min(compare.length, p.length);
    diff = levens(compare.slice(0, minlen), p.slice(0, minlen));
    accuracy = 1 - (diff / minlen);
    log("RAW LEVENSHTEIN", diff, minlen, accuracy);
    if (minlen >= 4 && accuracy >= 0.70) {
      return "prompt";
    }
    return false;
  };
  checkAnswer = function(compare, answer, question) {
    var compyr, inputText, neg, p, pos, questionWords, word, year, _i, _len, _ref;
    if (question == null) {
      question = '';
    }
    log('---------------------------');
    question = removeDiacritics(question).trim();
    answer = removeDiacritics(answer).trim();
    compare = removeDiacritics(compare).trim();
    questionWords = splitWords(question);
    inputText = (function() {
      var _i, _len, _ref, _results;
      _ref = splitWords(compare);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        word = _ref[_i];
        if (__indexOf.call(questionWords, word) < 0) {
          _results.push(word);
        }
      }
      return _results;
    })();
    _ref = parseAnswer(answer.trim()), pos = _ref[0], neg = _ref[1];
    log("ACCEPT", pos, "REJECT", neg);
    for (_i = 0, _len = pos.length; _i < _len; _i++) {
      p = pos[_i];
      if (compare.replace(/[^0-9]/g, '').length === 4) {
        year = compare.replace(/[^0-9]/g, '');
        compyr = p.replace(/[^0-9]/g, '');
        log("YEAR COMPARE", year, compyr);
        if (year === compyr) {
          return true;
        }
      } else {
        if (advancedCompare(inputText, p, questionWords)) {
          return true;
        }
        if (rawCompare(compare, p)) {
          return true;
        }
      }
    }
    return false;
  };
  safeCheckAnswer = function(compare, answer, question) {
    try {
      return checkAnswer(compare, answer, question);
    } catch (error) {
      log("ERROR", error);
      return false;
    }
  };
  stopnames = splitWords(stopnames);
  if (typeof exports !== "undefined" && exports !== null) {
    exports.checkAnswer = safeCheckAnswer;
    return exports.parseAnswer = parseAnswer;
  }
})();

//Ah you think loneliness is your ally? 
//You merely adopted the lonely. I was born in it, molded by it. 
//I didn't see a friend until I was already a man, by then it was nothing to me but boring! 

//omegle bot (condensed)

// a shorter version of http://antimatter15.com/misc/botchat.html

//var zed={};Object.keys(replies).filter(function(e){return /^[a-z\? ]+$/i.test(e) && replies[e].length > 20}).forEach(function(e){zed[e.replace(/[^a-z]/g,'')] = replies[e].filter(function(e){return e.length < 30 && e.trim().length > 1})});JSON.stringify(zed).length

omeglebot_replies = {"hello":["whats up?","in the HELL","hi","goodbye","asl","YES!","what first?","hold on","I'm a fucking","in the war","20 male china","No no","i did live in texas","howdy","whats weird haha","fuck you ","420?","sup?","whats up","ah ok","come on","AARON CARTER IS BACK.","whats ur beleif with religion","HEY","Hello.","ok","tell yo mama come","your email?","gracias","hihihihihihihihihi","asl!!!","bye","how r u?","bend it like???","hi.","huh?","this life is","not yet","i win","ASL?","Hey, Asl?","do you belive?","of Christ?","are you?","GOOD-BYE","no","I am a salamander","hello","heey","watsup?","yo","F/M?","you hobby","secks","Nederlands","add me","It's very kind of you","hoii","I will be back.","alohsa","nice try","bye bye bye","please your introduce","weare your from","You're weird.","hai is japanese for yes","you dont understand what?","lol, me too","no asl","hi again","So i lost?^^","hi ^^","you are girl?","heeeeeeeeeeeeeeey","really?","bye?","hi?","Whats a paraquite?","ola","wanna see my cock","im a horn dog","uh?","dont hang up","Where do you learn this word?","whatt ?","how's it ","heey :D","i g2g now","oink oink","Oh cooollll","m or f?","wanna have sex?","yes?","honestly lol else?","hi!","you","haha fuck","Not sure I can either","mean","yes urs","exactly","HOLY SHIT","how are you?","or boy?","fair enough","jerk","fat?","????????? spian","moi <3","icuaatro","you get shit","honestly..","0 0","ILLGIVE YOU A BEAT","WHAT THE FUCK","moi","oh ","hai","HEEEE'","the world is urs","hi pindick","wats up","hello. asl?","sup","uk?","now what?","what?","and i dont forget","from ?","i a chistian      ","fffffffffffffffffffff","the land of the asians.      ","haha, wanna dirty talk?",":)      ","im curious thx"],"nothing":["same here","I'M A GUY WHO LIOVES GUYS","hi","that didn't even make sense","No.","Maybe.","face","huh?","every thing","i am nothig without you","not much","that was good","u China","You needn't know my age","i win","I hate mexico","Bend It Lick Bheckam.","where are u from?","no i love my gf","ok","please dont be asian","you just said god damn","but i'm not good at ENGLISH","Nothing?","why","absolutely nothing","ever happens","you !","years old","Seriously.","asl","im horny","nice english lol","f or m ?","nope","i think nothing alla time","ESTAS CONTENTO????!!!!","u know everything","noting ","you love your ass?","i like it","and what???","Or","no","que?","so you're human","and that means?","ah ok","was cool playing with you","japan","so","what?","bored as shit","im going to disconnect","NAZI","asl?","nothing","im just an old dude being gay","who?","bitches"],"metoo":["lol","so","ok","OMGF","Oh god","my dick measured 8.0\"","cause it's hairless","thats why im on here","from?","how old are you","IM TURKISH","ok...bye...boy.","i usually to someone though","and abusif sex","yuiop","oot em","http://tinyurl.com/24xkna","no","good","i asked u where are you from?","23 m korea","asl?","but","lolz ?","cool","something about what DEAR??","hi","alright","hi there?","o rly?","mothafucker china","slut","whos there?","and on the third date finally","send?","it's a highway","and you?","huh?","so you are not john conner?","ruck me all night long","ha!","what???"," i hate you","i hate those","No me","thanks","hola?","hey ;p","And what about you?","oh","meow","i'm a boy","zzz","bye","um.....","and im wet.","sweet.","å“ªé‡Œäººï¼Ÿ","can I see your pussy?"],"lol":["where from?",":|","me","passing some time","for somebody who is bored","k...",":D","i like men","XUTOS CRL","*in","thin","I want you to book it!","go ahead","keep going","so","lol","else","say smth new","interesting","well done","are you a girl?","horny ","are you a bi male?","So am I","why r u so gay?","okay","if you want to sex","why","why u lol","??","your name?","hehe","is*","and ya","*smiles nervously*","you lose","Boring","no","bye bye","are you ready?","I do not like man","im not gay","what?","Shirley","secks?","bye-bye :D","how do you feel about ...","and you?","great win","what ever you say","were are you NOT from","do it","yes","random","laughing quietly","Sup","about which statement?","AND SCENE","you america's next top model","china","hello","do you have aspergers?","you lookin at me?","alright little wierd","you're sick","Nude prefferebly","Or are you a mop?","17 F...","no,i have no ass","???","              fuck u ","r u a male or female","hi","Do not tell you","GOODBEY","what","im from mexico","you sound fine tho","i totally agree","Finger?","heyy","so asl","I am fine, thank you.","well for a weekday","XD","HAI","a/s/l.","hiho","cock","haha","sorry","funk","what?......","Well, bye.","Looks like i win","noob","male","/////","instant","i mean","_|_","i have to go , ","u i rydhgbnf","?>","teeny weenie","mdr","how are u","alright i give up","SAY SOMETHING","=)","swedish=","swedish?","your femal","u r gay","asl..?","so whats ur asl?","hey","from","i want your nipples","wtf ? :D","oh","what contry?","I SAID NO OMG THE AGONY","CHINA IS A BIG PLACE","16 f taiwan","age_?","where are you from?","hi.","come on,baby","man","je hoofd","u fat perv","not lol","asl? x","but how old are you?","SUCKMAHWANG.","was man","ohhhhhhhhhhhhhh","god get out","Sorry.","you want to save me ?","the duck","ok","u do?","please don't be weird","cock?","no lol","r you male?","hi^^","can i see you ?","lies","^^","vice versa","xP","lol, johnny, so funny!","you ?","I wasn't including you!","<:(","What's funny?","yeah bye","are you a guy or a girl?","loski","well depends","=,,=","I was in North Korea","leona lewis?","are you a bot?","u a faget","1033110","fqmv","ok then cunt come get me","nice to me you",":P","are you a homophobe?","and nineteen","17 female","are you a socialist?","shur hun for u","lmao","idk","it's not that funny","o rly?","`?","heippa","im tired","wanna blow?","closes","you again","pull of heads","16 f and wanna blow???","y?","and u?","enough already","No lol.","I wanna fuck your ass now","u?","were are you from?","umm","okay perv, I dont have tits","you don't know","sup loser","asl?","hello!","imma fappin","Stranger","but only on cereal","Mr Wonka?","whoa hold","But semi nude is okay too","WHAT THE FUUUCK","fuck","EW FUCK YOU ","N!GGE p","Like that :D","lily","boy or gurl","im not small",":)","i can what","u r a bitch","f/m?","i see","21 old~","you laughing at me?","i am raping it","Stranger: wo cao nima","all the time","mas tudo bem","sn nerelisin ?","GET","in turn who r u","Hi!","it","You said f","BUTTS","that meant Lots of love btw","F1","england","watsup?","He certainly is","jk","but i like","naturally","la la","i luv pussy ","oh,where are you?","i am a lover of asses","what is v","yes u are...","they use ke in italy","22 m uk ","i dont know what your saying","Just gibberish :D","Unique.","queer","male?","are you sure?","I ^ ^ great Chinese Chinese","-0-","^-^","the gods have abanoned me","heello","i like soup","Are you Japanese?","you are funny","ã…‹ã„·","Kalol?","give me your MSN","ë§í•´","Yer crazy","david, is that you?","Stranger is typing...","weird","hohohoo","i get it","sonnie","get fuck the out g","good weed","  nothing, just a chat ","so finally falling in love...","the rasmus",":S","How can you tell?","what u on?","Are you listening to music?","I'm blind and deaf","FALCON PUNCH!","It prevents teenage pregnacy.","wasabi","yez im god!","i just give peo[le headaches","yaa :(","sgb","Do u know Juhannus?","what's that","penny for ur thoughts","what is your fav. colour?","you?","lol is evil","me too actually","blue","4chan ;D","k so asl?"],"whereareyoufrom":["m or f","you first","canada!","hi","go on","cali","from japan","u first","u?  chinese?","uhh","cojones","you introduce","im god","its spelles aunt","age?","brazil","I'm so curiousa","norway","nono","ANTARCTICA","im from the south","i love my gf","male or female?","so where are u from","what do u mean lady","LOQ","im pretty damn straight ","i asked first","why do you think you know me?","from fomosse","\\tx","China","FINLAND","the US","you?","Fuuuckfaceland","ireland(:"],"cool":["boy? girl?","you?","Smurf*","i love you","wo cao nima","excuse me mister","when and where?","your penis into my pussy","are you growling at me?","you  come from ",":)","you have inspired me","Hey","SOME MUCH.","<3333333333333333","asl?","fine ,thank u ,and u?","ye","YES!","hi","so do i","uh nope","then I am","TELL UR GURLS","cool","and how old are you?","wath are your say ?","17 boy from earth","u r a pair of pants","gay boy?","bye slut","bye slut ..say bye asshole","for what","THATS RACIST","anyways","sdas","I ASKED YOU.","rio de janeiro","i hope you'll like Dis:","u ok","indeed","thanks","ola","are you a Volturi?","I'm Brasilian.","ok","You can do a joke","got any friskies?","just for fun","u?","Pizza"," ass ?","I AM?","hey :)","im 14 u?","im tired","bye!","any pussy ","Lick?","cunt","You are in North Korea?","EPIC","and u?","thank u","what","but u r  lie","you ?","fuck you?","are you a student?","noot really.","umm"],"boygirl":["boy","girl","hi","BOY CRL","i'm  20 M","ur a fat beaner?","BUTTS","Smurg","what?","17 f florida","14 years?","wat r u","can you speak Chinese?","Boy.","ok","m 25 india","u dont understand english","Girl. U?","i'm a guy","bye :)","heya","did you see that video?","both","asl?","hairy pussy","fuck off you weirdo","hello?","r u the lesbian","Shit is great","were you nailed","lol","Goodmorning."],"i":["ola","cyber?","asl?","boy","normal","Europe","hello","madrid","SKAHFASDHFAIHSDFHA","and","hi","how r u","hei","woman or man?","eu sei de onde tu vem hahaha","how ar eyou","what doyou say","HAI","OKay.","so asl","yup","hi~","um","ass shit dick fuck","f/22/usa","bye!","shit","hey","sd?","do you speak english?","me either","why are you such a tuna cunt","talk","fine?","i don't need anyone","didnt we already cover this?","uh boooooo","f or m","from","rule the word?","word","ok","HI NIGGAH","???","i mean","i had a good thing going","get the fuck out","raawwrr","arigato","i am not a pedophile","add me","Do not tell you","nope","how r y?","hi .","lol","man ?","russian boy","tomorrow","asl","passing some time","cool","what","Gordon Brown","hui","hellllllo","thats not good","there","how are u?","16 f uk","or a catscan?","me too!!!!!!","i can't either","where are you from?","is awesome ","??","how is it today...","but I don't hate jew","la la","how u doin sewwt thing","stranger","are you a socialist?","hitler...","/b/","spring brother is pure man","sup","wait YOU LIE","ah ok","Tell me, do you hate niggers?","i do love me some ass","47/m/connecticut","i am Vitality","fail","...","like what=?","My sisters are my children","i'm gay","= =","simply awful"," okay","winb",":P","it sucked","fron","sexy ","wath?","hum..","is anyone there","then i ll tell u","i from beasli","I'm Petra, 16 from UK you","loli is good","what from??","you ,30 woman?","Hello.","heyy(:","yes","me too","bye","hello there?","herro.","i suppose","DOESN'T MATTER","Finland?","How do you feel like today","helo"," hi","nausea to me","Herro",":)","wanna see my cock","where are you from","fat?","u?","how are you?","what's your name..?","ATJO","a tool?","hi what","you are playing me","hello'","china","YOU'RE HILARIOUS.","good","where thaksin was PM","that asshole","where you live?","bitch","hi!","....","mag ficken dich?","i hope","Hello)","i am not","hillo","that's new to me","are you a lesbian?",";;","just for fun","alles goed?","from?","no, i know","shall we stop with it?","what your name","no\\","another question","hmmmmm","hi :)","ur asl?","single","awesome","age?","4 11","dimelo","como?","ji","hey!~","on omegle","you?","what your major","m or f?","yes!!","hi ^^","how ar you","e...","Know what?","my head want to talk to you"," KINOSTI!!11","ur high?","whats wrong with u???","do you fuck ?","gender ?","1or 0","dont know why ^^","who?","0.06","Hi.","just a few","to omegle?","hi what?","are you man ?","Ello","seems cool","heey","22 m london","What's funny?","nice","ciao","cool then","4 11?","WHERE ARE YOU FROM?????","in the butt","hello nice to meet you ","What are they afraid of","Does not understand","hmm","hello   hehe ","teeny weenie"," Taiwan","14","honestly..","wird","i'm a killer","i think this is stupid","lets be professional","knock knock","heyhey","17 f usa","fuck u too","how are you","helllo","what the fcukk.??","you are a computer","the sky","sup?","party","sorru","hi :'D","sd","oh","nihao ","in english?","think","I'm Dutch","carnaval is music","where are u from ?","i cant understand","No","where u live?","die","what turn","really","bye.","u type fast","melbourne","what are you talking about?","Hello again, #12.","knockknock","Hi stranger","now i say it again","Sieg Heil!","democrat","als?","Why should I say?","Not true.","male?","16 m portugal","what is wrong","pussy","yeay.","are","cunt","unlike all the rest","why?","correction","are you Asian or what?","Do you like poop?","bipolar much?","yeah!","i am very hungry","not?","Hello there","haha","Tell me","porque","what?","i'm a bit bored","what is rot?","so what the hell man?","hi PETER","What the fuck ever","age sex location","germany.","MMMM YUMM","the cia is watching us","you doing drugs or what?","ok...bye...boy.","hihihi","are you?","do you?","why does god hate me..","meh","norway?","got it","What the hell?","foxy","godspeed","just like the bullshit","yo","damn","OH ,its a secret","uh nope","suk?","Oregon","who are you?","Make me happy!","huh?","minut","...what?","online sex?","oh   hi","I'm a nigger faggot","Gewd","DO WHAT?","me?","why","aha","..Hi?","give me your msn","fuck]you]","with a monitor","asl plz ~","Yes what","liar","i guess not","nothing","girl","anybody's home??????","0.06?","ming?","hay banda?","MYyyy ROOOOM","come from","and you are?","YOUR TURN MOTHERFUCKER",":\\","you chinese?","ha-ha","hello!","asl ?","does not lying","brazil","i said \"what?\"","bye*","yeah","23 m korea","that is just weird man","getting a headache","yea","jaja","oh and i'm not fat!"," pedo bear","and your favorites?","but how?","are you horny?","wha?","girl?","I LOVE LAMP","so wat do u do for fun","everyone","/b/?","mot","what do u mean?","not atm, have you got any ?","have you got MSN?","get me honry","Were you on the bus?","LAWLZ BYE","what the fuck","hard ","omv","hate what","D:","there honey","i really dont like you","my darling",">=l","ha","i'm strong enough","MYYYYYYY ROOOM","21","don't cross the beams","its genetic","it 1:37am","my back hurts","sucks","what do you do !","ha ha","anubis","win??","its like a anal bum cover","fuck you fag",";)","what??","oh lawds","oh..= =","i'll be you and you be me","nothing, why : O","dk!","okay","sorry...","I SAID FINLAND","im not being phased by it kid","sorry","are you okay?","lame dude","no i ditent","I TOTALLY UNDERSTAND","for vendetta","internet","WHY THE FUCK NOT","only my bf","oh yes?","hii","i dont understand","wow","my name is kyungju","indian","AARON CARTER","say something. please :)","~~~~~~~~~","from?'","I'M A GUY WHO LIOVES GUYS","i am a boy"," WHERE IS YOUR COUNTRY","are you chineseã€","you scold me","i hope you're a good one","fair from a view?","horny","F1","whr from","hi?","whatus","cali","you suck","in what do i need to help you","YOUR A S L","what u name???","hi yourself","ily noob","whats your name i have to go","i was a bit nasty but ","im charlie zelenoff bitch","AGE/SIZE/LONGETUDE","fuck ","I'm a boy","eyy","cool :)","lets becoome fuck friends","u can fall","i love you","im from usa","his name is mauricio","|:(","omg","me2","helo.","japan ?","where?","haha no you didnt lol","where to?","john*","iH","lol, hi","jerk off,it helps pass time","im no robot","fuck off you weirdo","now what?","so im not 1","I know you're asian","what name?","54","but u win","whats up?","25","14, but I look 18.      ","you go!","so","gud","ah","FukC YaSELF","why love me?","you have inspired me      ","æ“ä½ å¦ˆï¼Œæ»š","Go get crotchrot.      ","you cant talk to him","Do you have a bad memory?","o.o","how come i thought you a man","hallo","17","and you?","oh NO","Yep ; o","why europe sux????","honngi","are oyu gonna talk dirty now?","xD","No really, who?","hi..","im female","zxcvbnm","anger wont help",":|"],"ola":["watsup?","im male","eae","aloha amigo","we can cam there","what","olala","was??","nice get away from me!!","ola","anyone there","hola?","no you dont","else","than its ok.","and you are one?","palmeiras","fuck off pervert dude'","ola isn't a word","u cant even say it right","hi lesbian :)?"],"what":["do you horny?","are you ?","i beg your pardon?","where are you","no school for me","oh","-17","CHina?","are","heyyyyyyyyyyyyyy","sweet so am i","KINOSTI","from","i  can;t see you","where are you from ?","very..","mao le ni de what","i like men toooo.","asl?","where u from?","b?","Well sum guys like men :P","where are you from?","lmao","I am your head","do ","AT 13","you are a death","what is it","where are you from","halapeno","will be 15 in 2 days","im emo","age, sex, location?","hi","Taiwanese looks funny","do you like?","0.0","aleyster crowler","ola","lol","you're a pancake guy?","orly?","what","me2","tight latina?","what up","happens","sorry bout lastnight lol","obama","I like boys","are you me?","its a good thing","what is not ture","Oh god","a ha u are chiense","do u have email *","aaron carter sucks","please explain","one ball","click clock","i hate those","are u a pshyco","the sky","GD","OUT","eres una puta del libertador","22 m uk ","12","i have to go now :D","whe","yes","```````from??","im china ","telephone number?","what?","LAWLZ","man means man","NO WHAT","wehre are you from`","Aunshawnalakeisha","what what","30 m","name","hell","oke bye","okay","tell me","THE","What's funny?"],"oh":["i get it","lol","yes","em cima","really","i like women","small?","oh what?","I win","why are you so fat?","hi","asl","You can be \"best.\"","oppositegame?","men or women?","no not satiliets","like seriously","is that a yes?","no","bye","o you Alge","MY","ass ,,,too","nihao ","asl?","ok","city","haha","i'm leaving","newyork","NO,I play QQ","BYE sweety","21","you a chinese","13 f holland ","go !","hoho","ho","You were too direct","im telling u","what should i do","my dick has benn cuted ","huh","im a real man","i will count at three ","josef fritzl <3","_|_","ni hao ma?","tot ziens","u got pics?","i bet","like Brazil?","china is democracy?","whaaaattttttttttaaaaaaa","bye bye? why","and ur not bi/lesbian?","i'm hurt","BYE FOR U","thath yeah","from ?","hii","shit","Heyy Heyy","al final he perdido....","i know its okay","american sign language?","hey","yeah","u like","u have a poor english","I am  17","hmmm...","really?","I love Russia ","wait ,ok?","Jealous?","I'm from Korea","no I see"," spian?","i'm a bit bored","only u can answer that","finally :D","china","i g2g","where do live ","ä»€éº¼","hey you tellme really","definitly","oh?","n't understand wha","plz","YOU ARE ODD","ok?","but guys like em","hmm","great","help me","hehe","sorry","devil","too bad","eww","yah."],"igetit":["facial muscles make me smile.","lol","bye then:D","the game","do you?","no you don't","what do u get?","not yet","you are chinese","is you","you get shit","hi",":DD:","what?","hard ","god told me ","i don't","haha   ","where are you from ?","get  out here","cali","hello","get what ?","bott","i get it","whats my what?"],"hey":["hi","maybe you had handjob before?","WHAT A COINCEDENCE","Did you hear?","You don't care?","17 male","i burn a nerd","Hey!","whats up","Hey","im sorry","do i kno u?","yu","yo","i hate those","MY ROOM","ello","hum..","were r  u from","Where do you learn this word?","in the war","you said what","THATS RACIST","Nah","wi wi","asl?","very","huh?","i like men","asl??","watashi no naku chris-desu","you should","AND I HOLLA WASSUp","bum bum bum bum bum",":(","hay!","hello","ah","lol","i am an astrounot","from?","wht","....say something","fat?","sup","what","wasaap?","bye","ur asl?","HAI","GO THE MOMBATS!","is that kroean ?","i'll fukk your brains out","and i'm not a mister","whats up?","hiii","your name","still there?","wat","sorry","long time no see","i luv pussy ","reverse","china","what?","fuck u","laugh ","hola","ok let me see ","whatever","just check","i know","hey is not chinese","m or f?","what up?","boy","word love ???","hey there","are you a gay?","hey brethren","heyhey","indian","o sorry","you ","ke fai - what are you doing","asl","ciao","ok","yes","wuts up","als?","m 25 india","something to take care of","because what?","XDD","im from the UK ","helo","so how old ru","im ask a question","go on","nice job","Are you gay or straight ","i win","are you a guy?","u r good men","9 f","you're grounded","hrey","start","i m 20 ","hey :)","fine?","yes yes","im a sexual tiger","k what do you mean","what your major","you alright?","unite soviet states republic?","What's funny?","female?","GARY THE FUCK OAK","girl or guy?","are you a chinamen?","i have you :)","nigger","try?","You want to have it now?","ya","Why should I say?","have you seen my hoodie?","where r u from?","so fuck off american idiot!","Hello.","are u there?","male or female?","or hello?","then u","kasjkjf  ","FALCON PUNCH","did you kown \"é¸Ÿ\"","lllllllllllllllllllll8","..jude, don't make it bad","meow","do you like soccer?","fuk u off","hey\\hey","birth","you ,30 woman?","yes!","whats with canada?","how do you know this web","r u excited?","a bull?","wats ur name *","male","again?","I'm here","you're from china","and now i am from france","badsmell","yt","guy","age  is not a big problem","i'm fat","but badgers","same here","Are you tigeR?","kroea 17 f","sorry I do not understand","cunt","what language is that      ","Pardon me ","you are muslim?","feel bad for the dude","usa","no no","it;s a modal","hey, do u like Finland guys?","SAVE THE EARTH","i  can tell u i am chinese.","male 2","i am a chinese","from","sa,e?","Herro","23 m usa","male or female","Uk?","Hi@","hi]","or not","hiya","where","get in","how old r u?","y are not normal","'t understand w","gud","frm?","yez!?","lov me","hey\\","ove?","yeah i'm a girl","hi? :D","how are you","u move i shoot","Ice cream <3","fuuuck you !","Pics?","chest","i did"],"iam":["fat?","you're hot too","BAD","i know you are","good stuff","hi","zomg no wai","what does \"e fixe?\" mean?","you are!","gd?","I see","hey there","yes","Indeed.","horny","fine","u asian?","... ","so","who?","Say hi!","and","bie","you want to sex","no cyber plz asl?","yeah yeah yeah ","you are ?","omg wat","ha~","wib","right","how much do you weigh?","-->","you have small penis","da person","naw"],"fat":["no","me?","i am one hour ahed of you now","slim","obese","albert?","short","i hate those","are you saying...","Im....","what ?","yes","thin!","abso-bleeding-lutely","ct","haha","wat is it about","nope","not me","fucking motherfiucker duck","from?","i'm  not  fat.","nooo","what","no, big as in pig","you sounds like a computer","strong","No.","wtf","the major","go","no fat","im not fat!","Nah, I'm skinny","no... but not skinny","hare","ask ur momma","your what?","which country","hoii","uhhh.","FATä½ åª½å•¦","gotta go","SBå•Šä½ ","so?","asl ?"],"no":["are you sure?","pff..then no..","interesting","Why","is that portugues?","i am","ah ok","that's wrong","what no?","don't you want?","and a big ass?","fuck you","yes","no NO ur brown i hate ur kind","horse","IM ONLY HERE","children?","Im a lone wolf","I love my penis.","Hey","until","neither, idk yet","cmon, make some effort","lol","you lost.","where are you from","no?","cock a doodle quack","R u a girl","see you","i like men to","Oh","born in miami","more german","ASL?","-17","coercion does it for me","fuck?","why?","just want to speak","what","o then wat did u name?","hi","how r u","yeah yeah yeah ","sorry","now I have to go","J'ai un petit ami, maintenant","erm","ARe you a male opr female","you a female?","Going to get along.","why  hold on","NOOOO","yes i am a American","i am raping it","you sound fine tho",".//","come in","found it","man ?","me? a man? no.","Suo","im usa","im sedat","are you feet in the air?","??","ok ","wtf?","don't konw?","what?","me too!!!!!!","alpacas are smarter","me?","you LIKE?","does not lying","Shit is great","lol okay.","boy","ill say","so?","i'm girl","why are u asking ?","win","wi","asl plz","me neither","where are u from","20m","NOW","NO","yes.","empty","YOU KNOW WHAT?","hyy","u?","im  here","what are you talking about?","you man?",":(","..","yes, it is","slm","no what?","don't have a country?","men?","19 f","russia","its ok","good","neh mean?","yes !","wanna fuck?","u lady?","man","my dick is tickling","u from?","bad","how do you call me","almere","Otherwise?","you want  my  email?","you win?","fuck u ","Are you asian?","it smells like shit","bye","do u love your ass?","fucker","don't hit me! please","hilli","NO WHAT","noou","i g2g","yes you do.","i'm talking to a comuter","not a computer","why not","you r a lady ","nice","fin","turkey","no wat","You are not delicious^^~!","16","what do u mean?","u said that","yes,  bi","where from?","...did it hurt?","asl","hahah","m?","okay ","just","r u crazy?","fuck","eh ","asl!!!","from?","???","I can't even see anything.","what is that","DONT LEAVE","only u can answer that","heee","whats the problem, then?","you?","usa?","Gordon Brown","holland","100","my name is kyungju","the writing","fine    fine   fine","i   want   to   sleep","horny?","jennifer?","then who?","jock","21/man","And why not.","up*","Hayy","are you gay?","fat?","yes!","hello stranger","Canada",":o)","just kidding :)","no hay banda","there where you at","with waht?","excuseme bitches first","ew","there are only nazi girls","who,? o.O","let's rap","maybe","^_^","i am having fun ","guy","It's very kind of you","nope","WHERE ARE YOU FROM?????","r u?"," whre r u from?","but you can guess my name","haha","sure","17","whats the passwor","i know you know it","yep","alright","-_-","what were you thinking","hello","I hate him","yes it is","How Old Are You?","18/female/taiwan","NO MINDGAMES","how old are you","norway?","ok i gotta go","FUCKSAUCE","both.","what country?","u wana see","im not fat =[","don't","2.2","not today","lied u what?","seaking?","come from","I not","i'm japan","a??","queer = gay","you gay?","i sold em","All americans are","talk","is that britain?","your>","en ","sorry I do not understand","whe","ok~","my dad has a huge cock","im a guy","kissessssssssssss","just hard to believe","im 16","im 10 years old","your age?","it","do you have a long dick?","who are you??","i am a boy","No?!","I WANT THAT LARGE COKE","the great I AM?","boy or girl?","lolz ?","i'm a killer","ha ha ha ","lol.","19, m, new zealand","2+2=?","???MSN?","compuyer","thanks","nothing","GOODBEY","0 0?","u take it up the shite pipe","how old r u?","thats what you think","god?why?","i'll take your word for it","I am Taiwaness","boy? girl?","why no?","china ","bye babe"," why u say that","not yet","do you thing i am a floo","HE HE!","So what are u wearing darlin","Yeah, i am","well, i can","Like, russian ","wtf are you smoking","www.lemonparty.org","zhang  yan   ni","can you help with my endlish?","ye i did","rich","and cum inside you ","No.","haven't we talked?","well done?","waht no?","u japanese>","stand","pants","but i have pants","you are a computer?","Right time","you cant spell","yeah something like that","No you dont like vagina?","ok guy","are you married?","you sound like a nigger","noo","idiot","can you read?","exactly!","homem ou mulher?","yours","I feel pirhanas in my pants.","i said that","pl0x?","im from united states","female ?!","crap","I hate gays","No one does :(","he is coming","behind the wall","no is a word","you can't even speak english","Yes, I am.","What.","Whats ur asl","TITS FIRST!","im from...","i also dont know","u f?","i am not","no catwoman","m/f","where u go?","oke","nononno","girl?","u! bor or girl","oh the cat just ran out","after the mice",": D","F2","ya","blah blah blah","india","and i can be one","then its good ","tuesdays","you are so asian","i dont :9","I cry","well","wanna cyber","Palin","ASÃ–","FFFFFFFFFFFFFFFDLSFDS","fag","brazil","FUUUUUUU"],"areyousure":["no","not yet","mm","ys","Cybering is for gay people.","gracias","definately","you suck so much","mhhh.. yes.","d'oh","are u sure?","asl?","im from portugal","yes","About what?","hi","england","r u sure of ur self","dum gooks","im sure"],"notyet":["lol","asl?","maybe you?","bye sexy","why","pedobear","Hey","not yet","On a besoin d'amour","words words words",":(","asl","age and location?","hartford","srap","OOOOH CRAP","no,, not yet","ok",":/","so so","i'm trying nothing.","16","NO","canada","okay","Offcourse yet.","Brb.","Oh, come on. it's friday!","Hmm/","YOU SON OF A BITCH","u thought i was some girl","then you are a gayfish"],"girl":["i hate you","u?","sex plz?","Who is this?","boy","yes","yes is said so before","hi","yeah","run","no ","ya","girl?","soo fast","r u kidding","you're from china","coca?","yep","male","so u r a girl","i used to be"],"cyber":["nothing","m or f","nope","hi","nono..","yes","win","*anal","not a dude..","fuck yourself.","no","if you're gay.. but i'm not","no!! ","haha, that's dutch","ohhhh sounds good to me","He certainly is","at last where are you from ?","other","huh?"],"heyy":["asl","hello","Oh,,i'm here ,,baby","America?","f/m?","well.","sup?","hehe","from?",".......","hey","im from spanish, true","wut","where you from","u fucking dog eaters","m or f","and i love tila tequila","hihi","are u girl ","phone sex?","hi","asl?","oi","ok    I forgive you","cyber??","JK that was rascist","no no wat","yea","eu sei de onde tu vem hahaha","eyy","owned      ",";D"],"canada":["19 f ","what ","im from portugal","What make u came here ?","cool","Canada?","no","eh?","u?","come on now","but this is just awful","china.","hi","Ew.","whats with canada?","so?","canada","lol","Hey","doei","What in the world?","yes","just a few","be more funny","how old are you","Are you Canadian by the way?","son of bitch= =~","alaska","so your female?"],"you":["ah sorry","im 24","girl?","famale","I make poop","bitch","me what?","What the heck.","you","brazil","`?","o rly?","tu","webcam","...","me","I'm not dwowning!!","hi","GO THE MOMBATS!","talk to strangers","Nah","i have 145","hi ~","me2","again and again","why?","it","asl? x","do you?","watsup?","ou forgot","aaron carter sucks","yeah","No rail route","' '?","HELLO","what a u doing ,,now..!","17/m/ny","I sed m","nice to meet you you","TELL ME WHERE ARE U FROM?","17 m UK : D","no","baby  what can i do for u"],"me":["no","too","fat","me","i find jews sexy","i don't have msn","you likr me","i can't see","=(","can you speak chinese?","hi","you",":O","what??","wtf?","wut?","what?","again?","huh wat?:P","nah what are you on about","puse","comprende?","penis!","VW!","???","either","aa","i think so","me either","i live in n.y.c","sorry","watashi wa","yeeeah"],"normal":["usa","i do lots of red bull","sexy ","from?","yea","Hello","from","riight","better","someone's touchy today","large","I am not English","pardon","i cant understand u","great","16","abnormal","WHAT WERE YOU THINKING","hahahaha","you are crazy","oh","?????","unnormal","may be]","POOR ENGLISH"],"yeah":["20 m Portugal","where are you?","hui","yup","oh","u?","where are you from?","nope","cool","then i am from spain!","and how are you?","okaz","which city ?","awesome","dastardly","freaky","boy","in myyyyy ROOM","no","huh","so","i m from  China","heeeeeeeeeeeeeeey","my bad","ok","hi","o palmeiras ta a jogar melhor","f?","what's your name","asl","why?"," are u ok?","i think you is a boy","That I'm tolly' awesome?","where you from","so is my nevue","Jihaaa","sorry","where from?","staufelhammer!","r u a student?","yea","can you be normal?","yeah","means yes then","good night","adjkawkl;wd\\","don't leave me","oke","of the same sex right","still","start","okay","ass","you mean guy oR something?","in","sure ?","wait, girl or boy?","YOU DO HAVE GENITAL HERPES","male,24","where r u from?","u r spicy","!!!!!!!!!!!!!!","im UK","omegle.com","oooh thanks you ","hartford","sweet so am i","ROAAARRR","i'm not!","i gotta tell someone","why do u want 2","us","bye!","we should be friends","wow","I'm bulimic","um ?","so should be","i'm going","you?","omg.","do you smoke pot","are you male or female","are yuo  a guy or girl","enhe","go away then","drink 1.5% milk","so, where you from?","it's great","india","Nothing to say","and hot",":D:D:D:D","gourd","DOESN'T MATTER"],"fullofenergieisee":[":)","c'mon barbie let's go party","Whats ur asl","yup","i supose?","how old are you?","i dont wanna hear about them","hello","yes","i'm korean","i dont know","so far",":p","im a boxer","are you gay?","jep","kjdsafkabf","brazil","well done","sb","are u psycho?","im right here..","you are rude","yes. i have energy in my ass."],"sorry":["watsup?","me","where are you from","fuck off ~~","love u always","whhat is asd","cao","asl","What","understand","wot","your acting is very poor","its awful","ok","you","fuck you","gtg cya","for what?","onthing","gekkerd!","msn?","dont call me pathetic.","fuck i need to sleep","freaky","reat news","like me","from usa","football?","your fucking weird","why","ahhh","SIA","bye","okay","thats gay :P","S'ok","what?","..... ma","gabby?","is the true","apology accepted :)","hi","wtf?","Only on tuesdays","come on","who are you?","im not a fairy","it was a close call","  i  have  QQ","im too gay for you","I JUST GAVE YOU INTERNET AIDS","what about new york","=/","Great","summer","fail","where aew from?","idk","hey!","how old are u","i jerk out","for hwta","what about you,m r f?","yeah","sure","sorry india","i want you","np","for what","I placed it there by accident","you're woman?","and a girl..","means yes then","Do you know Turkish ?"],"watsup":["didnt got that one","my penis"," Taiwan","ronaldo ?","nm u??","not much? yourself?","so much","sorry  sorry","no","cha dude","welll~~~","tired","thin!","on the seel","not much","my thumbs are","what","sorry,,","nah not much","hi?","not bad","girl","42","why do not","boy or gurl","me2","ciao","hi!","for you i could be","germany"],"passingsometime":["no","tooo","ortigoza","how big is your dick lol","And male.","lol cool","okay ","I'm confused","hi:)","You wanna cyber?","You are a scholar.","hello","what time is there?","wha?","i don't speak japanese","256","Nah","Throwing clocks","you dont even say hi '","yes, you aaaare","fun"],"noitoldyou":["ola","hey","...","O.o","You're weird.","There u go again","u r a gay","huh what do you want to say?","INDEED","heLLo","heyya ","you suck ","FAIL","m/f?","wher?","(L)","??","you are shitting me?","im hot","TOLD ME WAT!","ah ok"],"spian":["sorry ,i don","u girl?","lol","raawwrr","That atalion in Family guy","Going to get along.","parle vous englas?","hi","what a bitch","purtogal?","PORTUGAL","21m","asian","what is spian?","Demo?","beijing?","nah. too far to travel","hehehe]","spian",":)","norway","No, USA","engrish","Hello.","ok ok ","Russian.","No","what's that"],"ah":["are you a socialist?","i really really love you","sucks","ah ok","hej",". well. im lost","just in the head?","its cool its cool","so where are you from?","youre great","Does not understand","HEY HI HELLO","je ne sais pas","what's you asl?","oh"," where","nah what?","you are not a ture man","So...","so ","u fuckin shemale","yar?","you?"," go to hell","damn","so yes","fuck you fag","Khaaaaaaaaaaaaaaaaaaay6yyyy","why?","i dont know....","me??   why","hey there","a weird guy","hi",":o)","BUCK","no no wat","sup","are u a prick?","we should have a chat","Nah","words words words","Oh you're horny?"],"areyouasocialist":["YES!","o palmeiras ta a jogar melhor","no, i'm pedobear","pedobear","no","yes","and","and one more","what's then","FASCIST","3,2,1 GO","hi","i love you so much im sorry!","no no wat","     no no","Why should I say?","in the field of sex","only on a fullmoon","i am a student","actually iam or not","why you ask this","uh ","no facist","do you drunk?","i love guys","nah","erm. no","?????","not really","do you want sense?","REPEAT!","you","meh, not sure","pschhhhhhhh","sex?","where are u from?","i can't either","quit training your bot","PEN15","Whats ur asl","sure","palmeiras","sure.","whr r u from","awww its ok i'll be gentle","hii","good for u","s typing...","3rd time","4th time"],"capitalistsaresomoneyhungary":["i totally agree","motha fugger","but im in australia","nazi","oh","Well duh","lol","uhuu","start from the begining","maybe it does'nt matter","good","Hungary is Marvin","capitalism rules","chinese is my song favourite","u?","YA rly","???","www.nobrain.dk"],"youfirst":["no","come on","no fucking waaaaaaay?","no u first","my what?","thats not strange","polute me now","11 and 35/4563","ok","not my country","me last","fu","at what","u named ur dick?","Besoin d'un amour XXL","r u a random person","i did when","all hate chinese","you confused me","u r a nigger","sure...","no man","old ?","and you?","i dont care abt what?","you sound like a tool","how old are  you?","your not making sense brah","japan","svenne banana","korea","hi 22 m germany","you second","but i cant see","bastard","8 inch","what","me first what?","i said alrdy","i just told you...","I am a Chinese person ","16 f us...","17/m/korea","bumb ditch","do you want sense?","nothing","you are girl?","18","nice 2 meet u","you just lose it now","i asked first... ",":o","i said that!","im from usa","where you from?","if then am sorry ","Penis.","hi","china"],"mypenis":["me too!!!!!!","are you gay???","haha","oh","yur mothers","nicccceeeee","sexy ","yeah","27 m","ys?","where are you from","ok :D:D:D:D","was-immer, auf weidesen","hi","don't stop with that","5453634555","haha ik lach me dood","hahaha","NO ITS POLO",";\\","you ","sandwich","you have small penis","bor","tu hermana"],"youloveyourass":["no","ya ","i do","What... ","...","no? xD","``` ```","jew you like my ass?","it's nice","whats weird haha","their screaming sound nice","What??","yes.","do you love barack obama?","i am chinese","Who is she?","yes ","oh god","hmm... dunno","of course","yum","??","Yup","uh nope","*whistles a tune*","gay","no  china girl","pickasu lost 39 hp","are you 19?","i should . i love to shit "],"asslover":["HA HA!","correction : your ass lover","obama?","boob lover","you?","..","u?","something to take care of","i love your ass","EAT ME","i do lovee ass!","i am a lover of asses","if the rectum fits","hi","you male?","love anal"," GETTIN BORED GUY","ye i do ","hello ","yeah","what you mean","i dont like asses","what?","ooh yeah","MY NAME ISM ICHAEL WESTON","check it out","cool","u asked again","ni hao!","wht","still there?","NONO","I knew, Robert","female","lol","yo"],"indeed":["normal","I'm great","fat -obesity","sad facez.","what is v","INDEED","HORSE LOVER","poor horse","yea","hi","oh~","ASL?","Purple dicks are gross.","fuck you stupid.","i can help you]","which one\\","yes","with ketchup pls","that's my word!!!!","=       =","he likes it","california","iolbiwbniopufuwjeniwebnfie","me?","that right","???","hows ur mum doing?","ok","XD sily noob","so...","I'm here.","  china ",":|","No.","look at the cat ","DEED","wow","jack pot . u r falling","holland?","means?","are you chinese?","fck"],"nice":["oh","fuck you","sb","you too","yup","hey","sweet","he got cherpies","you   jew sucks","were r u from","any pics?","which country?","or boy?","not so much","..........","19male","20/m/poland, i am not horny","Stop being weird.","i wanna fuck your asshole","you a guy a girl","so","when is it carnaval?","thanks?","turkey","LAME","sex?","or i wont believe that","4 what?","yes","What's nice? :)","hi","bye3 ","roflmao. what'sup?","where are you from?","for somebody who is bored","i like sex with squirrels","lol","25","whats that","thanks","that doesn't matter","you fall in love withme ?","Tamale","Yes.","What","i'm gay","gay","I know.","I16 years old",":D","what lol","yeah","whats nice","(:"],"whatsup":["nothing","fine","or suck mon jeeett","satelites","i'll fukk your brains out","is that kroean ?","whats up?","nothin","from?","hasteemos yeah","only old woman attract me","friday :D","hello","hello :D","are you from turkey","AM I GOING TO HELL","very young","Not much, just maxin relaxin.","hi","sick head?"],"uagirl":["i'm a boy","yeah","my darling","ima horse","i just lost my leg","nope","no,  i am a boy, i said it","no","whats it matter?","yes","hell no","China","hi","fuk u","yeh wat r u?","I'm from Russia","hahahahahhahahahhaha","man","yes are u?","You?","im sry for everything","haha ","men","your!","No?","buddy am a man","well , it depends"],"trytoputyourfingersihyourass":["lol","you may do it for me","ok","No","Nah","lawl wut?","f/m?","try?","just finger?","cool",":/","so ur a female","i'm doing that right now","yes","im a girl","at 18.36 (pm)","fun","R u a girl","i cant help it","i chat only to girls","all the fingers are in ","are you there?","IH? NO","I wish I knew you that well","no thanks","New england","i have no fingers just a nub","bye"],"ya":["fat?","Female?","u have msn?","great","you fail at life goodbye","right?","word","we have so much in common","http://urneed.sitesled","duhhh","ok","I win","ya","s am i","ay","Fuck. I lost The Game.","where are you  from?","cu?","vagina","hey","whats with canada?","you too?","no scott","Yes.","im","penis","=       =","am borin","what the problem with U?"],"comeapapajoanacomeapapa":["tudo bem ?","Gordon Brown","Eh what now?","so you are a american?","ok. i loove capitalists","Nah","what?","what ?","lol wats dat","m/f?","hahaha","\"i hate you\"","cojones","come to me","already noted bad girl","lakj;fadskjljdfsklakjadfs","tv","17","wtf"],"palmeiras":["me?","ahhh your spanish?","Florida?","coca cola","=.=","boom.","88","young?","baka","????","ass lover",":(","AIDS","no clue what that is","no","walks","what's palmeiras?","yes","cao","haah","knockknock","i`m japan","......","oh,so young"],"haha":["me tooo.","no","what's funny","Huh?","have u been smoking drugs?","sda","hey man","Yeah man, fuck that noise","hoho","lol.","hehe","sup brah","I ask you ","okay then","asia","were not gonna take it","Life","Where are you from?","are you 50cent?","where're u from","17:05 there","bhahaha)","huhu","y want see you cunt","hahaha","JIJI","U NO","dime","you are jap?","what's ur name ?","normal","hahahahahahahha","you asked me","i chat only to girls","search in youtube:","2+2=?","......","what u meam?","??","haha","I ACCEPT","m/f","thank s for this discussing","hey","russian boy","ha-ha"," omg","someone's touchy today","wi wi","are you a girl or a guy?","Israel","lol","YES","I'm funny hea?","fun to talk to you","hats of ","where are u from","í™ê¸°!!!!!!!!!!!!","not good enough.","i'm brazilian","Berbatov ftw!","sex?","I'M A GUY WHO LIOVES GUYS"],"so":["lol","so what","so ;)","cool,i am chinese","do it ","wow... ","fine?","Juliet! oh","can u answer??","yes....,..?","en?","anh","yea so..","japanese love korean","seeya","so?","Sew....","Soe","here we are","and i'm gorgeous","Jumping of a cliff","what","and gay","suck  what?","buff","where are you","is that u grandpa?","ohhh yes","orly?","yes?","don't leave me","...bebe","hi","like?","i got an anal probe once","joo","and ideas are bulletproof","Hiya.","next","bye then:D","well??","what do u say","can i see ur photo","=)","you are?","@_@","you can barely grief","no","ha!","Seriously.","Likes to challenge you?","FUCKSAUCE","so you will jizzzz","brasil","eat yourself..","okay bye","asl","so","batman?","16"],"hy":["lol","cause you are giving me sass","....","hi","i thought u were a girl","i love him","funny","what you want","but i'm not good at ENGLISH","...","eh. shit happens","soory babe","im horny ^_^","what","u f or m?","hMmM","maybe you had handjob before?","aint seen for a while","u r girl?","what?","what   about  you","lemonparty.com","i win","japanese love korean","i just sorry for you ","where you from","Puerto Rico","why","because the asshole is tight","im from azeroth","niggers","s with canada?","everyone always leaves me.","He's hot"],"else":["lol","yum","or else you will be unhip","but youuuuuuu","- (fuck bheckam)","weed?","=  =","already it was time","=DDDDDDD","i love u too sexy","do you love me ?","what kind of music do u like?","i  love   there","hoe are you","ok","what's wrong?","open it","u r good person","don't go away","where r u?"],"keepgoing":["ok","stop going","you don't like him ?","hmm","Notinterested, bye.","Eh?","my huge dick into your hole?",".........pussies","no thanks","who doesnt?","^_^","US = USA","because i'm a man","Yes.","i am very hot","ever wonder what u r","pika chuuuuu~","then a spork"],"well":["lol","well...","no wait...i like f","what about u","just girls in general","NO","and a cheeseburger","whut?","yes?","hi","ca/m/19","well","0.07","thats like the biggest gay","I never wear it in public","Indeedly","yes..","blah","okay ","its 6AM"],"welldone":["R u a girl","hui","hi","love you so much","Alright","where are you from","i just translated","i love you","here's a radio song...","gracia","why do you go on this site?","I'll wait for you phone","hi!","wo","No really, who?","I am pulling my wet pussi","u dont understand english","SURPRISE BUTTSECKS","jsut like i \"done\" yo mom","thanks","You?","hoe rude","whats well done?","looking for a sex chat","laughing quietly","\"Hi","asl","21","england","u having a good day?","hey there sexxyy"],"iloveyou":["oink","hmmmmm","so do i","me horny baby","what you say you look at ","you are no man or woman","I did say that earlier","llamas are so fucking awesome","you confuse me sir","fuck me in the pooper","bye babe","male or female?","uh oh","no you dont","asl","TITS OR GTFO","thank u","hmmm: >","i love u, too","who said i was a boy","what? nope","i am a 19 year old  guy ",".....","oh","have a hadache","ahaa awh i dont know you!","yeah ok","do you like me","me explique?","The speech is really direct","so r u m?","most awesome statement ever","hm","its turning me so on","i love you too","good luck though","like twillight?","thank u!","I said the Chinese","Thats cool.","also i came","i love you too, little one","girl","=]","NO","say me","hey","Male.","m?","Sure, why not?","india","hahaha, wo ai ni","5th time try some one else"],"v":["lol","no","yes","heo yeah","vEEH","I ACCEPT","im afraid.....","nice to meet you ","lol? so,  Iam a boy xD","shall i call the exorcist?","wat","ok","huh?","wmdvmedvmweovm","voev","vme","yea!","where r u from?","asl?","brave ","stfu","what is ir","Yes.","so those like","we down to fukkin hardcore ","??","Jam","ok  that is a good place","you've lost me","v what?","yesssssss","moimoimoi:D","rouw, yea.. i'm not","im not gay","bye","V?","you from?","I'll bet you do","wat r u talking about?","a song?","JesusLOL","suck me","Im from Rio De janeiro","your a virgin?","Kung Fu","me,too","no?","From the White House.","keep going","i dont know im hyptnotized","wats is that","i can't either","what you mean","your a faggot","no thanks","how old are you","cao ","i live in usa","viva la nation?","Ä±hl juro dess sold","3333333333333333333","retard","3333333333333333333v","v3333333333333333333","hi .      "],"sexy":["bored pardon","why thank u","what?","yeah","i love youuuuu","r u boy or girl?","absolutely","bye !:D","yes","want to kiss u","c'mon","big boobs is sexy","hoe oud en f/m?","yea","hmm","How do you win.","LOL the sky?","hoi","??"],"yourenglishisawful":["me?","thanks","I DON'T SPEAK ENGLISH","i like men","ur ma is awful","...","sorry.","sorry?","just so so","are you from usa","Haha.","fat?","korea","no!! ","my english is poor","im american...","Suck my penis?","yes, your english is.","What/","ok carry on"],"china":["boy","oh god ","im a sexual tiger","and i feed on vagina","See? good friends","fun place","?????","wisconsin","America,","you most not get the ladies ","if you want to sex","o yeah ,china 2","I like Chinese","ok","hmm","yep","wat r u talking about?","Gordon Brown","spain","you ","M, dawg.","R u a girl","korea","Mudkipz","me too","u confuse me a lot","good night","noo","how are you doing?","taiwan","what do you do !","im an idiot sorr","Ummm. America?","usa]","bs","i can not  stand you ","0.06","china","turned out to be very nice","add me","anywhere","no i ditent","btw i'm 56 / m / usa","next what?","oh fuck",":)","no habla espanol","sure","what's your mean?","cooool","sex?","seinfeld fan?","I AM LEGOOOLAS","I am very pure","chinese","where are you from ?","hey","they have nice songss","what?","how are you?","no ","!why!","Suo","what your major","22 m turkey","it felt good","female","plasse","where are you from","You said f","what are you jop","how","ä¸è·Ÿä½ è¿™å‚»é€¼è´¹æ—¶é—´","ciao","hi","Holland","bye!","i cant","neu","georgia","hahaha","usa"],"fine":["your turn","you","see my site","ok","um .. hi ?!?","Don't like your car","horny","im a freking fine lady","fridays","okay then, if you wanna","i'm male, 23 old, and u?","coercion?","lol","that's all i've got","u?","are you a trani?","i know","kyke","good and you?","DO NOT WANT","Oh,,i'm a boy","i LOVE men","ddddddddddd","right","offering?","barrack",":D Let the got be with u","are you drunk?","ZÒ‰AÒ‰LÒ‰GÒ‰OÌšÌ•Ìš","what","what?"],"asl":["how old are you ","16/m/sweden","what's mean?","And again i'm the big winner","have to do some real thing","were from?","lsa","24 m can","girl","nice hand","you man?","MALE","m or f first","m?","13 f holland ","is your vagina big and wet?","asl","BLaaRgL","lol","what","17 m japan ","let me see your photo","22 m germany","asl .","i wish, uk","15 male tr","european union","..","i cant understand","stop that!","fail","20 / f / tx","sinus large, medium or small?","cool","13,f,brasil","yoo?","again??","None, doesn't apply to me.","hi","winwi","Dolphins dont have fingers","you are a computer","21/f","?????","25 M NC","SHUUNNNN!","answer what","16.f.uk","15 f nz","he has things to do","18 f antartica","Maryland","99/f/china","lulz","bot","hey","cause im horny","im a girl!!!","ur nanme?","fuck u","here?","what?","IS NOT","feetjob?","Oh. my. god. :)","is that taboo in your eyes","14fcn","i really love you","1-32 in my place","u first :)","21","i love you so much im sorry!","You are not proper","yes it is","asl?.. sorry kinda new here","ok ok ok","i said that it's ok","minut","u're not hot...","for vendetta","ã…‹ã…‹ã…‹ã…‹","oh.","16, female, denmark.. u?","u first","where?","i know","16 female  HOUSE, hbu?","No","*sucker","14/f/alaska","23 from germany","16/m/australia","still","ruck me all night long","so where are you from?","male, China"],"ordonrown":["asl","I'm a girl","who the fuck is gordon brown","HE HE!","europe sux","hey","HARVEY OSWALT","Leaking upon you","watermeloniqua.","okay..","Assholes.","so?","so poor english","u take it up the shite pipe","Sarkozy!","u r a good person","sex","is susan boyle","brown bears","feel your smell","i love that movie","Murphy Brown","hello","wat","vEEH","sorry,i can figure that out",".. no problem.. ","no","where r u now?","do you love barack obama?","i said that it's ok","atletic","sup","who","what;?","hi","Who?","wtf"],"u":[":)","^^ wow","i am a girl","ignore the question mark","you","me what?","you don't like asian?","u?","me","i know you r not from japan!","asl ?","asl?","<3<","sexo anal greco","Taiwanese","and u?","fennechot@gmail.com","no u stupid","yhup","kajdfkl","boy","where you from ?","vale, hay me has pillado","u are travelling?","watsup?","cool","go ahead","how are you","..................:(","where'd i hear that before?","in my pooper","me?","what","m the bottoStranger: i get it","34","FUCK YOU!","m or f?","jj","tut","do u know LOVE","fuck"],"from":["k...","eu sei de onde tu vem hahaha","cao","im working now.","your ass.","The exotic jungle","korea","canada","i form china","xian in china","england","Australia","uk","toutaghamon","china~","sweden","boy or girl?","about what","o rly?","20 male england","i love","The USA.  You?","sussman","hahaha wat r u tlkin bout?","dutch","from...south central....","noooooooo"],"howoldareyou":["17","old enough","You pervert","well done","so","73","are you a guy?","18.","0 0","Me?","i cant speak with u","18","i'm fine ","20 i told you manty times","why","Take a wild guess","from soviet union","mean","16","o_O","AND I HOLLA WASSUp","are you male or female?","Hi Katie","53","yes","asl?","ke?","I am from INDIA","18.And you?","or white trash","19","fuk u"],"nope":["bored pardon","i have secks","hi i suck","secks","liar hahaha","so sorry :P","sorry ?","hi","do you?","yes","but only the pretty one","Wooshmannlich","nope what?","horny","16 f and wanna blow???","then go","it says right here","No. Antarctica, fuckass","well... define young","/b/?","me,too","what*","satelites","nope>?","whats that","ok","cuz i havent seen you","i like chinese girls","to it","nope?","i am 18","i have pants and im not rich","the woman","what does it mean?","I said sweden","teh sky","its an emergency","you didn't","RAPE"],"noschoolforme":["aha for me to.","im just here","your boring","im not fat","you're in vacation?","im dissappointed","you dont even belong on 4chan","o   coplany","yeah man","just use goolge","your grade bad?","why","mmm","aha","you already said that","ok","im 14 m korea","yeah, not for me either","hahahahahahahaha",":(","cuz i havent seen you","im very old","i love him","cool","OMG WHO ARE YOU????","School's out for the summer?","Deserve","stop"],"urgay":["lol","fuck you","fuck ","ruck you","no","why?????","this is goog","so is your face","Hello! :D","pat pat","wait wat sex r u???","Wow thanks","choppork","hi","yes","you?","and u","ass you first"],"whyrusogay":[":|","because i'm a man","GAY","what?","its genetic","wait","hi","cuz i definitely dont","Orly","??","China?","no, i serius","What the fuck?","making u wet","birth","because i'm mad",";(","I not ","why do you think i am gay?","lol","why are u so green?","i dunno","shouldn't you be sleeping?","with a penis?"," im 25 male ","u said so","|o|","ya you","nooooo","hey","the one children of god?","20m","be as loose as a truck","and ur not bi/lesbian?","because life sucks","I like muffins","I dont know :(","i'm not gay","yes..","im not gay"],"okay":["just for you","for vagina","U from","okay, i am quite familiar ","more german","nahhhh","howdy to u too","u too","Hello","lol","y want see you penis","fuck u ","I TOTALLY UNDERSTAND","do you know critiano ronaldo?","JAPAN","okay","what's the time then?","If you say so.","hey","from?","i do not understand","Are you from 4chan?","how?","Cheese Puffs : D","u frm?","?????","lick me out","I am your head","no problem","ok","that's great","kay","i take your okay as a yes","who's your daddy?","youre strange","ok what?","childish","bye?","..","havent we?","truth or dare","(:","SKAHFASDHFAIHSDFHA"],"yup":["you first","so","i know right","Where do you live?","do you have msn","bye","what are you doing now","were you from","how about you","My friend is a lesbian","go ","get out!","hoho","so where r you?","you?","why did u say it ?","how old are you ","and you are one?","confusion on my face","go away","where are you from?","where?","lick me out","hey","what","how else?","have a seat over there","ers","chinese","eeeee","You guy, don't understand it","what is wrong whiy you","  20","fecalpheliac","ola","where are you came  from?","GET THE FUCK OUT","indian girl?zz","Cozy.","I have a penis","oh, eslan then, huh?","what bout you? =)","yepp","I am confused.","its okey","ah","i have it","WHITE POWER","we're 3","....","*person"],"hatsurasl":["normal","you neither","helloo","16, f, Finland","age","boy ,21,denmark","bye","i have 145","girl","jonas brothers lovers...","spain","hey,asl?","olny once","GD","seattle, Wa","or else you will be unhip","you","60/m/your mums asshole","why not","Fuuuuuuuuhi"],"fuck":["i love you","fuck","thats not a size honey","?...","No.","Yes.","alllright?","hey","what?","you too","so am i?","its only a flight away","OUT","hi","OFF","what state u live in","oui oui","shit","ok","damn","ha!","WHAT'S THAT THING","what? sex? iwant that","whs that","u r hopeless","not again","of this amazing conversation","boy or girl","The game","what do i get out of it?","i try to practise","thank you"," Fuck you","you","me in my ass","like the religion","so you dont","am not jew","where's you picture?","say nigger at","oh","GAME!","ay bay bay","you?","what u want me to say","*phew*","Great","heyo","How are you?","no","okey dokey","gay","did i mention","yeah","do me","lol what","do you want a g/f?","Mature","somewhere?","=  =","get out","I'm so confused...","i said ur age","oh key?","i think you is a boy","wan trade pix","fuck you","Brazil ","you bitch"],"fuckyou":["u r gay","we could be great friends","wait","come in","...","babe","i hate those","Hey","oh god ","I am a Chinese","come","I LOST","ok","y too)","fuck me.","x)","you don't have a dick","you from china?","gang bang on you  ","tanhks","..","can you do it for me","NEJ","DEDDY CORBUZIER","Like.. yeah.. right","no fucking waaaaaaay?","unlike all the rest","America","fuck me","Gewd","cool,i am chinese","i am fine","i mean ,,,in OMEGLE"," :D","fuck you to faggot","ah ah ah yeah","are u gay","19 f","Fack you too.","FUCK YOU","lol","yes","me too","9/f/usa","fuck your face bitch","sory "],"f":[":'(","df","fun","win","ok","i want you.","yes.","IM GOING TO F","FF","FFFFFFFFF","you man?","wbu?","female","i said that i'm a boy","f?","really?","yes","terrible","yeah","where r u from","i am m","answer","boy or girl?","u r an asian","i love you ","........?","yea","why bye?","i kill u","You are female?","why?","?!?*","wht","what?","flowers"," 2 pac","from?","you suck","i'm m","18/m/usa","howdy","hi","can i have a pic","how old ?","omg","u f/m","so,  where r u from?","you're weird. Get a life","ya","i don't really understand","do you ?","peachy?","Yeah, i am","ortigoza","O_o","you","france?","bye","IN ","er","rwe","er2","NO!!","dsf","fds","what' that mean?",">:","wf","ndfn","wef","yh","so","cock a doodle quack","16","i dont believe","china"],"ihatethose":["boy? girl?","are you a girl or a guy?","what","hate what","lmfao","huh","i hate those","what is it","i suppose","me too","what's cool?","Yep ; o","SHE WAS CHEATED ON ME","are u chinese?","so where are u from","why?","who r they?","get over yourself","asl?","??","you hate wohm?","yea so do i","those are the worst","asl people?","ah ok","BAI","u rn't be a chinese?!!!! r u?","who?","asl","THAT'S GROSSED.","oh okay","do me","hi.","u a guy?","what?","Im not angry","I'm 16 and I am taiwans","you hate gordonn brown's?","were the fuck you from"],"why":["canada","why couldnt you get it up?","wo cao nima","f/17/japan","now you switch to insults?","XD sily noob","russian boy","can you speak chese","are u a boy","what a why?","i love man","anger wont help","where?","i don't know, do you?","why","im jew","i'm a chinese","We are TCoD.","from?","i dont understand you at all","boy or girl?","hi <3<3<3<3","youre oke?","i don't understand","i'm brazilin","feetjob?","flamengo","18","you are not what?","men?","o rly?","m or ","19 f","because aliens exists","so give me your email","16 f china","i like girlz XD","deepthroat","hi .","callliffforniaaaaa","cause i want to see them :)","wow!!!!!!!!","asdlnjlag?A??","i like it like that","sorry. i forget","y wat ","i'm a bit bored","hi","short?","no, i have a big dick","Why what?","wats up?","pics no","talk to strangers","where are you from","....jeez....not suit","What why?","When?","what are you","you are 30","fuck","it's an idea.","youre 22 23 18 and then 24..","asl?"],"really":["yeah","yes","maybe ,,,you'll say 19 f uk","where a u from?","Yes haga","yes :)","what r u talkin' bout","i like china","but you changed gender?","china ?","you know?","yes really","no,chinese too","bye","i saw them","you don't know where that i","well","shame","hi","yea","en","yeh","how?"],"suckme":["me too","ilol be glad to have it?","OKAI.","wow","i blow(:","from ","Good one?","suck  what?","olololol","po","beautiful","only my bf","u first","imi white","and u","okay?","spian ??????????? wat","lol","Sure","a cheeseburger?","HI","nope, you","OK/","no","you don't even have a dick"],"reat":["sept","ur really strange","ok","haha, you lose","i like women","really?","exactly","no its vanessa","lol","r u a girl?","hey ","you?","u?","female","ti?","u from?","tu conhece Frerard? '-'","i'm not one","hi","ur asl","what?!","Yeah man, fuck that noise","What?","i am zhang guilin","from?","Im not Tyrone","wht  r  thy?","YES"],"sd":["as","sda","asd","I broke you :D","helloo","A girl hehe","I wants to lick SD","fucking chat ","u r discousting","hii","no","sweden?","lol","BATMAN!","im  here","sdï¼Ÿwhatï¼Ÿ","dsf","ds","sd","dsd"],"df":["sd","very","good luck with this one","df?","sorry?","dick fuck?","what is df","no ","do me","anne coulter","from?","korea?","ahhhhhhhhhhhhhh","sorry ","mexico ah?","ok keep saying","tldr","No pictures?","Hello, Experiment #12.","??","df","nice","OH GAWD!","you are my ass lover?","got any pics?","ur ma is illegal"," your msn!!!","not at all","are you student","COOL","who r u????","OMG f!","will you be my new master?"],"thanks":["yeah","if this is a challenge","JEWSSS","Cut peppers feeds","You're Asian?","ok","hi","and you're welcome","sorry","jesus loves you","so what about you then?","i'ld kill for tiiit","AND I USE TO BE A SPY","i am male and you?","por que?","huh?","Why","russian boy","thanks",":DD:","u too"],"ho":["well done","hi","AARON CARTER","i am male and you?","asl","im chineses u fucka","im my room?","me?","what?","that guy?","OH NO","  china ","then sleep you stupid asian","indeed","ok  that is a good place","Your not even from canada","yes!","the man who will fuck ","Mike JONES!!","you?"],"iwin":["nothing","No","2000 points","i win","And male."," win","YES!","what are you talking about","are you a student?","u r a gay","iam male","heyo","i do","other","you r so weird","i know u will do it ","FBI wins","i loose","i dongt know what you say ","How in the hell do you win?","How do you win.","orly?","thats not strange","R u a girl","i have a new game...","i had a good thing going","fuck","u r girl?","u too","which country","i am lost","yes","I never said that.","No way.","girls","no way"],"fail":["lol","let's rap","on so many levels","you boy?","couldnt you get it up?","hi","you fail.","sorry.....","boy girl?","and why is that?","u looking for someone?","was is los","from?","you fail, dickcheese","if u need dick","well my dildo is at home","what/","OK?","nvm","or boy?","on reversal day","gayfail","0:00!!!!!","are u two then?","i like girlz","no","win ","phail you mean","hui?","please....","oh","yeaah","Epic?","Holland"," are u ok?","ah ok","then fall ","fail","st?"],"ure":[":D","i m a jesus lover","iam fine how about you","a son fo bitch","i'm a bitch","or japan","ok","and it's muslim","asl","go on","Good one?","hi","USA","Why?","ur msn plz","tired. = _=","ure","am fine","lol","apparently"],"areyou":["hi","no school for me","I'm Australian.","r u Hitler?","what","what/.","so how old ru","yes i am","No.","Mudkipz","yes","your gay","im working now.","okay","Offcourse.","No","me?","I am many thungs","no, will do later"],"whyareyousofat":["noi told you ","ah","i'm not, fuck you!!!!!!","i wanna be fat","i know","Do you have PayPal?","no reson","yea","what?","im not ",".... burger king ...","i'm not fat","ok","fat?","-.-","im not at lol","im not fat????///","???","asl?","how do you know I am fat?= =","because i ate your lil dick","im always eating","i am not"],"very":["very","df","Yes what","yum","from?","but not out loud","im 14 u?","definitly","very what?)","30cm de miembro","My what can deceive you? ","nice, where are you from?\\","i'm japanese","how old are u","scary","slightly","what","your mother fucker!!!!!","you are China?","good"],"shit":["EVERYBODY WEIRD FACE","lol","INDEED","HORSE LOVER","heeeeeeeey","Everybody weird face.","get away","sun of a bitch","BUCK","what?","shait","just saying","what are you talking about","y?","Nah","are you?","im a sexual tiger","hahahahahahahha","try again ","Fack.","H BUT WA","how tight is your cunt??","gay me?","oww"],"iknow":["right","no not satiliets","bye","Me too","You can't know","yeah","lithuania\\","THATS RACIST","im sure","it's a city of delusion","Oh dear.","no","how that?","f or m ?","but","i hate that","i am an astrounot","sorry I do not understand","ruck you","tv","fridays","do u ","hey","it was a draw","ask ur momma"],"right":["sucks","so were are you not from?","very sad","loli is good","your","you can barely grief","You are American or Chinese?","is it nice there?","u are man?","u are from usa","are you the dude?","yeah","hi","send ID","im in the uk too","cause i eat a lot","foxes are cute as","yes","I'M A GUY WHO LIOVES GUYS","brave ","nice country side","i totally agree","terrible","left","knock knock","you can","yup"],"hmm":["motha fugger","was i right?","MEOW","no","wait YOU LIE","Im hott mate ;)","so what areyou","its fine now","these riddles intice me","from?","I SAID I'M A BOY","ahaaaaaaa","LOQ","Hmm","axn","So i herd u liek mudkipz","so you are at the space now?","hi","OMG","HAY"],"okey":["I LOVE LAMP","Hi Im Kevin 18 from virginia","win","No.","okay","asl","18","i'm getting tired","THIS SHIT IS GAY ","okey","fat","what?","lets talk","girl?","like I!!","Yes.","Okey?","when will you be back","Great.","sure","hi","hihihihihihihi"],"wat":["Gordon Brown","???","wow..","hi","are u female","you are a russian boy?","i don't love you anymore","fuck ?","dat","heyy","haha what","what*","no ?","are you okay?","Hello.","yes","what who?","wana cyber?","im 24","so,... your old :) ","asl?","where are you from","girl or boy?"],"where":["that's nice.","lol","Oh im peachy.","MYyyy ROOOOM","you??","korea","I am come from China ,you?","no i dont want little dink","hi","do you mind if i from China?","us","uk","here","female?","New gineau","on the table","age?","where?","there they go...","16","there where you at","NO"," 21 male ","papapapaapappapapapa","your body shape is fat","i don't know","up your butt","RICK ROLL'D","asl","what?","im sorry","huh?","too late","I like tacos","Colin Farrell","you can barely grief","å°æ¹¾","your home.","tell me"],"ono":["Gordon Brown",":3 orly","Are you fun?","youre just some dumbass","hhh","yes yes","erm yes","but how?","what?..","where are you from?","u like talking in eng?","what?","Fuck you Niggur","no what?","Leiria city","hi there","iup","what's funny","usa   you  ","eat my shit","oh oh","what","æ»š"],"whererufrom":["america","i'm a bit bored","iraq","fin","korea! -_-","u asked again","i ask you first","you have?","dddddddd","Mars,","you have a name?","? : D","honestly..","212 121 2121",":|","I am from JAPAN","I love you.","where r u from?","still from finland","bot"],"c":["so i'm very unlucky","how big are you","u/","what","u feel my fingers babe?","say chinses","it was very painful","what about him?","=(","asl",":)  bye funny boy","c?","suck  what?","whats weird haha","i like raping lil bi boys","no you","by","you are Chinese,right?","I  TEACH  YOU  ONE WORD","c???","shaved balls?","ok:)"],"k":["i can't either","how old","an issue not and issue","what mean","kkthxbye","what?","kittybread","what's the weather like?","dol ma","?? ","fuck you nigger","helloooo??","I see you naked","joke",":)","winwi","f or m?","wat ?","blow","again and again","Where do you learn this word?","very very good",";;","OK or No OK","chungechunyemen","yeap","A week of group","jt","send me 50$","fg","cry boy...","kk"],"andyou":["no","where?","my roooooom","Tells me    you from?ok ok ","I'm petting kittens.","nao","you are my ass lover?","go jump of a cliff","Or doesn't?","i'm seriously","troller too","cyber","dunno","i'm glad to hear that","so?","Happy as in gay","you are?","i love you","17 m","know wat?","21m",":)","yo ?","korea","from?","i think its normal too","yes"],"um":["k...","age? sex? location?","where from","do you want a g/f?","Â´what's cool?","where are you from?","from?","good?",":DDD","where?","I wouldn't say \"love\".","ik","FUCK ME","what","what u want now","/b/?","i'm not, fuck you!!!!!!","hey","o sorry","are you ismo","thinking? I've got all night","m or f ?","lalalalala"],"ge":["very","sex?","24","mine?","21","23.:)","hola","edad","16","16'","jhi","u like em or not?","19","asshole","15","you are girl?","ronaldo ?","wow I love it ","name?","hello?","15years old","you ,35 woman???","17 g"," i totall","Great","785"],"iunno":["i am","i'm a girl","i'm koren seoul","hiyaaaaa","I just ask where are you from","i cant understand your words","what your name","mhhh!","Oh Ok.","what is it?","where is that?","pity u","okey dokey....   slan agus x","idoos","iunno","age?","good","yes","en","im f","u?","zup.","HAY AY HAY AY NAY NAY\\"],"up":["weird.","r u a guy?","maybe you?","asl","from?","hey hey hey","ahah","sup??","how is your nuclear weapon","Greetings Mortal","ill be pikachu","fron","42","hate what","Oh. my. god. :)","fuck","kiss","WATERBOARDING","???","what's the hell!","Yeah, i am","nigger","~ã€‚~","are yu from england?","sdown","are you... MORPHEOUS?","are you a computer?","u are china>"],"bye":["i am not from Japan","sorry"," 21 male ","wher?","I ACCEPT","!!!!!!!!111","oh","ok lets start again","ok","bye","what time is it  now there?","heeeeeeeeeeeeeeey","doei","asl",":(","Of RAGING HOROMONES","boy?","hi","i g2g now","no","...","you lie to me","nh","USA","iiiiihh","palmeiras","vale, hay me has pillado","say","=)","what state u live in","chiou","of","show me a pic first","kissessssssssssss","is for","fine","in slow motion","where from?","di ci","you  are  a   student ?","they","what?","byebye","FFFFUUUUUUUUUUUUUUUUUU-","Wooshmannlich","sda","you're high on fart gas","KINOSTI","ur really strange","bye~~","we can talk some other things","year","JOIN KKK","fuck u","your pic","unlucky fucking boy","bye:)","you from madrid","if u wish","but fall in love","retard","bye then","Aufiederzehn","aha","bb","sd?"],"see":["yeah","You have the religious belief","hi","what..?","I see","im 12","i can too","i give i dont recieve","hi,man?","hello","kk","you have a big cock?",",,","kool","i came","what are you thinking??!!!!","new orfans      "],"russianboy":["listen buddy","g'day mate","john locke has died ","why couldnt you get it up?","no","yes","that's....good","you are russian boy?","incorrect","chinese girl","hi","ganja","huh?","haha","aa?",":)","portable choir service","aaa???","see you","siamese twins","privet"],"didntwealreadycoverthis":["china","what??","chinese?","i dont know","hmm","what the fuck","we did?","no wot u talkin bout","when","mal","dont kno am a bit lost","u?","for wat?","no","cover?","yes","cover what?","didnt we already cover this?","asl?"],"howru":["better than I was last week","flamboyant","what are you talking about?","no religion","good u","Yes,","JEW","this is really all youve got?","iam fine how about you","16/m","swedish?","gtg","and i love cute girls","girl?","asl","fine, but not anymore","fine","=       =","I dont have penis","you likr me","why did you do that?","yup","and press ur boobs?","god doesn't hate you."],"y":["how old are you?","wow","morning?","you?","im a girl!!!","my eyes are red","whats wrong","penis","yeay.","haha","remember that name","yes","hat?","slm","tf","No.","ty","tu","hj","5y"],"wtf":["bored pardon","What do you mean?","youre slow","Heey","have fun with that kid","sorry but i dont get you ","?????","fuck the what?",":|","sorry?","explane?","SKAHFASDHFAIHSDFHA","Buhh Bye.","what?","i know!!!???","You know..","idk","asl?","im lost","letter","I WANT","oh","spread the word!","well.... my name is"],"male":["u?","age","no no n o","male,24","sex","you","u r  chinese","oh","NY","yes","are you asking or telling","ussr","student?","hia","fqmv","..","what   about  you ","ok","21","What make u came here ?","I noticed","America?","You?","hey","NO SHIT","male","gay","*shakes head* ","so ","rome."],"addme":["what's the hell!","what","m or f?","what?","answer me","byebye","imm your girlfrined baby","hi","msn?","right","msn","whis there?","no","add you?","umm no...","Well... see ya later!","from?","???","America?","again?","male","20cm","i do too.","eqve"," ã…‹ã…‹ã…‹   ????","*who","to what?","they are nice"],"o":["asl","oh","nice to meet you","ok","what country are you from?>","hi","nop","aleyster crowler","where you from","17/m/europe","not gay","do you a wonbat?","hii","i know","3d","jdth","O?","me what?","stm","wanna fuck?"],"p":["like the religion","ensp","age","what p?","you dont capitalize your \"I\"s","i see","oqeui","hi","i am not too","so what we gonna do now?","so can i have it !","You don't want my pictures?","the game?","HEIL HITLER","knockknock","ok?","are you an hot girl?","21 m tr u?","yo"],"g":["gdeognS","AMAZING","you ?","jj","gf","hhj","wg","wgg","awg","weg","ger","er","g?","age?","lol okay."],"huh":["lols","e fixe?..is it eng.?","MSN?","man","win","cant keep up?","Which in the end you people"," Hao are you ","what??","who the hell is that?","huh?","fFck!","finnish","get out of my life","that is what you are","don't you japan?","asl ?","... ?","Heyy","uhu","o_O","when i started getting wet","Hiya","Like its twillight?","omg definitely","umm??","i'll fukk your brains out","search in youtube:","thanks","ooh yeah","lol","canada","ok","Laughing on the inside.","What's your name?","nothing","you never jizzed","and your dick","well?","photos?","u from china?","nevermind","owh"],"wait":["FILTHY LYING HE BITCH","no ?","ok","thanks","no","and ?","Dumb shit","depends","fuck you","be quick","hi","f/22/usa","heyy","I DIDN'T KNOW","cool","and you ?","WHAT","so?","wanna have cam sex?"],"hoho":["hehe","tebit","why u so stupid?","where?","are you okay?","..","Ding dong","asl, can i ask? n__n","i guess i win this time","i win again","son of bitch","whatever","send me the pics first","ahh, what you do?","heey santa claus","23 m L.A.","pic!","i just dont get it","people like","u?","BYE!","18 f japan","no not satiliets","wine whip","whats with canada?","hihi","santa..","what time is it at your place","hoho?"],"us":["california","wow","you're weird","i understand spanish","u?","whats us?","AGE?","U 're very interesting","ur from us??","GET OUT","not you ","take a shit","but u are a dude?","smoke","then say something chinese","harder","no","Why?","what?","hey ","you form","he doesnt","i hope","hi","gude"],"win":["win","Huh?","no","winwi","wi","you  come from ","okey","wib","ooooooooooooooooh","YOU LOSE.","where r u from?","anour nipplesd y","hi","So i lost?^^","U PHAIL!","hare","entirely different","sorry?..","a win? i'm not sure","what is not true","where do you find win?","is*","Brazil","so you are from ?","please","omg wat","do you play wii and win","hiã€","Right","ag"],"brazil":[":D","Oh cooollll","cool","yes","why?","and oyu?","rio de janeiro","19 female","e tu?","u?","estou muito quente","hangin out you","what about brazil","asl?","girl!","but i is, masta","portugal","ILVOEYOU.","so do i!!","SO FAR","africa","male or female","you?","and you?"],"w":["didnt we already cover this?","ohh, ok","usa","w?","hi","im very old","r34","faw","gwegawgawe","gwe","gw","ew","fw","ef","and im not china"],"yea":["why are you so fat?","sure","want to see a photro on me?","help me !!!!","and japanese","it is fine now","Because I am a Taiwan people","i'm in beijing"," omg","i'm upset","heyy","hah  interesting","that's a simple question.","sorry im not understand","what was the fat thing about?","Hm.","HI","not in this life","u from turkey ?","do you thing i am a floo","tell me","no","heippa","kkkkkkkkk","Oh yeah","16 m korea","www.nobrain.dk","get i","fds","what?","whatever they are"],"good":["sorry","asl?","good","gross","thats how we like em in ga","prostestant","he was from wuhan","bad","lol","your name ?","cause i am","wut","PEN15","okay","hi","sal?","how?","<<3","k what do you mean","I am 24 years old","alpacas are smarter","why?","å¹¹ä½ å¨˜   means   i'm fine","thank u ",":D","you are weird","and u?","yes"],"x":["me too!!!!!!","=D","are you  ok?",":D",":P ","heippa","bye ","mmmk.","hi","portugal","bone?","me 2","haha","i did","ummmm..ok","so rly","yes","xD","no","I know you didn't","normal?","1 inch long 10 inches wide","you \"are \" girl","bai","well seeya"],"boy":["you","i am a boy","what happen","AND I HOLLA WASSUp","country?","ok old?","Stay away from my child!","you?","new orfans","no ","girl","pics no","asl?","ahahahha","Nothing","bye","Yes im swedish","why?","you jewish?","helloo","where?","what do you do !","Where do you come from","you f","noï¼man","u?","wei shen me  ","girl here","ur asl?","yez im sure","im a girl","i'm Tony"],"boredpardon":["umm","go ","ololol","you are","hi","nope","sight","say sth.","Or f","fuck","14, but I look 18.","asl?","well iam a girl ","so accept defeat","fail","Yeah"],"h":["hi","terrible","what? oO","wat?","rt","gh","gj","jh","hg","rth","5y","hsrth","erh","s hf hfh","*hi lol","asl?"],"es":["You do?","to?","you said me B in my face?","that is horrible","no","You too"," are u ok?","f or m?","how old are u?","in the war","all the time","taipei","how old are you?","send pic of dic","21 f usa","MYyyy ROOOOM","hi","i like pikachu","u kind man","I like","I am holier-than-thee.","me too","What?","oka","u?","you or me>","where are u from? seriously","yeah","noo i dooo","y too)","wo cao nima","hii","perhapes","I see","do u know it","where are you from?","u still believe?","wha        t!?","they use ke in italy","idea?","yur turn","lol","age","?/??/Algeria","and you?","i used to be","are you gay?","i know","i have 36d's ","why are you such a tuna cunt","wtf u stupid lil shit"," you","i've been getting","goodbye","asian?","YES","i am","m or fe","çº¯å‚»é€¼","drunk? i am","a desire","do it faggot","hahaha","First-Person Shooter","can i leave ","fuck you","robot.","type 123 if you are a robot.","yes is the opposite of no","Cool.","waaaaait...","he's awesome","a;oweifja;wofijaw;oefij","WIN","dead bored","dum gooks","it's gret","nazifag","pika","i ask someone else","always","mawÃ¶","you?"],"ok":["gooooodmorgon","lol what","cook","bye","what are you thinking??!!!!","really?","alright"," im a guy","how you want","hmm","FUCK U","Where you from, stranger?","la la","you want to sex","um no","WHO ARE U TALKING TO","where","i'","eggs","what?where  are  you  from?","eeeee","so now what?","I am upfor that","whats with canada?","for who?","wat is that ?","wats ur email *","so what do u want from me *","wats ur adress ?","OK?","i like men","fuck","lets kick it dude","=  =","im pretty damn straight ","lllllllllllllllllllll8","do all u want ","so u a girl or boy","liar hahaha","taiwan","like","i am doing","i like sxe","ASL!?","hi","i am","u japan?","hey","ya","u girl?","where are you from?","bored pardon","... ?","F1","mfï¼Ÿ","you?","Spring elder brother pure men","what is it mean?","17","not a man","boring","which one","what?","computer?"," you just got ","ooh yeah im so hot","AFA SER DIG","yea ra u ","no, not ok","silly woman, dicks are for...","fine","Know what?","nok.","ok","yes","so are U Chinese","hey can we  frends?",">_>","you're liar","u lik to fuk?","yea","wht!","u a liar","nah 15","*sigh","i see moons","Fuuuuuck me","fat?","rawr... ima effin lion.","you lost it.","do it hard"],"m":["19 female","where r u from????/","u?","so, end of story?","relax","male","you are a boy?","hey","MINE",":)","how old?","m of marica?","age?","hi","impress me","you","london","m?","I like alpacas","never mind","wow........","cause you are giving me sass","you are mad","or a catscan?","are you m or f ","hoe old r u?","because","off","what do u mean?","i'm hard","i love you","no","quarter szed"],"orly":["o rly?","o rly?","USA","where are you","so","why?","u're not hot...","m or ","slut?","FFF","`?","good","NO","bye bye","lol","fine","yes","slut","im not jew asshole","/b/?","im horny","any pussy ","yep","xD","IT\"S BEEN A WHILE!","oreilly","Hi","m?",":'(","XDD","um","whats your hobby?","jasmine","I'm here.","nothing","asl?","And Paint.","both","yepp","fuck you man","Ya","hilarious"]}




