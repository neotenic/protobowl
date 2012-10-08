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
