mongoose = require 'mongoose'

### ------------- DATABASE CODE IS BASED HERE ------------------ ###
#### -------- NOW ALL YOUR DATA ARE BELONG TO US -------------- ####
#Database connection helper function
connect_database = (host, db_name) ->
	db = mongoose.createConnection(host, db_name)

	db.on 'error', (err) ->
		console.log db_name + " Database Error", err

	db.on 'open', (err) ->
		console.log "Opened Database " + db_name

	return db

userDB = connect_database 'localhost', 'proto_user_db'

## -------------------------- Schemas ---------------------- ##
activity_schema = new mongoose.Schema {
	uid:		String,
	date:		Date,
	activity:	String
}

event_schema = new mongoose.Schema {
	uid: 		String,
	sid: 		String,
	qid: 		String,
	room: 		String,
	answer: 	String,
	category: 	String,
	difficulty: String,
	guess: 		String,
	date: 		Number,
	seen: 		Number,
	tspent: 	Number,
	users:		Array,
	early: 		Boolean,
	ruling: 	Boolean,
	interrupt:	Boolean
}

## -------------------- User Database Models --------------------- ##
Activity = userDB.model 'Activity', activity_schema
Event = userDB.model 'Event', event_schema

## ------------------ User Database Collections ------------------ ##
events = Event.collection
events.ensureIndex { uid: 1 }

activities = Activity.collection
activities.ensureIndex { uid: 1 }

## ------------------- Database Helper Functions -------------------- ##
update_state = (state, isEmail, info) ->
	if isEmail
		User.update({"email":info}, {$set: {"state":state}}).exec()
	else
		User.update({"uid":info}, {$set: {"state":state}}).exec()

update_current_room = (room, email) ->
	User.update({"email":email}, {$set: {"curr_room":room}}).exec()

create_event = (data) ->
	aBuzz = new Event(data)

	aBuzz.save (err) ->
		console.log(err)

exports.Event = Event
exports.Activity = Activity
exports.update_state = update_state
exports.update_current_room = update_current_room
exports.create_event = create_event
