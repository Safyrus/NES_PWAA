table_evidence_top_lo:
.byte <evidence_0_top
.byte <evidence_1_top
.byte <evidence_2_top
.byte <evidence_3_top
.byte <evidence_4_top
.byte <profile_0_top
.byte <profile_1_top
.byte <profile_2_top
.byte <profile_3_top
.byte <profile_4_top

table_evidence_top_hi:
.byte >evidence_0_top
.byte >evidence_1_top
.byte >evidence_2_top
.byte >evidence_3_top
.byte >evidence_4_top
.byte >profile_0_top
.byte >profile_1_top
.byte >profile_2_top
.byte >profile_3_top
.byte >profile_4_top

table_evidence_bot_lo:
.byte <evidence_0_bot
.byte <evidence_1_bot
.byte <evidence_2_bot
.byte <evidence_3_bot
.byte <evidence_4_bot
.byte <profile_0_bot
.byte <profile_1_bot
.byte <profile_2_bot
.byte <profile_3_bot
.byte <profile_4_bot

table_evidence_bot_hi:
.byte >evidence_0_bot
.byte >evidence_1_bot
.byte >evidence_2_bot
.byte >evidence_3_bot
.byte >evidence_4_bot
.byte >profile_0_bot
.byte >profile_1_bot
.byte >profile_2_bot
.byte >profile_3_bot
.byte >profile_4_bot


table_cr2photo:
.byte 0
.byte 1
.byte 6
.byte 7
.byte 2
.byte 42
.byte 43
.byte 44
.byte 45
.byte 46


evidence_0_top:
.byte "Attorney's Badge", 1, 1
.byte "Type: Other", 1
.byte "Obtained: One of my", 1
.byte "possessions.", 2
evidence_0_bot:
.byte "No one would believe I was", 1
.byte "a defense attorney if I", 1
.byte "didn't carry this.", 2

evidence_1_top:
.byte "Cindy's Autopsy Report", 1, 1
.byte "Type: Reports", 1
.byte "Obtained: Received", 1
.byte "from Mia Fey.", 2
evidence_1_bot:
.byte "Time of death: 7/31, 4PM-5PM.", 1
.byte "Cause of death: loss of blood", 1
.byte "due to blunt trauma.", 2

evidence_2_top:
.byte "Statue/The Thinker", 1, 1
.byte "Type: Weapons", 1
.byte "Obtained: Submitted", 1
.byte "as evidence", 1
.byte "by Prosecutor Payne.", 2
evidence_2_bot:
.byte "A statue in the shape of", 1
.byte $22, "The Thinker", $22,".", 1
.byte "It's rather heavy.", 2

evidence_3_top:
.byte "Passport", 1, 1
.byte "Type: Evidence", 1
.byte "Obtained: Submitted", 1
.byte "as evidence by", 1
.byte "Prosecutor Payne.", 2
evidence_3_bot:
.byte "The victim apparently arrived", 1
.byte "home from Paris on 7/30,", 1
.byte "the day before the murder.", 2

evidence_4_top:
.byte "Blackout Record", 1, 1
.byte "Type: Documents", 1
.byte "Obtained: Submitted", 1
.byte "as evidence by", 1
.byte "Prosecutor Payne.", 2
evidence_4_bot:
.byte "Electricity to Ms. Stone's", 1
.byte "building was out from noon to", 1
.byte "6 PM on the day of the crime.", 2

profile_0_top:
.byte "Mia Fey", 1, 1
.byte "Age: 27", 1
.byte "Gender: Female", 2
profile_0_bot:
.byte "Chief Attorney at Fey & Co..", 1
.byte "My boss, and a very good", 1
.byte "defense attorney.", 2

profile_1_top:
.byte "Larry Butz", 1, 1
.byte "Age: 23", 1
.byte "Gender: Male", 2
profile_1_bot:
.byte "The defendant in this case.", 1
.byte "A likeable guy who was my", 1
.byte "friend in grade school.", 2

profile_2_top:
.byte "Cindy Stone", 1, 1
.byte "Age: 22", 1
.byte "Gender: Female", 2
profile_2_bot:
.byte "The victim in this case.", 1
.byte "A model, she lived in an", 1
.byte "apartment by herself.", 2

profile_3_top:
.byte "Winston Payne", 1, 1
.byte "Age: 52", 1
.byte "Gender: Male", 2
profile_3_bot:
.byte "The prosecutor for this case.", 1
.byte "Lacks presence. Generally bad", 1
.byte "at getting his points across.", 2

profile_4_top:
.byte "Frank Sahwit", 1, 1
.byte "Age: 44*", 1
.byte "Gender: Male", 2
profile_4_bot:
.byte "Discovered Ms. Stone's body.", 1
.byte "Newspaper salesman who saw", 1
.byte "Larry flee the scene.", 2
