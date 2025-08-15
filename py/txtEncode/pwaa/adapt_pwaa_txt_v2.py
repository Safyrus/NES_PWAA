import argparse
import re
from tqdm import tqdm
from adapt_pwaa_txt_const import *


# constants
MAX_REGEX_LOOP = 20

# args
parser = argparse.ArgumentParser()
parser.add_argument("input", type=str)
parser.add_argument("output", type=str)
parser.add_argument("-t", "--remove_incorrect_tag", dest="remove_tag", type=int, default=True)
args = parser.parse_args()
infile = args.input
outfile = args.output
remove_incorrect_tag = args.remove_tag

# read text file
print(f"reading file...")
with open(infile, "r") as f:
    text = f.read()

print(f"regex filtering...")
# removing
text = re.sub(r"\n", "", text)
# pre replace
text = re.sub(r"<bganim:98,357>", "<choice_anim>", text)  # choice anim
text = re.sub(r"<5D:([^>]*)>", r"<center_text:\1>", text)  # 5D = center_text
text = re.sub(r"<6B:([^>]*)>", r"<choice_thing_maybe:\1>", text)  # something with choice and gavel but can't find use
text = re.sub(r"<26:([^>]*)>", r"<unknow_bool:\1>", text)  # unknown boolean, can't find use
text = re.sub(r"<nextpage_nobutton>", "<fp>", text)
text = re.sub(r"<nextpage_button>", "<p>", text)
text = re.sub(r"<bg:([^>]*)>", r"<background:\1>", text)
text = re.sub(r"<10:([^>]*)>", r"<something_with_choice_or_jump_maybe:\1>", text)
text = re.sub(r"<1D:([^>]*)>", r"<scrolling_unknow_arg:\1>", text)
text = re.sub(r"<23:([^>]*)>", r"<music:MUS_NONE,\1>", text)
text = re.sub(r"<29:1>", r"<testimony_start>", text)
text = re.sub(r"<29:2>", r"<return_to_testimony>", text)
text = re.sub(r"<29:([^>]*)>", r"<something_with_testimony:\1>", text)
text = re.sub(r"<30:1>", r"<bip:BIP_NONE>", text)
text = re.sub(r"<30:2>", r"<bip:BIP_TYPEWRITER>", text)
text = re.sub(r"<33:([^>]*)>", r"<unknow_tag_2_args_appear_alot_end_of_block:\1>", text)
text = re.sub(r"<35:([^>]*)>", r"<unknow_tag_2_big_args:\1>", text)
text = re.sub(r"<36>", r"<unknow_tag_at_end_of_block>", text)
text = re.sub(r"<37:([^>]*)>", r"<something_with_unlocking_choice_maybe:\1>", text)
text = re.sub(r"<56:([^>]*)>", r"<unknow_tag_appear_2_times_total_2_args:\1>", text)
text = re.sub(r"<64:([^>]*)>", r"<unknow_tag_appear_only_once_1_arg_related_to_grossbarg:\1>", text)
text = re.sub(r"<45>", r"<unknow_tag_related_to_menu>", text)
text = re.sub(r"<4D:30,(.)>", r"<hide_bottom_sprite:\1>", text)
text = re.sub(r"<74>", r"<unknow_tag_start_of_scene>", text)
text = re.sub(r"<music:(\w+),0>", r"<music:\1>", text)
text = re.sub(r"<music:(\w+),(\w+)>", r"<wait:\2><music:\1>", text)
text = re.sub(r"<background:4095>", "<background_none>", text)
# text = re.sub(r"<animation:[0-9]+,[0-9]+>", "<character:CHR_NONE><animation:ANI_NONE><background:BKG_OBJECTION><shake><wait:60><character:CHR_NONE><animation:ANI_NONE>", text) # need to manually replace the character after
# text = re.sub(r"<removephoto>", r"<photo:0>", text)
text = re.sub(r"<showphoto:([^>]*)>", r"<photo:\1>", text)

text = re.sub(r"<sound:(\w+),1>", r"<sound:\1>", text)
text = re.sub(r"<sound:(\w+),0>", r"<sound:\1><sound_stop_maybe>", text)

text = re.sub(r"<bgcolor:769,8,31>", r"<flash:FLASH_DEFAULT_FORCE,FLASH_DEFAULT_TIME>", text)

text = re.sub(r"<animation:3,1>", r"<background:BKG_EXCLAMATION_OBJ>", text)

# fades in/out
text = re.sub(r"<bgcolor:513,1,31>", r"<fade_out_1>", text)  # fade out
text = re.sub(r"<bgcolor:514,1,31>", r"<fade_out_2>", text)  # fade out
text = re.sub(r"<bgcolor:516,1,31>", r"<fade_out_4>", text)  # fade out
text = re.sub(r"<bgcolor:257,1,31>", r"<fade_in_1>", text)  # fade in
text = re.sub(r"<bgcolor:258,1,31>", r"<fade_in_2>", text)  # fade in
text = re.sub(r"<bgcolor:260,1,31>", r"<fade_in_4>", text, )  # fade in
text = re.sub(r"<fade_out_1><wait:([^>]*)>", r"<fade_o1:4,\1><wait:\1>", text)
text = re.sub(r"<fade_out_2><wait:([^>]*)>", r"<fade_o2:4,\1><wait:\1><wait:\1><wait:\1>", text)
text = re.sub(r"<fade_out_4><wait:([^>]*)>", r"<fade_o4:4,\1><wait:\1><wait:\1><wait:\1><wait:\1>", text)
text = re.sub(r"<fade_in_1><wait:([^>]*)>", r"<fade_i1:0,\1><wait:\1>", text)
text = re.sub(r"<fade_in_2><wait:([^>]*)>", r"<fade_i2:0,\1><wait:\1><wait:\1><wait:\1>", text)
text = re.sub(r"<fade_in_4><wait:([^>]*)>", r"<fade_i4:0,\1><wait:\1><wait:\1><wait:\1><wait:\1>", text)

# text color
text = re.sub(r"<color:0>", r"<color:COL_WHITE>", text)
text = re.sub(r"<color:1>", r"<color:COL_RED>", text)
text = re.sub(r"<color:2>", r"<color:COL_BLUE>", text)
text = re.sub(r"<color:3>", r"<color:COL_GREEN>", text)

text = re.sub(r"<shake:([0-9]+),([0-9]+)>", r"<shake:\2,\1>", text)
# text = re.sub(r"<fadetoblack:[^>]*>", r"<fade_out>", text) # fade out
text = re.sub(r"<special_jmp>", r"<return>", text)
# text = re.sub(r"<fademusic:[^>]*>", r"<music:MUS_NONE>", text) # same
# text = re.sub(r"<hideperson>", "<character:CHR_NONE><animation:ANI_NONE>", text)
text = re.sub(r"<bganim:98,273>", "<gavel_1>", text)  # gavel slam anim
text = re.sub(r"<bganim:98,579>", "<was_not_gavel_tag_idk>", text)  # don't know
# text = re.sub(r"<lifebar:[^>]*>", "<event:EVT_HP>", text) # toggle life-bar display
# text = re.sub(r"<newevidence:([^>]*)>", r"<event:EVT_CR_SET,\1>", text) # new evidence (4), evidence idx (14bit=character(1) or evidence(0))
# text = re.sub(r"<littlesprite:[^>]*>", "<event:EVT_LILSPR,0>", text) # littlesprite/point_on_map (5), which point where
# text = re.sub(r"<testimony_animation:1>", "<event:EVT_TESTIMONY_ON>", text) # testimony scrolling animation (6) + testimony top text
# text = re.sub(r"<testimony_animation:0>", "<event:EVT_TESTIMONY_OFF>", text) # remove testimony top text (7)
# text = re.sub(r"<testimony_box:[^>]*>", "<event:EVT_CR_OBJ>", text) # cross-examination top text (8)
text = re.sub(r"<2B>", "<lifehit_effect>", text)  # lifehit_effect

# character fade/in/out
text = re.sub(r"<personvanish:4,1>", r"<!--person_fade:out,spd_normal-->", text)
text = re.sub(r"<personvanish:4,2>", r"<!--person_fade:out,spd_slow-->", text)
text = re.sub(r"<personvanish:4,4>", r"<!--person_fade:out,spd_veryslow-->", text)
text = re.sub(r"<personvanish:3,1>", r"<!--person_fade:in,spd_normal-->", text)
text = re.sub(r"<personvanish:3,2>", r"<!--person_fade:in,spd_slow-->", text)
text = re.sub(r"<personvanish:3,4>", r"<!--person_fade:in,spd_veryslow-->", text)

# courtroom swoosh effect
text = re.sub(r"<swoosh:0,1,([^>]*>)", r"<swoosh:left_middle,left_dir,\1", text)
text = re.sub(r"<swoosh:0,4096,([^>]*>)", r"<swoosh:left_middle,right_dir,\1", text)
text = re.sub(r"<swoosh:1,1,([^>]*>)", r"<swoosh:left_right,left_dir,\1", text)
text = re.sub(r"<swoosh:1,4096,([^>]*>)", r"<swoosh:left_right,right_dir,\1", text)
text = re.sub(r"<swoosh:2,1,([^>]*>)", r"<swoosh:middle_right,left_dir,\1", text)
text = re.sub(r"<swoosh:2,4096,([^>]*>)", r"<swoosh:middle_right,right_dir,\1", text)


# surely useless tag
text = re.sub(r"<endjmp>", "", text)
text = re.sub(r"<unknow_bool:0>", "", text)
text = re.sub(r"<unknow_bool:1>", "", text)

# moving
for _ in range(MAX_REGEX_LOOP):
    text = re.sub(r"(<name:[^>]*>)(<[^>]*>)", r"\2\1", text)
    text = re.sub(r"<b>(<[^>]*>)", r"\1<b>", text)
for _ in range(MAX_REGEX_LOOP):
    text = re.sub(r"<person:[^>]*><person:([^>]*)>", r"<person:\1>", text)
# post replace
# text = re.sub(r"<person:(\w+),(\w+),(\w+)>([\s\S]*?)(<p>|<fp>)", r"<character:\1><animation:\2>\4\5<animation:\3>", text)

# parsing file
i = 0
new_text = ""
char = "-1"
bip = "-1"
talk_anim = "-1"
stand_anim = "-1"
last_char = ""
last_talk_anim = ""
last_stand_anim = ""
last_bip = ""
last_name = ""
chapter_count = 0
box_toggle = True
fade_out = False
dialog_start = True
bar = tqdm(total=len(text), desc="raw filtering...", dynamic_ncols=True)
while i < len(text):
    old_i = i
    c = text[i]
    if c == "[":
        # get label
        label_end = text.find("]", i)
        label = text[i + 1 : label_end]
        #
        char = "-1"
        talk_anim = "-1"
        stand_anim = "-1"
        bip = "-1"
        dialog_start = True
        last_name = ""
        # transform label
        if label == "0":
            chapter_count += 1
            box_toggle = True
            fade_out = False
            comment = CHAPTER_START.replace("???", str(chapter_count))
            label = comment + "<label:label_" + str(chapter_count) + "_" + label + ">\n"
        else:
            comment = SCENE_START.replace("???", label)
            label = comment + "<label:label_" + str(chapter_count) + "_" + label + ">\n"
        # set new label
        i = label_end + 1
        new_text += label
    elif c == "<":
        # get tag
        tag_end = text.find(">", i)
        tag = text[i + 1 : tag_end]
        # find tag name and args
        if ":" in tag:
            name, args = tag.split(":")
            args = args.split(",")
        else:
            name, args = tag, []

        if name == "person":
            last_char = char
            last_talk_anim = talk_anim
            last_stand_anim = stand_anim
            char = args[0]
            talk_anim = args[1]
            stand_anim = args[2]
            # if last_char != char:
                # tag = "character:" + char
            if last_talk_anim != talk_anim or stand_anim != last_stand_anim:
                # if last_char != char:
                #     tag += "><animation:" + talk_anim
                # else:
                tag = "character:" + talk_anim
            else:
                tag = ""
        elif name == "fade_i1":
            tag = f"fade:0,{args[1]}"
        elif name == "fade_i2":
            tag = f"fade:0,{int(args[1])*3}"
        elif name == "fade_i4":
            tag = f"fade:0,{int(args[1])*4}"
        elif name == "fade_o1":
            tag = f"fade:4,{args[1]}"
        elif name == "fade_o2":
            tag = f"fade:4,{int(args[1])*3}"
        elif name == "fade_o4":
            tag = f"fade:4,{int(args[1])*4}"
        elif name == "p":
            if talk_anim != stand_anim:
                tag = "character:" + stand_anim + "><p><character:" + talk_anim
            dialog_start = True
        elif name == "speed":
            n = int(args[0])
            args[0] = 0
            if n != 0:
                args[0] = str(int(32 * 2 / n))
            tag = f"speed:{args[0]}"
        elif name == "finger_choice_2args_jmp":
            args[0] = str(int(args[0]) - 128)
            args[1] = str(int(args[1]) - 128)
            ani = f"character:{stand_anim}><" if int(stand_anim) >= 0 else ""
            tag = f"{ani}p><act><jump:label_{chapter_count}_{args[0]},0,1>TODO1<b><jump:label_{chapter_count}_{args[1]},0,0>TODO2<b"
        elif name == "finger_choice_3args_jmp":
            args[0] = str(int(args[0]) - 128)
            args[1] = str(int(args[1]) - 128)
            args[2] = str(int(args[2]) - 128)
            ani = f"character:{stand_anim}><" if int(stand_anim) >= 0 else ""
            tag = f"{ani}p><act><jump:label_{chapter_count}_{args[0]},0,1>TODO1<b><jump:label_{chapter_count}_{args[1]},0,1>TODO2<b><jump:label_{chapter_count}_{args[2]},0,0>TODO3<b"
        elif name == "jmp" or name == "rejmp":
            args[0] = str(int(args[0]) - 128)
            tag = f"fp><jump:label_{chapter_count}_{args[0]}"
        elif name == "name":
            if args[0] == "0": # NAME_NONE
                args[0] = last_name
            last_name = args[0]
            name_const_key = [x[0] for x in NAME_CONST]
            if args[0] in name_const_key:
                n = name_const_key.index(args[0])
                last_bip = bip
                bip = NAME_CONST[n][3]
                if bip and bip != last_bip:
                    tag = f"name:{args[0]}><bip:{bip}"
                else:
                    tag = f"name:{args[0]}"
            else:
                tag = f"name:{args[0]}"
        elif name == "bip":
            last_music = bip
            bip = args[0]
            if bip == last_bip:
                tag = ""
            elif bip == "BIP_NONE":
                if last_bip == "-1":
                    tag == f"bip:0><bip:0"
                else:
                    tag == f"bip:{last_bip}"
                last_bip = "-1"
        elif name == "photo":
            if int(args[0]) >= 256:
                tag = f"photo_on_right><photo:{int(args[0])-256}"
        elif name == "swoosh":
            args[2] = next((x[1] for x in CHR_CONST if x[0] == args[2]), args[2])
            args[3] = next((x[1] for x in ANI_CONST if x[0] == args[3]), args[3])
            tag = f"!--{name}:{','.join(args)}--" # comment for now
        # set new tag
        i = tag_end + 1
        if tag != "":
            new_text += "<" + tag + ">"
    else:
        i1 = text.find("<", i)
        i2 = text.find("[", i)
        if i2 < i1:
            i1 = i2
        if i1 < 0:
            i1 = i + 1
        if dialog_start:
            # if "\n" not in text[i:i1]:
            #     new_text += "\n"
            dialog_start = False
        new_text += text[i:i1]
        i = i1
    bar.update(i - old_i)
text = new_text
bar.close()

# post replace
print(f"post regex filtering...")
for k, v in SPECIAL_CHAR.items():
    text = re.sub(r"\{" + str(k) + r"\}", v, text)
text = re.sub(r"<noop>", "", text)
text = re.sub(r"<b>[\n]*<b>", "<b>", text)
text = re.sub(r"<p>[\n]*<p>", "<p>", text)
text = re.sub(r"<speed:255>", r"<speed:SPD_DEFAULT>", text)
text = re.sub(r"<speed:0>", r"<speed:SPD_NORMAL>", text)

# create a correct tag list
correct_tag = "<!--[^>]*-->|"
for tag in KNOWN_TAG_LIST:
    correct_tag += "<" + tag + ":[^>]*>|" + "<" + tag + ">|"
correct_tag = correct_tag[:-1]
# print all invalid tag
print("search invalid tag...")
invalid_tag_list = {}
for m in re.finditer(rf"({correct_tag})|(<[^>]*>)", text):
    m = m.group(2)
    if m and "<!--" not in m:
        m = m.split(":")[0].split(">")[0][1:]
        if m:
            if m not in invalid_tag_list:
                invalid_tag_list[m] = 0
            invalid_tag_list[m] += 1
invalid_tag_list = dict(sorted(invalid_tag_list.items(), key=lambda item: item[1], reverse=True))

print(f"invalid tag found: ({sum(invalid_tag_list.values())})")
print(invalid_tag_list)
# remove all tag not in KNOWN_TAG_LIST
if remove_incorrect_tag:
    print(f"remove all invalid tags...")
    text = re.sub(rf"({correct_tag})|<[^>]*>", r"\1", text)

# formatting
print(f"formatting...")
text = re.sub(r"<b>", "<b>\n", text)
text = re.sub(r"(<p>|<fp>)", r"\1\n\n", text)
text = re.sub(r"(<name:[^>]*>)", r"\n\n\1\n", text)
text = re.sub(r"(<name:[^>]*>)\n(<bip:[^>]*>)", r"\1\2\n", text)
text = re.sub(r"\n{3,}", "\n\n", text)

# replace value by constants
print(f"replace vals by constants...")
for c in NAME_CONST:
    text = re.sub(rf"<name:{c[0]}>", f"<name:{c[1]}>", text)
for c in BKG_CONST:
    text = re.sub(rf"<background:{c[0]}>", f"<background:{c[1]}>", text)
# for c in CHR_CONST:
#     text = re.sub(rf"<character:{c[0]}>", f"<character:{c[1]}>", text)
for c in MUS_CONST:
    text = re.sub(rf"<music:{c[0]}>", f"<music:{c[1]}>", text)
for c in SFX_CONST:
    text = re.sub(rf"<sound:{c[0]}>", f"<sound:{c[1]}>", text)
for c in ANI_CONST:
    text = re.sub(rf"<character:{c[0]}>", f"<character:{c[1]}>", text)
for c in PHT_CONST:
    text = re.sub(rf"<photo:{c[0]}>", f"<photo:{c[1]}>", text)

# outputting results
print(f"writing file...")
with open(outfile, "w") as f:
    f.write(text)

print(f"done.")
