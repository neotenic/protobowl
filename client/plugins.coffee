window.requestAnimationFrame ||=
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) ->
    window.setTimeout( ->
      callback(+new Date())
    , 1000 / 60)


jQuery.fn.disable = (value) ->
	current = $(this).attr('disabled') is 'disabled'
	if current != value
		$(this).attr 'disabled', value

jQuery.fn.fireworks = (times = 5) ->
	for i in [0...times]
		duration = Math.random() * 2000
		@.delay(duration).queue =>
			{top, left} = @position()
			left += jQuery(window).width() * Math.random()
			top += jQuery(window).height() * Math.random()
			color = '#'+Math.random().toString(16).slice(2,8)
			@dequeue()
			for j in [0...50]
				ang = Math.random() * 6.294
				speed = Math.min(100, 150 * Math.random())
				
				vx = speed * Math.cos(ang)
				vy = speed * Math.sin(ang)

				seconds = 2 * Math.random()
				size = 5
				end_size = Math.random() * size
				jQuery('<div>')
				.css({
					"position": 'fixed',
					"background-color": color,
					'width': size,
					'height': size,
					'border-radius': size,
					'top': top,
					'left': left
				})
				.appendTo('body')
				.animate {
					left: "+=#{vx * seconds}",
					top: "+=#{vy * seconds}",
					width: end_size,
					height: end_size
				}, {
					duration: seconds * 1000,
					complete: ->
						$(this).remove()
				}

# an expando is a thing which expands to fill space, minus some fixed width thing in front
# used for lots of ui components in protobowl

$(window).resize ->
	$('.expando').each ->
		add = 0
		add += $(i).outerWidth() for i in $(this).find('.add-on, .padd-on')
		# console.log add
		size = $(this).width()
		input = $(this).find('input, .input')
		if input.hasClass 'input'
			outer = 0
		else
			outer = input.outerWidth() - input.width()
		# console.log 'exp', input, add, outer, size
		# console.log(input[0], outer, add)
		if Modernizr.csscalc
			input.css('width', "-webkit-calc(100% - #{outer + add}px)")
			input.css('width', "-moz-calc(100% - #{outer + add}px)")
			input.css('width', "-o-calc(100% - #{outer + add}px)")
			input.css('width', "calc(100% - #{outer + add}px)")
			
		else
			input.width size - outer - add


$(window).resize()

setTimeout ->
	$(window).resize()
, 762 # feynman

setTimeout ->
	$(window).resize()
, 2718 # euler

setTimeout ->
	$(window).resize()
, 6022 # avogadro