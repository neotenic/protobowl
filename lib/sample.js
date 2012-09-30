var AliasMethod;

AliasMethod = (function() {

  function AliasMethod(object) {
    var avg, count, i, label, large, less, more, p, probabilities, small, sum, _i, _j, _len;
    probabilities = [];
    this.labelmap = [];
    for (label in object) {
      if (object.hasOwnProperty(label)) {
        this.labelmap.push(label);
        probabilities.push(object[label]);
      }
    }
    count = probabilities.length;
    sum = 0;
    for (_i = 0, _len = probabilities.length; _i < _len; _i++) {
      p = probabilities[_i];
      sum += p;
    }
    probabilities = (function() {
      var _j, _len1, _results;
      _results = [];
      for (_j = 0, _len1 = probabilities.length; _j < _len1; _j++) {
        p = probabilities[_j];
        _results.push(p / sum);
      }
      return _results;
    })();
    this.alias = [];
    this.prob = [];
    avg = 1 / count;
    small = [];
    large = [];
    for (i = _j = 0; 0 <= count ? _j < count : _j > count; i = 0 <= count ? ++_j : --_j) {
      if (probabilities[i] >= avg) {
        large.push(i);
      } else {
        small.push(i);
      }
    }
    while (!(small.length === 0 || large.length === 0)) {
      less = small.pop();
      more = large.pop();
      this.prob[less] = probabilities[less] * count;
      this.alias[less] = more;
      probabilities[more] += probabilities[less] - avg;
      if (probabilities[more] >= avg) {
        large.push(more);
      } else {
        small.push(more);
      }
    }
    while (small.length !== 0) {
      this.prob[small.pop()] = 1;
    }
    while (large.length !== 0) {
      this.prob[large.pop()] = 1;
    }
  }

  AliasMethod.prototype.next = function() {
    var col;
    col = Math.floor(Math.random() * this.prob.length);
    if (Math.random() < this.prob[col]) {
      return this.labelmap[col];
    } else {
      return this.labelmap[this.alias[col]];
    }
  };

  return AliasMethod;

})();

exports.AliasMethod = AliasMethod;
