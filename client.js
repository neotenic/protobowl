// Generated by CoffeeScript 1.3.3
var actionMode, addAnnotation, avg, changeQuestion, chatAnnotation, computeScore, createBundle, cumsum, formatTime, guessAnnotation, last_question, latency_log, mobileLayout, public_id, public_name, removeSplash, renderPartial, renderState, renderTimer, serverTime, setActionMode, sock, stdev, sync, sync_offset, sync_offsets, synchronize, testLatency, time, userSpan, users,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

sock = io.connect();

sync = {};

users = {};

sync_offsets = [];

sync_offset = 0;

jQuery.fn.disable = function(value) {
  var current;
  current = $(this).attr('disabled') === 'disabled';
  if (current !== value) {
    return $(this).attr('disabled', value);
  }
};

mobileLayout = function() {
  return matchMedia('(max-width: 768px)').matches;
};

avg = function(list) {
  var item, sum, _i, _len;
  sum = 0;
  for (_i = 0, _len = list.length; _i < _len; _i++) {
    item = list[_i];
    sum += item;
  }
  return sum / list.length;
};

stdev = function(list) {
  var item, mu;
  mu = avg(list);
  return Math.sqrt(avg((function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      item = list[_i];
      _results.push((item - mu) * (item - mu));
    }
    return _results;
  })()));
};

cumsum = function(list, rate) {
  var num, sum, _i, _len, _results;
  sum = 0;
  _results = [];
  for (_i = 0, _len = list.length; _i < _len; _i++) {
    num = list[_i];
    _results.push(sum += Math.round(num) * rate);
  }
  return _results;
};

/*
	So in this application, we have to juggle around not one, not two, but three notions of time
	(and possibly four if you consider freezable time, which needs a cooler name, like what 
	futurama calls intragnizent, so I'll use that, intragnizent time) anyway. So we have three
	notions of time. The first and simplest is server time, which is an uninterruptable number
	of milliseconds recorded by the server's +new Date. Problem is, that the client's +new Date
	isn't exactly the same (can be a few seconds off, not good when we're dealing with precisions
	of tens of milliseconds). However, we can operate off the assumption that the relative duration
	of each increment of time is the same (as in, the relativistic effects due to players in
	moving vehicles at significant fractions of the speed of light are largely unaccounted for
	in this version of the application), and even imprecise quartz clocks only loose a second
	every day or so, which is perfectly okay in the short spans of minutes which need to go 
	unadjusted. So, we can store the round trip and compare the values and calculate a constant
	offset between the client time and the server time. However, for some reason or another, I
	decided to implement the notion of "pausing" the game by stopping the flow of some tertiary
	notion of time (this makes the math relating to calculating the current position of the read
	somewhat easier).

	This is implemented by an offset which is maintained by the server which goes on top of the
	notion of server time. 

	Why not just use the abstraction of that pausable (tragnizent) time everywhere and forget
	about the abstraction of server time, you may ask? Well, there are two reasons, the first
	of which is that two offsets are maintained anyway (the first prototype only used one, 
	and this caused problems on iOS because certain http requests would have extremely long
	latencies when the user was scrolling, skewing the time, this new system allows the system
	to differentiate a pause from a time skew and maintain a more precise notion of time which
	is calculated by a moving window average of previously observed values)

	The second reason, is that there are times when you actually need server time. Situations
	like when you're buzzing and you have a limited time to answer before your window shuts and
	control gets handed back to the group.
*/


time = function() {
  if (sync.time_freeze) {
    return sync.time_freeze;
  } else {
    return serverTime() - sync.time_offset;
  }
};

serverTime = function() {
  return new Date - sync_offset;
};

window.onbeforeunload = function() {
  localStorage.old_socket = sock.socket.sessionid;
  return null;
};

sock.on('echo', function(data, fn) {
  return fn('alive');
});

sock.on('disconnect', function() {
  return setTimeout(function() {
    return $('#disco').modal('show');
  }, 1000);
});

public_name = null;

public_id = null;

sock.once('connect', function() {
  $('.actionbar button').disable(false);
  $('.timer').removeClass('disabled');
  return sock.emit('join', {
    old_socket: localStorage.old_socket,
    room_name: channel_name,
    public_name: public_name
  }, function(data) {
    public_name = data.name;
    public_id = data.id;
    return $('#username').val(public_name);
  });
});

$('#username').keyup(function() {
  if ($(this).val().length > 0) {
    return sock.emit('rename', $(this).val());
  }
});

synchronize = function(data) {
  var attr, below, item, thresh;
  sync_offsets.push(+(new Date) - data.real_time);
  thresh = avg(sync_offsets);
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
  sync_offset = avg(below);
  $('#sync_offset').text(sync_offset.toFixed(1) + '/' + stdev(below).toFixed(1));
  for (attr in data) {
    sync[attr] = data[attr];
  }
  if ('users' in data) {
    renderState();
  } else {
    renderPartial();
  }
  if (sync.attempt) {
    if (sync.attempt.user !== public_id) {
      if (actionMode === 'guess') {
        return setActionMode('');
      }
    }
  }
};

sock.on('sync', function(data) {
  return synchronize(data);
});

latency_log = [];

testLatency = function() {
  var initialTime;
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
      latency_log.push(CSC1);
      latency_log.push(SCS1);
      return latency_log.push(CSC2);
    });
  });
};

setTimeout(function() {
  testLatency();
  return setInterval(testLatency, 30 * 1000);
}, 2500);

last_question = null;

sock.on('chat', function(data) {
  return chatAnnotation(data);
});

/*
	Correct: 10pts
	Early: 15pts
	Interrupts: -5pts
*/


computeScore = function(user) {
  var CORRECT, EARLY, INTERRUPT;
  CORRECT = 10;
  EARLY = 15;
  INTERRUPT = -5;
  return user.early * EARLY + (user.correct - user.early) * CORRECT + user.interrupts * INTERRUPT;
};

formatTime = function(timestamp) {
  var date;
  date = new Date;
  date.setTime(timestamp);
  return ('0' + date.getHours()).substr(-2, 2) + ':' + ('0' + date.getMinutes()).substr(-2, 2) + ':' + ('0' + date.getSeconds()).substr(-2, 2);
};

renderState = function() {
  var action, badge, count, list, name, row, user, votes, _i, _j, _len, _len1, _ref, _ref1, _ref2;
  if (sync.users) {
    _ref = sync.users;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      user = _ref[_i];
      votes = [];
      for (action in sync.voting) {
        if (_ref1 = user.id, __indexOf.call(sync.voting[action], _ref1) >= 0) {
          votes.push(action);
        }
      }
      user.votes = votes.join(', ');
      users[user.id] = user;
    }
    list = $('.leaderboard tbody');
    count = 0;
    list.find('tr').addClass('to_remove');
    _ref2 = sync.users.sort(function(a, b) {
      return computeScore(b) - computeScore(a);
    });
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      user = _ref2[_j];
      $('.user-' + user.id).text(user.name);
      count++;
      row = list.find('.sockid-' + user.id);
      list.append(row);
      if (row.length < 1) {
        row = $('<tr>').appendTo(list);
        row.popover({
          placement: function() {
            if (mobileLayout()) {
              return "top";
            } else {
              return "left";
            }
          },
          title: user.name + "'s stats",
          trigger: 'manual'
        });
        row.click(function() {
          $('.leaderboard tbody tr').not(this).popover('hide');
          return $(this).popover('toggle');
        });
      }
      row.attr('data-content', ("User ID: " + (user.id.slice(0, 16)) + "\n										Last Seen: " + (formatTime(user.last_action)) + "\n										Correct: " + user.correct + "\n										Early: " + user.early + "\n										Incorrect: " + (user.guesses - user.correct) + "\n										Interrupts: " + user.interrupts + "\n										Guesses: " + user.guesses).replace(/\n/g, '<br>'));
      row.find('td').remove();
      row.addClass('sockid-' + user.id);
      row.removeClass('to_remove');
      badge = $('<span>').addClass('badge').text(computeScore(user));
      if (user.id === public_id) {
        badge.addClass('badge-info');
        badge.attr('title', 'You');
      } else {
        if (user.online) {
          if (serverTime() - user.last_action > 1000 * 60 * 10) {
            badge.addClass('badge-warning');
            badge.attr('title', 'Idle');
          } else {
            badge.addClass('badge-success');
            badge.attr('title', 'Online');
          }
        }
      }
      $('<td>').text(count).append('&nbsp;').append(badge).appendTo(row);
      name = $('<td>').text(user.name);
      name.appendTo(row);
      $('<td>').text(user.interrupts).appendTo(row);
    }
    list.find('tr.to_remove').remove();
  }
  $(window).resize();
  return renderPartial();
};

renderPartial = function() {
  var bundle, buzz, children, cumulative, del, element, elements, i, index, label_type, list, new_text, old_spots, old_text, rate, spots, timeDelta, unread, visible, words, _i, _j, _ref, _ref1, _ref2;
  if (!(sync.question && sync.timing)) {
    return;
  }
  if (sync.question !== last_question) {
    changeQuestion();
    last_question = sync.question;
  }
  if (!sync.time_freeze) {
    removeSplash();
  }
  timeDelta = time() - sync.begin_time;
  words = sync.question.replace(/\s+/g, ' ').split(' ');
  _ref = sync.timing, list = _ref.list, rate = _ref.rate;
  cumulative = cumsum(list, rate);
  index = 0;
  while (timeDelta > cumulative[index]) {
    index++;
  }
  bundle = $('#history .bundle.active');
  new_text = words.slice(0, index).join(' ').trim();
  old_text = bundle.find('.readout .visible').text().replace(/\s+/g, ' ').trim();
  spots = (function() {
    var _i, _len, _ref1, _results;
    _ref1 = bundle.data('starts') || [];
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      buzz = _ref1[_i];
      del = buzz - sync.begin_time;
      i = 0;
      while (del > cumulative[i]) {
        i++;
      }
      _results.push(i - 1);
    }
    return _results;
  })();
  visible = bundle.find('.readout .visible');
  unread = bundle.find('.readout .unread');
  old_spots = visible.data('spots') === spots.join(',');
  if (new_text !== old_text || !old_spots) {
    visible.data('spots', spots.join(','));
    unread.text('');
    children = visible.children();
    children.slice(index).remove();
    elements = [];
    for (i = _i = 0, _ref1 = words.length; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; i = 0 <= _ref1 ? ++_i : --_i) {
      element = $('<span>');
      if (words[i].indexOf('*') !== -1) {
        element.append(" <span class='inline-icon label'><i class='icon-white icon-asterisk'>" + words[i] + "</i></span> ");
      } else {
        element.append(words[i] + " ");
      }
      if (__indexOf.call(spots, i) >= 0) {
        label_type = 'label-important';
        if (i === words.length - 1) {
          label_type = "label-info";
        }
        element.append(" <span class='inline-icon label " + label_type + "'><i class='icon-white icon-bell'></i></span> ");
      }
      elements.push(element);
    }
    for (i = _j = 0, _ref2 = words.length; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; i = 0 <= _ref2 ? ++_j : --_j) {
      if (i < index) {
        if (children.eq(i).html() !== elements[i].html()) {
          children.slice(i).remove();
          visible.append(elements[i]);
        }
      } else {
        unread.append(elements[i].contents());
      }
    }
  }
  renderTimer();
  if (sync.attempt) {
    guessAnnotation(sync.attempt);
  }
  if (latency_log.length > 0) {
    return $('#latency').text(avg(latency_log).toFixed(1) + "/" + stdev(latency_log).toFixed(1));
  }
};

setInterval(renderState, 10000);

setInterval(renderPartial, 50);

renderTimer = function() {
  var cs, elapsed, min, ms, pad, progress, sec, sign, starts, _ref;
  if (sync.time_freeze) {
    if (sync.attempt) {
      starts = $('.bundle.active').data('starts') || [];
      if (_ref = sync.attempt.start, __indexOf.call(starts, _ref) < 0) {
        starts.push(sync.attempt.start);
      }
      $('.bundle.active').data('starts', starts);
      $('.label.pause').hide();
      $('.label.buzz').fadeIn();
    } else {
      $('.label.pause').fadeIn();
      $('.label.buzz').hide();
    }
    if ($('.pausebtn').text() !== 'Resume') {
      $('.pausebtn').text('Resume').addClass('btn-success').removeClass('btn-warning');
    }
  } else {
    $('.label.pause').fadeOut();
    $('.label.buzz').fadeOut();
    if ($('.pausebtn').text() !== 'Pause') {
      $('.pausebtn').text('Pause').addClass('btn-warning').removeClass('btn-success');
    }
  }
  $('.timer').toggleClass('buzz', !!sync.attempt);
  $('.progress').toggleClass('progress-warning', !!(sync.time_freeze && !sync.attempt));
  $('.progress').toggleClass('active progress-danger', !!sync.attempt);
  if (sync.attempt) {
    elapsed = serverTime() - sync.attempt.realTime;
    ms = sync.attempt.duration - elapsed;
    progress = elapsed / sync.attempt.duration;
    $('.pausebtn, .buzzbtn').disable(true);
  } else {
    ms = sync.end_time - time();
    elapsed = time() - sync.begin_time;
    progress = elapsed / (sync.end_time - sync.begin_time);
    $('.pausebtn').disable(ms < 0);
    $('.buzzbtn').disable(ms < 0 || elapsed < 100);
    if (ms < 0) {
      $('.bundle.active').find('.answer').css('visibility', 'visible');
    }
  }
  if ($('.progress .bar').hasClass('pull-right')) {
    $('.progress .bar').width((1 - progress) * 100 + '%');
  } else {
    $('.progress .bar').width(progress * 100 + '%');
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

removeSplash = function(fn) {
  var bundle, start;
  bundle = $('.bundle.active');
  start = bundle.find('.start-page');
  if (start.length > 0) {
    bundle.find('.readout').width(start.width()).slideDown('normal', function() {
      return $(this).width('auto');
    });
    return start.slideUp('normal', function() {
      start.remove();
      if (fn) {
        return fn();
      }
    });
  } else {
    if (fn) {
      return fn();
    }
  }
};

changeQuestion = function() {
  var bundle, cutoff, nested, old, start, well;
  cutoff = 15;
  if (mobileLayout()) {
    cutoff = 1;
  }
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
  if (!last_question && sync.time_freeze && sync.time_freeze - sync.begin_time < 500) {
    start = $('<div>').addClass('start-page');
    well = $('<div>').addClass('well').appendTo(start);
    $('<button>').addClass('btn btn-success btn-large').text('Start the Question').appendTo(well).click(function() {
      return removeSplash(function() {
        return $('.pausebtn').click();
      });
    });
    bundle.find('.readout').hide().before(start);
  }
  bundle.slideDown("slow").queue(function() {
    bundle.width('auto');
    return $(this).dequeue();
  });
  if (old.find('.readout').length > 0) {
    nested = old.find('.readout .visible>span');
    old.find('.readout .visible').append(nested.contents());
    nested.remove();
    old.find('.readout')[0].normalize();
    return old.queue(function() {
      old.find('.readout').slideUp("slow");
      return $(this).dequeue();
    });
  }
};

createBundle = function() {
  var addInfo, annotations, breadcrumb, bundle, readout, star, well;
  bundle = $('<div>').addClass('bundle');
  breadcrumb = $('<ul>').addClass('breadcrumb');
  addInfo = function(name, value) {
    breadcrumb.find('li').last().append($('<span>').addClass('divider').text('/'));
    return breadcrumb.append($('<li>').text(name + ": " + value));
  };
  addInfo('Category', sync.info.category);
  addInfo('Difficulty', sync.info.difficulty);
  addInfo('Tournament', sync.info.year + ' ' + sync.info.tournament);
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
  breadcrumb.append($('<li>').addClass('pull-right answer').text("Answer: " + sync.answer));
  readout = $('<div>').addClass('readout');
  well = $('<div>').addClass('well').appendTo(readout);
  well.append($('<span>').addClass('visible'));
  well.append(document.createTextNode(' '));
  well.append($('<span>').addClass('unread').text(sync.question));
  annotations = $('<div>').addClass('annotations');
  return bundle.append(breadcrumb).append(readout).append(annotations);
};

userSpan = function(user) {
  var _ref;
  return $('<span>').addClass('user-' + user).text(((_ref = users[user]) != null ? _ref.name : void 0) || '[name missing]');
};

addAnnotation = function(el) {
  el.css('display', 'none').prependTo($('#history .bundle .annotations').first());
  el.slideDown();
  return el;
};

guessAnnotation = function(_arg) {
  var correct, early, final, id, interrupt, line, marker, ruling, session, text, user;
  session = _arg.session, text = _arg.text, user = _arg.user, final = _arg.final, correct = _arg.correct, interrupt = _arg.interrupt, early = _arg.early;
  id = user + '-' + session;
  if ($('#' + id).length > 0) {
    line = $('#' + id);
  } else {
    line = $('<p>').attr('id', id);
    marker = $('<span>').addClass('label').text("Buzz");
    if (early) {

    } else if (interrupt) {
      marker.addClass('label-important');
    } else {
      marker.addClass('label-info');
    }
    line.append(marker);
    line.append(" ");
    line.append(userSpan(user).addClass('author'));
    line.append(document.createTextNode(' '));
    $('<span>').addClass('comment').appendTo(line);
    ruling = $('<span>').addClass('label ruling').hide();
    line.append(' ');
    line.append(ruling);
    addAnnotation(line);
  }
  if (final) {
    if (text === '') {
      line.find('.comment').html('<em>(blank)</em>');
    } else {
      line.find('.comment').text(text);
    }
  } else {
    line.find('.comment').text(text);
  }
  if (final) {
    ruling = line.find('.ruling').show().css('display', 'inline');
    if (correct) {
      ruling.addClass('label-success').text('Correct');
    } else {
      ruling.addClass('label-warning').text('Wrong');
    }
    if (actionMode === 'guess') {
      return setActionMode('');
    }
  }
};

chatAnnotation = function(_arg) {
  var final, id, line, session, text, time, user;
  session = _arg.session, text = _arg.text, user = _arg.user, final = _arg.final, time = _arg.time;
  id = user + '-' + session;
  if ($('#' + id).length > 0) {
    line = $('#' + id);
  } else {
    line = $('<p>').attr('id', id);
    line.append(userSpan(user).addClass('author').attr('title', formatTime(time)));
    line.append(document.createTextNode(' '));
    $('<span>').addClass('comment').appendTo(line);
    addAnnotation(line);
  }
  if (final) {
    if (text === '') {
      line.find('.comment').html('<em>(no message)</em>');
    } else {
      line.find('.comment').text(text);
    }
  } else {
    line.find('.comment').text(text);
  }
  return line.toggleClass('typing', !final);
};

sock.on('introduce', function(_arg) {
  var line, user;
  user = _arg.user;
  line = $('<p>').addClass('log');
  line.append(userSpan(user));
  line.append(" joined the room");
  return addAnnotation(line);
});

sock.on('leave', function(_arg) {
  var line, user;
  user = _arg.user;
  line = $('<p>').addClass('log');
  line.append(userSpan(user));
  line.append(" left the room");
  return addAnnotation(line);
});

jQuery('.bundle .breadcrumb').live('click', function() {
  var readout;
  if (!$(this).is(jQuery('.bundle .breadcrumb').first())) {
    readout = $(this).parent().find('.readout');
    return readout.width($('#history').width()).slideToggle("slow", function() {
      return readout.width('auto');
    });
  }
});

actionMode = '';

setActionMode = function(mode) {
  actionMode = mode;
  $('.guess_input, .chat_input').blur();
  $('.actionbar').toggle(mode === '');
  $('.chat_form').toggle(mode === 'chat');
  $('.guess_form').toggle(mode === 'guess');
  return $(window).resize();
};

$('.chatbtn').click(function() {
  setActionMode('chat');
  return $('.chat_input').data('input_session', Math.random().toString(36).slice(3)).val('').focus();
});

$('.skipbtn').click(function() {
  return sock.emit('skip', 'yay');
});

$('.buzzbtn').click(function() {
  if ($('.buzzbtn').attr('disabled') === 'disabled') {
    return;
  }
  setActionMode('guess');
  $('.guess_input').val('').focus();
  return sock.emit('buzz', 'yay');
});

$('.pausebtn').click(function() {
  return removeSplash(function() {
    if (!!sync.time_freeze) {
      return sock.emit('unpause', 'yay');
    } else {
      return sock.emit('pause', 'yay');
    }
  });
});

$('input').keydown(function(e) {
  return e.stopPropagation();
});

$('.chat_input').keyup(function(e) {
  if (e.keyCode === 13) {
    return;
  }
  return sock.emit('chat', {
    text: $('.chat_input').val(),
    session: $('.chat_input').data('input_session'),
    final: false
  });
});

$('.chat_form').submit(function(e) {
  sock.emit('chat', {
    text: $('.chat_input').val(),
    session: $('.chat_input').data('input_session'),
    final: true
  });
  e.preventDefault();
  return setActionMode('');
});

$('.guess_input').keyup(function(e) {
  if (e.keyCode === 13) {
    return;
  }
  return sock.emit('guess', {
    text: $('.guess_input').val(),
    final: false
  });
});

$('.guess_form').submit(function(e) {
  sock.emit('guess', {
    text: $('.guess_input').val(),
    final: true
  });
  e.preventDefault();
  return setActionMode('');
});

$('body').keydown(function(e) {
  var _ref, _ref1, _ref2;
  if (actionMode === 'chat') {
    return $('.chat_input').focus();
  }
  if (actionMode === 'guess') {
    return $('.guess_input').focus();
  }
  if (e.shiftKey || e.ctrlKey || e.metaKey) {
    return;
  }
  if (e.keyCode === 32) {
    e.preventDefault();
    $('.buzzbtn').click();
  } else if ((_ref = e.keyCode) === 83 || _ref === 78 || _ref === 74) {
    $('.skipbtn').click();
  } else if ((_ref1 = e.keyCode) === 80 || _ref1 === 82) {
    $('.pausebtn').click();
  } else if ((_ref2 = e.keyCode) === 47 || _ref2 === 111 || _ref2 === 191 || _ref2 === 67) {
    e.preventDefault();
    $('.chatbtn').click();
  }
  return console.log(e.keyCode);
});

$(window).resize(function() {
  return $('.expando').each(function() {
    var add, outer, size;
    add = $(this).find('.add-on').outerWidth();
    size = $(this).width();
    outer = $(this).find('input').outerWidth() - $(this).find('input').width();
    return $(this).find('input').width(size - outer - add);
  });
});

$(window).resize();

setTimeout(function() {
  return $(window).resize();
}, 762);

if (!Modernizr.touch && !mobileLayout()) {
  $('.actionbar button').tooltip();
  $('.actionbar button').click(function() {
    return $('.actionbar button').tooltip('hide');
  });
  $('#history').tooltip({
    selector: "a[rel=tooltip]",
    placement: function() {
      if (mobileLayout()) {
        return "error";
      } else {
        return "left";
      }
    }
  });
}

if (Modernizr.touch) {
  $('.show-keyboard').hide();
  $('.show-touch').show();
} else {
  $('.show-keyboard').show();
  $('.show-touch').hide();
}
