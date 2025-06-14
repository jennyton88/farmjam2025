extends Resource

class_name CharDialogue

enum ConvoType {
	NORMAL,
	CHOICE,
	CHOSEN,
	EXIT, # subtype
	NONE, # subtype
}

# NORMAL: Normal dialogue, nothing to check for
# CHOICE: Paired with EXIT (required) (should clean up/organize later),
# adds the choices to a dialogue
# CHOSEN: Jumped to a certain choice, now evaluate the data from save_choice
# EXIT: Allows adding choices so player can't click past the text
# w/o choosing one of the choices
# NONE: Just for filling in the subtype if it's not a choice line

# expected format

#0: { <-- id number or string for the group
	# "name": should the name be visible or not, name comes from char. info
	# "type": of dialogue this piece is
	# "subtype": for choices or not
	# NOT IMPLEMENTED YET(?) "skip": false, # allow for skipping choice options
	# "text": array of several lines, note one line only for a shop keeper if 
	# they are opening up their store, any # of lines before they do, and 
	# after closed shop
	# "choices": two max. for now, written choices / required for choices
	# "jump": which choice to jump to / required for choices
	# "next": next group of lines to go to
#},


#var siya_1 = {
	#"start": 0,
	#"reset_start": 0,
	#0: {
		#"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		#"text": [""],
		#"next": 0,
	#}
#};

# tutto
# siya
# grandma
# chek seller
# nowe seller


var tutto_1 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Howdy there! Welcome back on land!",
			"Your grandma has been expecting you.",
			"Go up to town to find her. Check your [M]ap if you need help.",
			"There is no way you can get lost here. Surely not.",
			
		],
		"next": 1,
	},
	1: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"You know what you're doing with those tools city cat?",
			"If you're talking to me, you know how to [E]nteract at least.",
			"Do the same with your tools, of course on your farm.",
			"I'm sure you remember your roots, so these skills should be natural for you."
		],
		"next": 2,
	},
	2: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["It's to my right."],
		"next": 0,
	},

	#1: {
		#"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		#"text": [ "Lucky you huh?", "Having to live next to THAT forest..." ],
		#"next": 2,
	#},
	#2: {
		#"name": true, "type": ConvoType.CHOICE, "subtype": ConvoType.NONE,
		#"text": ["That must be terrible right?",],
		#"choices": ["Yes it is...", "Nope!",],
		#"jump": [3,4], "next": 5,
	#},
	#3: {
		#"name": true, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		#"save_choice": { "positive": 0, },  # can add data here to save depending on choice
		#"text": [ "Too bad for you, living there.", "So sad" ],
		#"next": 5,
	#},
	#4: {
		#"name": true, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		#"save_choice": { "positive": 1 },
		#"text": [ "Good for you then." ],
		#"next": 5,
	#},
	#5: {
		#"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		#"text": [ "Bye!" ],
		#"next": 0,
	#}
};




var tutto_2 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["I'm always standing here. For no particular reason."],
		"next": 0,
	},
};

var tutto_3 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["I have nothing to say to you."],
		"next": 0,
	},
};

var tutto_4 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["Leave."],
		"next": 0,
	},
};

var tutto_5 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["I've made peace with myself... The end is nigh! The end is nigh!"],
		"next": 0,
	},
};

var tutto_6 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["Go away already. Can't you see I'm just waiting for the end here?"],
		"next": 0,
	},
};

var tutto_7 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["...You're still talking to me?", "The end is nigh!"],
		"next": 0,
	},
};


var grandma_1 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["It's about time you got here child. Did Siya take the long way around or what?"],
		"next": 1,
	},
	1: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"I didn't want to call you here, but everyone else in town is blissfully ignorant, and they don't want to bother with this task.",
			"Even your cousin is nonchalant about this.",
			"But it's old traditions and whatnot! It's been here for a reason, and we can't just abandon it.",
			"The altar in the forest is for the deities protecting this small town, as well as the whole island.",
			"I have been giving some offerings here and there, but it isn't enough.",
			"The forest has become increasingly more hostile and these old bones of mine can't make the trip so many times over.",
		],
		"next": 2,
	},
	2: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"You must offer the bounty of the ground, 3 different types of crops.",
			"Cat grass, wheat, and tomatoes.",
			"I calculated the offerings to be exactly 20 wheat, 30 cat grass, and 40 tomatoes.",
			"Nothing more, nothing less. And, ALL at the SAME time. You'll have 7 days to do it, including today.",
			"Use the old farm next to the docks alright?",
			"Good luck child, and may you save our town from certain destruction.",
		],
		"next": 0,
	},
};


var grandma_2 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["6 days left child. The rest of the days should be enough to grow those crops."],
		"next": 0,
	},
};

var grandma_3 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.CHOICE, "subtype": ConvoType.EXIT,
		"text": ["5 days left child. How have you been doing?."],
		"choices": ["Doing good.", "Not very good."],
		"jump": [1,2], "next": 0,
	},
	1: {
		"name": true, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		"save_choice": { "a": false },
		"text": ["That's good. After all, our fate rests in your paws.", "Keep on working!"],
		"next": 0,
	},
	2: {
		"name": true, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		"save_choice": { "a": false },
		"text": ["Did you remember to water those crops? We still have some time left so don't fret."],
		"next": 0,
	}
};

var grandma_4 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["4 days left child..."],
		"next": 0,
	},
}

var grandma_5 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["3 days left child..."],
		"next": 0,
	},
}

var grandma_6 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["2 days left child...", "Have you gathered everything you need yet?"],
		"next": 0,
	},
}

var grandma_7 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["1 day left, today...", "You must offer everything today, or we'll all perish here."],
		"next": 1,
	},
	1: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["Good luck, and may this not be the last time we meet."],
		"next": 0,
	},
}


var siya_1 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"I brought you over here in a hurry. I don't get what's happening, but grandma says it's urgent.",
			"Take these tools and seeds. Grandma told me to give them to you. Take care of my tools alright! No selling them off!",
			"I'll be here minding the ship...",
		],
		"next": 1,
	},
	1: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"What are you waiting for? Go ahead already!"
		],
		"next": 0,
	},
};

var siya_2 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"It's not bad being out at sea.", 
			"Despite this boa-- ahem, ship rocking around when the waves feel uppity, it's very relaxing just staring out into the ocean.",
		],
		"next": 1,
	},
	1: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"I hope you're taking care of my tools. You'll have to give them back to me later.", 
		],
		"next": 2,
	},
	2: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Making use of that map right? The only way I won't get lost is by staying on this ship here.",
			"I know it's a small place, but it's difficult to navigate alright?!",
		],
		"next": 0,
	},
};

var siya_3 = {
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Chilling at the docks couldn't be better...", 
			"But why is the fur on my neck standing up?",
			"Something feels a little ominous around here...",
		],
		"next": 0,
	},
};

var siya_4 = {
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["Hmm... I feel a little better today. Maybe it was nothing."],
		"next": 0,
	},
};

var siya_5 = {
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["It's nothing... it's nothing... Is it that forest? I was always creeped out by it."],
		"next": 0,
	},
};

var siya_6 = {
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["..."],
		"next": 0,
	},
};

var siya_7 = {
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["I feel a bit sick, is something bad going to happen today?"],
		"next": 0,
	},
};

var rocc_1 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["I'm standing still. Yes it's great!"],
		"next": 0,
	},
};

var mint_1 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["The forest is real scary... I think I heard something growling behind those trees!", "But I'm safe here... I think."],
		"next": 0,
	},
};

var rock_1 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": ["Today is nice, but the forest feels unrestful... What will night bring us?"],
		"next": 0,
	},
};

var rocsiu_1 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Did you know? Watering your crops speeds up their growth!",
			"You have to water them every few minutes though.",
			"Or just have a little patience!",
		],
		"next": 0,
	},
};

var rocsiu_2 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Did you know? Tomato crops grow continuously over time!",
			"It's a good crop to sell.",
			"Mmm... pizzzza...",
		],
		"next": 0,
	},
};

var rocsiu_3 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Did you know? There a monster in the forest.",
			"Surely you know by now!",
		],
		"next": 0,
	},
};

var rocsiu_4 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Did you know? The lantern is really nice! It's the latest edition in the Light2000 series!"
		],
		"next": 0,
	},
};

var rocsiu_5 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Did you know? The world is ending soon!",
		],
		"next": 0,
	},
};

var rocsiu_6 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Did you know? My nose is itchy. Aachooo!!!!"
		],
		"next": 0,
	},
};

var rocsiu_7 = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.NORMAL, "subtype": ConvoType.NONE,
		"text": [
			"Did you know? Today is the last day to offer your crops up to the deities above~"
		],
		"next": 0,
	},
};


var seller_talk = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": true, "type": ConvoType.CHOICE, "subtype": ConvoType.EXIT,
		"text": [ "Want to buy something?" ],
		"choices": ["Yes", "No"],
		"jump": [3,4], "next": 5,
	},
	3: {
		"name": false, "type": ConvoType.CHOSEN, "subtype": ConvoType.EXIT,
		"save_choice": { "buy": true, },
		"text": [
			"Here are my wares. Put stuff you want to sell on my side, and put stuff you want to buy on your side.",
		],
		"choices": ["Trade!", "I'm good."],
		"jump": [5, 4], "next": 0,
	},
	4: {
		"name": true, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		"save_choice": { "buy": false, "complete_trade": false },
		"text": [ "Have a good day!" ],
		"next": 0,
	},
	5: {
		"name": true, "type": ConvoType.CHOSEN, "subtype": ConvoType.EXIT,
		"save_choice": { "test_trade": true, },
		"text": [ "Is this good?" ],
		"choices": ["Yes", "No"],
		"jump": [6, 3], "next": 0,
	},
	6: {
		"name": true, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		"save_choice": { "complete_trade": true, },
		"text": [ "Good trade. Have a good day!", ],
		"next": 0,
	},
};


var altar_talk = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": false, "type": ConvoType.CHOICE, "subtype": ConvoType.EXIT,
		"text": [ "Sacrifice to the altar?" ],
		"choices": ["Yes.", "Not yet."],
		"jump": [1,2], "next": 2,
	},
	1: {
		"name": false, "type": ConvoType.CHOSEN, "subtype": ConvoType.EXIT,
		"save_choice": { "sacrifice": true, },
		"text": ["..."],
		"choices": ["I'm done."],
		"jump": [2], "next": 0,
	},
	2: {
		"name": false, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		"save_choice": { "sacrifice": false, },
		"text": [ "You leave." ],
		"next": 0,
	},
};


var bed_talk = {
	"start": 0,
	"reset_start": 0,
	0: {
		"name": false, "type": ConvoType.CHOICE, "subtype": ConvoType.EXIT,
		"text": [ "Go to sleep?" ],
		"choices": ["Yes.", "Not yet."],
		"jump": [1,2], "next": 2,
	},
	1: {
		"name": false, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		"save_choice": { "skip_time": true, },
		"text": ["Sleeping time!"],
		"next": 0,
	},
	2: {
		"name": false, "type": ConvoType.CHOSEN, "subtype": ConvoType.NONE,
		"save_choice": { "skip_time": false, },
		"text": [ "Gotta keep working." ],
		"next": 0,
	},

};
