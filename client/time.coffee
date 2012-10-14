getTimeSpan = do ->
	# https://github.com/skovalyov/coffee-script-utils/tree/master/date
	SECOND_IN_MILLISECONDS = 1000
	FEW_SECONDS = 5
	MINUTE_IN_SECONDS = 60
	HOUR_IN_SECONDS = MINUTE_IN_SECONDS * 60
	MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	WEEKDAY_NAMES = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

	formatTime = (date) ->
		minutes = date.getMinutes()
		hours = date.getHours()
		ampm = if hours > 12 then "pm" else "am"
		formattedHours = if hours == 0 or hours == 12 then "12" else "#{hours % 12}";
		formattedMinutes = if minutes < 10 then "0#{minutes}" else "#{minutes}"
		formattedTime = "#{formattedHours}:#{formattedMinutes}#{ampm}"
		return formattedTime

	formatMonth = (date) -> MONTH_NAMES[date.getMonth()]

	formatWeekday = (date) -> WEEKDAY_NAMES[date.getDay()]

	getTimeSpan = (date) ->
		now = new Date()
		range = (now.getTime() - date.getTime()) / SECOND_IN_MILLISECONDS
		nextYearStart = new Date now.getFullYear() + 1, 0, 1
		nextWeekStart = new Date now.getFullYear(), now.getMonth(), now.getDate() + (7 - now.getDay())
		tomorrowStart = new Date now.getFullYear(), now.getMonth(), now.getDate() + 1
		theDayAfterTomorrowStart = new Date now.getFullYear(), now.getMonth(), now.getDate() + 2
		todayStart = new Date now.getFullYear(), now.getMonth(), now.getDate()
		yesterdayStart = new Date now.getFullYear(), now.getMonth(), now.getDate() - 1
		thisWeekStart = new Date now.getFullYear(), now.getMonth(), now.getDate() - now.getDay()
		thisYearStart = new Date now.getFullYear(), 0, 1
		nextYearRange = (now.getTime() - nextYearStart.getTime()) / SECOND_IN_MILLISECONDS
		nextWeekRange = (now.getTime() - nextWeekStart.getTime()) / SECOND_IN_MILLISECONDS
		theDayAfterTomorrowRange = (now.getTime() - theDayAfterTomorrowStart.getTime()) / SECOND_IN_MILLISECONDS
		tomorrowRange = (now.getTime() - tomorrowStart.getTime()) / SECOND_IN_MILLISECONDS
		todayRange = (now.getTime() - todayStart.getTime()) / SECOND_IN_MILLISECONDS
		yesterdayRange = (now.getTime() - yesterdayStart.getTime()) / SECOND_IN_MILLISECONDS
		thisWeekRange = (now.getTime() - thisWeekStart.getTime()) / SECOND_IN_MILLISECONDS
		thisYearRange = (now.getTime() - thisYearStart.getTime()) / SECOND_IN_MILLISECONDS
		if range >= 0
			if range < FEW_SECONDS
				result = "A few seconds ago"
			else if range < MINUTE_IN_SECONDS
				result = "#{Math.floor(range)} seconds ago"
			else if range < MINUTE_IN_SECONDS * 2
				result = "About a minute ago"
			else if range < HOUR_IN_SECONDS
				result = "#{Math.floor(range / MINUTE_IN_SECONDS)} minutes ago"
			else if range < HOUR_IN_SECONDS * 2
				result = "About an hour ago"
			else if range < todayRange
				result = "#{Math.floor(range / HOUR_IN_SECONDS)} hours ago"
			else if range < yesterdayRange
				result = "Yesterday at #{formatTime(date)}"
			else if range < thisWeekRange
				result = "#{formatWeekday(date)} at #{formatTime(date)}"
			else if range < thisYearRange
				result = "#{formatMonth(date)} #{date.getDate()} at #{formatTime(date)}"
			else
				result = "#{formatMonth(date)} #{date.getDate()}, #{date.getFullYear()} at #{formatTime(date)}"
		else
			if range > -FEW_SECONDS
				result = "In a few seconds"
			else if range > -MINUTE_IN_SECONDS
				result = "In #{Math.floor(-range)} seconds"
			else if range > -MINUTE_IN_SECONDS * 2
				result = "In about a minute"
			else if range > -HOUR_IN_SECONDS
				result = "In #{Math.floor(-range / MINUTE_IN_SECONDS)} minutes"
			else if range > -HOUR_IN_SECONDS * 2
				result = "In about an hour"
			else if range > tomorrowRange
				result = "In #{Math.floor(-range / HOUR_IN_SECONDS)} hours"
			else if range > theDayAfterTomorrowRange
				result = "Tomorrow at #{formatTime(date)}"
			else if range > nextWeekRange
				result = "#{formatWeekday(date)} at #{formatTime(date)}"
			else if range > nextYearRange
				result = "#{formatMonth(date)} #{date.getDate()} at #{formatTime(date)}"
			else
				result = "#{formatMonth(date)} #{date.getDate()}, #{date.getFullYear()} at #{formatTime(date)}"
		return result
	return getTimeSpan

formatRelativeTime = (timestamp) ->
	date = new Date
	date.setTime timestamp
	# console.log 'formatting time', date, timestamp
	return getTimeSpan(date)
	# (date.getHours() % 12)+':'+
	# ('0'+date.getMinutes()).substr(-2,2)+
	# #':'+ ('0'+date.getSeconds()).substr(-2,2) +
	# (if date.getHours() > 12 then "pm" else "am")

formatTime = (timestamp) ->
	date = new Date
	date.setTime timestamp
	(date.getHours() % 12)+':'+
	('0'+date.getMinutes()).substr(-2,2)+
	#':'+ ('0'+date.getSeconds()).substr(-2,2) +
	(if date.getHours() > 12 then "pm" else "am")
