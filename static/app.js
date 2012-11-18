protobowl_build = 'Sat Nov 17 2012 23:52:35 GMT-0500 (EST)';
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

}(window.jQuery);
/* =========================================================
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

}(window.jQuery);
/* ===========================================================
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

}(window.jQuery);
/* ==========================================================
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

}(window.jQuery);
/* ============================================================
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

}(window.jQuery);
/* =============================================================
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

/**
*
*  Secure Hash Algorithm (SHA1)
*  http://www.webtoolkit.info/
*
**/
 
function sha1(msg) {
 
	function rotate_left(n,s) {
		var t4 = ( n<<s ) | (n>>>(32-s));
		return t4;
	};
 
	function lsb_hex(val) {
		var str="";
		var i;
		var vh;
		var vl;
 
		for( i=0; i<=6; i+=2 ) {
			vh = (val>>>(i*4+4))&0x0f;
			vl = (val>>>(i*4))&0x0f;
			str += vh.toString(16) + vl.toString(16);
		}
		return str;
	};
 
	function cvt_hex(val) {
		var str="";
		var i;
		var v;
 
		for( i=7; i>=0; i-- ) {
			v = (val>>>(i*4))&0x0f;
			str += v.toString(16);
		}
		return str;
	};
 
 
	function Utf8Encode(string) {
		string = string.replace(/\r\n/g,"\n");
		var utftext = "";
 
		for (var n = 0; n < string.length; n++) {
 
			var c = string.charCodeAt(n);
 
			if (c < 128) {
				utftext += String.fromCharCode(c);
			}
			else if((c > 127) && (c < 2048)) {
				utftext += String.fromCharCode((c >> 6) | 192);
				utftext += String.fromCharCode((c & 63) | 128);
			}
			else {
				utftext += String.fromCharCode((c >> 12) | 224);
				utftext += String.fromCharCode(((c >> 6) & 63) | 128);
				utftext += String.fromCharCode((c & 63) | 128);
			}
 
		}
 
		return utftext;
	};
 
	var blockstart;
	var i, j;
	var W = new Array(80);
	var H0 = 0x67452301;
	var H1 = 0xEFCDAB89;
	var H2 = 0x98BADCFE;
	var H3 = 0x10325476;
	var H4 = 0xC3D2E1F0;
	var A, B, C, D, E;
	var temp;
 
	msg = Utf8Encode(msg);
 
	var msg_len = msg.length;
 
	var word_array = new Array();
	for( i=0; i<msg_len-3; i+=4 ) {
		j = msg.charCodeAt(i)<<24 | msg.charCodeAt(i+1)<<16 |
		msg.charCodeAt(i+2)<<8 | msg.charCodeAt(i+3);
		word_array.push( j );
	}
 
	switch( msg_len % 4 ) {
		case 0:
			i = 0x080000000;
		break;
		case 1:
			i = msg.charCodeAt(msg_len-1)<<24 | 0x0800000;
		break;
 
		case 2:
			i = msg.charCodeAt(msg_len-2)<<24 | msg.charCodeAt(msg_len-1)<<16 | 0x08000;
		break;
 
		case 3:
			i = msg.charCodeAt(msg_len-3)<<24 | msg.charCodeAt(msg_len-2)<<16 | msg.charCodeAt(msg_len-1)<<8	| 0x80;
		break;
	}
 
	word_array.push( i );
 
	while( (word_array.length % 16) != 14 ) word_array.push( 0 );
 
	word_array.push( msg_len>>>29 );
	word_array.push( (msg_len<<3)&0x0ffffffff );
 
 
	for ( blockstart=0; blockstart<word_array.length; blockstart+=16 ) {
 
		for( i=0; i<16; i++ ) W[i] = word_array[blockstart+i];
		for( i=16; i<=79; i++ ) W[i] = rotate_left(W[i-3] ^ W[i-8] ^ W[i-14] ^ W[i-16], 1);
 
		A = H0;
		B = H1;
		C = H2;
		D = H3;
		E = H4;
 
		for( i= 0; i<=19; i++ ) {
			temp = (rotate_left(A,5) + ((B&C) | (~B&D)) + E + W[i] + 0x5A827999) & 0x0ffffffff;
			E = D;
			D = C;
			C = rotate_left(B,30);
			B = A;
			A = temp;
		}
 
		for( i=20; i<=39; i++ ) {
			temp = (rotate_left(A,5) + (B ^ C ^ D) + E + W[i] + 0x6ED9EBA1) & 0x0ffffffff;
			E = D;
			D = C;
			C = rotate_left(B,30);
			B = A;
			A = temp;
		}
 
		for( i=40; i<=59; i++ ) {
			temp = (rotate_left(A,5) + ((B&C) | (B&D) | (C&D)) + E + W[i] + 0x8F1BBCDC) & 0x0ffffffff;
			E = D;
			D = C;
			C = rotate_left(B,30);
			B = A;
			A = temp;
		}
 
		for( i=60; i<=79; i++ ) {
			temp = (rotate_left(A,5) + (B ^ C ^ D) + E + W[i] + 0xCA62C1D6) & 0x0ffffffff;
			E = D;
			D = C;
			C = rotate_left(B,30);
			B = A;
			A = temp;
		}
 
		H0 = (H0 + A) & 0x0ffffffff;
		H1 = (H1 + B) & 0x0ffffffff;
		H2 = (H2 + C) & 0x0ffffffff;
		H3 = (H3 + D) & 0x0ffffffff;
		H4 = (H4 + E) & 0x0ffffffff;
 
	}
 
	var temp = cvt_hex(H0) + cvt_hex(H1) + cvt_hex(H2) + cvt_hex(H3) + cvt_hex(H4);
 
	return temp.toLowerCase();
 
}
var clone_shallow;

window.requestAnimationFrame || (window.requestAnimationFrame = window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
  return window.setTimeout(function() {
    return callback(+new Date());
  }, 1000 / 60);
});

if (!String.prototype.trim) {
  String.prototype.trim = function() {
    return this.replace(/^\s+/, '').replace(/\s+$/, '');
  };
}

clone_shallow = function(obj) {
  var attr, new_obj;
  new_obj = {};
  for (attr in obj) {
    new_obj[attr] = obj[attr];
  }
  return new_obj;
};

jQuery.fn.disable = function(value) {
  return $(this).each(function() {
    var current;
    current = $(this).attr('disabled') === 'disabled';
    if (current !== value) {
      return $(this).attr('disabled', value);
    }
  });
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

var addAnnotation, addImportant, banButton, boxxyAnnotation, chatAnnotation, createAlert, guessAnnotation, logAnnotation, userSpan, verbAnnotation,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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
  if (/superstalkers/.test(room.name)) {
    prefix = (((_ref = room.users[user]) != null ? (_ref1 = _ref.room) != null ? _ref1.name : void 0 : void 0) || 'unknown') + '/';
  }
  text = '';
  if (user.slice(0, 2) === "__") {
    text = prefix + user.slice(2).replace(/_/g, ' ');
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
  scope.addClass(hash).addClass('user-' + user).addClass('username').text(text);
  if (user.slice(0, 2) === "__") {
    if (/ninja/.test(user)) {
      scope.prepend("<i class='icon-magic' style='padding-right: 5px'></i>");
    } else {
      scope.prepend("<i class='icon-bullhorn' style='padding-right: 5px'></i>");
    }
  }
  return scope;
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
  if ($('#history .bundle.active .sticky').length !== 0) {
    el.css('display', 'none').prependTo($('#history .bundle.active .sticky'));
  } else {
    el.css('display', 'none').prependTo($('#history .sticky:first'));
  }
  el.slideDown();
  return el;
};

banButton = function(id, line) {
  var i, u;
  if (me.id[0] !== '_') {
    if (id === me.id) {
      return;
    }
    if (me.score() < 50) {
      return;
    }
    if (((function() {
      var _ref, _results;
      _ref = room.users;
      _results = [];
      for (i in _ref) {
        u = _ref[i];
        if (u.active()) {
          _results.push(1);
        }
      }
      return _results;
    })()).length < 3) {
      return;
    }
  }
  return line.append($('<a>').attr('href', '#').attr('title', 'Initiate ban tribunal for this user').attr('rel', 'tooltip').addClass('label label-important pull-right banhammer').append($("<i>").addClass('icon-ban-circle')).click(function(e) {
    e.preventDefault();
    return me.trigger_tribunal(id);
  }));
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
    annotation_spot = $('#history .bundle[name="question-' + sha1(room.generated_time + room.question) + '"]:first .annotations');
    if (annotation_spot.length === 0) {
      annotation_spot = $('#history .annotations:first');
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
        old_score = me.score();
        checkScoreUpdate = function() {
          var magic_multiple, magic_number, updated_score;
          updated_score = me.score();
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
      if (user in room.users && room.users[user].score() < 0) {
        banButton(user, line);
      }
      if (user === me.id && me.id in room.users) {
        old_score = me.score();
        if (old_score < -100) {
          createAlert(ruling.parents('.bundle'), 'you suck', 'like seriously you really really suck. you are a turd.');
        }
      }
    }
    answer = room.answer;
    ruling.click(function() {
      me.report_answer({
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
  if (!session) {
    session = 'auto-' + Math.random().toString(36).slice(3);
  }
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
    if (/\.(jpe?g|gif|png)$/i.test(url)) {
      return "<a href='" + real_url + "' class='show_image' target='_blank'>" + url + "</a> (click to show) 				<div style='display:none;overflow:hidden' class='chat_image'>					<img src='" + real_url + "' alt='" + url + "'>				</div>";
    } else {
      return "<a href='" + real_url + "' target='_blank'>" + url + "</a>";
    }
  }).replace(/!@([a-z0-9]+)/g, function(match, user) {
    return userSpan(user).addClass('recipient').clone().wrap('<div>').parent().html();
  });
  if (done) {
    line.removeClass('buffer');
    if (text === '' || (text.slice(0, 1) === '@' && text.indexOf(me.id) === -1 && user !== me.id)) {
      line.find('.comment').html('<em>(no message)</em>');
      line.slideUp();
    } else {
      if (text.slice(0, 1) === '@') {
        line.prepend('<i class="icon-user"></i> ');
      }
      line.find('.comment').html(html);
      if (user in room.users && text.length > 140) {
        banButton(user, line);
      }
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
  var line, selection, time, user, verb, verbclass;
  user = _arg.user, verb = _arg.verb, time = _arg.time;
  verbclass = "verb-" + user + "-" + (verb.split(' ').slice(0, 2).join('-'));
  line = $('<p>').addClass('log');
  line.addClass(verbclass);
  if (user) {
    line.append(userSpan(user).attr('title', formatTime(time)));
    line.append(" " + verb.replace(/!@([a-z0-9]+)/g, function(match, user) {
      return userSpan(user).clone().wrap('<div>').parent().html();
    }));
  } else {
    line.append(verb);
  }
  if (/paused the/.test(verb) || /skipped/.test(verb) || /category/.test(verb) || /difficulty/.test(verb) || /ban tribunal/.test(verb) || me.id[0] === '_') {
    banButton(user, line);
  }
  if (verb.split(' ')[0] === 'joined' && $(".bundle.active .verb-" + user + "-left").length > 0) {
    $(".bundle.active .verb-" + user + "-left").slideUp();
    verbAnnotation({
      user: user,
      verb: 'reloaded the page',
      time: time
    });
    return;
  }
  selection = $(".bundle.active ." + verbclass);
  if (selection.length > 0) {
    line.data('count', selection.data('count') + 1);
    line.hide();
    line.prepend($('<span style="margin-right:5px">').addClass('badge').text(line.data('count') + 'x'));
    selection.slideUp('normal', function() {
      return $(this).remove();
    });
    return addAnnotation(line);
  } else {
    line.data('count', 1);
    return addAnnotation(line);
  }
};

logAnnotation = function(text) {
  var line;
  line = $('<p>').addClass('log');
  line.append(text);
  return addAnnotation(line);
};

boxxyAnnotation = function(_arg) {
  var against, guilty, id, line, not_guilty, time, tribunal, votes, votes_needed, witnesses, _ref, _ref1, _ref2;
  id = _arg.id, tribunal = _arg.tribunal;
  votes = tribunal.votes, time = tribunal.time, witnesses = tribunal.witnesses, against = tribunal.against;
  if ((_ref = me.id, __indexOf.call(witnesses, _ref) < 0) && me.id[0] !== '_') {
    return;
  }
  votes_needed = Math.floor((witnesses.length - 1) / 2 + 1) - votes.length + against.length;
  line = $('<div>').addClass('alert').addClass('troll-' + id);
  if (id === me.id) {
    line.text('Protobowl has detected high rates of activity coming from your account.\n');
    line.append(" <strong> Currently " + votes.length + " of " + (witnesses.length - 1) + " users have voted</strong> (" + votes_needed + " more votes are needed to ban you from this room for 10 minutes).");
  } else {
    line.append($("<strong>").append('Is ').append(userSpan(id)).append(' trolling? '));
    line.append('Protobowl has detected high rates of activity coming from the user ');
    line.append(userSpan(id));
    line.append('. If a majority of other active players vote to ban this user, the user will be sent to ');
    line.append("<a href='" + room.name + "-banned'>/" + room.name + "-banned</a> and banned from this room for 10 minutes. This message will be automatically dismissed in a minute. <br> ");
    guilty = $('<button>').addClass('btn btn-small').text('Ban this user');
    line.append(guilty);
    line.append(' ');
    not_guilty = $('<button>').addClass('btn btn-small').text("Don't ban");
    line.append(not_guilty);
    line.append(" <strong> Currently " + votes.length + " of " + (witnesses.length - 1) + " users have voted</strong> (" + votes_needed + " more votes are needed to ban ");
    line.append(userSpan(id));
    line.append(")");
    guilty.click(function() {
      return me.vote_tribunal({
        user: id,
        position: 'ban'
      });
    });
    not_guilty.click(function() {
      return me.vote_tribunal({
        user: id,
        position: 'free'
      });
    });
    guilty.add(not_guilty).disable((_ref1 = me.id, __indexOf.call(votes, _ref1) >= 0) || (_ref2 = me.id, __indexOf.call(against, _ref2) >= 0));
  }
  if ($('.troll-' + id).length > 0 && $('.troll-' + id).parents('.active').length > 0) {
    return $('.troll-' + id).replaceWith(line);
  } else {
    $('.troll-' + id).slideUp('normal', function() {
      return $(this).remove();
    });
    if (id !== me.id || votes.length > 1) {
      return addImportant(line);
    }
  }
};

var actionMode, chat, findReferences, mobileLayout, next, protobot_engaged, protobot_last, protobot_write, rate_limit_ceiling, rate_limit_check, recent_actions, setActionMode, skip,
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
  var action, current_time, filtered_actions, rate_limited, rate_threshold, _i, _len;
  if (!connected()) {
    return false;
  }
  rate_threshold = 7;
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
  if (room.rate < 1) {
    if (rate_limit_check()) {
      return;
    }
  }
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
  if ($('.sounds')[0].checked && !$('.sounds').data('ding_sound')) {
    $('.sounds').data('ding_sound', new Audio('/sound/ding.wav'));
  }
  return me.buzz('yay', function(status) {
    if (status === 'http://www.whosawesome.com/') {
      $('.guess_input').removeClass('disabled');
      if ($('.sounds')[0].checked) {
        $('.sounds').data('ding_sound').play();
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
  if (rate_limit_check()) {
    return;
  }
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
    $('.chat_input').val('');
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
    var existing, id, name, names, option, prefix, user, _i, _len, _ref, _ref1, _ref2, _results;
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
    names = ['individuals'];
    _ref = room.users;
    for (id in _ref) {
      user = _ref[id];
      if (_ref1 = user.name, __indexOf.call(names, _ref1) < 0) {
        names.push(user.name);
      }
      if (user.team && (_ref2 = user.team, __indexOf.call(names, _ref2) < 0)) {
        names.push(user.team);
      }
    }
    _results = [];
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      name = names[_i];
      if (__indexOf.call(existing, name) < 0 && name !== me.name) {
        _results.push("" + prefix + name);
      }
    }
    return _results;
  },
  matcher: function(candidate) {
    return this.query[0] === '@' && !findReferences(this.query)[1];
  }
});

findReferences = function(text) {
  var changed, entities, id, identity, name, reconstructed, team, _ref, _ref1;
  reconstructed = '@';
  changed = true;
  entities = {};
  _ref = room.users;
  for (id in _ref) {
    _ref1 = _ref[id], name = _ref1.name, team = _ref1.team;
    entities[name] = '!@' + id + ', ';
    team || (team = 'individuals');
    if (!entities[team]) {
      entities[team] = '';
    }
    entities[team] += entities[name];
  }
  while (changed === true) {
    changed = false;
    text = text.replace(/^[@\s,]*/g, '');
    for (name in entities) {
      identity = entities[name];
      if (text.slice(0, name.length) === name) {
        reconstructed += identity;
        text = text.slice(name.length);
        changed = true;
        break;
      }
    }
  }
  return [reconstructed.replace(/[\s,]*$/g, ''), text];
};

protobot_engaged = false;

protobot_last = '';

protobot_write = function(message) {
  var count, session, writeLetter;
  count = 0;
  session = Math.random().toString(36).slice(2);
  writeLetter = function() {
    if (++count <= message.length) {
      chatAnnotation({
        text: message.slice(0, count),
        session: session,
        user: '__protobot',
        done: count === message.length,
        time: room.serverTime()
      });
      return setTimeout(writeLetter, 1000 * 60 / 6 / (80 + Math.random() * 50));
    }
  };
  return writeLetter();
};

chat = function(text, done) {
  var pick, refs, reply;
  if (text.length < 15 && /lonely/i.test(text) && /re |m /i.test(text) && !/you/i.test(text) && !protobot_engaged) {
    protobot_engaged = true;
    protobot_last = $('.chat_input').data('input_session');
    protobot_write("I'm lonely too. Plz talk to meeeee");
  } else if (protobot_engaged && (typeof omeglebot_replies !== "undefined" && omeglebot_replies !== null) && protobot_last !== $('.chat_input').data('input_session')) {
    pick = function(list) {
      return list[Math.floor(list.length * Math.random())];
    };
    if (text.replace(/[^a-z]/g, '') in omeglebot_replies && Math.random() > 0.1) {
      protobot_write(pick(omeglebot_replies[text.replace(/[^a-z]/g, '')]));
      protobot_last = $('.chat_input').data('input_session');
    } else if (done) {
      reply = pick(Object.keys(omeglebot_replies));
      reply = pick(omeglebot_replies[reply]);
      protobot_write(reply);
    }
  }
  if (text.slice(0, 1) === '@') {
    refs = findReferences(text);
    if (refs[0] === '@') {
      text = '@' + refs[1];
    } else {
      text = refs.join(' ');
    }
  }
  return me.chat({
    text: text,
    session: $('.chat_input').data('input_session'),
    done: done
  });
};

$('.chat_input').keyup(function(e) {
  if (e.keyCode === 13) {
    return;
  }
  if ($('.livechat')[0].checked && $('.chat_input').val().slice(0, 1) !== '@') {
    $('.chat_input').data('sent_typing', '');
    return chat($('.chat_input').val(), false);
  } else if ($('.chat_input').data('sent_typing') !== $('.chat_input').data('input_session')) {
    chat('(typing)', false);
    return $('.chat_input').data('sent_typing', $('.chat_input').data('input_session'));
  }
});

$('.chat_form').submit(function(e) {
  var time_delta;
  setActionMode('');
  chat($('.chat_input').val(), true);
  e.preventDefault();
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
  setActionMode('');
  me.guess({
    text: $('.guess_input').val(),
    done: true
  });
  return e.preventDefault();
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
  setActionMode('');
  me.guess({
    text: $('.prompt_input').val(),
    done: true
  });
  return e.preventDefault();
});

$('body').keydown(function(e) {
  var _ref, _ref1, _ref10, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
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
      $('.nextbtn').click();
    } else {
      $('.buzzbtn').click();
    }
  } else if ((_ref = e.keyCode) === 83) {
    skip();
  } else if ((_ref1 = e.keyCode) === 78 || _ref1 === 74) {
    next();
  } else if ((_ref2 = e.keyCode) === 75) {
    $('.bundle:not(.active):first .readout').slideToggle();
  } else if ((_ref3 = e.keyCode) === 80 || _ref3 === 82) {
    $('.pausebtn').click();
  } else if ((_ref4 = e.keyCode) === 47 || _ref4 === 111 || _ref4 === 191 || _ref4 === 67 || _ref4 === 65 || _ref4 === 13) {
    e.preventDefault();
    $('.chatbtn').click();
  } else if ((_ref5 = e.keyCode) === 87) {
    e.preventDefault();
    $('.chatbtn').click();
    $('.chat_input').val('@');
  } else if ((_ref6 = e.keyCode) === 84) {
    e.preventDefault();
    $('.chatbtn').click();
    $('.chat_input').val('@' + (me.team || 'individuals') + " ");
  } else if ((_ref7 = e.keyCode) === 70) {
    me.finish();
  } else if ((_ref8 = e.keyCode) === 66) {
    $('.bundle.active .bookmark').click();
  }
  if (location.hostname === 'localhost') {
    if ((_ref9 = e.keyCode) === 68) {
      me.buzz();
      return me.guess({
        text: room.answer,
        done: true
      });
    } else if ((_ref10 = e.keyCode) === 69) {
      me.buzz();
      return me.guess({
        text: '',
        done: true
      });
    }
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
  return me.set_category($('.categories').val());
});

$('.difficulties').change(function() {
  return me.set_difficulty($('.difficulties').val());
});

$('.dist-picker .increase').live('click', function(e) {
  var item, obj, _i, _len, _ref, _results;
  if (!room.distribution) {
    return;
  }
  item = $(this).parents('.category-item');
  obj = clone_shallow(room.distribution);
  obj[$(item).data('value')]++;
  me.set_distribution(obj);
  _ref = $('.custom-category .category-item');
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    item = _ref[_i];
    _results.push(renderCategoryItem(item));
  }
  return _results;
});

$('.dist-picker .decrease').live('click', function(e) {
  var cat, item, obj, s, val, _i, _len, _ref, _ref1, _results;
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
  obj = clone_shallow(room.distribution);
  if (obj[$(item).data('value')] > 0 && s > 1) {
    obj[$(item).data('value')]--;
    me.set_distribution(obj);
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

$('.allowskip').change(function() {
  return me.set_skip($('.allowskip')[0].checked);
});

$('.showbonus').change(function() {
  return me.set_bonus($('.showbonus')[0].checked);
});

$('.livechat').change(function() {
  return me.set_show_typing($('.livechat')[0].checked);
});

$('.lock').change(function() {
  return me.set_lock($('.lock')[0].checked);
});

$('.movingwindow').change(function() {
  if ($('.movingwindow')[0].checked) {
    return me.set_movingwindow(20);
  } else {
    return me.set_movingwindow(false);
  }
});

$('.sounds').change(function() {
  me.set_sounds($('.sounds')[0].checked);
  return $('.sounds').data('ding_sound', new Audio('/sound/ding.wav'));
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

$('.singleuser').click(function() {
  return $('.singleuser .stats').slideUp().queue(function() {
    $('.singleuser').data('full', !$('.singleuser').data('full'));
    renderUsers();
    return $(this).dequeue().slideDown();
  });
});

$('.show_image').live('click', function(e) {
  e.preventDefault();
  return $(this).parent().find('.chat_image').slideToggle();
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

var changeQuestion, checkAlone, createBundle, createCategoryList, createStatSheet, get_score, last_rendering, reader_children, reader_last_state, renderCategoryItem, renderParameters, renderPartial, renderTimer, renderUpdate, renderUsers, updateInlineSymbols, updateTextPosition,
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
  var count, u, wpm;
  if (room.category === 'custom') {
    createCategoryList();
    $('.custom-category').slideDown();
  } else {
    $('.custom-category').slideUp();
  }
  $('.categories').val(room.category);
  $('.difficulties').val(room.difficulty);
  $('.multibuzz').attr('checked', !room.max_buzz);
  $('.allowskip').attr('checked', !room.no_skip);
  if ($('.settings').is(':hidden')) {
    $('.settings').slideDown();
    $(window).resize();
  }
  if (me.id in room.users && 'show_typing' in room.users[me.id]) {
    $('.livechat').attr('checked', room.users[me.id].show_typing);
    $('.sounds').attr('checked', room.users[me.id].sounds);
    $('.lock').attr('checked', room.users[me.id].lock);
    $('.teams').val(room.users[me.id].team);
    if (me.guesses > 0) {
      $('.reset-score').slideDown();
    } else {
      $('.reset-score').slideUp();
    }
    count = ((function() {
      var _results;
      _results = [];
      for (u in room.users) {
        _results.push(1);
      }
      return _results;
    })()).length;
    if (count > 1) {
      $('.set-team').slideDown();
    } else {
      $('.set-team').slideUp();
    }
  }
  if (me.id && me.id[0] === '_') {
    $('a.brand').attr('href', '/stalkermode');
    $('div.navbar-inner').css('background', 'rgb(224, 235, 225)');
    $('.motto').text('omg did you know im a ninja?');
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
    if ($('#history .bundle[name="question-' + sha1(room.generated_time + room.question) + '"]').length === 0) {
      changeQuestion();
    }
  }
  updateTextPosition();
  return renderTimer();
};

renderTimer = function() {
  var cs, elapsed, fraction, min, ms, pad, progress, ruling, sec, sign, time;
  if (room.end_time && room.begin_time) {
    $('.timer').removeClass('disabled');
  } else {
    $('.timer').addClass('disabled');
  }
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
      if ($('.pausebtn').hasClass('btn-warning')) {
        $('.pausebtn .resume').show();
        $('.pausebtn .pause').hide();
        $('.pausebtn').addClass('btn-success').removeClass('btn-warning');
      }
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
    if (!$(".nextbtn").is(":hidden")) {
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
  if (room.no_skip) {
    $('.skipbtn').disable(true);
  }
  ms = Math.max(0, ms);
  sign = "";
  if (ms < 0) {
    sign = "+";
  }
  sec = Math.abs(ms) / 1000;
  if (isNaN(sec)) {
    $('.timer .face').text('00:00');
    return $('.timer .fraction').text('.0');
  } else {
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
  }
};

get_score = function(user) {
  if (me.movingwindow) {
    return user.score() - [0].concat(user.history).slice(-me.movingwindow)[0];
  } else {
    return user.score();
  }
};

renderUsers = function() {
  var active_count, attr, attrs, badge, entities, id, idle_count, list, lock_electorate, lock_votes, member, members, name, needed, ranking, row, team, team_count, team_hash, teams, user, user_count, user_index, val, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
  if (!room.users) {
    return;
  }
  teams = {};
  team_hash = '';
  _ref = room.users;
  for (id in _ref) {
    user = _ref[id];
    if (user.team) {
      if (!('t-' + user.team in teams)) {
        teams['t-' + user.team] = [];
      }
      teams['t-' + user.team].push(user.id);
      team_hash += user.team + user.id;
    }
    userSpan(user.id, true);
    if (user.tribunal) {
      boxxyAnnotation(user);
    } else {
      $('.troll-' + user.id).slideUp('normal', function() {
        return $(this).remove();
      });
    }
  }
  lock_votes = 0;
  lock_electorate = 0;
  _ref1 = room.users;
  for (id in _ref1) {
    user = _ref1[id];
    if (user.active()) {
      if (user.active()) {
        lock_electorate++;
        if (user.lock) {
          lock_votes++;
        }
      }
    }
  }
  if (lock_electorate <= 2) {
    $('.lockvote').slideUp();
    $('.globalsettings .checkbox, .globalsettings .expando').css('opacity', '1').find('select, input').disable(false);
  } else {
    $('.lockvote').slideDown();
    needed = Math.floor(lock_electorate / 2 + 1);
    if (lock_votes < needed) {
      $('.lockvote .electorate').text("" + (needed - lock_votes) + " needed");
    } else {
      $('.lockvote .electorate').text("" + lock_votes + "/" + lock_electorate + " votes");
    }
    $('.lockvote .status_icon').removeClass('icon-lock icon-unlock');
    if (lock_votes >= needed) {
      $('.lockvote .status_icon').addClass('icon-lock');
      $('.globalsettings .checkbox, .globalsettings .expando').css('opacity', '0.5').find('select, input').disable(true);
    } else {
      $('.lockvote .status_icon').addClass('icon-unlock');
      $('.globalsettings .checkbox, .globalsettings .expando').css('opacity', '1').find('select, input').disable(false);
    }
  }
  if ($('.teams').data('teamhash') !== team_hash) {
    $('.teams').data('teamhash', team_hash);
    $('.teams').empty();
    $('.teams')[0].options.add(new Option('Individual', ''));
    for (team in teams) {
      members = teams[team];
      team = team.slice(2);
      $('.teams')[0].options.add(new Option("" + team + " (" + members.length + ")", team));
    }
    $('.teams')[0].options.add(new Option('Create Team', 'create'));
    if (me.id in room.users) {
      $('.teams').val(room.users[me.id].team);
    }
  }
  list = $('.leaderboard tbody');
  ranking = 1;
  entities = (function() {
    var _ref2, _results;
    _ref2 = room.users;
    _results = [];
    for (id in _ref2) {
      user = _ref2[id];
      _results.push(user);
    }
    return _results;
  })();
  user_count = entities.length;
  team_count = 0;
  if ($('.teams').val() || me.id.slice(0, 2) === "__") {
    entities = (function() {
      var _i, _len, _ref2, _results;
      _results = [];
      for (team in teams) {
        members = teams[team];
        team = team.slice(2);
        attrs = new QuizPlayer(room, 't-' + team.toLowerCase().replace(/[^a-z0-9]/g, ''));
        team_count++;
        for (_i = 0, _len = members.length; _i < _len; _i++) {
          member = members[_i];
          _ref2 = room.users[member];
          for (attr in _ref2) {
            val = _ref2[attr];
            if (typeof val === 'number') {
              if (!(attr in attrs)) {
                attrs[attr] = 0;
              }
              attrs[attr] += val;
            }
          }
        }
        attrs.members = members;
        attrs.name = team;
        _results.push(attrs);
      }
      return _results;
    })();
    _ref2 = room.users;
    for (id in _ref2) {
      user = _ref2[id];
      if (!user.team) {
        entities.push(user);
      }
    }
  }
  list.empty();
  _ref3 = entities.sort(function(a, b) {
    return get_score(b) - get_score(a);
  });
  for (user_index = _i = 0, _len = _ref3.length; _i < _len; user_index = ++_i) {
    user = _ref3[user_index];
    if (entities[user_index - 1] && get_score(user) < get_score(entities[user_index - 1])) {
      ranking++;
    }
    row = $('<tr>').data('entity', user).appendTo(list);
    row.click(function() {
      return 1;
    });
    badge = $('<span>').addClass('badge pull-right').text(get_score(user));
    if (_ref4 = me.id, __indexOf.call(user.members || [user.id], _ref4) >= 0) {
      badge.addClass('badge-info').attr('title', 'You');
    } else {
      idle_count = 0;
      active_count = 0;
      _ref5 = user.members || [user.id];
      for (_j = 0, _len1 = _ref5.length; _j < _len1; _j++) {
        member = _ref5[_j];
        if (room.users[member].online()) {
          if (room.serverTime() - room.users[member].last_action > 1000 * 60 * 10) {
            idle_count++;
          } else {
            active_count++;
          }
        }
      }
      if (active_count > 0) {
        badge.addClass('badge-success').attr('title', 'Online');
      } else if (idle_count > 0) {
        badge.addClass('badge-warning').attr('title', 'Idle');
      }
    }
    $('<td>').addClass('rank').append(badge).append(ranking).appendTo(row);
    name = $('<td>').appendTo(row);
    $('<td>').text(user.interrupts).appendTo(row);
    if (!user.members) {
      name.append($('<span>').text(user.name));
    } else {
      name.append($('<span>').text(user.name).css('font-weight', 'bold')).append(" (" + user.members.length + ")");
      _ref6 = user.members.sort(function(a, b) {
        return get_score(room.users[b]) - get_score(room.users[a]);
      });
      for (_k = 0, _len2 = _ref6.length; _k < _len2; _k++) {
        member = _ref6[_k];
        user = room.users[member];
        row = $('<tr>').addClass('subordinate').data('entity', user).appendTo(list);
        row.click(function() {
          return 1;
        });
        badge = $('<span>').addClass('badge pull-right').text(get_score(user));
        if (user.id === me.id) {
          badge.addClass('badge-info').attr('title', 'You');
        } else {
          if (user.online()) {
            if (room.serverTime() - user.last_action > 1000 * 60 * 10) {
              badge.addClass('badge-warning').attr('title', 'Idle');
            } else {
              badge.addClass('badge-success').attr('title', 'Online');
            }
          }
        }
        $('<td>').css("border", 0).append(badge).appendTo(row);
        name = $('<td>').text(user.name);
        name.appendTo(row);
        $('<td>').text(user.interrupts).appendTo(row);
      }
    }
  }
  if (user_count > 1 && connected()) {
    if ($('.leaderboard').is(':hidden')) {
      $('.leaderboard').slideDown();
      $('.singleuser').slideUp();
    }
  } else if (room.users[me.id]) {
    $('.singleuser .stats table').replaceWith(createStatSheet(room.users[me.id], !!$('.singleuser').data('full')));
    if ($('.singleuser').is(':hidden')) {
      $('.leaderboard').slideUp();
      $('.singleuser').slideDown();
    }
  }
  return checkAlone();
};

checkAlone = function() {
  var active_count, id, user, _ref;
  if (!connected()) {
    return;
  }
  active_count = 0;
  _ref = room.users;
  for (id in _ref) {
    user = _ref[id];
    if (user.online() && room.serverTime() - user.last_action < 1000 * 60 * 10) {
      active_count++;
    }
  }
  if (active_count === 1) {
    return me.check_public('', function(data) {
      var can, count, links, suggested_candidates;
      suggested_candidates = [];
      for (can in data) {
        count = data[can];
        if (count > 0 && can !== room.name) {
          suggested_candidates.push(can);
        }
      }
      if (suggested_candidates.length > 0) {
        links = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = suggested_candidates.length; _i < _len; _i++) {
            can = suggested_candidates[_i];
            _results.push(can.link("/" + can) + (" (" + data[can] + ") "));
          }
          return _results;
        })();
        $('.foreveralone .roomlist').html(links.join(' or '));
        return $('.foreveralone').slideDown();
      } else {
        return $('.foreveralone').slideUp();
      }
    });
  } else {
    return $('.foreveralone').slideUp();
  }
};

createStatSheet = function(user, full) {
  var body, row, table;
  table = $('<table>').addClass('table headless');
  body = $('<tbody>').appendTo(table);
  row = function(name, val) {
    return $('<tr>').appendTo(body).append($("<th>").text(name)).append($("<td>").addClass("value").append(val));
  };
  row("Score", $('<span>').addClass('badge').text(get_score(user)));
  row("Correct", user.correct);
  row("Interrupts", user.interrupts);
  if (full) {
    row("Early", user.early);
  }
  if (full) {
    row("Incorrect", user.guesses - user.correct);
  }
  row("Guesses", user.guesses);
  row("Seen", user.seen);
  if (user.team) {
    row("Team", user.team);
  }
  if (full) {
    row("ID", user.id.slice(0, 10));
  }
  if (full) {
    row("Last Seen", formatRelativeTime(user.last_action));
  }
  return table;
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
  var addInfo, breadcrumb, bundle, readout, star, well, _ref;
  bundle = $('<div>').addClass('bundle').attr('name', 'question-' + sha1(room.generated_time + room.question)).addClass('room-' + ((_ref = room.name) != null ? _ref.replace(/[^a-z0-9]/g, '') : void 0));
  breadcrumb = $('<ul>');
  star = $('<a>', {
    href: "#",
    rel: "tooltip",
    title: "Bookmark this question"
  }).addClass('icon-star-empty bookmark').click(function(e) {
    var info;
    info = bundle.data('report_info');
    bundle.toggleClass('bookmarked');
    star.toggleClass('icon-star-empty', !bundle.hasClass('bookmarked'));
    star.toggleClass('icon-star', bundle.hasClass('bookmarked'));
    me.bookmark({
      id: info.qid,
      value: bundle.hasClass('bookmarked')
    });
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
  if (room.info.tournament && room.info.year) {
    addInfo('Tournament', room.info.year + ' ' + room.info.tournament);
  } else if (room.info.year) {
    addInfo('Year', room.info.year);
  } else if (room.info.tournament) {
    addInfo('Tournament', room.info.tournament);
  }
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
    var cancel_btn, cat, cat_list, controls, ctype, div, form, info, option, rtype, stype, submit_btn, _i, _j, _len, _len1, _ref1, _ref2;
    info = bundle.data('report_info');
    div = $("<div>").addClass("alert alert-block alert-info").insertBefore(bundle.find(".annotations")).hide();
    div.append($("<button>").attr("data-dismiss", "alert").attr("type", "button").html("&times;").addClass("close"));
    div.append($("<h4>").text("Report Question"));
    form = $("<form>");
    form.addClass('form-horizontal').appendTo(div);
    rtype = $('<div>').addClass('control-group').appendTo(form);
    rtype.append($("<label>").addClass('control-label').text('Description'));
    controls = $("<div>").addClass('controls').appendTo(rtype);
    _ref1 = ["Wrong category", "Wrong details", "Broken question"];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      option = _ref1[_i];
      controls.append($("<label>").addClass("radio").append($("<input type=radio name=description>").val(option.split(" ")[1].toLowerCase())).append(option));
    }
    submit_btn = $('<button type=submit>').addClass('btn btn-primary').text('Submit');
    form.find(":radio").change(function() {
      if (form.find(":radio:checked").val() === 'category') {
        return ctype.slideDown();
      } else {
        ctype.slideUp();
        return submit_btn.disable(false);
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
    $(cat_list).change(function() {
      return submit_btn.disable(cat_list.val() === info.category);
    });
    cat_list.val(info.category);
    $(cat_list).change();
    stype = $('<div>').addClass('control-group').appendTo(form);
    cancel_btn = $('<button>').addClass('btn').text('Cancel').click(function(e) {
      div.slideUp('normal', function() {
        return $(this).remove();
      });
      e.stopPropagation();
      return e.preventDefault();
    });
    $("<div>").addClass('controls').appendTo(stype).append(submit_btn).append(' ').append(cancel_btn);
    $(form).submit(function() {
      var describe;
      describe = form.find(":radio:checked").val();
      if (describe === 'category') {
        info.fixed_category = cat_list.val();
      }
      info.describe = describe;
      me.report_question(info);
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
  return bundle.append($('<ul>').addClass('breadcrumb').append(breadcrumb)).append(readout).append($('<div>').addClass('sticky')).append($('<div>').addClass('annotations'));
};

reader_children = null;

reader_last_state = -1;

updateTextPosition = function() {
  var index, start_index, timeDelta, word_index, _i, _j;
  if (!(room.question && room.timing)) {
    return;
  }
  timeDelta = room.time() - room.begin_time;
  start_index = Math.max(0, reader_last_state);
  index = start_index;
  while (timeDelta > room.cumulative[index]) {
    index++;
  }
  if (start_index > index) {
    for (word_index = _i = index; index <= start_index ? _i < start_index : _i > start_index; word_index = index <= start_index ? ++_i : --_i) {
      reader_children[word_index].className = 'unread';
    }
  }
  for (word_index = _j = start_index; start_index <= index ? _j < index : _j > index; word_index = start_index <= index ? ++_j : --_j) {
    reader_children[word_index].className = '';
  }
  return reader_last_state = index - 1;
};

updateInlineSymbols = function() {
  var bundle, children, early_index, element, elements, i, label_type, readout, spots, stops, words, _i, _j, _ref, _ref1;
  if (!(room.question && room.timing)) {
    return;
  }
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
    if (children.eq(i).html() === elements[i].html()) {
      children.eq(i).addClass('unread');
    } else {
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

var QuizPlayer,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

QuizPlayer = (function() {

  function QuizPlayer(room, id) {
    this.id = id;
    this.room = room;
    this.guesses = 0;
    this.interrupts = 0;
    this.early = 0;
    this.seen = 0;
    this.correct = 0;
    this.history = [];
    this.time_spent = 0;
    this.last_action = this.room.serverTime();
    this.last_session = this.room.serverTime();
    this.created = this.room.serverTime();
    this.times_buzzed = 0;
    this.show_typing = true;
    this.team = '';
    this.banned = 0;
    this.sounds = false;
    this.lock = false;
    this.movingwindow = false;
    this.tribunal = null;
    this.__timeout = null;
    this.__recent_actions = [];
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
    return this.online() && (this.room.serverTime() - this.last_action) < 1000 * 60 * 10;
  };

  QuizPlayer.prototype.online = function() {
    return true;
  };

  QuizPlayer.prototype.score = function() {
    var CORRECT, EARLY, INTERRUPT;
    CORRECT = 10;
    EARLY = 15;
    INTERRUPT = -5;
    return this.early * EARLY + (this.correct - this.early) * CORRECT + this.interrupts * INTERRUPT;
  };

  QuizPlayer.prototype.ban = function() {
    this.banned = this.room.serverTime();
    this.verb("was banned from " + this.room.name, true);
    return this.emit('redirect', "/" + this.room.name + "-banned");
  };

  QuizPlayer.prototype.emit = function(name, data) {
    return this.room.log('QuizPlayer.emit(name, data) not implemented');
  };

  QuizPlayer.prototype.bookmark = function(_arg) {
    var id, value;
    value = _arg.value, id = _arg.id;
    return 0;
  };

  QuizPlayer.prototype.disco = function() {
    return 0;
  };

  QuizPlayer.prototype.rate_limit = function() {
    var action_delay, current_time, id, mean_elapsed, s, time, user, window_size, witnesses, _i, _len, _ref;
    witnesses = (function() {
      var _ref, _results;
      _ref = this.room.users;
      _results = [];
      for (id in _ref) {
        user = _ref[id];
        if (id[0] !== "_" && user.active()) {
          _results.push(id);
        }
      }
      return _results;
    }).call(this);
    if (witnesses.length <= 2) {
      return;
    }
    window_size = 5;
    action_delay = 876;
    current_time = this.room.serverTime();
    this.__recent_actions.push(current_time);
    this.__recent_actions = this.__recent_actions.slice(-window_size);
    if (this.__recent_actions.length === window_size) {
      s = 0;
      _ref = this.__recent_actions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        time = _ref[_i];
        s += time;
      }
      mean_elapsed = current_time - s / window_size;
      if (mean_elapsed < window_size * action_delay / 2) {
        return this.create_tribunal();
      }
    }
  };

  QuizPlayer.prototype.create_tribunal = function() {
    var current_time, id, user, witnesses,
      _this = this;
    if (!this.tribunal) {
      current_time = this.room.serverTime();
      witnesses = (function() {
        var _ref, _results;
        _ref = this.room.users;
        _results = [];
        for (id in _ref) {
          user = _ref[id];
          if (id[0] !== "_" && user.active()) {
            _results.push(id);
          }
        }
        return _results;
      }).call(this);
      this.__timeout = setTimeout(function() {
        _this.verb('survived the tribunal', true);
        _this.tribunal = null;
        return _this.room.sync(1);
      }, 1000 * 60);
      this.tribunal = {
        votes: [],
        against: [],
        time: current_time,
        witnesses: witnesses
      };
      return this.room.sync(1);
    }
  };

  QuizPlayer.prototype.trigger_tribunal = function(user) {
    var _ref;
    this.verb('created a ban tribunal for !@' + user);
    return (_ref = this.room.users[user]) != null ? _ref.create_tribunal() : void 0;
  };

  QuizPlayer.prototype.ban_user = function(user) {
    var _ref;
    return (_ref = this.room.users[user]) != null ? _ref.ban() : void 0;
  };

  QuizPlayer.prototype.vote_tribunal = function(_arg) {
    var against, position, tribunal, undecided, user, votes, witnesses, _ref, _ref1, _ref2, _ref3;
    user = _arg.user, position = _arg.position;
    tribunal = (_ref = this.room.users[user]) != null ? _ref.tribunal : void 0;
    if (tribunal) {
      votes = tribunal.votes, against = tribunal.against, witnesses = tribunal.witnesses;
      if (_ref1 = this.id, __indexOf.call(witnesses, _ref1) < 0) {
        if ((_ref2 = this.id, __indexOf.call(votes, _ref2) >= 0) || (_ref3 = this.id, __indexOf.call(against, _ref3) >= 0)) {

        }
      }
      if (position === 'ban') {
        votes.push(this.id);
        this.verb('voted to ban !@' + user);
      } else if (position === 'free') {
        against.push(this.id);
        this.verb('voted to free !@' + user);
      } else {
        this.verb('voted with a hanging chad');
      }
      if (votes.length > (witnesses.length - 1) / 2 + against.length) {
        this.room.users[user].verb('got voted off the island', true);
        clearTimeout(this.room.users[user].__timeout);
        this.room.users[user].tribunal = null;
        this.room.users[user].ban();
      }
      undecided = witnesses.length - against.length - votes.length - 1;
      if (votes.length + undecided <= (witnesses.length - 1) / 2 + against.length) {
        this.room.users[user].verb('was freed because of a hung jury', true);
        this.room.users[user].tribunal = null;
        clearTimeout(this.room.users[user].__timeout);
      }
      return this.room.sync(1);
    }
  };

  QuizPlayer.prototype.verb = function(action, no_rate_limit) {
    if (this.id.toString().slice(0, 2) === '__') {
      return;
    }
    if (!no_rate_limit) {
      this.rate_limit();
    }
    return this.room.emit('log', {
      user: this.id,
      verb: action,
      time: this.room.serverTime()
    });
  };

  QuizPlayer.prototype.disconnect = function() {
    var seconds;
    if (this.sockets.length === 0) {
      seconds = (this.room.serverTime() - this.last_session) / 1000;
      if (seconds > 90) {
        this.verb("left the room (logged on " + (Math.round(seconds / 60)) + " minutes ago)");
      } else if (seconds > 1) {
        this.verb("left the room (logged on " + (Math.round(seconds)) + " seconds ago)");
      } else {
        this.verb("left the room");
      }
    }
    this.touch();
    return this.room.sync(1);
  };

  QuizPlayer.prototype.echo = function(data, callback) {
    return callback(this.room.serverTime());
  };

  QuizPlayer.prototype.buzz = function(data, fn) {
    if (this.room.buzz(this.id, fn)) {
      return this.rate_limit();
    }
  };

  QuizPlayer.prototype.guess = function(data) {
    return this.room.guess(this.id, data);
  };

  QuizPlayer.prototype.chat = function(_arg) {
    var done, session, text;
    text = _arg.text, done = _arg.done, session = _arg.session;
    this.touch();
    this.room.emit('chat', {
      text: text,
      session: session,
      user: this.id,
      done: done,
      time: this.room.serverTime()
    });
    if (done) {
      return this.rate_limit();
    }
  };

  QuizPlayer.prototype.skip = function() {
    this.touch();
    if (!this.room.attempt && !this.room.no_skip) {
      this.room.new_question();
      return this.verb('skipped a question');
    }
  };

  QuizPlayer.prototype.next = function() {
    this.touch();
    return this.room.next();
  };

  QuizPlayer.prototype.finish = function() {
    this.touch();
    if (!this.room.attempt && !this.room.no_skip) {
      this.verb('skipped to the end of a question');
      this.room.finish();
      return this.room.sync(1);
    }
  };

  QuizPlayer.prototype.pause = function() {
    this.touch();
    if (this.room.time_freeze) {
      return;
    }
    if (!this.room.attempt && this.room.time() < this.room.end_time) {
      this.verb('paused the game');
      this.room.freeze();
      return this.room.sync();
    }
  };

  QuizPlayer.prototype.unpause = function() {
    var duration;
    this.touch();
    if (!this.room.time_freeze) {
      return;
    }
    if (!this.room.question) {
      this.room.new_question();
      this.room.unfreeze();
    } else if (!this.room.attempt) {
      duration = Math.round((this.room.offsetTime() - this.room.time_freeze) / 1000);
      if (duration > 2) {
        this.verb("resumed the game (paused for " + duration + " seconds}");
      } else {
        this.verb("resumed the game");
      }
      this.room.unfreeze();
    }
    return this.room.sync();
  };

  QuizPlayer.prototype.set_lock = function(val) {
    this.lock = !!val;
    this.touch();
    return this.room.sync(1);
  };

  QuizPlayer.prototype.set_name = function(name) {
    if (name.trim().length > 0) {
      this.name = name.trim().slice(0, 140);
      this.touch();
      return this.room.sync(1);
    }
  };

  QuizPlayer.prototype.set_distribution = function(data) {
    var cat, count, disabled, enabled,
      _this = this;
    this.touch();
    if (!data) {
      return;
    }
    enabled = [];
    disabled = [];
    for (cat in data) {
      count = data[cat];
      if (this.room.distribution[cat] === 0 && count > 0) {
        enabled.push(cat);
      }
      if (this.room.distribution[cat] > 0 && count === 0) {
        disabled.push(cat);
      }
    }
    this.room.distribution = data;
    this.room.sync(3);
    return this.room.get_size(function(size) {
      if (enabled.length > 0) {
        _this.verb("enabled " + (enabled.join(', ')) + " (" + size + " questions)");
      }
      if (disabled.length > 0) {
        return _this.verb("disabled " + (disabled.join(', ')) + " (" + size + " questions)");
      }
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
    if (this.room.max_buzz !== data) {
      if (!data) {
        this.verb('allowed players to buzz multiple times');
      } else if (data === 1) {
        this.verb('restricted players and teams to a single buzz per question');
      } else if (data > 1) {
        this.verb("restricted players and teams to " + data + " buzzes per question");
      }
    }
    this.room.max_buzz = data;
    this.touch();
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
    return this.room.sync(1);
  };

  QuizPlayer.prototype.set_type = function(name) {
    var _this = this;
    if (name) {
      this.room.type = name;
      this.room.category = '';
      this.room.difficulty = '';
      this.room.sync(3);
      return this.room.get_size(function(size) {
        return _this.verb("changed the question type to " + name + " (" + size + " questions)");
      });
    }
  };

  QuizPlayer.prototype.set_show_typing = function(data) {
    this.show_typing = data;
    return this.room.sync(1);
  };

  QuizPlayer.prototype.set_sounds = function(data) {
    this.sounds = data;
    return this.room.sync(1);
  };

  QuizPlayer.prototype.set_movingwindow = function(num) {
    if (num) {
      this.movingwindow = num;
    } else {
      this.movingwindow = false;
    }
    return this.room.sync(1);
  };

  QuizPlayer.prototype.set_skip = function(data) {
    this.room.no_skip = !data;
    this.room.sync(1);
    if (this.room.no_skip) {
      return this.verb('disabled question skipping');
    } else {
      return this.verb('enabled question skipping');
    }
  };

  QuizPlayer.prototype.set_bonus = function(data) {
    this.room.show_bonus = data;
    if (this.room.show_bonus) {
      this.verb('enabled showing bonus questions');
    } else {
      this.verb('disabled showing bonus questions');
    }
    return this.room.sync(1);
  };

  QuizPlayer.prototype.reset_score = function() {
    this.verb("was reset from " + (this.score()) + " points (" + this.correct + " correct, " + this.early + " early, " + this.guesses + " guesses)");
    this.seen = this.interrupts = this.guesses = this.correct = this.early = 0;
    this.history = [];
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

var QuizRoom, default_distribution, error_bonus, error_question,
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

error_bonus = {
  'category': 'Mission Accomplished',
  'difficulty': 'null',
  'num': 'undefined',
  'tournament': 'magic smoke',
  'question': 'This question has not yet been written.',
  'answer': 'failure',
  'year': 2003,
  'round': '1'
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
    this.start_offset = 0;
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
    this.no_skip = false;
    this.show_bonus = false;
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
    var _this = this;
    setTimeout(function() {
      if (_this.next_id === '__error_bonus') {
        return cb(error_bonus);
      } else {
        return cb(error_question);
      }
    }, 10);
    return this.log('NOT IMPLEMENTED (async get question)');
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
      return this.offsetTime();
    }
  };

  QuizRoom.prototype.offsetTime = function() {
    return this.serverTime() - this.time_offset;
  };

  QuizRoom.prototype.serverTime = function() {
    return new Date - this.sync_offset;
  };

  QuizRoom.prototype.set_time = function(ts) {
    return this.time_offset = this.serverTime() - ts;
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
      if (!question || !question.question || !question.answer) {
        question = error_question;
      }
      delete _this.generating_question;
      _this.generated_time = _this.serverTime();
      _this.attempt = null;
      _this.next_id = question.next || null;
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
      _this.begin_time = _this.time() + _this.start_offset;
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
        user.history.push(user.score());
        user.history = user.history.slice(-30);
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

  QuizRoom.prototype.finish = function() {
    return this.set_time(this.end_time);
  };

  QuizRoom.prototype.next = function() {
    if (this.time() > this.end_time - this.answer_duration && !this.generating_question && !this.attempt) {
      this.unfreeze();
      return this.new_question();
    }
  };

  QuizRoom.prototype.check_answer = function(attempt, answer, question) {
    if (Math.random() > 0.8) {
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
            if (user.active()) {
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
      this.journal();
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
      if (this.attempt === null) {
        this.emit('log', {
          user: user,
          verb: 'has already buzzed'
        });
      }
    } else if (this.max_buzz && team_buzzed >= this.max_buzz) {
      if (fn) {
        fn('THE BUZZES ARE TOO DAMN HIGH');
      }
      this.emit('log', {
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
      this.timeout(this.attempt.duration, function() {
        return _this.end_buzz(session);
      });
      return true;
    } else if (this.attempt) {
      this.emit('log', {
        user: user,
        verb: 'lost the buzzer race'
      });
      if (fn) {
        fn('THE GAME');
      }
    } else {
      this.emit('log', {
        user: user,
        verb: 'attempted an invalid buzz'
      });
      if (fn) {
        fn('THE GAME');
      }
    }
    return false;
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
      real_time: this.serverTime()
    };
    blacklist = ["question", "answer", "generated_time", "timing", "voting", "info", "cumulative", "users", "generating_question", "distribution", "sync_offset"];
    user_blacklist = ["sockets", "room"];
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
          if (!(id[0] !== '_')) {
            continue;
          }
          user = {};
          for (attr in this.users[id]) {
            if (__indexOf.call(user_blacklist, attr) < 0 && ((_ref = typeof this.users[id][attr]) !== 'function') && attr[0] !== '_') {
              user[attr] = this.users[id][attr];
            }
          }
          user.online_state = this.users[id].online();
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
      data.generated_time = this.generated_time;
    }
    if (level >= 3) {
      data.distribution = this.distribution;
      this.get_parameters(this.type, this.difficulty, function(difficulties, categories) {
        data.difficulties = difficulties;
        data.categories = categories;
        return _this.emit('sync', data);
      });
      return this.journal();
    } else {
      return this.emit('sync', data);
    }
  };

  QuizRoom.prototype.journal = function() {
    return 0;
  };

  QuizRoom.prototype.journal_export = function() {
    var attr, data, field, id, settings, user, user_blacklist, _i, _len;
    data = {};
    user_blacklist = ["sockets", "room"];
    data.users = (function() {
      var _ref, _results;
      _results = [];
      for (id in this.users) {
        user = {};
        for (attr in this.users[id]) {
          if (__indexOf.call(user_blacklist, attr) < 0 && ((_ref = typeof this.users[id][attr]) !== 'function') && attr[0] !== '_') {
            user[attr] = this.users[id][attr];
          }
        }
        _results.push(user);
      }
      return _results;
    }).call(this);
    settings = ["type", "name", "difficulty", "category", "rate", "answer_duration", "max_buzz", "distribution", "no_skip", "show_bonus"];
    for (_i = 0, _len = settings.length; _i < _len; _i++) {
      field = settings[_i];
      data[field] = this[field];
    }
    return data;
  };

  return QuizRoom;

})();

if (typeof exports !== "undefined" && exports !== null) {
  exports.QuizRoom = QuizRoom;
}

var Avg, QuizPlayerClient, QuizPlayerSlave, QuizRoomSlave, StDev, Sum, compute_sync_offset, connected, handleCacheEvent, initialize_offline, last_freeze, latency_log, listen, me, offline_startup, online_startup, room, sock, sync_offsets, synchronize, testLatency,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(function() {
  var t;
  t = new Date(protobowl_build);
  return $('#version').text("" + (t.getMonth() + 1) + "/" + (t.getDate()) + "/" + (t.getFullYear() % 100) + " " + (t.getHours()) + ":" + ((t.getMinutes() / 100).toFixed(2).slice(2)));
})();

initialize_offline = function(cb) {
  return $.ajax({
    url: '/offline.js',
    cache: true,
    dataType: 'script',
    success: cb
  });
};

offline_startup = function() {
  initialize_offline(function() {
    room.__listeners.joined({
      id: 'offline',
      name: 'offline user'
    });
    room.sync(3);
    return me.verb('joined the room');
  });
  return setTimeout(function() {
    return chatAnnotation({
      text: 'Feeling lonely offline? Just say "I\'m Lonely" and talk to me!',
      user: '__protobot',
      done: true
    });
  }, 30 * 1000);
};

sock = null;

online_startup = function() {
  sock = io.connect(location.hostname, {
    "connect timeout": 4000
  });
  sock.on('connect', function() {
    $('.disconnect-notice').slideUp();
    $('#reload, #disconnect, #reconnect').hide();
    $('#disconnect').show();
    return me.disco({
      old_socket: localStorage.old_socket,
      version: 5
    });
  });
  return sock.on('disconnect', function() {
    var line, _ref;
    $('#reload, #disconnect, #reconnect').hide();
    $('#reconnect').show();
    if (((_ref = room.attempt) != null ? _ref.user : void 0) !== me.id) {
      room.attempt = null;
    }
    line = $('<div>').addClass('alert alert-error');
    line.append($('<p>').append("You were ", $('<span class="label label-important">').text("disconnected"), " from the server for some reason. ", $('<em>').text(new Date)));
    line.append($('<p>').append("This may be due to a drop in the network 				connectivity or a malfunction in the server. The client will automatically 				attempt to reconnect to the server and in the mean time, the app has automatically transitioned				into <b>offline mode</b>. You can continue playing alone with a limited offline set				of questions without interruption. However, you might want to try <a href=''>reloading</a>."));
    return addImportant($('<div>').addClass('log disconnect-notice').append(line));
  });
};

if (typeof io !== "undefined" && io !== null) {
  online_startup();
  setTimeout(function() {
    if (!sock.socket.connected) {
      return $('#slow').slideDown();
    }
  }, 1000 * 3);
  setTimeout(initialize_offline, 1000);
} else {
  offline_startup();
}

connected = function() {
  return (sock != null) && sock.socket.connected;
};

QuizPlayerClient = (function(_super) {

  __extends(QuizPlayerClient, _super);

  function QuizPlayerClient() {
    return QuizPlayerClient.__super__.constructor.apply(this, arguments);
  }

  QuizPlayerClient.prototype.online = function() {
    return this.online_state;
  };

  return QuizPlayerClient;

})(QuizPlayer);

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
    blacklist = ['envelop_action', 'score', 'online', 'active'];
    for (name in this) {
      method = this[name];
      if (typeof method === 'function' && __indexOf.call(blacklist, name) < 0) {
        this.envelop_action(name);
      }
    }
  }

  return QuizPlayerSlave;

})(QuizPlayerClient);

QuizRoomSlave = (function(_super) {

  __extends(QuizRoomSlave, _super);

  QuizRoomSlave.prototype.emit = function(name, data) {
    return this.__listeners[name](data);
  };

  function QuizRoomSlave(name) {
    QuizRoomSlave.__super__.constructor.call(this, name);
    this.__listeners = {};
  }

  QuizRoomSlave.prototype.load_questions = function(cb) {
    var _this = this;
    if (typeof load_questions !== "undefined" && load_questions !== null) {
      return load_questions(cb);
    } else {
      return setTimeout(function() {
        return _this.load_questions(cb);
      }, 100);
    }
  };

  QuizRoomSlave.prototype.check_answer = function(attempt, answer, question) {
    return checkAnswer(attempt, answer, question);
  };

  QuizRoomSlave.prototype.get_parameters = function(type, difficulty, cb) {
    return this.load_questions(function() {
      return get_parameters(type, difficulty, cb);
    });
  };

  QuizRoomSlave.prototype.count_questions = function(type, difficulty, category, cb) {
    return this.load_questions(function() {
      return count_questions(type, difficulty, category, cb);
    });
  };

  QuizRoomSlave.prototype.get_question = function(cb) {
    var _this = this;
    return this.load_questions(function() {
      var category;
      category = (_this.category === 'custom' ? _this.distribution : _this.category);
      return get_question(_this.type, _this.difficulty, category, function(question) {
        return cb(question || error_question);
      });
    });
  };

  return QuizRoomSlave;

})(QuizRoom);

room = new QuizRoomSlave();

me = new QuizPlayerSlave(room, 'temporary');

listen = function(name, fn) {
  if (sock != null) {
    sock.on(name, fn);
  }
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

listen('force_application_update', function() {
  $('#update').data('force', true);
  return applicationCache.update();
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
  $('#slow').slideUp();
  me.id = data.id;
  me.name = data.name;
  room.users[me.id] = me;
  $('.actionbar button').disable(false);
  $('#username').val(me.name);
  return $('#username').disable(false);
});

sync_offsets = [];

latency_log = [];

last_freeze = -1;

synchronize = function(data) {
  var attr, blacklist, cumsum, del, i, starts, u, user, user_blacklist, val, variable, _i, _len, _ref, _ref1;
  blacklist = ['real_time', 'users'];
  sync_offsets.push(+(new Date) - data.real_time);
  compute_sync_offset();
  for (attr in data) {
    val = data[attr];
    if (__indexOf.call(blacklist, attr) < 0) {
      room[attr] = val;
    }
  }
  if (connected()) {
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
      if (((function() {
        var _results;
        _results = [];
        for (u in room.users) {
          _results.push(1);
        }
        return _results;
      })()).length > data.users.length + 5) {
        room.users = {};
      }
      user_blacklist = ['id'];
      _ref = data.users;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        user = _ref[_i];
        if (user.id === me.id) {
          room.users[user.id] = me;
        } else {
          if (!(user.id in room.users)) {
            room.users[user.id] = new QuizPlayerClient(room, user.id);
          }
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
  renderPartial();
  if (last_freeze !== room.time_freeze) {
    last_freeze = room.time_freeze;
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
    return renderUsers();
  }
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

handleCacheEvent = function() {
  var status;
  status = applicationCache.status;
  switch (applicationCache.status) {
    case applicationCache.UPDATEREADY:
      $('#cachestatus').text('Updated');
      $('#update').slideDown();
      if (localStorage.auto_reload === "yay" || $('#update').data('force') === true) {
        setTimeout(function() {
          return location.reload();
        }, 500 + Math.random() * 2000);
      }
      return applicationCache.swapCache();
    case applicationCache.UNCACHED:
      return $('#cachestatus').text('Uncached');
    case applicationCache.OBSOLETE:
      return $('#cachestatus').text('Obsolete');
    case applicationCache.IDLE:
      return $('#cachestatus').text('Cached');
    case applicationCache.DOWNLOADING:
      return $('#cachestatus').text('Downloading');
    case applicationCache.CHECKING:
      return $('#cachestatus').text('Checking');
  }
};

(function() {
  var name, _i, _len, _ref, _results;
  if (window.applicationCache) {
    _ref = ['cached', 'checking', 'downloading', 'error', 'noupdate', 'obsolete', 'progress', 'updateready'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      _results.push(applicationCache.addEventListener(name, handleCacheEvent));
    }
    return _results;
  }
})();
