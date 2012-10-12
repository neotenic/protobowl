/* Modernizr 2.6.1 (Custom Build) | MIT & BSD
 * Build: http://modernizr.com/download/#-touch-teststyles-prefixes
 */

;window.Modernizr=function(a,b,c){function w(a){j.cssText=a}function x(a,b){return w(m.join(a+";")+(b||""))}function y(a,b){return typeof a===b}function z(a,b){return!!~(""+a).indexOf(b)}function A(a,b,d){for(var e in a){var f=b[a[e]];if(f!==c)return d===!1?a[e]:y(f,"function")?f.bind(d||b):f}return!1}var d="2.6.1",e={},f=!0,g=b.documentElement,h="modernizr",i=b.createElement(h),j=i.style,k,l={}.toString,m=" -webkit- -moz- -o- -ms- ".split(" "),n={},o={},p={},q=[],r=q.slice,s,t=function(a,c,d,e){var f,i,j,k=b.createElement("div"),l=b.body,m=l?l:b.createElement("body");if(parseInt(d,10))while(d--)j=b.createElement("div"),j.id=e?e[d]:h+(d+1),k.appendChild(j);return f=["&#173;",'<style id="s',h,'">',a,"</style>"].join(""),k.id=h,(l?k:m).innerHTML+=f,m.appendChild(k),l||(m.style.background="",g.appendChild(m)),i=c(k,a),l?k.parentNode.removeChild(k):m.parentNode.removeChild(m),!!i},u={}.hasOwnProperty,v;!y(u,"undefined")&&!y(u.call,"undefined")?v=function(a,b){return u.call(a,b)}:v=function(a,b){return b in a&&y(a.constructor.prototype[b],"undefined")},Function.prototype.bind||(Function.prototype.bind=function(b){var c=this;if(typeof c!="function")throw new TypeError;var d=r.call(arguments,1),e=function(){if(this instanceof e){var a=function(){};a.prototype=c.prototype;var f=new a,g=c.apply(f,d.concat(r.call(arguments)));return Object(g)===g?g:f}return c.apply(b,d.concat(r.call(arguments)))};return e}),n.touch=function(){var c;return"ontouchstart"in a||a.DocumentTouch&&b instanceof DocumentTouch?c=!0:t(["@media (",m.join("touch-enabled),("),h,")","{#modernizr{top:9px;position:absolute}}"].join(""),function(a){c=a.offsetTop===9}),c};for(var B in n)v(n,B)&&(s=B.toLowerCase(),e[s]=n[B](),q.push((e[s]?"":"no-")+s));return e.addTest=function(a,b){if(typeof a=="object")for(var d in a)v(a,d)&&e.addTest(d,a[d]);else{a=a.toLowerCase();if(e[a]!==c)return e;b=typeof b=="function"?b():b,f&&(g.className+=" "+(b?"":"no-")+a),e[a]=b}return e},w(""),i=k=null,function(a,b){function k(a,b){var c=a.createElement("p"),d=a.getElementsByTagName("head")[0]||a.documentElement;return c.innerHTML="x<style>"+b+"</style>",d.insertBefore(c.lastChild,d.firstChild)}function l(){var a=r.elements;return typeof a=="string"?a.split(" "):a}function m(a){var b=i[a[g]];return b||(b={},h++,a[g]=h,i[h]=b),b}function n(a,c,f){c||(c=b);if(j)return c.createElement(a);f||(f=m(c));var g;return f.cache[a]?g=f.cache[a].cloneNode():e.test(a)?g=(f.cache[a]=f.createElem(a)).cloneNode():g=f.createElem(a),g.canHaveChildren&&!d.test(a)?f.frag.appendChild(g):g}function o(a,c){a||(a=b);if(j)return a.createDocumentFragment();c=c||m(a);var d=c.frag.cloneNode(),e=0,f=l(),g=f.length;for(;e<g;e++)d.createElement(f[e]);return d}function p(a,b){b.cache||(b.cache={},b.createElem=a.createElement,b.createFrag=a.createDocumentFragment,b.frag=b.createFrag()),a.createElement=function(c){return r.shivMethods?n(c,a,b):b.createElem(c)},a.createDocumentFragment=Function("h,f","return function(){var n=f.cloneNode(),c=n.createElement;h.shivMethods&&("+l().join().replace(/\w+/g,function(a){return b.createElem(a),b.frag.createElement(a),'c("'+a+'")'})+");return n}")(r,b.frag)}function q(a){a||(a=b);var c=m(a);return r.shivCSS&&!f&&!c.hasCSS&&(c.hasCSS=!!k(a,"article,aside,figcaption,figure,footer,header,hgroup,nav,section{display:block}mark{background:#FF0;color:#000}")),j||p(a,c),a}var c=a.html5||{},d=/^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i,e=/^<|^(?:a|b|button|code|div|fieldset|form|h1|h2|h3|h4|h5|h6|i|iframe|img|input|label|li|link|ol|option|p|param|q|script|select|span|strong|style|table|tbody|td|textarea|tfoot|th|thead|tr|ul)$/i,f,g="_html5shiv",h=0,i={},j;(function(){try{var a=b.createElement("a");a.innerHTML="<xyz></xyz>",f="hidden"in a,j=a.childNodes.length==1||function(){b.createElement("a");var a=b.createDocumentFragment();return typeof a.cloneNode=="undefined"||typeof a.createDocumentFragment=="undefined"||typeof a.createElement=="undefined"}()}catch(c){f=!0,j=!0}})();var r={elements:c.elements||"abbr article aside audio bdi canvas data datalist details figcaption figure footer header hgroup mark meter nav output progress section summary time video",shivCSS:c.shivCSS!==!1,supportsUnknownElements:j,shivMethods:c.shivMethods!==!1,type:"default",shivDocument:q,createElement:n,createDocumentFragment:o};a.html5=r,q(b)}(this,b),e._version=d,e._prefixes=m,e.testStyles=t,g.className=g.className.replace(/(^|\s)no-js(\s|$)/,"$1$2")+(f?" js "+q.join(" "):""),e}(this,this.document),function(a,b,c){function d(a){return"[object Function]"==o.call(a)}function e(a){return"string"==typeof a}function f(){}function g(a){return!a||"loaded"==a||"complete"==a||"uninitialized"==a}function h(){var a=p.shift();q=1,a?a.t?m(function(){("c"==a.t?B.injectCss:B.injectJs)(a.s,0,a.a,a.x,a.e,1)},0):(a(),h()):q=0}function i(a,c,d,e,f,i,j){function k(b){if(!o&&g(l.readyState)&&(u.r=o=1,!q&&h(),l.onload=l.onreadystatechange=null,b)){"img"!=a&&m(function(){t.removeChild(l)},50);for(var d in y[c])y[c].hasOwnProperty(d)&&y[c][d].onload()}}var j=j||B.errorTimeout,l=b.createElement(a),o=0,r=0,u={t:d,s:c,e:f,a:i,x:j};1===y[c]&&(r=1,y[c]=[]),"object"==a?l.data=c:(l.src=c,l.type=a),l.width=l.height="0",l.onerror=l.onload=l.onreadystatechange=function(){k.call(this,r)},p.splice(e,0,u),"img"!=a&&(r||2===y[c]?(t.insertBefore(l,s?null:n),m(k,j)):y[c].push(l))}function j(a,b,c,d,f){return q=0,b=b||"j",e(a)?i("c"==b?v:u,a,b,this.i++,c,d,f):(p.splice(this.i++,0,a),1==p.length&&h()),this}function k(){var a=B;return a.loader={load:j,i:0},a}var l=b.documentElement,m=a.setTimeout,n=b.getElementsByTagName("script")[0],o={}.toString,p=[],q=0,r="MozAppearance"in l.style,s=r&&!!b.createRange().compareNode,t=s?l:n.parentNode,l=a.opera&&"[object Opera]"==o.call(a.opera),l=!!b.attachEvent&&!l,u=r?"object":l?"script":"img",v=l?"script":u,w=Array.isArray||function(a){return"[object Array]"==o.call(a)},x=[],y={},z={timeout:function(a,b){return b.length&&(a.timeout=b[0]),a}},A,B;B=function(a){function b(a){var a=a.split("!"),b=x.length,c=a.pop(),d=a.length,c={url:c,origUrl:c,prefixes:a},e,f,g;for(f=0;f<d;f++)g=a[f].split("="),(e=z[g.shift()])&&(c=e(c,g));for(f=0;f<b;f++)c=x[f](c);return c}function g(a,e,f,g,h){var i=b(a),j=i.autoCallback;i.url.split(".").pop().split("?").shift(),i.bypass||(e&&(e=d(e)?e:e[a]||e[g]||e[a.split("/").pop().split("?")[0]]),i.instead?i.instead(a,e,f,g,h):(y[i.url]?i.noexec=!0:y[i.url]=1,f.load(i.url,i.forceCSS||!i.forceJS&&"css"==i.url.split(".").pop().split("?").shift()?"c":c,i.noexec,i.attrs,i.timeout),(d(e)||d(j))&&f.load(function(){k(),e&&e(i.origUrl,h,g),j&&j(i.origUrl,h,g),y[i.url]=2})))}function h(a,b){function c(a,c){if(a){if(e(a))c||(j=function(){var a=[].slice.call(arguments);k.apply(this,a),l()}),g(a,j,b,0,h);else if(Object(a)===a)for(n in m=function(){var b=0,c;for(c in a)a.hasOwnProperty(c)&&b++;return b}(),a)a.hasOwnProperty(n)&&(!c&&!--m&&(d(j)?j=function(){var a=[].slice.call(arguments);k.apply(this,a),l()}:j[n]=function(a){return function(){var b=[].slice.call(arguments);a&&a.apply(this,b),l()}}(k[n])),g(a[n],j,b,n,h))}else!c&&l()}var h=!!a.test,i=a.load||a.both,j=a.callback||f,k=j,l=a.complete||f,m,n;c(h?a.yep:a.nope,!!i),i&&c(i)}var i,j,l=this.yepnope.loader;if(e(a))g(a,0,l,0);else if(w(a))for(i=0;i<a.length;i++)j=a[i],e(j)?g(j,0,l,0):w(j)?B(j):Object(j)===j&&h(j,l);else Object(a)===a&&h(a,l)},B.addPrefix=function(a,b){z[a]=b},B.addFilter=function(a){x.push(a)},B.errorTimeout=1e4,null==b.readyState&&b.addEventListener&&(b.readyState="loading",b.addEventListener("DOMContentLoaded",A=function(){b.removeEventListener("DOMContentLoaded",A,0),b.readyState="complete"},0)),a.yepnope=k(),a.yepnope.executeStack=h,a.yepnope.injectJs=function(a,c,d,e,i,j){var k=b.createElement("script"),l,o,e=e||B.errorTimeout;k.src=a;for(o in d)k.setAttribute(o,d[o]);c=j?h:c||f,k.onreadystatechange=k.onload=function(){!l&&g(k.readyState)&&(l=1,c(),k.onload=k.onreadystatechange=null)},m(function(){l||(l=1,c(1))},e),i?k.onload():n.parentNode.insertBefore(k,n)},a.yepnope.injectCss=function(a,c,d,e,g,i){var e=b.createElement("link"),j,c=i?h:c||f;e.href=a,e.rel="stylesheet",e.type="text/css";for(j in d)e.setAttribute(j,d[j]);g||(n.parentNode.insertBefore(e,n),m(c,0))}}(this,document),Modernizr.load=function(){yepnope.apply(window,[].slice.call(arguments,0))},Modernizr.addTest("csscalc",function(a,b,c){return b="width:",c="calc(10px);",a=document.createElement("div"),a.style.cssText=b+Modernizr._prefixes.join(c+b),!!a.style.length});
/* ===================================================
 * bootstrap-transition.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#transitions
 * ===================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  $(function () {

    "use strict"; // jshint ;_;


    /* CSS TRANSITION SUPPORT (http://www.modernizr.com/)
     * ======================================================= */

    $.support.transition = (function () {

      var transitionEnd = (function () {

        var el = document.createElement('bootstrap')
          , transEndEventNames = {
               'WebkitTransition' : 'webkitTransitionEnd'
            ,  'MozTransition'    : 'transitionend'
            ,  'OTransition'      : 'oTransitionEnd otransitionend'
            ,  'transition'       : 'transitionend'
            }
          , name

        for (name in transEndEventNames){
          if (el.style[name] !== undefined) {
            return transEndEventNames[name]
          }
        }

      }())

      return transitionEnd && {
        end: transitionEnd
      }

    })()

  })

}(window.jQuery);/* ==========================================================
 * bootstrap-alert.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#alerts
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* ALERT CLASS DEFINITION
  * ====================== */

  var dismiss = '[data-dismiss="alert"]'
    , Alert = function (el) {
        $(el).on('click', dismiss, this.close)
      }

  Alert.prototype.close = function (e) {
    var $this = $(this)
      , selector = $this.attr('data-target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = $(selector)

    e && e.preventDefault()

    $parent.length || ($parent = $this.hasClass('alert') ? $this : $this.parent())

    $parent.trigger(e = $.Event('close'))

    if (e.isDefaultPrevented()) return

    $parent.removeClass('in')

    function removeElement() {
      $parent
        .trigger('closed')
        .remove()
    }

    $.support.transition && $parent.hasClass('fade') ?
      $parent.on($.support.transition.end, removeElement) :
      removeElement()
  }


 /* ALERT PLUGIN DEFINITION
  * ======================= */

  $.fn.alert = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('alert')
      if (!data) $this.data('alert', (data = new Alert(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.alert.Constructor = Alert


 /* ALERT DATA-API
  * ============== */

  $(function () {
    $('body').on('click.alert.data-api', dismiss, Alert.prototype.close)
  })

}(window.jQuery);/* ============================================================
 * bootstrap-button.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#buttons
 * ============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

  "use strict"; // jshint ;_;


 /* BUTTON PUBLIC CLASS DEFINITION
  * ============================== */

  var Button = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.button.defaults, options)
  }

  Button.prototype.setState = function (state) {
    var d = 'disabled'
      , $el = this.$element
      , data = $el.data()
      , val = $el.is('input') ? 'val' : 'html'

    state = state + 'Text'
    data.resetText || $el.data('resetText', $el[val]())

    $el[val](data[state] || this.options[state])

    // push to event loop to allow forms to submit
    setTimeout(function () {
      state == 'loadingText' ?
        $el.addClass(d).attr(d, d) :
        $el.removeClass(d).removeAttr(d)
    }, 0)
  }

  Button.prototype.toggle = function () {
    var $parent = this.$element.closest('[data-toggle="buttons-radio"]')

    $parent && $parent
      .find('.active')
      .removeClass('active')

    this.$element.toggleClass('active')
  }


 /* BUTTON PLUGIN DEFINITION
  * ======================== */

  $.fn.button = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('button')
        , options = typeof option == 'object' && option
      if (!data) $this.data('button', (data = new Button(this, options)))
      if (option == 'toggle') data.toggle()
      else if (option) data.setState(option)
    })
  }

  $.fn.button.defaults = {
    loadingText: 'loading...'
  }

  $.fn.button.Constructor = Button


 /* BUTTON DATA-API
  * =============== */

  $(function () {
    $('body').on('click.button.data-api', '[data-toggle^=button]', function ( e ) {
      var $btn = $(e.target)
      if (!$btn.hasClass('btn')) $btn = $btn.closest('.btn')
      $btn.button('toggle')
    })
  })

}(window.jQuery);/* ==========================================================
 * bootstrap-carousel.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#carousel
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* CAROUSEL CLASS DEFINITION
  * ========================= */

  var Carousel = function (element, options) {
    this.$element = $(element)
    this.options = options
    this.options.slide && this.slide(this.options.slide)
    this.options.pause == 'hover' && this.$element
      .on('mouseenter', $.proxy(this.pause, this))
      .on('mouseleave', $.proxy(this.cycle, this))
  }

  Carousel.prototype = {

    cycle: function (e) {
      if (!e) this.paused = false
      this.options.interval
        && !this.paused
        && (this.interval = setInterval($.proxy(this.next, this), this.options.interval))
      return this
    }

  , to: function (pos) {
      var $active = this.$element.find('.item.active')
        , children = $active.parent().children()
        , activePos = children.index($active)
        , that = this

      if (pos > (children.length - 1) || pos < 0) return

      if (this.sliding) {
        return this.$element.one('slid', function () {
          that.to(pos)
        })
      }

      if (activePos == pos) {
        return this.pause().cycle()
      }

      return this.slide(pos > activePos ? 'next' : 'prev', $(children[pos]))
    }

  , pause: function (e) {
      if (!e) this.paused = true
      if (this.$element.find('.next, .prev').length && $.support.transition.end) {
        this.$element.trigger($.support.transition.end)
        this.cycle()
      }
      clearInterval(this.interval)
      this.interval = null
      return this
    }

  , next: function () {
      if (this.sliding) return
      return this.slide('next')
    }

  , prev: function () {
      if (this.sliding) return
      return this.slide('prev')
    }

  , slide: function (type, next) {
      var $active = this.$element.find('.item.active')
        , $next = next || $active[type]()
        , isCycling = this.interval
        , direction = type == 'next' ? 'left' : 'right'
        , fallback  = type == 'next' ? 'first' : 'last'
        , that = this
        , e = $.Event('slide', {
            relatedTarget: $next[0]
          })

      this.sliding = true

      isCycling && this.pause()

      $next = $next.length ? $next : this.$element.find('.item')[fallback]()

      if ($next.hasClass('active')) return

      if ($.support.transition && this.$element.hasClass('slide')) {
        this.$element.trigger(e)
        if (e.isDefaultPrevented()) return
        $next.addClass(type)
        $next[0].offsetWidth // force reflow
        $active.addClass(direction)
        $next.addClass(direction)
        this.$element.one($.support.transition.end, function () {
          $next.removeClass([type, direction].join(' ')).addClass('active')
          $active.removeClass(['active', direction].join(' '))
          that.sliding = false
          setTimeout(function () { that.$element.trigger('slid') }, 0)
        })
      } else {
        this.$element.trigger(e)
        if (e.isDefaultPrevented()) return
        $active.removeClass('active')
        $next.addClass('active')
        this.sliding = false
        this.$element.trigger('slid')
      }

      isCycling && this.cycle()

      return this
    }

  }


 /* CAROUSEL PLUGIN DEFINITION
  * ========================== */

  $.fn.carousel = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('carousel')
        , options = $.extend({}, $.fn.carousel.defaults, typeof option == 'object' && option)
        , action = typeof option == 'string' ? option : options.slide
      if (!data) $this.data('carousel', (data = new Carousel(this, options)))
      if (typeof option == 'number') data.to(option)
      else if (action) data[action]()
      else if (options.interval) data.cycle()
    })
  }

  $.fn.carousel.defaults = {
    interval: 5000
  , pause: 'hover'
  }

  $.fn.carousel.Constructor = Carousel


 /* CAROUSEL DATA-API
  * ================= */

  $(function () {
    $('body').on('click.carousel.data-api', '[data-slide]', function ( e ) {
      var $this = $(this), href
        , $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
        , options = !$target.data('modal') && $.extend({}, $target.data(), $this.data())
      $target.carousel(options)
      e.preventDefault()
    })
  })

}(window.jQuery);/* =============================================================
 * bootstrap-collapse.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#collapse
 * =============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

  "use strict"; // jshint ;_;


 /* COLLAPSE PUBLIC CLASS DEFINITION
  * ================================ */

  var Collapse = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.collapse.defaults, options)

    if (this.options.parent) {
      this.$parent = $(this.options.parent)
    }

    this.options.toggle && this.toggle()
  }

  Collapse.prototype = {

    constructor: Collapse

  , dimension: function () {
      var hasWidth = this.$element.hasClass('width')
      return hasWidth ? 'width' : 'height'
    }

  , show: function () {
      var dimension
        , scroll
        , actives
        , hasData

      if (this.transitioning) return

      dimension = this.dimension()
      scroll = $.camelCase(['scroll', dimension].join('-'))
      actives = this.$parent && this.$parent.find('> .accordion-group > .in')

      if (actives && actives.length) {
        hasData = actives.data('collapse')
        if (hasData && hasData.transitioning) return
        actives.collapse('hide')
        hasData || actives.data('collapse', null)
      }

      this.$element[dimension](0)
      this.transition('addClass', $.Event('show'), 'shown')
      $.support.transition && this.$element[dimension](this.$element[0][scroll])
    }

  , hide: function () {
      var dimension
      if (this.transitioning) return
      dimension = this.dimension()
      this.reset(this.$element[dimension]())
      this.transition('removeClass', $.Event('hide'), 'hidden')
      this.$element[dimension](0)
    }

  , reset: function (size) {
      var dimension = this.dimension()

      this.$element
        .removeClass('collapse')
        [dimension](size || 'auto')
        [0].offsetWidth

      this.$element[size !== null ? 'addClass' : 'removeClass']('collapse')

      return this
    }

  , transition: function (method, startEvent, completeEvent) {
      var that = this
        , complete = function () {
            if (startEvent.type == 'show') that.reset()
            that.transitioning = 0
            that.$element.trigger(completeEvent)
          }

      this.$element.trigger(startEvent)

      if (startEvent.isDefaultPrevented()) return

      this.transitioning = 1

      this.$element[method]('in')

      $.support.transition && this.$element.hasClass('collapse') ?
        this.$element.one($.support.transition.end, complete) :
        complete()
    }

  , toggle: function () {
      this[this.$element.hasClass('in') ? 'hide' : 'show']()
    }

  }


 /* COLLAPSIBLE PLUGIN DEFINITION
  * ============================== */

  $.fn.collapse = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('collapse')
        , options = typeof option == 'object' && option
      if (!data) $this.data('collapse', (data = new Collapse(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.collapse.defaults = {
    toggle: true
  }

  $.fn.collapse.Constructor = Collapse


 /* COLLAPSIBLE DATA-API
  * ==================== */

  $(function () {
    $('body').on('click.collapse.data-api', '[data-toggle=collapse]', function (e) {
      var $this = $(this), href
        , target = $this.attr('data-target')
          || e.preventDefault()
          || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '') //strip for ie7
        , option = $(target).data('collapse') ? 'toggle' : $this.data()
      $this[$(target).hasClass('in') ? 'addClass' : 'removeClass']('collapsed')
      $(target).collapse(option)
    })
  })

}(window.jQuery);/* ============================================================
 * bootstrap-dropdown.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#dropdowns
 * ============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

  "use strict"; // jshint ;_;


 /* DROPDOWN CLASS DEFINITION
  * ========================= */

  var toggle = '[data-toggle=dropdown]'
    , Dropdown = function (element) {
        var $el = $(element).on('click.dropdown.data-api', this.toggle)
        $('html').on('click.dropdown.data-api', function () {
          $el.parent().removeClass('open')
        })
      }

  Dropdown.prototype = {

    constructor: Dropdown

  , toggle: function (e) {
      var $this = $(this)
        , $parent
        , isActive

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      clearMenus()

      if (!isActive) {
        $parent.toggleClass('open')
        $this.focus()
      }

      return false
    }

  , keydown: function (e) {
      var $this
        , $items
        , $active
        , $parent
        , isActive
        , index

      if (!/(38|40|27)/.test(e.keyCode)) return

      $this = $(this)

      e.preventDefault()
      e.stopPropagation()

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      if (!isActive || (isActive && e.keyCode == 27)) return $this.click()

      $items = $('[role=menu] li:not(.divider) a', $parent)

      if (!$items.length) return

      index = $items.index($items.filter(':focus'))

      if (e.keyCode == 38 && index > 0) index--                                        // up
      if (e.keyCode == 40 && index < $items.length - 1) index++                        // down
      if (!~index) index = 0

      $items
        .eq(index)
        .focus()
    }

  }

  function clearMenus() {
    getParent($(toggle))
      .removeClass('open')
  }

  function getParent($this) {
    var selector = $this.attr('data-target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && /#/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = $(selector)
    $parent.length || ($parent = $this.parent())

    return $parent
  }


  /* DROPDOWN PLUGIN DEFINITION
   * ========================== */

  $.fn.dropdown = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('dropdown')
      if (!data) $this.data('dropdown', (data = new Dropdown(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.dropdown.Constructor = Dropdown


  /* APPLY TO STANDARD DROPDOWN ELEMENTS
   * =================================== */

  $(function () {
    $('html')
      .on('click.dropdown.data-api touchstart.dropdown.data-api', clearMenus)
    $('body')
      .on('click.dropdown touchstart.dropdown.data-api', '.dropdown form', function (e) { e.stopPropagation() })
      .on('click.dropdown.data-api touchstart.dropdown.data-api'  , toggle, Dropdown.prototype.toggle)
      .on('keydown.dropdown.data-api touchstart.dropdown.data-api', toggle + ', [role=menu]' , Dropdown.prototype.keydown)
  })

}(window.jQuery);/* =========================================================
 * bootstrap-modal.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#modals
 * =========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================= */


!function ($) {

  "use strict"; // jshint ;_;


 /* MODAL CLASS DEFINITION
  * ====================== */

  var Modal = function (element, options) {
    this.options = options
    this.$element = $(element)
      .delegate('[data-dismiss="modal"]', 'click.dismiss.modal', $.proxy(this.hide, this))
    this.options.remote && this.$element.find('.modal-body').load(this.options.remote)
  }

  Modal.prototype = {

      constructor: Modal

    , toggle: function () {
        return this[!this.isShown ? 'show' : 'hide']()
      }

    , show: function () {
        var that = this
          , e = $.Event('show')

        this.$element.trigger(e)

        if (this.isShown || e.isDefaultPrevented()) return

        $('body').addClass('modal-open')

        this.isShown = true

        this.escape()

        this.backdrop(function () {
          var transition = $.support.transition && that.$element.hasClass('fade')

          if (!that.$element.parent().length) {
            that.$element.appendTo(document.body) //don't move modals dom position
          }

          that.$element
            .show()

          if (transition) {
            that.$element[0].offsetWidth // force reflow
          }

          that.$element
            .addClass('in')
            .attr('aria-hidden', false)
            .focus()

          that.enforceFocus()

          transition ?
            that.$element.one($.support.transition.end, function () { that.$element.trigger('shown') }) :
            that.$element.trigger('shown')

        })
      }

    , hide: function (e) {
        e && e.preventDefault()

        var that = this

        e = $.Event('hide')

        this.$element.trigger(e)

        if (!this.isShown || e.isDefaultPrevented()) return

        this.isShown = false

        $('body').removeClass('modal-open')

        this.escape()

        $(document).off('focusin.modal')

        this.$element
          .removeClass('in')
          .attr('aria-hidden', true)

        $.support.transition && this.$element.hasClass('fade') ?
          this.hideWithTransition() :
          this.hideModal()
      }

    , enforceFocus: function () {
        var that = this
        $(document).on('focusin.modal', function (e) {
          if (that.$element[0] !== e.target && !that.$element.has(e.target).length) {
            that.$element.focus()
          }
        })
      }

    , escape: function () {
        var that = this
        if (this.isShown && this.options.keyboard) {
          this.$element.on('keyup.dismiss.modal', function ( e ) {
            e.which == 27 && that.hide()
          })
        } else if (!this.isShown) {
          this.$element.off('keyup.dismiss.modal')
        }
      }

    , hideWithTransition: function () {
        var that = this
          , timeout = setTimeout(function () {
              that.$element.off($.support.transition.end)
              that.hideModal()
            }, 500)

        this.$element.one($.support.transition.end, function () {
          clearTimeout(timeout)
          that.hideModal()
        })
      }

    , hideModal: function (that) {
        this.$element
          .hide()
          .trigger('hidden')

        this.backdrop()
      }

    , removeBackdrop: function () {
        this.$backdrop.remove()
        this.$backdrop = null
      }

    , backdrop: function (callback) {
        var that = this
          , animate = this.$element.hasClass('fade') ? 'fade' : ''

        if (this.isShown && this.options.backdrop) {
          var doAnimate = $.support.transition && animate

          this.$backdrop = $('<div class="modal-backdrop ' + animate + '" />')
            .appendTo(document.body)

          if (this.options.backdrop != 'static') {
            this.$backdrop.click($.proxy(this.hide, this))
          }

          if (doAnimate) this.$backdrop[0].offsetWidth // force reflow

          this.$backdrop.addClass('in')

          doAnimate ?
            this.$backdrop.one($.support.transition.end, callback) :
            callback()

        } else if (!this.isShown && this.$backdrop) {
          this.$backdrop.removeClass('in')

          $.support.transition && this.$element.hasClass('fade')?
            this.$backdrop.one($.support.transition.end, $.proxy(this.removeBackdrop, this)) :
            this.removeBackdrop()

        } else if (callback) {
          callback()
        }
      }
  }


 /* MODAL PLUGIN DEFINITION
  * ======================= */

  $.fn.modal = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('modal')
        , options = $.extend({}, $.fn.modal.defaults, $this.data(), typeof option == 'object' && option)
      if (!data) $this.data('modal', (data = new Modal(this, options)))
      if (typeof option == 'string') data[option]()
      else if (options.show) data.show()
    })
  }

  $.fn.modal.defaults = {
      backdrop: true
    , keyboard: true
    , show: true
  }

  $.fn.modal.Constructor = Modal


 /* MODAL DATA-API
  * ============== */

  $(function () {
    $('body').on('click.modal.data-api', '[data-toggle="modal"]', function ( e ) {
      var $this = $(this)
        , href = $this.attr('href')
        , $target = $($this.attr('data-target') || (href && href.replace(/.*(?=#[^\s]+$)/, ''))) //strip for ie7
        , option = $target.data('modal') ? 'toggle' : $.extend({ remote: !/#/.test(href) && href }, $target.data(), $this.data())

      e.preventDefault()

      $target
        .modal(option)
        .one('hide', function () {
          $this.focus()
        })
    })
  })

}(window.jQuery);/* ===========================================================
 * bootstrap-tooltip.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#tooltips
 * Inspired by the original jQuery.tipsy by Jason Frame
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* TOOLTIP PUBLIC CLASS DEFINITION
  * =============================== */

  var Tooltip = function (element, options) {
    this.init('tooltip', element, options)
  }

  Tooltip.prototype = {

    constructor: Tooltip

  , init: function (type, element, options) {
      var eventIn
        , eventOut

      this.type = type
      this.$element = $(element)
      this.options = this.getOptions(options)
      this.enabled = true

      if (this.options.trigger == 'click') {
        this.$element.on('click.' + this.type, this.options.selector, $.proxy(this.toggle, this))
      } else if (this.options.trigger != 'manual') {
        eventIn = this.options.trigger == 'hover' ? 'mouseenter' : 'focus'
        eventOut = this.options.trigger == 'hover' ? 'mouseleave' : 'blur'
        this.$element.on(eventIn + '.' + this.type, this.options.selector, $.proxy(this.enter, this))
        this.$element.on(eventOut + '.' + this.type, this.options.selector, $.proxy(this.leave, this))
      }

      this.options.selector ?
        (this._options = $.extend({}, this.options, { trigger: 'manual', selector: '' })) :
        this.fixTitle()
    }

  , getOptions: function (options) {
      options = $.extend({}, $.fn[this.type].defaults, options, this.$element.data())

      if (options.delay && typeof options.delay == 'number') {
        options.delay = {
          show: options.delay
        , hide: options.delay
        }
      }

      return options
    }

  , enter: function (e) {
      var self = $(e.currentTarget)[this.type](this._options).data(this.type)

      if (!self.options.delay || !self.options.delay.show) return self.show()

      clearTimeout(this.timeout)
      self.hoverState = 'in'
      this.timeout = setTimeout(function() {
        if (self.hoverState == 'in') self.show()
      }, self.options.delay.show)
    }

  , leave: function (e) {
      var self = $(e.currentTarget)[this.type](this._options).data(this.type)

      if (this.timeout) clearTimeout(this.timeout)
      if (!self.options.delay || !self.options.delay.hide) return self.hide()

      self.hoverState = 'out'
      this.timeout = setTimeout(function() {
        if (self.hoverState == 'out') self.hide()
      }, self.options.delay.hide)
    }

  , show: function () {
      var $tip
        , inside
        , pos
        , actualWidth
        , actualHeight
        , placement
        , tp

      if (this.hasContent() && this.enabled) {
        $tip = this.tip()
        this.setContent()

        if (this.options.animation) {
          $tip.addClass('fade')
        }

        placement = typeof this.options.placement == 'function' ?
          this.options.placement.call(this, $tip[0], this.$element[0]) :
          this.options.placement

        inside = /in/.test(placement)

        $tip
          .remove()
          .css({ top: 0, left: 0, display: 'block' })
          .appendTo(inside ? this.$element : document.body)

        pos = this.getPosition(inside)

        actualWidth = $tip[0].offsetWidth
        actualHeight = $tip[0].offsetHeight

        switch (inside ? placement.split(' ')[1] : placement) {
          case 'bottom':
            tp = {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
            break
          case 'top':
            tp = {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
            break
          case 'left':
            tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth}
            break
          case 'right':
            tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width}
            break
        }

        $tip
          .css(tp)
          .addClass(placement)
          .addClass('in')
      }
    }

  , setContent: function () {
      var $tip = this.tip()
        , title = this.getTitle()

      $tip.find('.tooltip-inner')[this.options.html ? 'html' : 'text'](title)
      $tip.removeClass('fade in top bottom left right')
    }

  , hide: function () {
      var that = this
        , $tip = this.tip()

      $tip.removeClass('in')

      function removeWithAnimation() {
        var timeout = setTimeout(function () {
          $tip.off($.support.transition.end).remove()
        }, 500)

        $tip.one($.support.transition.end, function () {
          clearTimeout(timeout)
          $tip.remove()
        })
      }

      $.support.transition && this.$tip.hasClass('fade') ?
        removeWithAnimation() :
        $tip.remove()

      return this
    }

  , fixTitle: function () {
      var $e = this.$element
      if ($e.attr('title') || typeof($e.attr('data-original-title')) != 'string') {
        $e.attr('data-original-title', $e.attr('title') || '').removeAttr('title')
      }
    }

  , hasContent: function () {
      return this.getTitle()
    }

  , getPosition: function (inside) {
      return $.extend({}, (inside ? {top: 0, left: 0} : this.$element.offset()), {
        width: this.$element[0].offsetWidth
      , height: this.$element[0].offsetHeight
      })
    }

  , getTitle: function () {
      var title
        , $e = this.$element
        , o = this.options

      title = $e.attr('data-original-title')
        || (typeof o.title == 'function' ? o.title.call($e[0]) :  o.title)

      return title
    }

  , tip: function () {
      return this.$tip = this.$tip || $(this.options.template)
    }

  , validate: function () {
      if (!this.$element[0].parentNode) {
        this.hide()
        this.$element = null
        this.options = null
      }
    }

  , enable: function () {
      this.enabled = true
    }

  , disable: function () {
      this.enabled = false
    }

  , toggleEnabled: function () {
      this.enabled = !this.enabled
    }

  , toggle: function () {
      this[this.tip().hasClass('in') ? 'hide' : 'show']()
    }

  , destroy: function () {
      this.hide().$element.off('.' + this.type).removeData(this.type)
    }

  }


 /* TOOLTIP PLUGIN DEFINITION
  * ========================= */

  $.fn.tooltip = function ( option ) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('tooltip')
        , options = typeof option == 'object' && option
      if (!data) $this.data('tooltip', (data = new Tooltip(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.tooltip.Constructor = Tooltip

  $.fn.tooltip.defaults = {
    animation: true
  , placement: 'top'
  , selector: false
  , template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
  , trigger: 'hover'
  , title: ''
  , delay: 0
  , html: true
  }

}(window.jQuery);
/* ===========================================================
 * bootstrap-popover.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#popovers
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* POPOVER PUBLIC CLASS DEFINITION
  * =============================== */

  var Popover = function (element, options) {
    this.init('popover', element, options)
  }


  /* NOTE: POPOVER EXTENDS BOOTSTRAP-TOOLTIP.js
     ========================================== */

  Popover.prototype = $.extend({}, $.fn.tooltip.Constructor.prototype, {

    constructor: Popover

  , setContent: function () {
      var $tip = this.tip()
        , title = this.getTitle()
        , content = this.getContent()

      $tip.find('.popover-title')[this.options.html ? 'html' : 'text'](title)
      $tip.find('.popover-content > *')[this.options.html ? 'html' : 'text'](content)

      $tip.removeClass('fade top bottom left right in')
    }

  , hasContent: function () {
      return this.getTitle() || this.getContent()
    }

  , getContent: function () {
      var content
        , $e = this.$element
        , o = this.options

      content = $e.attr('data-content')
        || (typeof o.content == 'function' ? o.content.call($e[0]) :  o.content)

      return content
    }

  , tip: function () {
      if (!this.$tip) {
        this.$tip = $(this.options.template)
      }
      return this.$tip
    }

  , destroy: function () {
      this.hide().$element.off('.' + this.type).removeData(this.type)
    }

  })


 /* POPOVER PLUGIN DEFINITION
  * ======================= */

  $.fn.popover = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('popover')
        , options = typeof option == 'object' && option
      if (!data) $this.data('popover', (data = new Popover(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.popover.Constructor = Popover

  $.fn.popover.defaults = $.extend({} , $.fn.tooltip.defaults, {
    placement: 'right'
  , trigger: 'click'
  , content: ''
  , template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>'
  })

}(window.jQuery);/* =============================================================
 * bootstrap-scrollspy.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#scrollspy
 * =============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* SCROLLSPY CLASS DEFINITION
  * ========================== */

  function ScrollSpy(element, options) {
    var process = $.proxy(this.process, this)
      , $element = $(element).is('body') ? $(window) : $(element)
      , href
    this.options = $.extend({}, $.fn.scrollspy.defaults, options)
    this.$scrollElement = $element.on('scroll.scroll-spy.data-api', process)
    this.selector = (this.options.target
      || ((href = $(element).attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
      || '') + ' .nav li > a'
    this.$body = $('body')
    this.refresh()
    this.process()
  }

  ScrollSpy.prototype = {

      constructor: ScrollSpy

    , refresh: function () {
        var self = this
          , $targets

        this.offsets = $([])
        this.targets = $([])

        $targets = this.$body
          .find(this.selector)
          .map(function () {
            var $el = $(this)
              , href = $el.data('target') || $el.attr('href')
              , $href = /^#\w/.test(href) && $(href)
            return ( $href
              && $href.length
              && [[ $href.position().top, href ]] ) || null
          })
          .sort(function (a, b) { return a[0] - b[0] })
          .each(function () {
            self.offsets.push(this[0])
            self.targets.push(this[1])
          })
      }

    , process: function () {
        var scrollTop = this.$scrollElement.scrollTop() + this.options.offset
          , scrollHeight = this.$scrollElement[0].scrollHeight || this.$body[0].scrollHeight
          , maxScroll = scrollHeight - this.$scrollElement.height()
          , offsets = this.offsets
          , targets = this.targets
          , activeTarget = this.activeTarget
          , i

        if (scrollTop >= maxScroll) {
          return activeTarget != (i = targets.last()[0])
            && this.activate ( i )
        }

        for (i = offsets.length; i--;) {
          activeTarget != targets[i]
            && scrollTop >= offsets[i]
            && (!offsets[i + 1] || scrollTop <= offsets[i + 1])
            && this.activate( targets[i] )
        }
      }

    , activate: function (target) {
        var active
          , selector

        this.activeTarget = target

        $(this.selector)
          .parent('.active')
          .removeClass('active')

        selector = this.selector
          + '[data-target="' + target + '"],'
          + this.selector + '[href="' + target + '"]'

        active = $(selector)
          .parent('li')
          .addClass('active')

        if (active.parent('.dropdown-menu').length)  {
          active = active.closest('li.dropdown').addClass('active')
        }

        active.trigger('activate')
      }

  }


 /* SCROLLSPY PLUGIN DEFINITION
  * =========================== */

  $.fn.scrollspy = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('scrollspy')
        , options = typeof option == 'object' && option
      if (!data) $this.data('scrollspy', (data = new ScrollSpy(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.scrollspy.Constructor = ScrollSpy

  $.fn.scrollspy.defaults = {
    offset: 10
  }


 /* SCROLLSPY DATA-API
  * ================== */

  $(window).on('load', function () {
    $('[data-spy="scroll"]').each(function () {
      var $spy = $(this)
      $spy.scrollspy($spy.data())
    })
  })

}(window.jQuery);/* ========================================================
 * bootstrap-tab.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#tabs
 * ========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ======================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* TAB CLASS DEFINITION
  * ==================== */

  var Tab = function (element) {
    this.element = $(element)
  }

  Tab.prototype = {

    constructor: Tab

  , show: function () {
      var $this = this.element
        , $ul = $this.closest('ul:not(.dropdown-menu)')
        , selector = $this.attr('data-target')
        , previous
        , $target
        , e

      if (!selector) {
        selector = $this.attr('href')
        selector = selector && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
      }

      if ( $this.parent('li').hasClass('active') ) return

      previous = $ul.find('.active a').last()[0]

      e = $.Event('show', {
        relatedTarget: previous
      })

      $this.trigger(e)

      if (e.isDefaultPrevented()) return

      $target = $(selector)

      this.activate($this.parent('li'), $ul)
      this.activate($target, $target.parent(), function () {
        $this.trigger({
          type: 'shown'
        , relatedTarget: previous
        })
      })
    }

  , activate: function ( element, container, callback) {
      var $active = container.find('> .active')
        , transition = callback
            && $.support.transition
            && $active.hasClass('fade')

      function next() {
        $active
          .removeClass('active')
          .find('> .dropdown-menu > .active')
          .removeClass('active')

        element.addClass('active')

        if (transition) {
          element[0].offsetWidth // reflow for transition
          element.addClass('in')
        } else {
          element.removeClass('fade')
        }

        if ( element.parent('.dropdown-menu') ) {
          element.closest('li.dropdown').addClass('active')
        }

        callback && callback()
      }

      transition ?
        $active.one($.support.transition.end, next) :
        next()

      $active.removeClass('in')
    }
  }


 /* TAB PLUGIN DEFINITION
  * ===================== */

  $.fn.tab = function ( option ) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('tab')
      if (!data) $this.data('tab', (data = new Tab(this)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.tab.Constructor = Tab


 /* TAB DATA-API
  * ============ */

  $(function () {
    $('body').on('click.tab.data-api', '[data-toggle="tab"], [data-toggle="pill"]', function (e) {
      e.preventDefault()
      $(this).tab('show')
    })
  })

}(window.jQuery);/* =============================================================
 * bootstrap-typeahead.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#typeahead
 * =============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function($){

  "use strict"; // jshint ;_;


 /* TYPEAHEAD PUBLIC CLASS DEFINITION
  * ================================= */

  var Typeahead = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.typeahead.defaults, options)
    this.matcher = this.options.matcher || this.matcher
    this.sorter = this.options.sorter || this.sorter
    this.highlighter = this.options.highlighter || this.highlighter
    this.updater = this.options.updater || this.updater
    this.$menu = $(this.options.menu).appendTo('body')
    this.source = this.options.source
    this.shown = false
    this.listen()
  }

  Typeahead.prototype = {

    constructor: Typeahead

  , select: function () {
      var val = this.$menu.find('.active').attr('data-value')
      this.$element
        .val(this.updater(val))
        .change()
      return this.hide()
    }

  , updater: function (item) {
      return item
    }

  , show: function () {
      var pos = $.extend({}, this.$element.offset(), {
        height: this.$element[0].offsetHeight
      })

      this.$menu.css({
        top: pos.top + pos.height
      , left: pos.left
      })

      this.$menu.show()
      this.shown = true
      return this
    }

  , hide: function () {
      this.$menu.hide()
      this.shown = false
      return this
    }

  , lookup: function (event) {
      var items

      this.query = this.$element.val()

      if (!this.query || this.query.length < this.options.minLength) {
        return this.shown ? this.hide() : this
      }

      items = $.isFunction(this.source) ? this.source(this.query, $.proxy(this.process, this)) : this.source

      return items ? this.process(items) : this
    }

  , process: function (items) {
      var that = this

      items = $.grep(items, function (item) {
        return that.matcher(item)
      })

      items = this.sorter(items)

      if (!items.length) {
        return this.shown ? this.hide() : this
      }

      return this.render(items.slice(0, this.options.items)).show()
    }

  , matcher: function (item) {
      return ~item.toLowerCase().indexOf(this.query.toLowerCase())
    }

  , sorter: function (items) {
      var beginswith = []
        , caseSensitive = []
        , caseInsensitive = []
        , item

      while (item = items.shift()) {
        if (!item.toLowerCase().indexOf(this.query.toLowerCase())) beginswith.push(item)
        else if (~item.indexOf(this.query)) caseSensitive.push(item)
        else caseInsensitive.push(item)
      }

      return beginswith.concat(caseSensitive, caseInsensitive)
    }

  , highlighter: function (item) {
      var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
      return item.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
        return '<strong>' + match + '</strong>'
      })
    }

  , render: function (items) {
      var that = this

      items = $(items).map(function (i, item) {
        i = $(that.options.item).attr('data-value', item)
        i.find('a').html(that.highlighter(item))
        return i[0]
      })

      items.first().addClass('active')
      this.$menu.html(items)
      return this
    }

  , next: function (event) {
      var active = this.$menu.find('.active').removeClass('active')
        , next = active.next()

      if (!next.length) {
        next = $(this.$menu.find('li')[0])
      }

      next.addClass('active')
    }

  , prev: function (event) {
      var active = this.$menu.find('.active').removeClass('active')
        , prev = active.prev()

      if (!prev.length) {
        prev = this.$menu.find('li').last()
      }

      prev.addClass('active')
    }

  , listen: function () {
      this.$element
        .on('blur',     $.proxy(this.blur, this))
        .on('keypress', $.proxy(this.keypress, this))
        .on('keyup',    $.proxy(this.keyup, this))

      if ($.browser.chrome || $.browser.webkit || $.browser.msie) {
        this.$element.on('keydown', $.proxy(this.keydown, this))
      }

      this.$menu
        .on('click', $.proxy(this.click, this))
        .on('mouseenter', 'li', $.proxy(this.mouseenter, this))
    }

  , move: function (e) {
      if (!this.shown) return

      switch(e.keyCode) {
        case 9: // tab
        case 13: // enter
        case 27: // escape
          e.preventDefault()
          break

        case 38: // up arrow
          e.preventDefault()
          this.prev()
          break

        case 40: // down arrow
          e.preventDefault()
          this.next()
          break
      }

      e.stopPropagation()
    }

  , keydown: function (e) {
      this.suppressKeyPressRepeat = !~$.inArray(e.keyCode, [40,38,9,13,27])
      this.move(e)
    }

  , keypress: function (e) {
      if (this.suppressKeyPressRepeat) return
      this.move(e)
    }

  , keyup: function (e) {
      switch(e.keyCode) {
        case 40: // down arrow
        case 38: // up arrow
          break

        case 9: // tab
        case 13: // enter
          if (!this.shown) return
          this.select()
          break

        case 27: // escape
          if (!this.shown) return
          this.hide()
          break

        default:
          this.lookup()
      }

      e.stopPropagation()
      e.preventDefault()
  }

  , blur: function (e) {
      var that = this
      setTimeout(function () { that.hide() }, 150)
    }

  , click: function (e) {
      e.stopPropagation()
      e.preventDefault()
      this.select()
    }

  , mouseenter: function (e) {
      this.$menu.find('.active').removeClass('active')
      $(e.currentTarget).addClass('active')
    }

  }


  /* TYPEAHEAD PLUGIN DEFINITION
   * =========================== */

  $.fn.typeahead = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('typeahead')
        , options = typeof option == 'object' && option
      if (!data) $this.data('typeahead', (data = new Typeahead(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.typeahead.defaults = {
    source: []
  , items: 8
  , menu: '<ul class="typeahead dropdown-menu"></ul>'
  , item: '<li><a href="#"></a></li>'
  , minLength: 1
  }

  $.fn.typeahead.Constructor = Typeahead


 /*   TYPEAHEAD DATA-API
  * ================== */

  $(function () {
    $('body').on('focus.typeahead.data-api', '[data-provide="typeahead"]', function (e) {
      var $this = $(this)
      if ($this.data('typeahead')) return
      e.preventDefault()
      $this.typeahead($this.data())
    })
  })

}(window.jQuery);
/* ==========================================================
 * bootstrap-affix.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#affix
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* AFFIX CLASS DEFINITION
  * ====================== */

  var Affix = function (element, options) {
    this.options = $.extend({}, $.fn.affix.defaults, options)
    this.$window = $(window).on('scroll.affix.data-api', $.proxy(this.checkPosition, this))
    this.$element = $(element)
    this.checkPosition()
  }

  Affix.prototype.checkPosition = function () {
    if (!this.$element.is(':visible')) return

    var scrollHeight = $(document).height()
      , scrollTop = this.$window.scrollTop()
      , position = this.$element.offset()
      , offset = this.options.offset
      , offsetBottom = offset.bottom
      , offsetTop = offset.top
      , reset = 'affix affix-top affix-bottom'
      , affix

    if (typeof offset != 'object') offsetBottom = offsetTop = offset
    if (typeof offsetTop == 'function') offsetTop = offset.top()
    if (typeof offsetBottom == 'function') offsetBottom = offset.bottom()

    affix = this.unpin != null && (scrollTop + this.unpin <= position.top) ?
      false    : offsetBottom != null && (position.top + this.$element.height() >= scrollHeight - offsetBottom) ?
      'bottom' : offsetTop != null && scrollTop <= offsetTop ?
      'top'    : false

    if (this.affixed === affix) return

    this.affixed = affix
    this.unpin = affix == 'bottom' ? position.top - scrollTop : null

    this.$element.removeClass(reset).addClass('affix' + (affix ? '-' + affix : ''))
  }


 /* AFFIX PLUGIN DEFINITION
  * ======================= */

  $.fn.affix = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('affix')
        , options = typeof option == 'object' && option
      if (!data) $this.data('affix', (data = new Affix(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.affix.Constructor = Affix

  $.fn.affix.defaults = {
    offset: 0
  }


 /* AFFIX DATA-API
  * ============== */

  $(window).on('load', function () {
    $('[data-spy="affix"]').each(function () {
      var $spy = $(this)
        , data = $spy.data()

      data.offset = data.offset || {}

      data.offsetBottom && (data.offset.bottom = data.offsetBottom)
      data.offsetTop && (data.offset.top = data.offsetTop)

      $spy.affix(data)
    })
  })


}(window.jQuery);

window.requestAnimationFrame || (window.requestAnimationFrame = window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
  return window.setTimeout(function() {
    return callback(+new Date());
  }, 1000 / 60);
});

jQuery.fn.disable = function(value) {
  var current;
  current = $(this).attr('disabled') === 'disabled';
  if (current !== value) {
    return $(this).attr('disabled', value);
  }
};

jQuery.fn.fireworks = function(times) {
  var duration, i, _i, _results,
    _this = this;
  if (times == null) {
    times = 5;
  }
  _results = [];
  for (i = _i = 0; 0 <= times ? _i < times : _i > times; i = 0 <= times ? ++_i : --_i) {
    duration = Math.random() * 2000;
    _results.push(this.delay(duration).queue(function() {
      var ang, color, end_size, j, left, seconds, size, speed, top, vx, vy, _j, _ref, _results1;
      _ref = _this.position(), top = _ref.top, left = _ref.left;
      left += jQuery(window).width() * Math.random();
      top += jQuery(window).height() * Math.random();
      color = '#' + Math.random().toString(16).slice(2, 8);
      _this.dequeue();
      _results1 = [];
      for (j = _j = 0; _j < 50; j = ++_j) {
        ang = Math.random() * 6.294;
        speed = Math.min(100, 150 * Math.random());
        vx = speed * Math.cos(ang);
        vy = speed * Math.sin(ang);
        seconds = 2 * Math.random();
        size = 5;
        end_size = Math.random() * size;
        _results1.push(jQuery('<div>').css({
          "position": 'fixed',
          "background-color": color,
          'width': size,
          'height': size,
          'border-radius': size,
          'top': top,
          'left': left
        }).appendTo('body').animate({
          left: "+=" + (vx * seconds),
          top: "+=" + (vy * seconds),
          width: end_size,
          height: end_size
        }, {
          duration: seconds * 1000,
          complete: function() {
            return $(this).remove();
          }
        }));
      }
      return _results1;
    }));
  }
  return _results;
};

$(window).resize(function() {
  return $('.expando').each(function() {
    var add, i, input, outer, size, _i, _len, _ref;
    add = 0;
    _ref = $(this).find('.add-on, .padd-on');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      add += $(i).outerWidth();
    }
    size = $(this).width();
    input = $(this).find('input, .input');
    if (input.hasClass('input')) {
      outer = 0;
    } else {
      outer = input.outerWidth() - input.width();
    }
    if (Modernizr.csscalc) {
      input.css('width', "-webkit-calc(100% - " + (outer + add) + "px)");
      input.css('width', "-moz-calc(100% - " + (outer + add) + "px)");
      input.css('width', "-o-calc(100% - " + (outer + add) + "px)");
      return input.css('width', "calc(100% - " + (outer + add) + "px)");
    } else {
      return input.width(size - outer - add);
    }
  });
});

$(window).resize();

setTimeout(function() {
  return $(window).resize();
}, 762);

setTimeout(function() {
  return $(window).resize();
}, 2718);

setTimeout(function() {
  return $(window).resize();
}, 6022);

var addAnnotation, addImportant, chatAnnotation, createAlert, guessAnnotation, logAnnotation, userSpan, verbAnnotation;

createAlert = function(bundle, title, message) {
  var div;
  div = $("<div>").addClass("alert alert-success").insertAfter(bundle.find(".annotations")).hide();
  div.append($("<button>").attr("data-dismiss", "alert").attr("type", "button").html("&times;").addClass("close"));
  div.append($("<strong>").text(title));
  div.append(" ");
  div.append(message);
  div.slideDown();
  return setTimeout(function() {
    return div.slideUp().queue(function() {
      $(this).dequeue();
      return $(this).remove();
    });
  }, 5000);
};

userSpan = function(user, global) {
  var c, el, hash, prefix, scope, text, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
  prefix = '';
  if (me.id && me.id.slice(0, 2) === "__") {
    prefix = (((_ref = room.users[user]) != null ? (_ref1 = _ref.room) != null ? _ref1.name : void 0 : void 0) || 'unknown') + '/';
  }
  text = '';
  if (user.slice(0, 2) === "__") {
    text = prefix + user.slice(2);
  } else {
    text = prefix + (((_ref2 = room.users[user]) != null ? _ref2.name : void 0) || "[name missing]");
  }
  hash = 'userhash-' + escape(text).toLowerCase().replace(/[^a-z0-9]/g, '');
  if (global) {
    scope = $(".user-" + user + ":not(." + hash + ")");
    for (_i = 0, _len = scope.length; _i < _len; _i++) {
      el = scope[_i];
      _ref3 = $(el).attr('class').split('\s');
      for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
        c = _ref3[_j];
        if (c.slice(0, 8) === 'userhash') {
          $(el).removeClass(c);
        }
      }
    }
  } else {
    scope = $('<span>');
  }
  return scope.addClass(hash).addClass('user-' + user).addClass('username').text(text);
};

addAnnotation = function(el, name) {
  var current_block, current_bundle;
  if (name == null) {
    name = typeof sync !== "undefined" && sync !== null ? sync.name : void 0;
  }
  $('.bundle .ruling').tooltip('destroy');
  current_bundle = $('.room-' + (name || '').replace(/[^a-z0-9]/g, ''));
  if (current_bundle.length === 0) {
    current_bundle = $('#history .bundle.active');
  }
  current_block = current_bundle.eq(0).find('.annotations');
  if (current_block.length === 0) {
    current_block = $('#history .annotations').eq(0);
  }
  el.css('display', 'none').prependTo(current_block);
  el.slideDown();
  return el;
};

addImportant = function(el) {
  $('.bundle .ruling').tooltip('destroy');
  if ($('#history .bundle.active .important').length !== 0) {
    el.css('display', 'none').prependTo($('#history .bundle.active .important'));
  } else {
    el.css('display', 'none').prependTo($('#history'));
  }
  el.slideDown();
  return el;
};

guessAnnotation = function(_arg) {
  var annotation_spot, answer, checkScoreUpdate, correct, decision, done, early, id, interrupt, line, marker, old_score, prompt, prompt_el, ruling, session, text, user;
  session = _arg.session, text = _arg.text, user = _arg.user, done = _arg.done, correct = _arg.correct, interrupt = _arg.interrupt, early = _arg.early, prompt = _arg.prompt;
  id = "" + user + "-" + session + "-" + (prompt ? 'prompt' : 'guess');
  if ($('#' + id).length > 0) {
    line = $('#' + id);
  } else {
    line = $('<p>').attr('id', id);
    if (prompt) {
      prompt_el = $('<a>').addClass('label prompt label-info').text('Prompt');
      line.append(' ');
      line.append(prompt_el);
    } else {
      marker = $('<span>').addClass('label').text("Buzz");
      if (early) {

      } else if (interrupt) {
        marker.addClass('label-important');
      } else {
        marker.addClass('label-info');
      }
      line.append(marker);
    }
    line.append(" ");
    line.append(userSpan(user).addClass('author'));
    line.append(document.createTextNode(' '));
    $('<span>').addClass('comment').appendTo(line);
    ruling = $('<a>').addClass('label ruling').hide().attr('href', '#').attr('title', 'Click to Report').data('placement', 'right');
    line.append(' ');
    line.append(ruling);
    annotation_spot = $('#history .bundle[name="' + room.qid + '"]').eq(0).find('.annotations');
    if (annotation_spot.length === 0) {
      annotation_spot = $('#history');
    }
    line.css('display', 'none').prependTo(annotation_spot);
    line.slideDown();
  }
  if (done) {
    if (text === '') {
      line.find('.comment').html('<em>(blank)</em>');
    } else {
      line.find('.comment').text(text);
    }
  } else {
    line.find('.comment').text(text);
  }
  if (done) {
    ruling = line.find('.ruling').show().css('display', 'inline');
    decision = "";
    if (correct === "prompt") {
      ruling.addClass('label-info').text('Prompt');
      decision = "prompt";
    } else if (correct) {
      decision = "correct";
      ruling.addClass('label-success').text('Correct');
      if (user === me.id) {
        old_score = computeScore(me);
        checkScoreUpdate = function() {
          var magic_multiple, magic_number, updated_score;
          updated_score = computeScore(me);
          if (updated_score === old_score) {
            setTimeout(checkScoreUpdate, 100);
            return;
          }
          magic_multiple = 1000;
          magic_number = Math.round(old_score / magic_multiple) * magic_multiple;
          if (magic_number === 0) {
            return;
          }
          if (magic_number > 0) {
            if (old_score < magic_number && updated_score >= magic_number) {
              $('body').fireworks(magic_number / magic_multiple * 10);
              return createAlert(ruling.parents('.bundle'), 'Congratulations', "You have over " + magic_number + " points! Here's some fireworks.");
            }
          }
        };
        checkScoreUpdate();
      }
    } else {
      decision = "wrong";
      ruling.addClass('label-warning').text('Wrong');
      if (user === me.id && me.id in room.users) {
        old_score = computeScore(me);
        if (old_score < -100) {
          createAlert(ruling.parents('.bundle'), 'you suck', 'like seriously you really really suck. you are a turd.');
        }
      }
    }
    answer = room.answer;
    ruling.click(function() {
      sock.emit('report_answer', {
        guess: text,
        answer: answer,
        ruling: decision
      });
      createAlert(ruling.parents('.bundle'), 'Reported Answer', "You have successfully told me that my algorithm sucks. Thanks, I'll fix it eventually. ");
      return false;
    });
    if (actionMode === 'guess') {
      setActionMode('');
    }
  }
  return line;
};

chatAnnotation = function(_arg) {
  var done, html, id, line, session, text, time, url_regex, user, _ref, _ref1;
  session = _arg.session, text = _arg.text, user = _arg.user, done = _arg.done, time = _arg.time;
  id = user + '-' + session;
  if ($('#' + id).length > 0) {
    line = $('#' + id);
  } else {
    line = $('<p>').attr('id', id);
    line.append(userSpan(user).addClass('author').attr('title', formatTime(time)));
    line.append(document.createTextNode(' '));
    $('<span>').addClass('comment').appendTo(line);
    addAnnotation(line, (_ref = room.users[user]) != null ? (_ref1 = _ref.room) != null ? _ref1.name : void 0 : void 0);
  }
  url_regex = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig;
  html = text.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/(^|\s+)(\/[a-z0-9\-]+)(\s+|$)/g, function(all, pre, room, post) {
    return pre + ("<a href='" + room + "'>" + room + "</a>") + post;
  }).replace(url_regex, function(url) {
    var real_url;
    real_url = url;
    if (!/:\//.test(url)) {
      real_url = "http://" + url;
    }
    if (/\.(jpe?g|gif|png)$/.test(url)) {
      return "<img src='" + real_url + "' alt='" + url + "'>";
    } else {
      return "<a href='" + real_url + "' target='_blank'>" + url + "</a>";
    }
  });
  if (done) {
    line.removeClass('buffer');
    if (text === '') {
      line.find('.comment').html('<em>(no message)</em>');
    } else {
      line.find('.comment').html(html);
    }
  } else {
    if (!$('.livechat')[0].checked || text === '(typing)') {
      line.addClass('buffer');
      line.find('.comment').text(' is typing...');
    } else {
      line.removeClass('buffer');
      line.find('.comment').html(html);
    }
  }
  return line.toggleClass('typing', !done);
};

verbAnnotation = function(_arg) {
  var line, user, verb;
  user = _arg.user, verb = _arg.verb;
  line = $('<p>').addClass('log');
  if (user) {
    line.append(userSpan(user));
    line.append(" " + verb);
  } else {
    line.append(verb);
  }
  return addAnnotation(line);
};

logAnnotation = function(text) {
  var line;
  line = $('<p>').addClass('log');
  line.append(text);
  return addAnnotation(line);
};

var actionMode, mobileLayout, next, rate_limit_ceiling, rate_limit_check, recent_actions, setActionMode, skip,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

$('#username').keyup(function(e) {
  if (e.keyCode === 13) {
    $(this).blur();
  }
  if ($(this).val().length > 0) {
    return me.set_name($(this).val());
  }
});

jQuery('.bundle .breadcrumb').live('click', function() {
  var readout;
  if (!$(this).is(jQuery('.bundle .breadcrumb').first())) {
    readout = $(this).parent().find('.readout');
    return readout.width($('#history').width()).slideToggle("normal", function() {
      return readout.width('auto');
    });
  }
});

actionMode = '';

setActionMode = function(mode) {
  actionMode = mode;
  $('.prompt_input, .guess_input, .chat_input').blur();
  $('.actionbar').toggle(mode === '');
  $('.chat_form').toggle(mode === 'chat');
  $('.guess_form').toggle(mode === 'guess');
  $('.prompt_form').toggle(mode === 'prompt');
  return $(window).resize();
};

$('.chatbtn').click(function() {
  setActionMode('chat');
  return $('.chat_input').data('input_session', Math.random().toString(36).slice(3)).data('begin_time', +(new Date)).val('').focus().keyup();
});

recent_actions = [0];

rate_limit_ceiling = 0;

rate_limit_check = function() {
  var action, current_time, filtered_actions, online_count, rate_limited, rate_threshold, user, _i, _len;
  return false;
  online_count = ((function() {
    var _i, _len, _ref, _results;
    _ref = sync.users;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      user = _ref[_i];
      if (user.online && user.last_action > new Date - 1000 * 60 * 10) {
        _results.push(user);
      }
    }
    return _results;
  })()).length;
  rate_threshold = 7;
  if (online_count > 1) {
    rate_threshold = 3;
  }
  current_time = +(new Date);
  filtered_actions = [];
  rate_limited = false;
  for (_i = 0, _len = recent_actions.length; _i < _len; _i++) {
    action = recent_actions[_i];
    if (current_time - action < 5000) {
      filtered_actions.push(action);
    }
  }
  if (filtered_actions.length >= rate_threshold) {
    rate_limited = true;
  }
  if (rate_limit_ceiling > current_time) {
    rate_limited = true;
  }
  recent_actions = filtered_actions.slice(-10);
  recent_actions.push(current_time);
  if (rate_limited) {
    rate_limit_ceiling = current_time + 5000;
    createAlert($('.bundle.active'), 'Rate Limited', "You been rate limited for doing too many things in the past five seconds. ");
  }
  return rate_limited;
};

skip = function() {
  if (rate_limit_check()) {
    return;
  }
  return me.skip();
};

next = function() {
  return me.next();
};

$('.skipbtn').click(skip);

$('.nextbtn').click(next);

$('.buzzbtn').click(function() {
  var submit_time;
  if ($('.buzzbtn').attr('disabled') === 'disabled') {
    return;
  }
  if (rate_limit_check()) {
    return;
  }
  setActionMode('guess');
  $('.guess_input').val('').addClass('disabled').focus();
  submit_time = +(new Date);
  return me.buzz('yay', function(status) {
    if (status === 'http://www.whosawesome.com/') {
      $('.guess_input').removeClass('disabled');
      if ($('.sounds')[0].checked) {
        if (ding_sound) {
          ding_sound.play();
        }
      }
      if (window._gaq) {
        return _gaq.push(['_trackEvent', 'Game', 'Response Latency', 'Buzz Accepted', new Date - submit_time]);
      }
    } else {
      setActionMode('');
      if (window._gaq) {
        return _gaq.push(['_trackEvent', 'Game', 'Response Latency', 'Buzz Rejected', new Date - submit_time]);
      }
    }
  });
});

$('.score-reset').click(function() {
  return me.reset_score();
});

$('.pausebtn').click(function() {
  if (!!room.time_freeze) {
    return me.unpause();
  } else {
    return me.pause();
  }
});

$('.chat_input').keydown(function(e) {
  var _ref, _ref1;
  if (((_ref = e.keyCode) === 47 || _ref === 111 || _ref === 191) && $(this).val().length === 0 && !e.shiftKey) {
    e.preventDefault();
  }
  if ((_ref1 = e.keyCode) === 27) {
    return $('.chat_form').submit();
  }
});

$('input').keydown(function(e) {
  e.stopPropagation();
  if ($(this).hasClass("disabled")) {
    return e.preventDefault();
  }
});

$('.chat_input').typeahead({
  source: function() {
    var existing, name, names, option, prefix, _i, _len, _results;
    prefix = '@' + this.query.slice(1).split(',').slice(0, -1).join(',');
    existing = (function() {
      var _i, _len, _ref, _results;
      _ref = this.query.slice(1).split(',').slice(0, -1);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        option = _ref[_i];
        _results.push($.trim(option));
      }
      return _results;
    }).call(this);
    if (prefix.length > 1) {
      prefix += ', ';
    }
    names = ['alphabet', 'bowl', 'chevrolet', 'darcy', 'encephalogram', 'facetious', 'glistening', 'high', 'jump rope', 'knowledge', 'loquacious', 'melanin', 'narcotic', 'obecalp', 'placebo', 'quiz', 'rapacious', 'singularity', 'time travel', 'underappreciated', 'vestigial', 'wolfram', 'xetharious', 'yonder', 'zeta function'];
    _results = [];
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      name = names[_i];
      if (__indexOf.call(existing, name) < 0) {
        _results.push("" + prefix + name);
      }
    }
    return _results;
  },
  matcher: function(candidate) {
    return this.query[0] === '@' && this.query.split(' ').length <= this.query.split(', ').length;
  }
});

$('.chat_input').keyup(function(e) {
  if (e.keyCode === 13) {
    return;
  }
  if ($('.livechat')[0].checked && $('.chat_input').val().slice(0, 1) !== '@') {
    $('.chat_input').data('sent_typing', '');
    return me.chat({
      text: $('.chat_input').val(),
      session: $('.chat_input').data('input_session'),
      done: false
    });
  } else if ($('.chat_input').data('sent_typing') !== $('.chat_input').data('input_session')) {
    me.chat({
      text: '(typing)',
      session: $('.chat_input').data('input_session'),
      done: false
    });
    return $('.chat_input').data('sent_typing', $('.chat_input').data('input_session'));
  }
});

$('.chat_form').submit(function(e) {
  var time_delta;
  me.chat({
    text: $('.chat_input').val(),
    session: $('.chat_input').data('input_session'),
    done: true
  });
  e.preventDefault();
  setActionMode('');
  time_delta = new Date - $('.chat_input').data('begin_time');
  if (window._gaq) {
    return _gaq.push(['_trackEvent', 'Chat', 'Typing Time', 'Posted Message', time_delta]);
  }
});

$('.guess_input').keyup(function(e) {
  if (e.keyCode === 13) {
    return;
  }
  return me.guess({
    text: $('.guess_input').val(),
    done: false
  });
});

$('.guess_form').submit(function(e) {
  me.guess({
    text: $('.guess_input').val(),
    done: true
  });
  e.preventDefault();
  return setActionMode('');
});

$('.prompt_input').keyup(function(e) {
  if (e.keyCode === 13) {
    return;
  }
  return me.guess({
    text: $('.prompt_input').val(),
    done: false
  });
});

$('.prompt_form').submit(function(e) {
  me.guess({
    text: $('.prompt_input').val(),
    done: true
  });
  e.preventDefault();
  return setActionMode('');
});

$('body').keydown(function(e) {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
  if (actionMode === 'chat') {
    return $('.chat_input').focus();
  }
  if (actionMode === 'guess') {
    return $('.guess_input').focus();
  }
  if (e.keyCode === 50 && e.shiftKey) {
    $('.chatbtn').click();
    $('.chat_input').focus();
  }
  if (e.shiftKey || e.ctrlKey || e.metaKey) {
    return;
  }
  if (e.keyCode === 32) {
    e.preventDefault();
    if ($('.start-page').length === 1) {
      return $('.nextbtn').click();
    } else {
      return $('.buzzbtn').click();
    }
  } else if ((_ref = e.keyCode) === 83) {
    return skip();
  } else if ((_ref1 = e.keyCode) === 78 || _ref1 === 74) {
    return next();
  } else if ((_ref2 = e.keyCode) === 80 || _ref2 === 82) {
    return $('.pausebtn').click();
  } else if ((_ref3 = e.keyCode) === 47 || _ref3 === 111 || _ref3 === 191 || _ref3 === 67 || _ref3 === 65) {
    e.preventDefault();
    return $('.chatbtn').click();
  } else if ((_ref4 = e.keyCode) === 70) {
    return me.finish();
  } else if ((_ref5 = e.keyCode) === 66) {
    return $('.bundle.active .bookmark').click();
  }
});

$('.speed').change(function() {
  var rate;
  $('.speed').not(this).val($(this).val());
  $('.speed').data("last_update", +(new Date));
  rate = 1000 * 60 / 5 / Math.round($(this).val());
  if (+$('.speed').val() > $('.speed').attr('max') - 10) {
    return me.set_speed(0.1);
  } else {
    return me.set_speed(rate);
  }
});

$('.categories').change(function() {
  if ($('.categories').val() === 'custom') {
    createCategoryList();
    $('.custom-category').slideDown();
  } else {
    $('.custom-category').slideUp();
  }
  return me.set_category($('.categories').val());
});

$('.difficulties').change(function() {
  return me.set_difficulty($('.difficulties').val());
});

$('.dist-picker .increase').live('click', function(e) {
  var item, _i, _len, _ref, _results;
  if (!room.distribution) {
    return;
  }
  item = $(this).parents('.category-item');
  room.distribution[$(item).data('value')]++;
  me.set_distribution(room.distribution);
  _ref = $('.custom-category .category-item');
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    item = _ref[_i];
    _results.push(renderCategoryItem(item));
  }
  return _results;
});

$('.dist-picker .decrease').live('click', function(e) {
  var cat, item, s, val, _i, _len, _ref, _ref1, _results;
  if (!room.distribution) {
    return;
  }
  item = $(this).parents('.category-item');
  s = 0;
  _ref = room.distribution;
  for (cat in _ref) {
    val = _ref[cat];
    s += val;
  }
  if (room.distribution[$(item).data('value')] > 0 && s > 1) {
    room.distribution[$(item).data('value')]--;
    me.set_distribution(room.distribution);
  }
  _ref1 = $('.custom-category .category-item');
  _results = [];
  for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
    item = _ref1[_i];
    _results.push(renderCategoryItem(item));
  }
  return _results;
});

$('.teams').change(function() {
  if ($('.teams').val() === 'create') {
    return me.set_team(prompt('Enter Team Name') || '');
  } else {
    return me.set_team($('.teams').val());
  }
});

$('.multibuzz').change(function() {
  return me.set_max_buzz(($('.multibuzz')[0].checked ? null : 1));
});

$('.livechat').change(function() {
  return me.set_show_typing($('.livechat')[0].checked);
});

$('.sounds').change(function() {
  return me.set_sounds($('.sounds')[0].checked);
});

mobileLayout = function() {
  if (window.matchMedia) {
    return matchMedia('(max-width: 768px)').matches;
  } else {
    return false;
  }
};

if (!Modernizr.touch && !mobileLayout()) {
  $('.actionbar button').tooltip();
  $('.actionbar button').click(function() {
    return $('.actionbar button').tooltip('hide');
  });
  $('#history, .settings').tooltip({
    selector: "[rel=tooltip]",
    placement: function() {
      if (mobileLayout()) {
        return "error";
      } else {
        return "left";
      }
    }
  });
}

$('body').click(function(e) {
  if ($(e.target).parents('.leaderboard, .popover').length === 0) {
    return $('.popover').remove();
  }
});

$(".leaderboard tbody tr").live('click', function(e) {
  var enabled, user, _ref;
  user = $(this).data('entity');
  enabled = (_ref = $(this).data('popover')) != null ? _ref.enabled : void 0;
  $('.leaderboard tbody tr').popover('destroy');
  if (!enabled) {
    $(this).popover({
      placement: mobileLayout() ? "top" : "left",
      trigger: "manual",
      title: "" + user.name + "'s Stats",
      content: function() {
        return createStatSheet(user, true);
      }
    });
    return $(this).popover('toggle');
  }
});

if (Modernizr.touch) {
  $('.show-keyboard').hide();
  $('.show-touch').show();
} else {
  $('.show-keyboard').show();
  $('.show-touch').hide();
}

var QuizPlayer;

QuizPlayer = (function() {

  function QuizPlayer(room, id) {
    this.id = id;
    this.room = room;
    this.guesses = 0;
    this.interrupts = 0;
    this.early = 0;
    this.seen = 0;
    this.time_spent = 0;
    this.last_action = this.room.serverTime();
    this.times_buzzed = 0;
    this.show_typing = true;
    this.team = 0;
    this.banned = false;
    this.sounds = false;
  }

  QuizPlayer.prototype.touch = function(no_add_time) {
    var current_time, elapsed;
    current_time = this.room.serverTime();
    if (!no_add_time) {
      elapsed = current_time - this.last_action;
      if (elapsed < 1000 * 60 * 10) {
        this.time_spent += elapsed;
      }
    }
    return this.last_action = current_time;
  };

  QuizPlayer.prototype.active = function() {
    return (this.room.serverTime() - this.last_action) < 1000 * 60 * 10;
  };

  QuizPlayer.prototype.verb = function(action) {
    if (this.id.toString().slice(0, 2) !== '__') {
      return this.room.emit('log', {
        user: this.id,
        verb: action
      });
    }
  };

  QuizPlayer.prototype.disco = function() {
    return 0;
  };

  QuizPlayer.prototype.disconnect = function() {
    this.verb('left the room');
    return this.room.sync(1);
  };

  QuizPlayer.prototype.echo = function(data, callback) {
    return callback(this.room.serverTime());
  };

  QuizPlayer.prototype.buzz = function(data, fn) {
    return this.room.buzz(this.id, fn);
  };

  QuizPlayer.prototype.guess = function(data) {
    return this.room.guess(this.id, data);
  };

  QuizPlayer.prototype.chat = function(_arg) {
    var done, session, text;
    text = _arg.text, done = _arg.done, session = _arg.session;
    this.touch();
    return this.room.emit('chat', {
      text: text,
      session: session,
      user: this.id,
      done: done,
      time: this.room.serverTime()
    });
  };

  QuizPlayer.prototype.skip = function() {
    this.touch();
    if (!this.room.attempt) {
      this.room.skip();
      return this.verb('skipped a question');
    }
  };

  QuizPlayer.prototype.next = function() {
    return this.room.next();
  };

  QuizPlayer.prototype.finish = function() {
    this.touch();
    if (!this.room.attempt) {
      this.room.finish();
      return this.room.sync(1);
    }
  };

  QuizPlayer.prototype.pause = function() {
    this.touch();
    this.room.pause();
    return this.room.sync();
  };

  QuizPlayer.prototype.unpause = function() {
    this.room.unpause();
    return this.room.sync();
  };

  QuizPlayer.prototype.set_name = function(name) {
    this.name = name;
    this.touch();
    return this.room.sync(1);
  };

  QuizPlayer.prototype.set_distribution = function(data) {
    var _this = this;
    this.touch();
    if (!data) {
      return;
    }
    this.room.distribution = data;
    this.room.sync(3);
    return this.room.get_size(function(size) {
      var cat, count, _results;
      _results = [];
      for (cat in data) {
        count = data[cat];
        if (_this.room.distribution[cat] === 0 && count > 0) {
          _this.verb("enabled category " + cat + " (" + size + " questions)");
        }
        if (_this.room.distribution[cat] > 0 && count === 0) {
          _results.push(_this.verb("disabled category " + cat + " (" + size + " questions)"));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
  };

  QuizPlayer.prototype.set_difficulty = function(data) {
    var _this = this;
    this.touch();
    this.room.difficulty = data;
    this.room.sync();
    return this.room.get_size(function(size) {
      return _this.verb("set difficulty to " + (data || 'everything') + " (" + size + " questions)");
    });
  };

  QuizPlayer.prototype.set_category = function(data) {
    var _this = this;
    this.touch();
    this.room.category = data;
    if (!data) {
      this.room.reset_distribution();
    }
    this.room.sync();
    return this.room.get_size(function(size) {
      if (data === 'custom') {
        return _this.verb("enabled a custom category distribution (" + size + " questions)");
      } else {
        return _this.verb("set category to " + (data.toLowerCase() || 'potpourri') + " (" + size + " questions)");
      }
    });
  };

  QuizPlayer.prototype.set_max_buzz = function(data) {
    this.room.max_buzz = data;
    this.touch();
    if (this.room.max_buzz !== data) {
      if (data === 0) {
        this.verb('allowed players to buzz multiple times');
      } else if (data === 1) {
        this.verb('restricted players and teams to a single buzz per question');
      } else if (data > 1) {
        this.verb("restricted players and teams to " + data + " buzzes per question");
      }
    }
    return this.room.sync();
  };

  QuizPlayer.prototype.set_speed = function(speed) {
    if (!speed) {
      return;
    }
    this.touch();
    this.room.set_speed(speed);
    return this.room.sync();
  };

  QuizPlayer.prototype.set_team = function(name) {
    if (name) {
      this.verb("switched to team " + name);
    } else {
      this.verb("is playing as an individual");
    }
    this.team = name;
    return this.room.sync(2);
  };

  QuizPlayer.prototype.set_show_typing = function(data) {
    this.show_typing = data;
    return this.room.sync(2);
  };

  QuizPlayer.prototype.set_sounds = function(data) {
    this.sounds = data;
    return this.room.sync(2);
  };

  QuizPlayer.prototype.reset_score = function() {
    this.seen = this.interrupts = this.guesses = this.correct = this.early = 0;
    return this.room.sync(1);
  };

  QuizPlayer.prototype.report_question = function() {
    return this.verb("did something unimplemented (report question)");
  };

  QuizPlayer.prototype.report_answer = function() {
    return this.verb("did something unimplemented (report answer)");
  };

  QuizPlayer.prototype.check_public = function() {
    return this.verb("did something unimplemented (check public)");
  };

  return QuizPlayer;

})();

if (typeof exports !== "undefined" && exports !== null) {
  exports.QuizPlayer = QuizPlayer;
}

var QuizRoom, default_distribution, error_question,
  __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

error_question = {
  'category': '$0x40000',
  'difficulty': 'segmentation fault',
  'num': 'NaN',
  'tournament': 'Guru Meditation Cup',
  'question': 'This type of event occurs when the queried database returns an invalid question and is frequently indicative of a set of constraints which yields a null set. Certain manifestations of this kind of event lead to significant monetary loss and often result in large public relations campaigns to recover from the damaged brand valuation. This type of event is most common with computer software and hardware, and one way to diagnose this type of event when it happens on the bootstrapping phase of a computer operating system is by looking for the POST information. Kernel varieties of this event which are unrecoverable are referred to as namesake panics in the BSD/Mach hybrid microkernel which powers Mac OS X. The infamous Disk Operating System variety of this type of event is known for its primary color backdrop and continues to plague many of the contemporary descendents of DOS with code names such as Whistler, Longhorn and Chidori. For 10 points, name this event which happened right now.',
  'answer': 'error',
  'year': 1970,
  'round': '0x080483ba'
};

default_distribution = {
  "Fine Arts": 2,
  "Literature": 4,
  "History": 3,
  "Science": 3,
  "Trash": 1,
  "Geography": 1,
  "Mythology": 1,
  "Philosophy": 1,
  "Religion": 1,
  "Social Science": 1
};

QuizRoom = (function() {

  function QuizRoom(name) {
    this.name = name;
    this.type = "qb";
    this.answer_duration = 1000 * 5;
    this.time_offset = 0;
    this.sync_offset = 0;
    this.end_time = 0;
    this.question = '';
    this.answer = '';
    this.timing = [];
    this.cumulative = [];
    this.rate = 1000 * 60 / 5 / 200;
    this.__timeout = -1;
    this.distribution = default_distribution;
    this.freeze();
    this.users = {};
    this.difficulty = '';
    this.category = '';
    this.max_buzz = null;
  }

  QuizRoom.prototype.log = function(message) {
    return this.emit('log', {
      verb: message
    });
  };

  QuizRoom.prototype.get_parameters = function(type, difficulty, cb) {
    this.emit('log', {
      verb: 'NOT IMPLEMENTED (async get params)'
    });
    return cb(['HS', 'MS'], ['Science', 'Trash']);
  };

  QuizRoom.prototype.count_questions = function(type, difficulty, category, cb) {
    return this.log('NOT IMPLEMENTED (question counting)');
  };

  QuizRoom.prototype.get_size = function(cb, type, difficulty, category) {
    if (type == null) {
      type = this.type;
    }
    if (difficulty == null) {
      difficulty = this.difficulty;
    }
    if (category == null) {
      category = this.category;
    }
    return this.count_questions(type, difficulty, (category === 'custom' ? this.distribution : category), function(count) {
      return cb(count);
    });
  };

  QuizRoom.prototype.get_question = function(cb) {
    cb(error_question);
    return this.log('NOT IMPLEMENTED (async get question)');
  };

  QuizRoom.prototype.emit_user = function() {
    var args, id;
    id = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return this.log('room.emit_user(id, name, data) not implemented');
  };

  QuizRoom.prototype.emit = function(name, data) {
    return console.log('room.emit(name, data) not implemented');
  };

  QuizRoom.prototype.reset_distribution = function() {
    return this.distribution = default_distribution;
  };

  QuizRoom.prototype.time = function() {
    if (this.time_freeze) {
      return this.time_freeze;
    } else {
      return this.serverTime() - this.time_offset;
    }
  };

  QuizRoom.prototype.serverTime = function() {
    return new Date - this.sync_offset;
  };

  QuizRoom.prototype.set_time = function(ts) {
    return this.time_offset = new Date - ts;
  };

  QuizRoom.prototype.freeze = function() {
    return this.time_freeze = this.time();
  };

  QuizRoom.prototype.unfreeze = function() {
    if (this.time_freeze) {
      this.set_time(this.time_freeze);
      return this.time_freeze = 0;
    }
  };

  QuizRoom.prototype.pause = function() {
    if (!(this.attempt || this.time() > this.end_time)) {
      return this.freeze();
    }
  };

  QuizRoom.prototype.unpause = function() {
    if (!this.attempt) {
      return this.unfreeze();
    }
  };

  QuizRoom.prototype.timeout = function(delay, callback) {
    this.clear_timeout();
    return this.__timeout = setTimeout(callback, delay);
  };

  QuizRoom.prototype.clear_timeout = function() {
    return clearTimeout(this.__timeout);
  };

  QuizRoom.prototype.new_question = function() {
    var _this = this;
    this.generating_question = true;
    return this.get_question(function(question) {
      var id, syllables, user, word, _ref, _ref1;
      delete _this.generating_question;
      _this.generated_time = _this.time();
      _this.attempt = null;
      _this.info = {
        category: question.category,
        difficulty: question.difficulty,
        tournament: question.tournament,
        num: question.num,
        year: question.year,
        round: question.round
      };
      _this.question = question.question.replace(/FTP/g, 'For 10 points').replace(/^\[.*?\]/, '').replace(/\n/g, ' ').replace(/\s+/g, ' ');
      _this.answer = question.answer.replace(/\<\w\w\>/g, '').replace(/\[\w\w\]/g, '');
      _this.qid = (question != null ? (_ref = question._id) != null ? _ref.toString() : void 0 : void 0) || 'question_id';
      _this.info.tournament.replace(/[^a-z0-9]+/ig, '-') + "---" + _this.answer.replace(/[^a-z0-9]+/ig, '-').slice(0, 20);
      _this.begin_time = _this.time();
      if (typeof SyllableCounter !== "undefined" && SyllableCounter !== null) {
        syllables = SyllableCounter;
      } else {
        syllables = require('./syllable').syllables;
      }
      _this.timing = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = this.question.split(" ");
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          word = _ref1[_i];
          _results.push(syllables(word) + 1);
        }
        return _results;
      }).call(_this);
      _this.set_speed(_this.rate);
      _ref1 = _this.users;
      for (id in _ref1) {
        user = _ref1[id];
        user.times_buzzed = 0;
        if (user.active()) {
          user.seen++;
        }
      }
      return _this.sync(2);
    });
  };

  QuizRoom.prototype.set_speed = function(rate) {
    var cumsum, done, duration, elapsed, new_duration, now, remainder;
    if (!rate) {
      return;
    }
    cumsum = function(list, rate) {
      var num, sum, _i, _len, _ref, _results;
      sum = 0;
      _ref = [5].concat(list).slice(0, -1);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        num = _ref[_i];
        _results.push(sum += Math.round(num) * rate);
      }
      return _results;
    };
    now = this.time();
    this.cumulative = cumsum(this.timing, this.rate);
    elapsed = now - this.begin_time;
    duration = this.cumulative[this.cumulative.length - 1];
    done = elapsed / duration;
    remainder = 0;
    if (done > 1) {
      remainder = elapsed - duration;
      done = 1;
    }
    this.rate = rate;
    this.cumulative = cumsum(this.timing, this.rate);
    new_duration = this.cumulative[this.cumulative.length - 1];
    this.begin_time = now - new_duration * done - remainder;
    return this.end_time = this.begin_time + new_duration + this.answer_duration;
  };

  QuizRoom.prototype.skip = function() {
    if (!this.attempt) {
      return this.new_question();
    }
  };

  QuizRoom.prototype.finish = function() {
    return this.set_time(this.end_time);
  };

  QuizRoom.prototype.next = function() {
    if (this.time() > this.end_time - this.answer_duration && !this.generating_question) {
      this.skip();
      return this.unpause();
    }
  };

  QuizRoom.prototype.check_answer = function() {
    this.log('CUSTOM ANSWER CHECKER NOT IMPLEMENTED');
    if (Math.random() > 0.9) {
      return 'prompt';
    }
    return Math.random() > 0.3;
  };

  QuizRoom.prototype.end_buzz = function(session) {
    var buzzed, do_prompt, id, pool, team, teams, times_buzzed, user, _ref, _ref1,
      _this = this;
    if (((_ref = this.attempt) != null ? _ref.session : void 0) !== session) {
      return;
    }
    if (!this.attempt.prompt) {
      this.clear_timeout();
      this.attempt.done = true;
      this.attempt.correct = this.check_answer(this.attempt.text, this.answer, this.question);
      do_prompt = false;
      if (this.attempt.correct === 'prompt') {
        do_prompt = true;
        this.attempt.correct = false;
      }
      if (do_prompt === true) {
        this.attempt.correct = "prompt";
        this.sync();
        this.attempt.prompt = true;
        this.attempt.done = false;
        this.attempt.realTime = this.serverTime();
        this.attempt.start = this.time();
        this.attempt.text = '';
        this.attempt.duration = 10 * 1000;
        this.timeout(this.attempt.duration, function() {
          return _this.end_buzz(session);
        });
      }
      this.sync();
    } else {
      this.attempt.done = true;
      this.attempt.correct = this.check_answer(this.attempt.text, this.answer, this.question);
      if (this.attempt.correct === 'prompt') {
        this.attempt.correct = false;
      }
      this.sync();
    }
    if (this.attempt.done) {
      this.unfreeze();
      if (this.attempt.correct) {
        this.users[this.attempt.user].correct++;
        if (this.attempt.early) {
          this.users[this.attempt.user].early++;
        }
        this.finish();
      } else {
        if (this.attempt.interrupt) {
          this.users[this.attempt.user].interrupts++;
        }
        buzzed = 0;
        pool = 0;
        teams = {};
        _ref1 = this.users;
        for (id in _ref1) {
          user = _ref1[id];
          if (id[0] !== "_") {
            if (user.sockets.length > 0 && (new Date - user.last_action) < 1000 * 60 * 10) {
              teams[user.team || id] = teams[user.team || id] || 0;
              teams[user.team || id] += user.times_buzzed;
            }
          }
        }
        for (team in teams) {
          times_buzzed = teams[team];
          if (times_buzzed >= this.max_buzz && this.max_buzz) {
            buzzed++;
          }
          pool++;
        }
        if (this.max_buzz) {
          if (buzzed >= pool) {
            this.finish();
          }
        }
      }
      this.attempt = null;
      return this.sync(1);
    }
  };

  QuizRoom.prototype.buzz = function(user, fn) {
    var early_index, id, member, session, team_buzzed, _ref,
      _this = this;
    team_buzzed = 0;
    _ref = this.users;
    for (id in _ref) {
      member = _ref[id];
      if ((member.team || id) === (this.users[user].team || user)) {
        team_buzzed += member.times_buzzed;
      }
    }
    if (this.max_buzz && this.users[user].times_buzzed >= this.max_buzz) {
      if (fn) {
        fn('THE BUZZES ARE TOO DAMN HIGH');
      }
      return this.emit('log', {
        user: user,
        verb: 'has already buzzed'
      });
    } else if (this.max_buzz && team_buzzed >= this.max_buzz) {
      if (fn) {
        fn('THE BUZZES ARE TOO DAMN HIGH');
      }
      return this.emit('log', {
        user: user,
        verb: 'is in a team which has already buzzed'
      });
    } else if (this.attempt === null && this.time() <= this.end_time) {
      if (fn) {
        fn('http://www.whosawesome.com/');
      }
      session = Math.random().toString(36).slice(2);
      early_index = this.question.replace(/[^ \*]/g, '').indexOf('*');
      this.attempt = {
        user: user,
        realTime: this.serverTime(),
        start: this.time(),
        duration: 8 * 1000,
        session: session,
        text: '',
        early: early_index !== -1 && this.time() < this.begin_time + this.cumulative[early_index],
        interrupt: this.time() < this.end_time - this.answer_duration,
        done: false
      };
      this.users[user].times_buzzed++;
      this.users[user].guesses++;
      this.freeze();
      this.sync(1);
      return this.timeout(this.attempt.duration, function() {
        return _this.end_buzz(session);
      });
    } else if (this.attempt) {
      this.emit('log', {
        user: user,
        verb: 'lost the buzzer race'
      });
      if (fn) {
        return fn('THE GAME');
      }
    } else {
      this.emit('log', {
        user: user,
        verb: 'attempted an invalid buzz'
      });
      if (fn) {
        return fn('THE GAME');
      }
    }
  };

  QuizRoom.prototype.guess = function(user, data) {
    var _ref;
    if (((_ref = this.attempt) != null ? _ref.user : void 0) === user) {
      this.attempt.text = data.text;
      if (data.done) {
        return this.end_buzz(this.attempt.session);
      } else {
        return this.sync();
      }
    }
  };

  QuizRoom.prototype.sync = function(level) {
    var attr, blacklist, data, id, user, user_blacklist,
      _this = this;
    if (level == null) {
      level = 0;
    }
    data = {
      real_time: +(new Date)
    };
    blacklist = ["question", "answer", "timing", "voting", "info", "cumulative", "users", "generating_question", "distribution", "sync_offset"];
    user_blacklist = ["sockets"];
    for (attr in this) {
      if (typeof this[attr] !== 'function' && __indexOf.call(blacklist, attr) < 0 && attr[0] !== "_") {
        data[attr] = this[attr];
      }
    }
    if (level >= 1) {
      data.users = (function() {
        var _ref, _results;
        _results = [];
        for (id in this.users) {
          if (!(!this.users[id].ninja)) {
            continue;
          }
          user = {};
          for (attr in this.users[id]) {
            if (__indexOf.call(user_blacklist, attr) < 0 && ((_ref = typeof this.users[id][attr]) !== 'function' && _ref !== 'object')) {
              user[attr] = this.users[id][attr];
            }
          }
          if ('sockets' in this.users[id]) {
            user.online = this.users[id].sockets.length > 0;
          } else {
            user.online = true;
          }
          _results.push(user);
        }
        return _results;
      }).call(this);
    }
    if (level >= 2) {
      data.question = this.question;
      data.answer = this.answer;
      data.timing = this.timing;
      data.info = this.info;
    }
    if (level >= 3) {
      data.distribution = this.distribution;
      return this.get_parameters(this.type, this.difficulty, function(difficulties, categories) {
        data.difficulties = difficulties;
        data.categories = categories;
        return _this.emit('sync', data);
      });
    } else {
      return this.emit('sync', data);
    }
  };

  return QuizRoom;

})();

if (typeof exports !== "undefined" && exports !== null) {
  exports.QuizRoom = QuizRoom;
}

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
  people = 'kirk,picard,feynman,einstein,erdos,huxley,robot,ben,batman,panda,pinkman,superhero,celebrity,traitor,alien,lemon,police,whale,astronaut,chicken,kitten,cats,shakespeare,dali,cherenkov,stallman,sherlock,sagan,irving,copernicus,kepler,astronomer';
  verb = 'on,enveloping,eating,drinking,in,near,sleeping,destroying,arresting,cloning,around,jumping,scrambling,painting,stalking,vomiting,defrauding,rappelling';
  noun = 'mountain,drugs,house,asylum,elevator,scandal,planet,school,brick,rock,pebble,lamp,water,paper,friend,toilet,airplane,cow,pony,egg,chicken,meat,book,wikipedia,turd,rhinoceros,paris,sunscreen,canteen,earwax,printer,staple,endorphins,trampoline,helicopter,feather,cloud,skeleton,uranus,neptune,earth,venus,mars,mercury,pluto,moon,jupiter,saturn,electorate';
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




var changeQuestion, createBundle, createCategoryList, last_question, last_rendering, reader_children, reader_last_state, renderCategoryItem, renderParameters, renderPartial, renderTimer, renderUpdate, renderUsers, updateInlineSymbols, updateTextPosition,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

createCategoryList = function() {
  var cat, item, picker, _i, _len, _ref, _results;
  $('.custom-category').empty();
  if (!room.distribution) {
    return;
  }
  _ref = room.categories;
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    cat = _ref[_i];
    item = $('<div>').addClass('category-item').appendTo('.custom-category').data('value', cat);
    $('<span>').addClass('name').text(cat).appendTo(item);
    picker = $('<div>').addClass('btn-group pull-right dist-picker').appendTo(item);
    $('<button>').addClass('btn btn-small decrease disabled').append($('<i>').addClass('icon-minus')).appendTo(picker);
    $('<button>').addClass('btn btn-small increase disabled').append($('<i>').addClass('icon-plus')).appendTo(picker);
    $('<span>').addClass('percentage pull-right').css('color', 'gray').appendTo(item);
    _results.push(renderCategoryItem(item));
  }
  return _results;
};

renderCategoryItem = function(item) {
  var cat, percentage, s, val, value, _ref;
  if (!room.distribution) {
    return;
  }
  s = 0;
  _ref = room.distribution;
  for (cat in _ref) {
    val = _ref[cat];
    s += val;
  }
  value = $(item).data('value');
  percentage = room.distribution[value] / s;
  $(item).find('.percentage').html("" + (Math.round(100 * percentage)) + "% &nbsp;");
  $(item).find('.increase').removeClass('disabled');
  if (percentage > 0 && s > 1) {
    $(item).find('.decrease').removeClass('disabled');
  } else {
    $(item).find('.decrease').addClass('disabled');
    $(item).find('.name').css('font-weight', 'normal');
  }
  if (percentage > 0) {
    return $(item).find('.name').css('font-weight', 'bold');
  }
};

renderParameters = function() {
  var cat, dif, _i, _j, _len, _len1, _ref, _ref1;
  $('.difficulties option').remove();
  $('.difficulties')[0].options.add(new Option("Any", ''));
  _ref = room.difficulties;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    dif = _ref[_i];
    $('.difficulties')[0].options.add(new Option(dif, dif));
  }
  $('.categories option').remove();
  $('.categories')[0].options.add(new Option('Everything', ''));
  $('.categories')[0].options.add(new Option('Custom', 'custom'));
  _ref1 = room.categories;
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    cat = _ref1[_j];
    $('.categories')[0].options.add(new Option(cat, cat));
  }
  return createCategoryList();
};

renderUpdate = function() {
  var wpm;
  if (room.category === 'custom') {
    $('.custom-category').slideDown();
  }
  $('.categories').val(room.category);
  $('.difficulties').val(room.difficulty);
  $('.multibuzz').attr('checked', !room.max_buzz);
  if ($('.settings').is(':hidden')) {
    $('.settings').slideDown();
    $(window).resize();
  }
  if (me.id in room.users && 'show_typing' in room.users[me.id]) {
    $('.livechat').attr('checked', room.users[me.id].show_typing);
    $('.sounds').attr('checked', room.users[me.id].sounds);
    $('.teams').val(room.users[me.id].team);
  }
  if (room.attempt) {
    guessAnnotation(room.attempt);
  }
  wpm = Math.round(1000 * 60 / 5 / room.rate);
  if (!$('.speed').data('last_update') || new Date - $(".speed").data("last_update") > 1337) {
    if (Math.abs($('.speed').val() - wpm) > 1) {
      $('.speed').val(wpm);
    }
  }
  if (!room.attempt || room.attempt.user !== me.id) {
    if (actionMode === 'guess' || actionMode === 'prompt') {
      return setActionMode('');
    }
  } else {
    if (room.attempt.prompt) {
      if (actionMode !== 'prompt') {
        setActionMode('prompt');
        return $('.prompt_input').val('').focus();
      }
    } else {
      if (actionMode !== 'guess') {
        return setActionMode('guess');
      }
    }
  }
};

last_rendering = 0;

last_question = '';

renderPartial = function() {
  var start, well;
  if ((!room.time_freeze || room.attempt) && room.time() < room.end_time) {
    requestAnimationFrame(renderPartial);
    if (new Date - last_rendering < 1000 / 20) {
      return;
    }
  }
  last_rendering = +(new Date);
  if (!room.question) {
    if ($('.start-page').length === 0) {
      console.log('adding a start thing');
      start = $('<div>').addClass('start-page').hide().prependTo('#history');
      well = $('<div>').addClass('well').appendTo(start);
      $('<button>').addClass('btn btn-success btn-large').text('Start the Question').appendTo(well).click(function() {
        return me.next();
      });
      start.slideDown();
    }
  } else {
    if ($('.start-page').length !== 0) {
      $('.start-page').slideUp('normal', function() {
        return $(this).remove();
      });
    }
    if (room.question + room.generated_time !== last_question) {
      changeQuestion();
      last_question = room.question + room.generated_time;
    }
  }
  updateTextPosition();
  return renderTimer();
};

renderTimer = function() {
  var cs, elapsed, fraction, min, ms, pad, progress, ruling, sec, sign, time;
  time = Math.max(room.begin_time, room.time());
  if (connected()) {
    $('.offline').fadeOut();
  } else {
    $('.offline').fadeIn();
  }
  if (room.time_freeze) {
    $('.buzzbtn').disable(true);
    if (room.attempt) {
      $('.label.pause').hide();
      $('.label.buzz').fadeIn();
    } else {
      $('.label.pause').fadeIn();
      $('.label.buzz').hide();
    }
    if ($('.pausebtn').hasClass('btn-warning')) {
      $('.pausebtn .resume').show();
      $('.pausebtn .pause').hide();
      $('.pausebtn').addClass('btn-success').removeClass('btn-warning');
    }
  } else {
    $('.label.pause').fadeOut();
    $('.label.buzz').fadeOut();
    if ($('.pausebtn').hasClass('btn-success')) {
      $('.pausebtn .resume').hide();
      $('.pausebtn .pause').show();
      $('.pausebtn').addClass('btn-warning').removeClass('btn-success');
    }
  }
  if (time > room.end_time - room.answer_duration) {
    if ($(".nextbtn").is(":hidden")) {
      $('.nextbtn').show();
      $('.skipbtn').hide();
    }
  } else {
    if ($(".skipbtn").is(":hidden")) {
      $('.nextbtn').hide();
      $('.skipbtn').show();
    }
  }
  $('.timer').toggleClass('buzz', !!room.attempt);
  $('.primary-bar').toggleClass('bar-warning', !!(room.time_freeze && !room.attempt));
  $('.primary-bar').toggleClass('bar-danger', !!room.attempt);
  $('.progress').toggleClass('active', !!room.attempt);
  if (room.attempt) {
    elapsed = room.serverTime() - room.attempt.realTime;
    ms = room.attempt.duration - elapsed;
    progress = elapsed / room.attempt.duration;
    $('.pausebtn, .buzzbtn, .skipbtn, .nextbtn').disable(true);
  } else {
    ms = room.end_time - time;
    elapsed = time - room.begin_time;
    progress = elapsed / (room.end_time - room.begin_time);
    $('.skipbtn, .nextbtn').disable(false);
    $('.pausebtn').disable(ms < 0);
    if (!room.time_freeze) {
      $('.buzzbtn').disable(ms < 0 || elapsed < 100);
    }
    if (ms < 0) {
      $('.bundle.active').addClass('revealed');
      ruling = $('.bundle.active').find('.ruling');
      if (!ruling.data('shown_tooltip')) {
        ruling.data('shown_tooltip', true);
        $('.bundle.active').find('.ruling').first().tooltip({
          trigger: "manual"
        }).tooltip('show');
      }
    }
  }
  if (room.attempt || room.time_freeze) {
    $('.progress .primary-bar').width(progress * 100 + '%');
    $('.progress .aux-bar').width('0%');
  } else {
    fraction = (1 - (room.answer_duration / (room.end_time - room.begin_time))) * 100;
    $('.progress .primary-bar').width(Math.min(progress * 100, fraction) + '%');
    $('.progress .aux-bar').width(Math.min(100 - fraction, Math.max(0, progress * 100 - fraction)) + '%');
  }
  ms = Math.max(0, ms);
  sign = "";
  if (ms < 0) {
    sign = "+";
  }
  sec = Math.abs(ms) / 1000;
  cs = (sec % 1).toFixed(1).slice(1);
  $('.timer .fraction').text(cs);
  min = sec / 60;
  pad = function(num) {
    var str;
    str = Math.floor(num).toString();
    while (str.length < 2) {
      str = '0' + str;
    }
    return str;
  };
  return $('.timer .face').text(sign + pad(min) + ':' + pad(sec % 60));
};

renderUsers = function() {
  return console.log('rendering users');
};

changeQuestion = function() {
  var bundle, cutoff, nested, old;
  if (!(room.question && room.generated_time)) {
    return;
  }
  cutoff = 15;
  if (mobileLayout()) {
    cutoff = 1;
  }
  $('.bundle .ruling').tooltip('destroy');
  $('.bundle:not(.bookmarked)').slice(cutoff).slideUp('normal', function() {
    return $(this).remove();
  });
  old = $('#history .bundle').first();
  old.removeClass('active');
  old.find('.breadcrumb').click(function() {
    return 1;
  });
  bundle = createBundle().width($('#history').width());
  bundle.addClass('active');
  $('#history').prepend(bundle.hide());
  updateInlineSymbols();
  bundle.slideDown("normal").queue(function() {
    bundle.width('auto');
    return $(this).dequeue();
  });
  if (old.find('.readout').length > 0) {
    nested = old.find('.readout .well>span');
    old.find('.readout .well').append(nested.contents());
    nested.remove();
    old.find('.readout')[0].normalize();
    return old.queue(function() {
      old.find('.readout').slideUp("normal");
      return $(this).dequeue();
    });
  }
};

createBundle = function() {
  var addInfo, annotations, breadcrumb, bundle, important, readout, star, well, _ref;
  bundle = $('<div>').addClass('bundle').attr('name', room.qid).addClass('room-' + ((_ref = room.name) != null ? _ref.replace(/[^a-z0-9]/g, '') : void 0));
  important = $('<div>').addClass('important');
  bundle.append(important);
  breadcrumb = $('<ul>');
  star = $('<a>', {
    href: "#",
    rel: "tooltip",
    title: "Bookmark this question"
  }).addClass('icon-star-empty bookmark').click(function(e) {
    bundle.toggleClass('bookmarked');
    star.toggleClass('icon-star-empty', !bundle.hasClass('bookmarked'));
    star.toggleClass('icon-star', bundle.hasClass('bookmarked'));
    e.stopPropagation();
    return e.preventDefault();
  });
  breadcrumb.append($('<li>').addClass('pull-right').append(star));
  addInfo = function(name, value) {
    var el;
    breadcrumb.find('li:not(.pull-right)').last().append($('<span>').addClass('divider').text('/'));
    if (value) {
      name += ": " + value;
    }
    el = $('<li>').text(name).appendTo(breadcrumb);
    if (value) {
      return el.addClass('hidden-phone');
    } else {
      return el.addClass('visible-phone');
    }
  };
  if ((me.id + '').slice(0, 2) === "__") {
    addInfo('Room', room.name);
  }
  addInfo('Category', room.info.category);
  addInfo('Difficulty', room.info.difficulty);
  addInfo('Tournament', room.info.year + ' ' + room.info.tournament);
  addInfo(room.info.year + ' ' + room.info.difficulty + ' ' + room.info.category);
  breadcrumb.find('li').last().append($('<span>').addClass('divider hidden-phone').text('/'));
  bundle.data('report_info', {
    year: room.info.year,
    difficulty: room.info.difficulty,
    category: room.info.category,
    tournament: room.info.tournament,
    round: room.info.round,
    num: room.info.num,
    qid: room.qid,
    question: room.question,
    answer: room.answer
  });
  breadcrumb.append($('<li>').addClass('clickable hidden-phone').text('Report').click(function(e) {
    var cat, cat_list, controls, ctype, div, form, info, option, rtype, stype, _i, _j, _len, _len1, _ref1, _ref2;
    info = bundle.data('report_info');
    div = $("<div>").addClass("alert alert-block alert-info").insertBefore(bundle.find(".annotations")).hide();
    div.append($("<button>").attr("data-dismiss", "alert").attr("type", "button").html("&times;").addClass("close"));
    div.append($("<h4>").text("Report Question"));
    form = $("<form>");
    form.addClass('form-horizontal').appendTo(div);
    rtype = $('<div>').addClass('control-group').appendTo(form);
    rtype.append($("<label>").addClass('control-label').text('Description'));
    controls = $("<div>").addClass('controls').appendTo(rtype);
    _ref1 = ["Wrong category", "Wrong details", "Bad question", "Broken formatting"];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      option = _ref1[_i];
      controls.append($("<label>").addClass("radio").append($("<input type=radio name=description>").val(option.split(" ")[1].toLowerCase())).append(option));
    }
    form.find(":radio").change(function() {
      if (form.find(":radio:checked").val() === 'category') {
        return ctype.slideDown();
      } else {
        return ctype.slideUp();
      }
    });
    ctype = $('<div>').addClass('control-group').appendTo(form);
    ctype.append($("<label>").addClass('control-label').text('Category'));
    cat_list = $('<select>');
    ctype.append($("<div>").addClass('controls').append(cat_list));
    controls.find('input:radio')[0].checked = true;
    _ref2 = room.categories;
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      cat = _ref2[_j];
      cat_list.append(new Option(cat));
    }
    cat_list.val(info.category);
    stype = $('<div>').addClass('control-group').appendTo(form);
    $("<div>").addClass('controls').appendTo(stype).append($('<button type=submit>').addClass('btn btn-primary').text('Submit'));
    $(form).submit(function() {
      var describe;
      describe = form.find(":radio:checked").val();
      if (describe === 'category') {
        info.fixed_category = cat_list.val();
      }
      info.describe = describe;
      sock.emit('report_question', info);
      createAlert(bundle, 'Reported Question', 'You have successfully reported a question. It will be reviewed and the database may be updated to fix the problem. Thanks.');
      div.slideUp();
      return false;
    });
    div.slideDown();
    e.stopPropagation();
    return e.preventDefault();
  }));
  breadcrumb.append($('<li>').addClass('pull-right answer').text(room.answer));
  readout = $('<div>').addClass('readout');
  well = $('<div>').addClass('well').appendTo(readout);
  well.append($('<span>').addClass('unread').text(room.question));
  annotations = $('<div>').addClass('annotations');
  return bundle.append($('<ul>').addClass('breadcrumb').append(breadcrumb)).append(readout).append(annotations);
};

reader_children = null;

reader_last_state = -1;

updateTextPosition = function() {
  var index, start_index, timeDelta, word_index, _i;
  if (!(room.question && room.timing)) {
    return;
  }
  timeDelta = room.time() - room.begin_time;
  start_index = Math.max(0, reader_last_state);
  index = start_index;
  while (timeDelta > room.cumulative[index]) {
    index++;
  }
  for (word_index = _i = start_index; start_index <= index ? _i < index : _i > index; word_index = start_index <= index ? ++_i : --_i) {
    reader_children[word_index].className = '';
  }
  return reader_last_state = index - 1;
};

updateInlineSymbols = function() {
  var bundle, children, early_index, element, elements, i, label_type, readout, spots, stops, words, _i, _j, _ref, _ref1;
  if (!(room.question && room.timing)) {
    return;
  }
  console.log('update inline symbols');
  words = room.question.split(' ');
  early_index = room.question.replace(/[^ \*]/g, '').indexOf('*');
  bundle = $('#history .bundle.active');
  spots = bundle.data('starts') || [];
  stops = bundle.data('stops') || [];
  readout = bundle.find('.readout .well');
  if (readout.length === 0) {
    return;
  }
  readout.data('spots', spots.join(','));
  children = readout.children();
  elements = [];
  for (i = _i = 0, _ref = words.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    element = $('<span>').addClass('unread');
    if (words[i].indexOf('*') !== -1) {
      element.append(" <span class='inline-icon'><span class='asterisk'>" + words[i] + "</span><i class='label icon-white icon-asterisk'></i></span> ");
    } else {
      element.append(words[i] + " ");
    }
    if (__indexOf.call(spots, i) >= 0) {
      label_type = 'label-important';
      if (i === words.length - 1) {
        label_type = "label-info";
      }
      if (early_index !== -1 && i < early_index) {
        label_type = "label";
      }
      element.append(" <span class='inline-icon'><i class='label icon-white icon-bell  " + label_type + "'></i></span> ");
    } else if (__indexOf.call(stops, i) >= 0) {
      element.append(" <span class='inline-icon'><i class='label icon-white icon-pause label-warning'></i></span> ");
    }
    elements.push(element);
  }
  for (i = _j = 0, _ref1 = words.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
    if (children.eq(i).html() !== elements[i].html()) {
      if (children.eq(i).length > 0) {
        children.eq(i).replaceWith(elements[i]);
      } else {
        readout.append(elements[i]);
      }
    }
  }
  reader_children = readout[0].childNodes;
  reader_last_state = -1;
  return updateTextPosition();
};

var formatRelativeTime, formatTime, getTimeSpan;

getTimeSpan = (function() {
  var FEW_SECONDS, HOUR_IN_SECONDS, MINUTE_IN_SECONDS, MONTH_NAMES, SECOND_IN_MILLISECONDS, WEEKDAY_NAMES, formatMonth, formatTime, formatWeekday;
  SECOND_IN_MILLISECONDS = 1000;
  FEW_SECONDS = 5;
  MINUTE_IN_SECONDS = 60;
  HOUR_IN_SECONDS = MINUTE_IN_SECONDS * 60;
  MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  WEEKDAY_NAMES = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  formatTime = function(date) {
    var ampm, formattedHours, formattedMinutes, formattedTime, hours, minutes;
    minutes = date.getMinutes();
    hours = date.getHours();
    ampm = hours > 12 ? "pm" : "am";
    formattedHours = hours === 0 || hours === 12 ? "12" : "" + (hours % 12);
    formattedMinutes = minutes < 10 ? "0" + minutes : "" + minutes;
    formattedTime = "" + formattedHours + ":" + formattedMinutes + ampm;
    return formattedTime;
  };
  formatMonth = function(date) {
    return MONTH_NAMES[date.getMonth()];
  };
  formatWeekday = function(date) {
    return WEEKDAY_NAMES[date.getDay()];
  };
  getTimeSpan = function(date) {
    var nextWeekRange, nextWeekStart, nextYearRange, nextYearStart, now, range, result, theDayAfterTomorrowRange, theDayAfterTomorrowStart, thisWeekRange, thisWeekStart, thisYearRange, thisYearStart, todayRange, todayStart, tomorrowRange, tomorrowStart, yesterdayRange, yesterdayStart;
    now = new Date();
    range = (now.getTime() - date.getTime()) / SECOND_IN_MILLISECONDS;
    nextYearStart = new Date(now.getFullYear() + 1, 0, 1);
    nextWeekStart = new Date(now.getFullYear(), now.getMonth(), now.getDate() + (7 - now.getDay()));
    tomorrowStart = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
    theDayAfterTomorrowStart = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 2);
    todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    yesterdayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1);
    thisWeekStart = new Date(now.getFullYear(), now.getMonth(), now.getDate() - now.getDay());
    thisYearStart = new Date(now.getFullYear(), 0, 1);
    nextYearRange = (now.getTime() - nextYearStart.getTime()) / SECOND_IN_MILLISECONDS;
    nextWeekRange = (now.getTime() - nextWeekStart.getTime()) / SECOND_IN_MILLISECONDS;
    theDayAfterTomorrowRange = (now.getTime() - theDayAfterTomorrowStart.getTime()) / SECOND_IN_MILLISECONDS;
    tomorrowRange = (now.getTime() - tomorrowStart.getTime()) / SECOND_IN_MILLISECONDS;
    todayRange = (now.getTime() - todayStart.getTime()) / SECOND_IN_MILLISECONDS;
    yesterdayRange = (now.getTime() - yesterdayStart.getTime()) / SECOND_IN_MILLISECONDS;
    thisWeekRange = (now.getTime() - thisWeekStart.getTime()) / SECOND_IN_MILLISECONDS;
    thisYearRange = (now.getTime() - thisYearStart.getTime()) / SECOND_IN_MILLISECONDS;
    if (range >= 0) {
      if (range < FEW_SECONDS) {
        result = "A few seconds ago";
      } else if (range < MINUTE_IN_SECONDS) {
        result = "" + (Math.floor(range)) + " seconds ago";
      } else if (range < MINUTE_IN_SECONDS * 2) {
        result = "About a minute ago";
      } else if (range < HOUR_IN_SECONDS) {
        result = "" + (Math.floor(range / MINUTE_IN_SECONDS)) + " minutes ago";
      } else if (range < HOUR_IN_SECONDS * 2) {
        result = "About an hour ago";
      } else if (range < todayRange) {
        result = "" + (Math.floor(range / HOUR_IN_SECONDS)) + " hours ago";
      } else if (range < yesterdayRange) {
        result = "Yesterday at " + (formatTime(date));
      } else if (range < thisWeekRange) {
        result = "" + (formatWeekday(date)) + " at " + (formatTime(date));
      } else if (range < thisYearRange) {
        result = "" + (formatMonth(date)) + " " + (date.getDate()) + " at " + (formatTime(date));
      } else {
        result = "" + (formatMonth(date)) + " " + (date.getDate()) + ", " + (date.getFullYear()) + " at " + (formatTime(date));
      }
    } else {
      if (range > -FEW_SECONDS) {
        result = "In a few seconds";
      } else if (range > -MINUTE_IN_SECONDS) {
        result = "In " + (Math.floor(-range)) + " seconds";
      } else if (range > -MINUTE_IN_SECONDS * 2) {
        result = "In about a minute";
      } else if (range > -HOUR_IN_SECONDS) {
        result = "In " + (Math.floor(-range / MINUTE_IN_SECONDS)) + " minutes";
      } else if (range > -HOUR_IN_SECONDS * 2) {
        result = "In about an hour";
      } else if (range > tomorrowRange) {
        result = "In " + (Math.floor(-range / HOUR_IN_SECONDS)) + " hours";
      } else if (range > theDayAfterTomorrowRange) {
        result = "Tomorrow at " + (formatTime(date));
      } else if (range > nextWeekRange) {
        result = "" + (formatWeekday(date)) + " at " + (formatTime(date));
      } else if (range > nextYearRange) {
        result = "" + (formatMonth(date)) + " " + (date.getDate()) + " at " + (formatTime(date));
      } else {
        result = "" + (formatMonth(date)) + " " + (date.getDate()) + ", " + (date.getFullYear()) + " at " + (formatTime(date));
      }
    }
    return result;
  };
  return getTimeSpan;
})();

formatRelativeTime = function(timestamp) {
  var date;
  date = new Date;
  date.setTime(timestamp);
  return getTimeSpan(date);
};

formatTime = function(timestamp) {
  var date;
  date = new Date;
  date.setTime(timestamp);
  return (date.getHours() % 12) + ':' + ('0' + date.getMinutes()).substr(-2, 2) + (date.getHours() > 12 ? "pm" : "am");
};

var Avg, QuizPlayerSlave, QuizRoomSlave, StDev, Sum, computeScore, compute_sync_offset, connected, latency_log, listen, me, room, sock, sync_offsets, synchronize, testLatency,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

sock = io.connect();

connected = function() {
  return (sock != null) && sock.socket.connected;
};

QuizPlayerSlave = (function(_super) {

  __extends(QuizPlayerSlave, _super);

  QuizPlayerSlave.prototype.envelop_action = function(name) {
    var master_action;
    master_action = this[name];
    return this[name] = function(data, callback) {
      if (connected()) {
        return sock.emit(name, data, callback);
      } else {
        return master_action.call(this, data, callback);
      }
    };
  };

  function QuizPlayerSlave(room, id) {
    var blacklist, method, name;
    QuizPlayerSlave.__super__.constructor.call(this, room, id);
    blacklist = ['envelop_action'];
    for (name in this) {
      method = this[name];
      if (typeof method === 'function' && __indexOf.call(blacklist, name) < 0) {
        this.envelop_action(name);
      }
    }
  }

  return QuizPlayerSlave;

})(QuizPlayer);

QuizRoomSlave = (function(_super) {

  __extends(QuizRoomSlave, _super);

  QuizRoomSlave.prototype.emit = function(name, data) {
    return this.__listeners[name](data);
  };

  function QuizRoomSlave(name) {
    QuizRoomSlave.__super__.constructor.call(this, name);
    this.__listeners = {};
  }

  return QuizRoomSlave;

})(QuizRoom);

room = new QuizRoomSlave();

me = new QuizPlayerSlave(room, 'temporary');

sock.on('connect', function() {
  $('.actionbar button').disable(false);
  $('.timer').removeClass('disabled');
  $('.disconnect-notice').slideUp();
  return me.disco({
    old_socket: localStorage.old_socket
  });
});

sock.on('disconnect', function() {
  var line, _ref;
  if (((_ref = room.attempt) != null ? _ref.user : void 0) !== me.id) {
    room.attempt = null;
  }
  line = $('<div>').addClass('well');
  line.append($('<p>').append("You were ", $('<span class="label label-important">').text("disconnected"), " from the server for some reason. ", $('<em>').text(new Date)));
  line.append($('<p>').append("This may be due to a drop in the network 			connectivity or a malfunction in the server. The client will automatically 			attempt to reconnect to the server and in the mean time, the app has automatically transitioned			into <b>offline mode</b>. You can continue playing alone with a limited offline set			of questions without interruption. However, you might want to try <a href=''>reloading</a>."));
  return addImportant($('<div>').addClass('log disconnect-notice').append(line));
});

listen = function(name, fn) {
  sock.on(name, fn);
  return room.__listeners[name] = fn;
};

listen('echo', function(data, fn) {
  return fn('alive');
});

listen('application_update', function() {
  if (typeof applicationCache !== "undefined" && applicationCache !== null) {
    return applicationCache.update();
  }
});

listen('application_force_update', function() {
  return $('#update').slideDown();
});

listen('redirect', function(url) {
  return window.location = url;
});

listen('alert', function(text) {
  return window.alert(text);
});

listen('chat', function(data) {
  return chatAnnotation(data);
});

listen('log', function(data) {
  return verbAnnotation(data);
});

listen('sync', function(data) {
  return synchronize(data);
});

listen('joined', function(data) {
  me.id = data.id;
  me.name = data.name;
  $('#username').val(me.name);
  return $('#username').disable(false);
});

sync_offsets = [];

latency_log = [];

synchronize = function(data) {
  var attr, blacklist, cumsum, del, difflist, i, starts, user, user_blacklist, val, variable, _i, _len, _ref, _ref1;
  blacklist = ['real_time', 'users'];
  sync_offsets.push(+(new Date) - data.real_time);
  compute_sync_offset();
  difflist = [];
  for (attr in data) {
    val = data[attr];
    if (val !== room[attr]) {
      difflist.push(attr);
    }
  }
  for (attr in data) {
    val = data[attr];
    if (__indexOf.call(blacklist, attr) < 0) {
      room[attr] = val;
    }
  }
  if ('timing' in data || room.__last_rate !== room.rate) {
    cumsum = function(list, rate) {
      var num, sum, _i, _len, _ref, _results;
      sum = 0;
      _ref = [5].concat(list).slice(0, -1);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        num = _ref[_i];
        _results.push(sum += Math.round(num) * rate);
      }
      return _results;
    };
    room.cumulative = cumsum(room.timing, room.rate);
    room.__last_rate = room.rate;
  }
  if ('users' in data) {
    user_blacklist = ['id'];
    _ref = data.users;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      user = _ref[_i];
      if (user.id === me.id) {
        console.log("it's me, mario!");
        room.users[user.id] = me;
      } else {
        if (!(user.id in room.users)) {
          room.users[user.id] = new QuizPlayer(room, user.id);
        }
        for (attr in user) {
          val = user[attr];
          if (__indexOf.call(user_blacklist, attr) < 0) {
            room.users[user.id][attr] = val;
          }
        }
      }
    }
  }
  if ('difficulties' in data) {
    renderParameters();
  }
  renderUpdate();
  if (__indexOf.call(difflist, 'time_freeze') >= 0) {
    variable = (room.attempt ? 'starts' : 'stops');
    del = room.time_freeze - room.begin_time;
    i = 0;
    while (del > room.cumulative[i]) {
      i++;
    }
    starts = $('.bundle.active').data(variable) || [];
    if (_ref1 = i - 1, __indexOf.call(starts, _ref1) < 0) {
      starts.push(i - 1);
    }
    $('.bundle.active').data(variable, starts);
    updateInlineSymbols();
  }
  if ('users' in data) {
    renderUsers();
  }
  return renderPartial();
};

computeScore = function(user) {
  var CORRECT, EARLY, INTERRUPT;
  if (!user) {
    return 0;
  }
  CORRECT = 10;
  EARLY = 15;
  INTERRUPT = -5;
  return user.early * EARLY + (user.correct - user.early) * CORRECT + user.interrupts * INTERRUPT;
};

Avg = function(list) {
  return Sum(list) / list.length;
};

Sum = function(list) {
  var item, s, _i, _len;
  s = 0;
  for (_i = 0, _len = list.length; _i < _len; _i++) {
    item = list[_i];
    s += item;
  }
  return s;
};

StDev = function(list) {
  var item, mu;
  mu = Avg(list);
  return Math.sqrt(Avg((function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      item = list[_i];
      _results.push((item - mu) * (item - mu));
    }
    return _results;
  })()));
};

compute_sync_offset = function() {
  var below, item, sync_offset, thresh;
  sync_offsets = sync_offsets.slice(-20);
  thresh = Avg(sync_offsets);
  below = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = sync_offsets.length; _i < _len; _i++) {
      item = sync_offsets[_i];
      if (item <= thresh) {
        _results.push(item);
      }
    }
    return _results;
  })();
  sync_offset = Avg(below);
  thresh = Avg(below);
  below = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = sync_offsets.length; _i < _len; _i++) {
      item = sync_offsets[_i];
      if (item <= thresh) {
        _results.push(item);
      }
    }
    return _results;
  })();
  room.sync_offset = Avg(below);
  return $('#sync_offset').text(room.sync_offset.toFixed(1) + '/' + StDev(below).toFixed(1) + '/' + StDev(sync_offsets).toFixed(1));
};

testLatency = function() {
  var initialTime;
  if (!connected()) {
    return;
  }
  initialTime = +(new Date);
  return sock.emit('echo', {}, function(firstServerTime) {
    var recieveTime;
    recieveTime = +(new Date);
    return sock.emit('echo', {}, function(secondServerTime) {
      var CSC1, CSC2, SCS1, secondTime;
      secondTime = +(new Date);
      CSC1 = recieveTime - initialTime;
      CSC2 = secondTime - recieveTime;
      SCS1 = secondServerTime - firstServerTime;
      sync_offsets.push(recieveTime - firstServerTime);
      sync_offsets.push(secondTime - secondServerTime);
      latency_log.push(CSC1);
      latency_log.push(SCS1);
      latency_log.push(CSC2);
      compute_sync_offset();
      if (latency_log.length > 0) {
        return $('#latency').text(Avg(latency_log).toFixed(1) + "/" + StDev(latency_log).toFixed(1) + (" (" + latency_log.length + ")"));
      }
    });
  });
};

setTimeout(function() {
  testLatency();
  return setInterval(function() {
    return testLatency();
  }, 30 * 1000);
}, 2000);
