import argparse
import sys
import re
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
text = re.sub(r"<endjmp>", "", text)
text = re.sub(r"<soundtoggle:[^>]*>", "<bip:BIP_NONE>", text)
text = re.sub(r"<fullscreen_text>", "", text)
text = re.sub(r"<bganim:98,357>", "", text) # choice anim
text = re.sub(r"<5D:([^>]*)>", "", text) # 5D = center_text
text = re.sub(r"<6B:([^>]*)>", "", text) # something with choice and gavel but can't find use
text = re.sub(r"<26:([^>]*)>", "", text) # unknown boolean, can't find use
# removing args
text = re.sub(r"<shake:[^>]*>", "<shake>", text)
# text = re.sub(r"<hidetextbox:.>", "<hidetextbox>", text)
# pre replace
text = re.sub(r"<speed:255>", "<speed:2>", text)
text = re.sub(r"<nextpage_nobutton>", "<fp>", text)
text = re.sub(r"<nextpage_button>", "<p>", text)
text = re.sub(r"<bg:([^>]*)>", r"<background:\1>", text)
text = re.sub(r"<10:([^>]*)>", r"<something_with_choice_or_jump_maybe:\1>", text)
text = re.sub(r"<1D:([^>]*)>", r"<something_with_scrolling:\1>", text)
text = re.sub(r"<23:[^>]*>", "<music:MUS_NONE>", text)
text = re.sub(r"<29:([^>]*)>", r"<something_with_testimony:\1>", text)
text = re.sub(r"<30:1>", r"<bip:BIP_NONE>", text)
text = re.sub(r"<30:2>", r"<bip:BIP_TYPEWRITER>", text)
text = re.sub(r"<33:([^>]*)>", r"<unknow_tag_2_args_appear_alot_end_of_block>", text)
text = re.sub(r"<35:([^>]*)>", r"<unknow_tag_2_big_args>", text)
text = re.sub(r"<36>", r"<unknow_tag_at_end_of_block>", text)
text = re.sub(r"<37:([^>]*)>", r"<something_with_unlocking_choice_maybe:\1>", text)
text = re.sub(r"<56:([^>]*)>", r"<unknow_tag_appear_2_times_total_2_args:\1>", text)
text = re.sub(r"<64:([^>]*)>", r"<unknow_tag_appear_only_once_1_arg_related_to_grossbarg:\1>", text)
text = re.sub(r"<45>", r"<unknow_tag_related_to_menu>", text)
text = re.sub(r"<4D:30,(.)>", r"<hide_bottom_sprite:\1>", text)
text = re.sub(r"<74>", r"<unknow_tag_start_of_scene>", text)
text = re.sub(r"<music:(\w+),0>", r"<music:\1>", text)
text = re.sub(r"<music:(\w+),(\w+)>", r"<wait:\2><music:\1>", text)
text = re.sub(r"<background:4095>", "<background:BKG_NONE>", text)
text = re.sub(r"<animation:[0-9]+,[0-9]+>", "", text)
# text = re.sub(r"<animation:[0-9]+,[0-9]+>", "<character:CHR_NONE><animation:ANI_NONE><background:BKG_OBJECTION><shake><wait:60><character:CHR_NONE><animation:ANI_NONE>", text) # need to manually replace the character after
text = re.sub(r"<removephoto>", r"<photo:0>", text)
text = re.sub(r"<showphoto:([^>]*)>", r"<photo:\1>", text)
text = re.sub(r"<sound:(\w+),\w+>", r"<sound:\1>", text)
text = re.sub(r"<bgcolor:769,8,31>", r"<flash>", text)
text = re.sub(r"<bgcolor:513,1,31>", r"<fade_out>", text) # fade out
text = re.sub(r"<bgcolor:514,1,31>", r"<fade_out>", text) # fade out
text = re.sub(r"<bgcolor:516,1,31>", r"<fade_out>", text) # fade out
text = re.sub(r"<bgcolor:260,1,31>", r"<fade_in>", text) # fade in
text = re.sub(r"<bgcolor:257,1,31>", r"<fade_in>", text) # fade in
text = re.sub(r"<bgcolor:258,1,31>", r"<fade_in>", text) # fade in
text = re.sub(r"<bgcolor:257,8,31>", r"<fade_in>", text) # really quick fade in
text = re.sub(r"<fadetoblack:[^>]*>", r"<fade_out>", text) # fade out
text = re.sub(r"<special_jmp>", r"<p>", text) # incorrect but will do for now
text = re.sub(r"<fademusic:[^>]*>", r"<music:MUS_NONE>", text) # same
text = re.sub(r"<personvanish:[^>]*>", "<character:CHR_NONE><animation:ANI_NONE>", text) # same
text = re.sub(r"<hideperson>", "<character:CHR_NONE><animation:ANI_NONE>", text)
text = re.sub(r"<swoosh:[^>]*>", "<event:EVT_SWOOSH>", text) # swoosh (0), (screen pos)
text = re.sub(r"<bganim:98,273>", "<event:EVT_GAVEL>", text) # gavel slam anim
text = re.sub(r"<bganim:98,579>", "<event:EVT_GAVEL_2>", text) # another gavel slam anim
text = re.sub(r"<lifebar:[^>]*>", "<event:EVT_HP>", text) # toggle life-bar display
text = re.sub(r"<newevidence:([^>]*)>", r"<event:EVT_CR_SET,\1>", text) # new evidence (4), evidence idx (14bit=character(1) or evidence(0))
text = re.sub(r"<littlesprite:[^>]*>", "<event:EVT_LILSPR,0>", text) # littlesprite/point_on_map (5), which point where
text = re.sub(r"<testimony_animation:1>", "<event:EVT_TESTIMONY_ON>", text) # testimony scrolling animation (6) + testimony top text
text = re.sub(r"<testimony_animation:0>", "<event:EVT_TESTIMONY_OFF>", text) # remove testimony top text (7)
text = re.sub(r"<testimony_box:[^>]*>", "<event:EVT_CR_OBJ>", text) # cross-examination top text (8)
text = re.sub(r"<2B>", "<event:9>", text) # lifehit_effect
# moving
for _ in range(MAX_REGEX_LOOP):
    text = re.sub(r"(<name:[^>]*>)(<[^>]*>)", r"\2\1", text)
    text = re.sub(r"<b>(<[^>]*>)", r"\1<b>", text)
for _ in range(MAX_REGEX_LOOP):
    text = re.sub(r"<person:[^>]*><person:([^>]*)>", r"<person:\1>", text)
# post replace
# text = re.sub(r"<person:(\w+),(\w+),(\w+)>([\s\S]*?)(<p>|<fp>)", r"<character:\1><animation:\2>\4\5<animation:\3>", text)

# parsing file
print(f"raw filtering...")
i = 0
new_text = ""
char = "-1"
talk_anim = "-1"
stand_anim = "-1"
last_char = ""
last_talk_anim = ""
last_stand_anim = ""
last_music = ""
chapter_count = 0
box_toggle = True
fade_out = False
print()
while i < len(text):
    if i % 1000 == 0:
        print("\033[A\033[2K", i/len(text)*100, "%")
    c = text[i]
    if c == "[":
        # get label
        label_end = text.find("]", i)
        label = text[i+1:label_end]
        #
        char = "-1"
        talk_anim = "-1"
        stand_anim = "-1"
        # transform label
        if label == "0":
            chapter_count += 1
            box_toggle = True
            fade_out = False
            comment = CHAPTER_START.replace("???", str(chapter_count))
            label = comment + "<label:label_" + str(chapter_count) + "_" + label + "><fp>\n"
        else:
            comment = SCENE_START.replace("???", label)
            label = comment + "<label:label_" + str(chapter_count) + "_" + label + "><fp>\n"
        # set new label
        i = label_end+1
        new_text += label
    elif c == "<":
        # get tag
        tag_end = text.find(">", i)
        tag = text[i+1:tag_end]
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
            if last_char != char:
                tag = "character:" + char
            if last_talk_anim != talk_anim or stand_anim != last_stand_anim:
                if last_char != char:
                    tag += "><animation:" + talk_anim
                else:
                    tag = "animation:" + talk_anim
            else:
                tag = "noop"
        elif name == "p":
            if talk_anim != stand_anim:
                tag = "animation:" + stand_anim + "><p><animation:" + talk_anim
            else:
                tag = "p"
        elif name == "music":
            if args[0] == "255":
                tag = "music:" + last_music
            else:
                if args[0] != "MUS_NONE":
                    last_music = args[0]
        elif name == "hidetextbox":
            if not (box_toggle ^ bool(int(args[0]))):
                tag = "hidetextbox"
                if not box_toggle:
                    tag += "><fp"
                box_toggle = not box_toggle
            else:
                tag = ""
        elif name == "photo":
            # bit 8 for box position (0=left, 1=right)
            tag = "photo:" + str(int(args[0]) & 0xFF)
        elif name == "finger_choice_2args_jmp":
            args[0] = str(int(args[0]) - 128)
            args[1] = str(int(args[1]) - 128)
            ani = f"animation:{stand_anim}><" if int(stand_anim) >= 0 else ""
            tag = f"{ani}p><act><jump:label_{chapter_count}_{args[0]},0,1>TODO1<b><jump:label_{chapter_count}_{args[1]},0,0>TODO2<b"
        elif name == "finger_choice_3args_jmp":
            args[0] = str(int(args[0]) - 128)
            args[1] = str(int(args[1]) - 128)
            args[2] = str(int(args[2]) - 128)
            ani = f"animation:{stand_anim}><" if int(stand_anim) >= 0 else ""
            tag = f"{ani}p><act><jump:label_{chapter_count}_{args[0]},0,1>TODO1<b><jump:label_{chapter_count}_{args[1]},0,1>TODO2<b><jump:label_{chapter_count}_{args[2]},0,0>TODO3<b"
        elif name == "jmp" or name == "rejmp":
            args[0] = str(int(args[0]) - 128)
            tag = f"fp><jump:label_{chapter_count}_{args[0]}"
        elif name == "fade_out":
            tag = "" if fade_out else "fade"
            fade_out = True
        elif name == "fade_in":
            tag = "" if not fade_out else "fade"
            fade_out = False
        #set new tag
        i = tag_end+1
        if tag != "": new_text += "<" + tag + ">"
    else:
        i += 1
        new_text += c
text = new_text

# post replace
print(f"post regex filtering...")
for k,v in SPECIAL_CHAR.items():
    text = re.sub(r"\{"+str(k)+r"\}", v, text)
text = re.sub(r"<noop>", "", text)
text = re.sub(r"<b>[\n]*<b>", "<b>", text)
text = re.sub(r"<p>[\n]*<p>", "<p>", text)

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
text = re.sub(r"\n{3,}", "\n\n", text)

# replace value by constants
print(f"replace vals by constants...")
for c in NAM_CONST:
    text = re.sub(rf"<name:{c[0]}>", f"<name:{c[1]}><bip:{c[3]}>", text)
for c in BKG_CONST:
    text = re.sub(rf"<background:{c[0]}>", f"<background:{c[1]}>", text)
for c in CHR_CONST:
    text = re.sub(rf"<character:{c[0]}>", f"<character:{c[1]}>", text)
for c in MUS_CONST:
    text = re.sub(rf"<music:{c[0]}>", f"<music:{c[1]}>", text)
for c in SFX_CONST:
    text = re.sub(rf"<sound:{c[0]}>", f"<sound:{c[1]}>", text)
for c in ANI_CONST:
    text = re.sub(rf"<animation:{c[0]}>", f"<animation:{c[1]}>", text)
for c in PHT_CONST:
    text = re.sub(rf"<photo:{c[0]}>", f"<photo:{c[1]}>", text)

print(f"add header...")
header = FILE_HEADER + DISCLAIMER
header += """
<!--
--------------------------
  CONSTANTS DECLARATIONS  
--------------------------
-->
"""
header += "\n<!-- Names constants -->\n"
for name in NAM_CONST:
    header += "<const:" + name[1] + "," + name[2] + ">\n"
header += "\n<!-- Backgrounds constants -->\n"
for b in BKG_CONST:
    header += "<const:" + b[1] + "," + b[2] + ">\n"
header += "\n<!-- Characters constants -->\n"
for b in CHR_CONST:
    header += "<const:" + b[1] + "," + b[2] + ">\n"
header += "\n<!-- Animations constants -->\n"
for b in ANI_CONST:
    header += "<const:" + b[1] + "," + b[2] + ">\n"
header += "\n<!-- Musics constants -->\n"
for b in MUS_CONST:
    header += "<const:" + b[1] + "," + b[2] + ">\n"
header += "\n<!-- SFX constants -->\n"
for b in SFX_CONST:
    header += "<const:" + b[1] + "," + b[2] + ">\n"
header += "\n<!-- Bip constants -->\n"
for b in BIP_CONST:
    header += "<const:" + b[0] + "," + b[1] + ">\n"
header += "\n<!-- Photo constants -->\n"
for b in PHT_CONST:
    header += "<const:" + b[1] + "," + b[2] + ">\n"
header += CUSTOM_CONST

print(f"add footer...")
footer = """

<label:label_unknow><jump:label_unknow>
"""

text = header + text + footer

# outputting results
print(f"writing file...")
with open(outfile, "w") as f:
    f.write(text)

print(f"done.")
